class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  before_action :set_simulation_mode
  
  def health
    render json: { 
      status: 'ok', 
      timestamp: Time.current,
      simulation_mode: @simulation_mode 
    }
  end
  
  private
  
  def set_simulation_mode
    @simulation_mode = SystemSetting['simulation_mode'] || true
  end
  
  def ensure_simulation_mode
    unless @simulation_mode
      flash[:error] = "This action is only available in simulation mode for safety."
      redirect_to root_path
    end
  end
end