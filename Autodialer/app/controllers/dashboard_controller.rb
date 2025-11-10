class DashboardController < ApplicationController
  before_action :ensure_simulation_mode
  
  def index
    @stats = calculate_statistics
    @recent_calls = CallLog.recent.includes(:phone_number).limit(10)
    @phone_numbers = PhoneNumber.recent.limit(10)
    @ai_commands = AiCommand.recent.limit(5)
    
    # Real-time data for dashboard updates
    @pending_calls = PhoneNumber.pending.count
    @active_calls = CallLog.in_progress.count
    @today_calls = CallLog.today.count
  end
  
  def statistics
    @detailed_stats = {
      phone_numbers: phone_number_stats,
      calls: call_stats,
      daily_stats: daily_call_stats,
      success_rates: success_rate_stats
    }
    
    respond_to do |format|
      format.html
      format.json { render json: @detailed_stats }
    end
  end
  
  private
  
  def calculate_statistics
    {
      total_numbers: PhoneNumber.count,
      pending_numbers: PhoneNumber.pending.count,
      completed_numbers: PhoneNumber.completed.count,
      failed_numbers: PhoneNumber.failed.count,
      total_calls: CallLog.count,
      successful_calls: CallLog.completed.count,
      failed_calls: CallLog.failed.count,
      active_calls: CallLog.in_progress.count,
      today_calls: CallLog.today.count,
      today_successful: CallLog.today.completed.count,
      today_failed: CallLog.today.failed.count,
      success_rate: success_rate,
      total_duration: CallLog.sum(:duration_seconds),
      total_cost: CallLog.sum(:cost)
    }
  end
  
  def phone_number_stats
    {
      total: PhoneNumber.count,
      by_status: PhoneNumber.group(:status).count,
      by_source: PhoneNumber.group(:source).count,
      recent_uploads: PhoneNumber.where('created_at > ?', 24.hours.ago).count
    }
  end
  
  def call_stats
    {
      total: CallLog.count,
      by_status: CallLog.group(:status).count,
      average_duration: CallLog.where.not(duration_seconds: 0).average(:duration_seconds)&.round(2) || 0,
      total_cost: CallLog.sum(:cost).round(4),
      calls_last_24h: CallLog.where('created_at > ?', 24.hours.ago).count
    }
  end
  
  def daily_call_stats
    # Last 7 days of call activity
    (6.days.ago.to_date..Date.current).map do |date|
      calls = CallLog.where(created_at: date.beginning_of_day..date.end_of_day)
      {
        date: date.strftime('%Y-%m-%d'),
        total: calls.count,
        completed: calls.completed.count,
        failed: calls.failed.count
      }
    end
  end
  
  def success_rate_stats
    total = CallLog.count
    return { overall: 0, today: 0, this_week: 0 } if total.zero?
    
    {
      overall: (CallLog.completed.count.to_f / total * 100).round(1),
      today: calculate_period_success_rate(Date.current.beginning_of_day..Date.current.end_of_day),
      this_week: calculate_period_success_rate(1.week.ago..Time.current)
    }
  end
  
  def calculate_period_success_rate(period)
    calls = CallLog.where(created_at: period)
    return 0 if calls.count.zero?
    
    (calls.completed.count.to_f / calls.count * 100).round(1)
  end
  
  def success_rate
    total = CallLog.count
    return 0 if total.zero?
    
    (CallLog.completed.count.to_f / total * 100).round(1)
  end
end