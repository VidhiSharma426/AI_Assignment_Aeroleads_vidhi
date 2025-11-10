class TwilioSimulatorService
  attr_reader :account_sid, :auth_token, :from_number
  
  def initialize
    @account_sid = SystemSetting['twilio_account_sid'] || 'demo_account_sid'
    @auth_token = SystemSetting['twilio_auth_token'] || 'demo_auth_token'
    @from_number = SystemSetting['default_from_number'] || '+918001234567'
  end
  
  def create_call(to_number, options = {})
    # Simulate Twilio API call creation
    call_response = {
      sid: generate_call_sid,
      account_sid: @account_sid,
      to: format_phone_number(to_number),
      from: @from_number,
      status: 'queued',
      direction: 'outbound-api',
      date_created: Time.current.utc.iso8601,
      price: nil,
      price_unit: 'USD',
      duration: nil,
      start_time: nil,
      end_time: nil,
      parent_call_sid: nil,
      uri: "/2010-04-01/Accounts/#{@account_sid}/Calls/#{generate_call_sid}.json"
    }
    
    Rails.logger.info "Simulated Twilio call created: #{call_response[:sid]} to #{to_number}"
    
    # Return a mock Twilio call object
    MockTwilioCall.new(call_response)
  end
  
  def get_call(call_sid)
    # Simulate fetching call details from Twilio
    call_log = CallLog.find_by(call_sid: call_sid)
    
    return nil unless call_log
    
    call_response = {
      sid: call_log.call_sid,
      account_sid: @account_sid,
      to: call_log.to_number,
      from: call_log.from_number,
      status: map_status_to_twilio(call_log.status),
      direction: call_log.direction,
      date_created: call_log.created_at.utc.iso8601,
      date_updated: call_log.updated_at.utc.iso8601,
      start_time: call_log.started_at&.utc&.iso8601,
      end_time: call_log.ended_at&.utc&.iso8601,
      duration: call_log.duration_seconds.to_s,
      price: call_log.cost.to_s,
      price_unit: 'USD',
      answered_by: call_log.successful? ? 'human' : nil,
      parent_call_sid: nil
    }
    
    MockTwilioCall.new(call_response)
  end
  
  def list_calls(options = {})
    # Simulate listing calls from Twilio
    calls = CallLog.order(created_at: :desc).limit(options[:limit] || 20)
    
    calls.map do |call_log|
      get_call(call_log.call_sid)
    end
  end
  
  def update_call(call_sid, options = {})
    # Simulate updating a call (e.g., hanging up)
    call_log = CallLog.find_by(call_sid: call_sid)
    
    return nil unless call_log
    
    if options[:status] == 'completed'
      call_log.complete_call!
    elsif options[:status] == 'cancelled'
      call_log.update!(status: 'cancelled', ended_at: Time.current)
    end
    
    get_call(call_sid)
  end
  
  def generate_twiml_response(message)
    # Generate TwiML for voice response
    <<~TWIML
      <?xml version="1.0" encoding="UTF-8"?>
      <Response>
        <Say voice="alice" language="en-IN">#{message}</Say>
        <Pause length="1"/>
        <Say voice="alice" language="en-IN">This is a demonstration call from the Autodialer system. No real connection has been made.</Say>
        <Hangup/>
      </Response>
    TWIML
  end
  
  def estimate_call_cost(duration_seconds)
    # Simulate Twilio pricing: $0.02 per minute for India
    rate_per_minute = 0.02
    minutes = duration_seconds / 60.0
    (minutes * rate_per_minute).round(4)
  end
  
  private
  
  def generate_call_sid
    "CA#{SecureRandom.hex(16)}"
  end
  
  def format_phone_number(number)
    # Format phone number for Twilio
    cleaned = number.to_s.gsub(/[^\d]/, '')
    
    if cleaned.match?(/^[6-9]\d{9}$/)
      "+91#{cleaned}"
    elsif cleaned.match?(/^1800\d{6,7}$/)
      "+91#{cleaned}"
    else
      "+91#{cleaned}"
    end
  end
  
  def map_status_to_twilio(status)
    # Map our internal statuses to Twilio statuses
    case status
    when 'queued' then 'queued'
    when 'ringing' then 'ringing'
    when 'in-progress' then 'in-progress'
    when 'completed' then 'completed'
    when 'busy' then 'busy'
    when 'failed' then 'failed'
    when 'no-answer' then 'no-answer'
    when 'cancelled' then 'canceled'
    else status
    end
  end
end

# Mock Twilio Call object for API compatibility
class MockTwilioCall
  attr_reader :attributes
  
  def initialize(attributes)
    @attributes = attributes.with_indifferent_access
  end
  
  def method_missing(method_name, *args, &block)
    if @attributes.key?(method_name.to_s)
      @attributes[method_name.to_s]
    else
      super
    end
  end
  
  def respond_to_missing?(method_name, include_private = false)
    @attributes.key?(method_name.to_s) || super
  end
  
  def to_hash
    @attributes
  end
  
  def to_json(*args)
    @attributes.to_json(*args)
  end
end