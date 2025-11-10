class CallLogsController < ApplicationController
  before_action :ensure_simulation_mode
  before_action :set_call_log, only: [:show, :destroy]
  
  def index
    @call_logs = CallLog.includes(:phone_number)
                       .order(params[:sort] || 'created_at DESC')
                       .page(params[:page])
                       .per(25)
    
    # Filter by status if specified
    @call_logs = @call_logs.where(status: params[:status]) if params[:status].present?
    
    # Filter by date if specified
    if params[:date].present?
      begin
        date = Date.parse(params[:date])
        @call_logs = @call_logs.where(created_at: date.beginning_of_day..date.end_of_day)
      rescue ArgumentError
        flash.now[:warning] = "Invalid date format"
      end
    end
    
    @stats = {
      total: CallLog.count,
      completed: CallLog.completed.count,
      failed: CallLog.failed.count,
      in_progress: CallLog.in_progress.count,
      today: CallLog.today.count
    }
    
    respond_to do |format|
      format.html
      format.json { render json: @call_logs.as_json(include: :phone_number) }
    end
  end
  
  def show
    respond_to do |format|
      format.html
      format.json { render json: @call_log.as_json(include: :phone_number) }
    end
  end
  
  def today
    @call_logs = CallLog.today.includes(:phone_number).recent
    @stats = {
      total: @call_logs.count,
      completed: @call_logs.completed.count,
      failed: @call_logs.failed.count,
      in_progress: @call_logs.in_progress.count,
      total_duration: @call_logs.sum(:duration_seconds),
      total_cost: @call_logs.sum(:cost)
    }
    
    respond_to do |format|
      format.html { render :index }
      format.json { render json: { call_logs: @call_logs.as_json(include: :phone_number), stats: @stats } }
    end
  end
  
  def statistics
    @stats = {
      overview: overview_stats,
      by_status: CallLog.group(:status).count,
      by_hour: hourly_stats,
      by_day: daily_stats,
      duration_stats: duration_stats,
      cost_stats: cost_stats
    }
    
    respond_to do |format|
      format.html
      format.json { render json: @stats }
    end
  end
  
  def destroy
    @call_log.destroy
    flash[:success] = "Call log deleted successfully."
    redirect_to call_logs_path
  end
  
  def clear_all
    count = CallLog.count
    CallLog.destroy_all
    
    # Reset phone number statuses
    PhoneNumber.update_all(status: 'pending', call_attempts: 0, last_called_at: nil)
    
    flash[:success] = "Cleared #{count} call logs and reset phone number statuses."
    redirect_to call_logs_path
  end
  
  private
  
  def set_call_log
    @call_log = CallLog.find(params[:id])
  end
  
  def overview_stats
    {
      total_calls: CallLog.count,
      successful_calls: CallLog.completed.count,
      failed_calls: CallLog.failed.count,
      active_calls: CallLog.in_progress.count,
      success_rate: calculate_success_rate,
      average_duration: CallLog.where.not(duration_seconds: 0).average(:duration_seconds)&.round(2) || 0,
      total_cost: CallLog.sum(:cost).round(4),
      calls_today: CallLog.today.count,
      calls_this_week: CallLog.where('created_at > ?', 1.week.ago).count
    }
  end
  
  def hourly_stats
    # Calls by hour for today
    (0..23).map do |hour|
      calls = CallLog.today.where('extract(hour from created_at) = ?', hour)
      {
        hour: hour,
        total: calls.count,
        completed: calls.completed.count,
        failed: calls.failed.count
      }
    end
  end
  
  def daily_stats
    # Calls by day for the last 30 days
    (29.days.ago.to_date..Date.current).map do |date|
      calls = CallLog.where(created_at: date.beginning_of_day..date.end_of_day)
      {
        date: date.strftime('%Y-%m-%d'),
        total: calls.count,
        completed: calls.completed.count,
        failed: calls.failed.count,
        duration: calls.sum(:duration_seconds),
        cost: calls.sum(:cost).round(4)
      }
    end
  end
  
  def duration_stats
    durations = CallLog.where.not(duration_seconds: 0).pluck(:duration_seconds)
    return {} if durations.empty?
    
    {
      average: durations.sum.to_f / durations.size,
      median: durations.sort[durations.size / 2],
      min: durations.min,
      max: durations.max,
      total: durations.sum
    }
  end
  
  def cost_stats
    costs = CallLog.pluck(:cost)
    return {} if costs.empty?
    
    {
      total: costs.sum.round(4),
      average: (costs.sum / costs.size).round(4),
      min: costs.min.round(4),
      max: costs.max.round(4),
      today: CallLog.today.sum(:cost).round(4),
      this_week: CallLog.where('created_at > ?', 1.week.ago).sum(:cost).round(4)
    }
  end
  
  def calculate_success_rate
    total = CallLog.count
    return 0 if total.zero?
    
    (CallLog.completed.count.to_f / total * 100).round(1)
  end
end