class Api::V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_default_response_format
  
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from StandardError, with: :internal_server_error
  
  private
  
  def set_default_response_format
    request.format = :json
  end
  
  def record_not_found(exception)
    render json: {
      error: 'Record not found',
      message: exception.message
    }, status: :not_found
  end
  
  def record_invalid(exception)
    render json: {
      error: 'Validation failed',
      message: exception.message,
      details: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end
  
  def internal_server_error(exception)
    Rails.logger.error "API Error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    render json: {
      error: 'Internal server error',
      message: Rails.env.development? ? exception.message : 'Something went wrong'
    }, status: :internal_server_error
  end
  
  def render_success(data = {}, message = nil)
    response = { success: true }
    response[:message] = message if message
    response[:data] = data unless data.empty?
    
    render json: response
  end
  
  def render_error(message, status = :unprocessable_entity, details = nil)
    response = {
      success: false,
      error: message
    }
    response[:details] = details if details
    
    render json: response, status: status
  end
end