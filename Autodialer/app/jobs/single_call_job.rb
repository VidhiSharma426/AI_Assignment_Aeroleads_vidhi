class SingleCallJob < ApplicationJob
  queue_as :default
  
  def perform(phone_number_id)
    phone_number = PhoneNumber.find(phone_number_id)
    
    Rails.logger.info "Making single call to #{phone_number.formatted_number}"
    
    unless phone_number.can_be_called?
      Rails.logger.warn "Phone number #{phone_number.number} cannot be called (status: #{phone_number.status})"
      return
    end
    
    make_simulated_call(phone_number)
  end
  
  private
  
  def make_simulated_call(phone_number)
    # Mark phone number as calling
    phone_number.mark_as_calling!
    
    # Find or create call log
    call_log = phone_number.call_logs.where(status: 'queued').first
    
    unless call_log
      call_log = phone_number.call_logs.create!(
        status: 'queued',
        to_number: phone_number.number,
        from_number: SystemSetting['default_from_number'] || '+918001234567',
        simulation: true,
        metadata: {
          initiated_by: 'manual',
          single_call: true
        }
      )
    end
    
    # Simulate call progression
    simulate_call_progression(call_log)
  end
  
  def simulate_call_progression(call_log)
    Rails.logger.info "Simulating call progression for call #{call_log.call_sid}"
    
    # Step 1: Queued -> Ringing
    sleep(0.5)
    call_log.start_call!
    
    # Step 2: Simulate network delay
    sleep(rand(1.0..2.0))
    
    # Step 3: Determine call outcome
    outcome = simulate_call_outcome
    
    case outcome
    when 'answered'
      # Call answered
      call_log.answer_call!
      
      # Simulate conversation duration
      duration = rand(10..60) # 10-60 seconds
      sleep(0.2) # Brief pause for simulation
      
      call_log.complete_call!(duration)
      
      Rails.logger.info "Call #{call_log.call_sid} completed successfully (#{duration}s)"
      
    when 'busy'
      call_log.update!(
        status: 'busy',
        ended_at: Time.current,
        error_message: 'Subscriber busy'
      )
      call_log.phone_number.mark_as_failed!
      
      Rails.logger.info "Call #{call_log.call_sid} resulted in busy signal"
      
    when 'no_answer'
      # Simulate ringing timeout
      sleep(1.0)
      call_log.update!(
        status: 'no-answer',
        ended_at: Time.current,
        error_message: 'No answer within timeout period'
      )
      call_log.phone_number.mark_as_failed!
      
      Rails.logger.info "Call #{call_log.call_sid} timed out with no answer"
      
    when 'failed'
      error_messages = [
        'Network unreachable',
        'Invalid number format',
        'Service temporarily unavailable',
        'Call blocked by carrier',
        'Insufficient balance'
      ]
      
      call_log.fail_call!(error_messages.sample)
      
      Rails.logger.info "Call #{call_log.call_sid} failed: #{call_log.error_message}"
      
    when 'cancelled'
      call_log.update!(
        status: 'cancelled',
        ended_at: Time.current,
        error_message: 'Call cancelled by system'
      )
      call_log.phone_number.mark_as_failed!
      
      Rails.logger.info "Call #{call_log.call_sid} was cancelled"
    end
  end
  
  def simulate_call_outcome
    # More realistic distribution for single calls
    rand_num = rand(100)
    
    case rand_num
    when 0..65    # 65% success rate (slightly higher for manual calls)
      'answered'
    when 66..78   # 12% busy
      'busy'
    when 79..90   # 12% no answer
      'no_answer'
    when 91..97   # 7% failed
      'failed'
    else          # 3% cancelled
      'cancelled'
    end
  end
end