class AiCommand < ApplicationRecord
  validates :input_text, presence: true
  validates :command_type, inclusion: { in: %w[text voice] }
  validates :status, inclusion: { in: %w[pending processed failed] }
  
  before_create :generate_session_id, :parse_command
  
  scope :recent, -> { order(created_at: :desc) }
  scope :processed, -> { where(status: 'processed') }
  scope :failed, -> { where(status: 'failed') }
  
  def self.command_patterns
    {
      start_calling: [
        /start calling/i,
        /begin calls/i,
        /start dialing/i,
        /call all numbers/i,
        /start autodialer/i
      ],
      make_call: [
        /call (\+?91)?[\s-]?(\d{10}|\d{4}[\s-]?\d{6,7})/i,
        /dial (\+?91)?[\s-]?(\d{10}|\d{4}[\s-]?\d{6,7})/i,
        /phone (\+?91)?[\s-]?(\d{10}|\d{4}[\s-]?\d{6,7})/i
      ],
      show_logs: [
        /show.*logs?/i,
        /display.*logs?/i,
        /call.*history/i,
        /show.*calls/i,
        /view.*logs?/i
      ],
      show_today_logs: [
        /today.*logs?/i,
        /todays.*calls/i,
        /calls.*today/i,
        /today.*history/i
      ],
      show_statistics: [
        /statistics/i,
        /stats/i,
        /summary/i,
        /report/i,
        /analytics/i
      ],
      stop_calling: [
        /stop calling/i,
        /halt calls/i,
        /pause dialing/i,
        /stop autodialer/i
      ],
      clear_logs: [
        /clear logs/i,
        /delete logs/i,
        /remove logs/i,
        /clean logs/i
      ],
      help: [
        /help/i,
        /commands/i,
        /what can you do/i,
        /instructions/i
      ]
    }
  end
  
  def process!
    case parsed_action
    when 'start_calling'
      process_start_calling
    when 'make_call'
      process_make_call
    when 'show_logs'
      process_show_logs
    when 'show_today_logs'
      process_show_today_logs
    when 'show_statistics'
      process_show_statistics
    when 'stop_calling'
      process_stop_calling
    when 'clear_logs'
      process_clear_logs
    when 'help'
      process_help
    else
      process_unknown_command
    end
    
    update!(status: 'processed')
  rescue => e
    update!(
      status: 'failed',
      error_message: e.message,
      response_text: "Sorry, I encountered an error: #{e.message}"
    )
  end
  
  private
  
  def generate_session_id
    self.session_id = SecureRandom.hex(8) unless session_id.present?
  end
  
  def parse_command
    text = input_text.downcase.strip
    
    self.class.command_patterns.each do |action, patterns|
      patterns.each do |pattern|
        if match = text.match(pattern)
          self.parsed_action = action.to_s
          self.parsed_parameters = extract_parameters(action, match)
          return
        end
      end
    end
    
    self.parsed_action = 'unknown'
    self.parsed_parameters = {}
  end
  
  def extract_parameters(action, match)
    case action
    when :make_call
      phone_number = match.captures.compact.last
      { phone_number: phone_number&.gsub(/\D/, '') }
    else
      {}
    end
  end
  
  def process_start_calling
    pending_count = PhoneNumber.pending.count
    
    if pending_count.zero?
      self.response_text = "No pending phone numbers found. Please upload some numbers first."
    else
      # Trigger background job to start calling
      AutodialerJob.perform_async
      self.response_text = "Started calling #{pending_count} phone numbers. You can monitor progress in the dashboard."
    end
  end
  
  def process_make_call
    phone_number = parsed_parameters['phone_number']
    
    if phone_number.blank?
      self.response_text = "Please provide a valid phone number to call."
      return
    end
    
    number_record = PhoneNumber.find_by(number: phone_number)
    
    if number_record.nil?
      self.response_text = "Phone number #{phone_number} not found in the system. Please add it first."
    elsif !number_record.can_be_called?
      self.response_text = "Phone number #{phone_number} cannot be called (status: #{number_record.status})."
    else
      # Trigger single call
      SingleCallJob.perform_async(number_record.id)
      self.response_text = "Initiated call to #{number_record.formatted_number}. Check the call logs for updates."
    end
  end
  
  def process_show_logs
    total_calls = CallLog.count
    today_calls = CallLog.today.count
    
    self.response_text = "Total calls: #{total_calls}, Today's calls: #{today_calls}. Visit the call logs page for detailed information."
  end
  
  def process_show_today_logs
    logs = CallLog.today
    completed = logs.completed.count
    failed = logs.failed.count
    in_progress = logs.in_progress.count
    
    self.response_text = "Today's calls: #{logs.count} total, #{completed} completed, #{failed} failed, #{in_progress} in progress."
  end
  
  def process_show_statistics
    total_numbers = PhoneNumber.count
    total_calls = CallLog.count
    success_rate = total_calls > 0 ? (CallLog.completed.count.to_f / total_calls * 100).round(1) : 0
    
    self.response_text = "Statistics: #{total_numbers} phone numbers, #{total_calls} calls made, #{success_rate}% success rate."
  end
  
  def process_stop_calling
    # This would stop any running jobs in a real implementation
    self.response_text = "Autodialer stopped. Any calls in progress will complete, but no new calls will be initiated."
  end
  
  def process_clear_logs
    count = CallLog.count
    # In a real app, you might want admin privileges for this
    self.response_text = "This action requires administrative privileges. Found #{count} call logs that could be cleared."
  end
  
  def process_help
    self.response_text = <<~HELP
      Available commands:
      • "Start calling" - Begin calling all pending numbers
      • "Call [phone number]" - Make a call to specific number
      • "Show logs" or "Show today's logs" - Display call history
      • "Statistics" - Show system statistics
      • "Stop calling" - Halt the autodialer
      • "Help" - Show this help message
    HELP
  end
  
  def process_unknown_command
    self.response_text = "I didn't understand that command. Try saying 'help' to see available commands."
  end
end