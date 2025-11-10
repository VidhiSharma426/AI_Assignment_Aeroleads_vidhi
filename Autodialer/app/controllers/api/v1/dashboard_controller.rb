class Api::V1::DashboardController < Api::V1::BaseController
  before_action :ensure_simulation_mode
  
  def stats
    render_success({
      overview: overview_stats,
      phone_numbers: phone_number_stats,
      calls: call_stats,
      recent_activity: recent_activity_stats,
      system_status: system_status
    })
  end
  
  private
  
  def overview_stats
    total_calls = CallLog.count
    success_rate = total_calls > 0 ? (CallLog.completed.count.to_f / total_calls * 100).round(1) : 0
    
    {
      total_phone_numbers: PhoneNumber.count,
      pending_numbers: PhoneNumber.pending.count,
      total_calls: total_calls,
      successful_calls: CallLog.completed.count,
      failed_calls: CallLog.failed.count,
      active_calls: CallLog.in_progress.count,
      success_rate: success_rate,
      total_cost: CallLog.sum(:cost).round(4),
      total_duration: CallLog.sum(:duration_seconds)
    }
  end
  
  def phone_number_stats
    {
      by_status: PhoneNumber.group(:status).count,
      by_source: PhoneNumber.group(:source).count,
      recent_uploads: PhoneNumber.where('created_at > ?', 24.hours.ago).count
    }
  end
  
  def call_stats
    {
      by_status: CallLog.group(:status).count,
      today: CallLog.today.count,
      this_week: CallLog.where('created_at > ?', 1.week.ago).count,
      average_duration: CallLog.where.not(duration_seconds: 0).average(:duration_seconds)&.round(2) || 0,
      cost_today: CallLog.today.sum(:cost).round(4)
    }
  end
  
  def recent_activity_stats
    {
      recent_calls: CallLog.recent.limit(5).as_json(
        include: { phone_number: { only: [:formatted_number] } },
        only: [:id, :status, :duration_seconds, :created_at]
      ),
      recent_numbers: PhoneNumber.recent.limit(5).as_json(
        only: [:id, :formatted_number, :status, :created_at]
      ),
      hourly_calls_today: hourly_calls_today
    }
  end
  
  def system_status
    {
      simulation_mode: SystemSetting['simulation_mode'],
      max_phone_numbers: SystemSetting['max_phone_numbers'],
      call_delay_seconds: SystemSetting['call_delay_seconds'],
      ai_voice_enabled: SystemSetting['ai_voice_enabled'],
      uptime: uptime_info,
      version: "1.0.0"
    }
  end
  
  def hourly_calls_today
    (0..23).map do |hour|
      count = CallLog.today.where('extract(hour from created_at) = ?', hour).count
      { hour: hour, calls: count }
    end
  end
  
  def uptime_info
    # Simple uptime calculation based on when the first record was created
    first_record = [PhoneNumber.first&.created_at, CallLog.first&.created_at].compact.min
    
    if first_record
      {
        started_at: first_record,
        uptime_seconds: (Time.current - first_record).to_i
      }
    else
      {
        started_at: Time.current,
        uptime_seconds: 0
      }
    end
  end
end