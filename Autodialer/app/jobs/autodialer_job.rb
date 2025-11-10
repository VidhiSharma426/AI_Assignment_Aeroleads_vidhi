class AutodialerJob < ApplicationJob
  queue_as :default
  
  def perform
    Rails.logger.info "Starting autodialer for all pending numbers"
    
    pending_numbers = PhoneNumber.pending.order(:created_at)
    call_delay = SystemSetting['call_delay_seconds'] || 2
    
    Rails.logger.info "Found #{pending_numbers.count} pending numbers"
    
    pending_numbers.find_each do |phone_number|
      begin
        # Check if we should continue (could add a stop mechanism here)
        break unless should_continue_calling?
        
        # Make the simulated call
        make_simulated_call(phone_number)
        
        # Wait between calls
        sleep(call_delay) if call_delay > 0
        
      rescue => e
        Rails.logger.error "Error calling #{phone_number.number}: #{e.message}"
        phone_number.mark_as_failed!
      end
    end
    
    Rails.logger.info "Autodialer completed"
  end
  
  private
  
  def should_continue_calling?
    # In a real implementation, this could check for stop signals
    # For now, we'll always continue unless the system is not in simulation mode
    SystemSetting['simulation_mode'] == true
  end
  
  def make_simulated_call(phone_number)
    Rails.logger.info "Making simulated call to #{phone_number.formatted_number}"
    
    # Mark phone number as calling
    phone_number.mark_as_calling!
    
    # Create call log
    call_log = phone_number.call_logs.create!(
      status: 'queued',
      to_number: phone_number.number,
      from_number: SystemSetting['default_from_number'] || '+918001234567',
      simulation: true,
      metadata: {
        initiated_by: 'autodialer',
        batch_job: true
      }
    )
    
    # Simulate call progression
    simulate_call_progression(call_log)
  end
  
  def simulate_call_progression(call_log)
    # Simulate call states with random outcomes
    
    # Step 1: Queued -> Ringing
    sleep(0.5)
    call_log.update!(status: 'ringing', started_at: Time.current)
    
    # Step 2: Determine call outcome
    outcome = simulate_call_outcome
    
    case outcome
    when 'answered'
      # Call answered
      sleep(1)
      call_log.update!(status: 'in-progress', answered_at: Time.current)
      
      # Simulate call duration (5-30 seconds)
      duration = rand(5..30)
      sleep(0.1) # Just a brief pause for simulation
      
      call_log.complete_call!(duration)
      call_log.phone_number.mark_as_completed!
      
    when 'busy'
      sleep(0.5)
      call_log.update!(
        status: 'busy',
        ended_at: Time.current,
        error_message: 'Line busy'
      )
      call_log.phone_number.mark_as_failed!
      
    when 'no_answer'
      # Let it ring for a while then timeout
      sleep(1)
      call_log.update!(
        status: 'no-answer',
        ended_at: Time.current,
        error_message: 'No answer after 30 seconds'
      )
      call_log.phone_number.mark_as_failed!
      
    when 'failed'
      sleep(0.3)
      call_log.fail_call!('Network error or invalid number')
      call_log.phone_number.mark_as_failed!
    end
    
    Rails.logger.info "Call to #{call_log.to_number} completed with status: #{call_log.status}"
  end
  
  def simulate_call_outcome
    # Simulate realistic call outcomes with weighted probabilities
    rand_num = rand(100)
    
    case rand_num
    when 0..60    # 60% success rate
      'answered'
    when 61..75   # 15% busy
      'busy'
    when 76..90   # 15% no answer
      'no_answer'
    else          # 10% failed
      'failed'
    end
  end
end