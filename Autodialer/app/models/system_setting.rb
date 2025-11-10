class SystemSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :data_type, inclusion: { in: %w[string integer boolean json] }
  
  def self.[](key)
    setting = find_by(key: key.to_s)
    return nil unless setting
    
    case setting.data_type
    when 'integer'
      setting.value.to_i
    when 'boolean'
      setting.value.to_s.downcase == 'true'
    when 'json'
      JSON.parse(setting.value) rescue {}
    else
      setting.value
    end
  end
  
  def self.[]=(key, value)
    setting = find_or_initialize_by(key: key.to_s)
    
    case value
    when Integer
      setting.data_type = 'integer'
      setting.value = value.to_s
    when TrueClass, FalseClass
      setting.data_type = 'boolean'
      setting.value = value.to_s
    when Hash, Array
      setting.data_type = 'json'
      setting.value = value.to_json
    else
      setting.data_type = 'string'
      setting.value = value.to_s
    end
    
    setting.save!
    value
  end
  
  def self.seed_defaults
    defaults = {
      'simulation_mode' => { value: true, data_type: 'boolean', description: 'Enable simulation mode for all calls' },
      'max_phone_numbers' => { value: 100, data_type: 'integer', description: 'Maximum number of phone numbers allowed' },
      'call_delay_seconds' => { value: 2, data_type: 'integer', description: 'Delay between calls in seconds' },
      'default_from_number' => { value: '+918001234567', data_type: 'string', description: 'Default caller ID number' },
      'twilio_account_sid' => { value: 'demo_account_sid', data_type: 'string', description: 'Twilio Account SID (demo)' },
      'twilio_auth_token' => { value: 'demo_auth_token', data_type: 'string', description: 'Twilio Auth Token (demo)' },
      'ai_voice_enabled' => { value: true, data_type: 'boolean', description: 'Enable AI voice responses' },
      'call_recording_enabled' => { value: false, data_type: 'boolean', description: 'Enable call recording (simulation)' },
      'daily_call_limit' => { value: 1000, data_type: 'integer', description: 'Maximum calls per day' }
    }
    
    defaults.each do |key, config|
      next if exists?(key: key)
      
      create!(
        key: key,
        value: config[:value].to_s,
        data_type: config[:data_type],
        description: config[:description]
      )
    end
  end
  
  def typed_value
    case data_type
    when 'integer'
      value.to_i
    when 'boolean'
      value.to_s.downcase == 'true'
    when 'json'
      JSON.parse(value) rescue {}
    else
      value
    end
  end
end