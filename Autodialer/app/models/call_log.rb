require 'securerandom'

class CallLog < ApplicationRecord
  belongs_to :phone_number
  
  validates :call_sid, presence: true, uniqueness: true
  validates :status, inclusion: { 
    in: %w[queued ringing in-progress completed busy failed no-answer cancelled]
  }
  validates :to_number, presence: true
  
  before_create :generate_call_sid, :set_default_values
  after_update :update_phone_number_status
  
  scope :today, -> { where(created_at: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: ['failed', 'busy', 'no-answer']) }
  scope :in_progress, -> { where(status: ['queued', 'ringing', 'in-progress']) }
  scope :recent, -> { order(created_at: :desc) }
  
  def self.statuses
    %w[queued ringing in-progress completed busy failed no-answer cancelled]
  end
  
  def self.success_statuses
    %w[completed]
  end
  
  def self.failure_statuses
    %w[failed busy no-answer cancelled]
  end
  
  def self.active_statuses
    %w[queued ringing in-progress]
  end
  
  def successful?
    status == 'completed'
  end
  
  def failed?
    self.class.failure_statuses.include?(status)
  end
  
  def active?
    self.class.active_statuses.include?(status)
  end
  
  def duration_formatted
    return "0s" if duration_seconds.zero?
    
    hours = duration_seconds / 3600
    minutes = (duration_seconds % 3600) / 60
    seconds = duration_seconds % 60
    
    if hours > 0
      "#{hours}h #{minutes}m #{seconds}s"
    elsif minutes > 0
      "#{minutes}m #{seconds}s"
    else
      "#{seconds}s"
    end
  end
  
  def cost_formatted
    "$#{cost.round(4)}"
  end
  
  def start_call!
    update!(
      status: 'ringing',
      started_at: Time.current
    )
  end
  
  def answer_call!
    update!(
      status: 'in-progress',
      answered_at: Time.current
    )
  end
  
  def complete_call!(duration = nil)
    now = Time.current
    duration ||= calculate_duration(now)
    
    update!(
      status: 'completed',
      ended_at: now,
      duration_seconds: duration,
      cost: calculate_cost(duration)
    )
  end
  
  def fail_call!(error_msg = nil)
    update!(
      status: 'failed',
      ended_at: Time.current,
      error_message: error_msg
    )
  end
  
  private
  
  def generate_call_sid
    # Generate a Twilio-like Call SID
    self.call_sid = "CA#{SecureRandom.hex(16)}"
  end
  
  def set_default_values
    self.simulation = true
    self.from_number ||= Rails.application.credentials.dig(:autodialer, :from_number) || "+918001234567"
    self.to_number ||= phone_number.number
    self.started_at ||= Time.current
  end
  
  def update_phone_number_status
    case status
    when 'completed'
      phone_number.mark_as_completed!
    when *self.class.failure_statuses
      phone_number.mark_as_failed!
    end
  end
  
  def calculate_duration(end_time)
    return 0 unless answered_at
    (end_time - answered_at).to_i
  end
  
  def calculate_cost(duration)
    # Simulated cost calculation: $0.02 per minute
    rate_per_minute = 0.02
    minutes = duration / 60.0
    (minutes * rate_per_minute).round(4)
  end
end