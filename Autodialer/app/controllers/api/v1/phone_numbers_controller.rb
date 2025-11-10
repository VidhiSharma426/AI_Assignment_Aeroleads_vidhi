class Api::V1::PhoneNumbersController < Api::V1::BaseController
  before_action :ensure_simulation_mode
  
  def index
    phone_numbers = PhoneNumber.includes(:call_logs)
                              .order(created_at: :desc)
                              .limit(params[:limit]&.to_i || 50)
    
    # Apply filters
    phone_numbers = phone_numbers.where(status: params[:status]) if params[:status].present?
    phone_numbers = phone_numbers.where(source: params[:source]) if params[:source].present?
    
    render_success({
      phone_numbers: phone_numbers.as_json(
        methods: [:total_calls, :successful_calls],
        include: {
          call_logs: {
            only: [:id, :status, :created_at, :duration_seconds],
            limit: 5,
            order: { created_at: :desc }
          }
        }
      ),
      total: phone_numbers.count,
      stats: {
        total: PhoneNumber.count,
        pending: PhoneNumber.pending.count,
        completed: PhoneNumber.completed.count,
        failed: PhoneNumber.failed.count
      }
    })
  end
end