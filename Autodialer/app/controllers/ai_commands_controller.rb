class AiCommandsController < ApplicationController
  before_action :ensure_simulation_mode
  
  def create
    @ai_command = AiCommand.new(ai_command_params)
    
    if @ai_command.save
      @ai_command.process!
      
      respond_to do |format|
        format.json { 
          render json: { 
            success: true, 
            response: @ai_command.response_text,
            command: @ai_command.as_json(except: [:input_text])
          } 
        }
        format.html { 
          flash[:success] = @ai_command.response_text
          redirect_to dashboard_path 
        }
      end
    else
      respond_to do |format|
        format.json { 
          render json: { 
            success: false, 
            errors: @ai_command.errors.full_messages 
          }, status: :unprocessable_entity 
        }
        format.html { 
          flash[:error] = @ai_command.errors.full_messages.join(', ')
          redirect_to dashboard_path 
        }
      end
    end
  end
  
  def process_text_command
    command = AiCommand.create!(
      input_text: params[:command],
      command_type: 'text',
      session_id: session_id
    )
    
    command.process!
    
    render json: {
      success: command.status == 'processed',
      response: command.response_text,
      action: command.parsed_action,
      parameters: command.parsed_parameters
    }
  end
  
  def process_voice_command
    # In a real implementation, this would process audio input
    # For now, we'll simulate voice-to-text conversion
    
    if params[:audio_text].present?
      command = AiCommand.create!(
        input_text: params[:audio_text],
        command_type: 'voice',
        session_id: session_id
      )
      
      command.process!
      
      render json: {
        success: command.status == 'processed',
        response: command.response_text,
        action: command.parsed_action,
        parameters: command.parsed_parameters,
        voice_response: generate_voice_response(command.response_text)
      }
    else
      render json: {
        success: false,
        error: "No audio input received"
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  def ai_command_params
    params.require(:ai_command).permit(:input_text, :command_type).merge(session_id: session_id)
  end
  
  def session_id
    session[:ai_session_id] ||= SecureRandom.hex(8)
  end
  
  def generate_voice_response(text)
    # In a real implementation, this would use a TTS service
    # For demo purposes, we'll return a mock response
    {
      text: text,
      audio_url: "/api/v1/tts/#{SecureRandom.hex(8)}.mp3",
      duration: estimate_speech_duration(text),
      voice: "en-IN-Neural2-A"
    }
  end
  
  def estimate_speech_duration(text)
    # Estimate speech duration: average 150 words per minute
    word_count = text.split.size
    duration_seconds = (word_count / 150.0 * 60).round(1)
    [duration_seconds, 1.0].max # Minimum 1 second
  end
end