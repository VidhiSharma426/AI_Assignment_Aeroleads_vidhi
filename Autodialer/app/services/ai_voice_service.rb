class AiVoiceService
  VOICE_MODELS = {
    'en-IN-Neural2-A' => { gender: 'female', language: 'en-IN', name: 'Aditi' },
    'en-IN-Neural2-B' => { gender: 'male', language: 'en-IN', name: 'Ravi' },
    'en-US-Neural2-C' => { gender: 'female', language: 'en-US', name: 'Sarah' },
    'en-US-Neural2-D' => { gender: 'male', language: 'en-US', name: 'John' }
  }.freeze
  
  def initialize
    @enabled = SystemSetting['ai_voice_enabled'] || true
    @default_voice = 'en-IN-Neural2-A'
  end
  
  def text_to_speech(text, options = {})
    return mock_tts_response(text, options) unless @enabled
    
    voice = options[:voice] || @default_voice
    speed = options[:speed] || 1.0
    
    # In a real implementation, this would call Google Cloud TTS, Amazon Polly, etc.
    # For demo purposes, we'll return a mock response
    
    Rails.logger.info "Generating TTS for: #{text.truncate(50)} with voice: #{voice}"
    
    {
      success: true,
      audio_url: generate_mock_audio_url(text),
      duration_seconds: estimate_speech_duration(text, speed),
      voice_used: voice,
      voice_info: VOICE_MODELS[voice],
      text: text,
      character_count: text.length,
      cost: estimate_tts_cost(text),
      metadata: {
        service: 'mock_tts',
        timestamp: Time.current.iso8601,
        speed: speed,
        language: VOICE_MODELS.dig(voice, :language) || 'en-IN'
      }
    }
  end
  
  def speech_to_text(audio_data, options = {})
    return mock_stt_response unless @enabled
    
    # In a real implementation, this would call Google Speech-to-Text, etc.
    # For demo purposes, we'll return a mock response
    
    Rails.logger.info "Processing STT for audio data (#{audio_data&.size || 0} bytes)"
    
    {
      success: true,
      transcription: generate_mock_transcription,
      confidence: rand(0.85..0.98).round(3),
      language: options[:language] || 'en-IN',
      duration_seconds: options[:duration] || rand(2..10),
      word_count: generate_mock_transcription.split.size,
      cost: estimate_stt_cost(options[:duration] || 5),
      metadata: {
        service: 'mock_stt',
        timestamp: Time.current.iso8601,
        audio_format: options[:format] || 'wav',
        sample_rate: options[:sample_rate] || 16000
      }
    }
  end
  
  def available_voices
    VOICE_MODELS.map do |voice_id, info|
      {
        id: voice_id,
        name: info[:name],
        gender: info[:gender],
        language: info[:language],
        language_name: language_name(info[:language])
      }
    end
  end
  
  def generate_call_script(phone_number, purpose = 'general')
    # Generate dynamic call scripts based on purpose
    scripts = {
      'general' => "Hello, this is a demonstration call from the Autodialer system to #{format_phone_number(phone_number)}. This is only a simulation and no real connection has been made. Thank you for your attention.",
      'survey' => "Hello, we are conducting a brief survey. This is a simulated call from our autodialer system. In a real scenario, we would collect your responses. This is only a demonstration.",
      'reminder' => "This is a reminder call regarding your appointment. This is a demonstration from our automated system calling #{format_phone_number(phone_number)}. No real appointment exists.",
      'notification' => "This is an important notification call. This message is being delivered through our autodialer system as a demonstration. No real notification is being sent."
    }
    
    script = scripts[purpose] || scripts['general']
    
    {
      script: script,
      estimated_duration: estimate_speech_duration(script),
      word_count: script.split.size,
      twiml: generate_twiml(script),
      voice_recommendation: @default_voice
    }
  end
  
  private
  
  def mock_tts_response(text, options)
    {
      success: true,
      audio_url: '/demo/audio/tts_simulation.mp3',
      duration_seconds: estimate_speech_duration(text),
      voice_used: @default_voice,
      text: text,
      cost: 0.0,
      metadata: { service: 'simulation', note: 'TTS disabled in settings' }
    }
  end
  
  def mock_stt_response
    {
      success: false,
      error: 'Speech-to-text is disabled in simulation mode',
      metadata: { service: 'simulation' }
    }
  end
  
  def generate_mock_audio_url(text)
    # Generate a deterministic but unique URL for demo purposes
    hash = Digest::MD5.hexdigest(text)[0..8]
    "/api/v1/audio/tts/#{hash}.mp3"
  end
  
  def generate_mock_transcription
    sample_commands = [
      "Start calling all numbers",
      "Call 9876543210",
      "Show me today's call logs",
      "What is the current status",
      "Stop the autodialer",
      "Help me with commands"
    ]
    
    sample_commands.sample
  end
  
  def estimate_speech_duration(text, speed = 1.0)
    # Average speaking rate: 150 words per minute
    words = text.split.size
    base_duration = (words / 150.0 * 60).round(1)
    (base_duration / speed).round(1)
  end
  
  def estimate_tts_cost(text)
    # Mock pricing: $0.000004 per character (similar to Google Cloud TTS)
    character_count = text.length
    (character_count * 0.000004).round(6)
  end
  
  def estimate_stt_cost(duration_seconds)
    # Mock pricing: $0.006 per 15-second increment
    increments = (duration_seconds / 15.0).ceil
    (increments * 0.006).round(4)
  end
  
  def format_phone_number(number)
    PhoneNumber.format_indian_number(number)
  end
  
  def language_name(code)
    language_names = {
      'en-IN' => 'English (India)',
      'en-US' => 'English (US)',
      'hi-IN' => 'Hindi (India)',
      'ta-IN' => 'Tamil (India)'
    }
    
    language_names[code] || code
  end
  
  def generate_twiml(script)
    <<~TWIML
      <?xml version="1.0" encoding="UTF-8"?>
      <Response>
        <Say voice="#{@default_voice.downcase}" language="en-IN">#{script}</Say>
        <Pause length="2"/>
        <Say voice="#{@default_voice.downcase}" language="en-IN">Press any key to end this demonstration call.</Say>
        <Gather numDigits="1" timeout="5">
          <Say voice="#{@default_voice.downcase}" language="en-IN">Waiting for input...</Say>
        </Gather>
        <Say voice="#{@default_voice.downcase}" language="en-IN">Thank you. This demonstration call is now ending.</Say>
        <Hangup/>
      </Response>
    TWIML
  end
end