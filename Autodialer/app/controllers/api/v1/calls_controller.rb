class Api::V1::CallsController < Api::V1::BaseController
  before_action :ensure_simulation_mode
  
  def index
    calls = CallLog.includes(:phone_number)
                  .order(created_at: :desc)
                  .limit(params[:limit]&.to_i || 50)
    
    # Apply filters
    calls = calls.where(status: params[:status]) if params[:status].present?
    calls = calls.where('created_at >= ?', Time.parse(params[:since])) if params[:since].present?
    
    render_success({
      calls: calls.as_json(
        include: {
          phone_number: { only: [:id, :number, :formatted_number, :status] }
        },
        methods: [:duration_formatted, :cost_formatted]
      ),
      total: calls.count,
      pagination: {
        limit: params[:limit]&.to_i || 50,
        offset: params[:offset]&.to_i || 0
      }
    })
  end
  
  def show
    call = CallLog.includes(:phone_number).find(params[:id])
    
    render_success({
      call: call.as_json(
        include: {
          phone_number: { only: [:id, :number, :formatted_number, :status] }
        },
        methods: [:duration_formatted, :cost_formatted]
      )
    })
  end
  
  def create
    phone_number = find_phone_number
    
    unless phone_number.can_be_called?
      render_error("Phone number cannot be called (status: #{phone_number.status})")
      return
    end
    
    call_log = phone_number.call_logs.create!(
      status: 'queued',
      to_number: phone_number.number,
      from_number: params[:from_number] || SystemSetting['default_from_number'],
      simulation: true,
      metadata: {
        initiated_by: 'api',
        api_version: 'v1'
      }
    )
    
    # Start the call in background
    SingleCallJob.perform_async(phone_number.id)
    
    render_success({
      call: call_log.as_json(methods: [:duration_formatted, :cost_formatted]),
      message: "Call initiated successfully"
    }, "Call queued for #{phone_number.formatted_number}")
  end
  
  private
  
  def find_phone_number
    if params[:phone_number_id].present?
      PhoneNumber.find(params[:phone_number_id])
    elsif params[:phone_number].present?
      number = params[:phone_number].gsub(/[^\d]/, '')
      PhoneNumber.find_by!(number: number)
    else
      raise ArgumentError, "phone_number_id or phone_number parameter required"
    end
  end
end