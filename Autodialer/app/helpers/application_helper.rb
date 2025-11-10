module ApplicationHelper
  def call_status_color(status)
    case status&.to_s&.downcase
    when 'completed'
      'success'
    when 'queued', 'ringing', 'in-progress'
      'primary'
    when 'failed', 'cancelled'
      'danger'
    when 'busy', 'no-answer'
      'warning'
    else
      'secondary'
    end
  end

  def phone_status_color(status)
    case status&.to_s&.downcase
    when 'completed'
      'success'
    when 'pending'
      'info'
    when 'calling', 'queued'
      'primary'
    when 'failed'
      'danger'
    else
      'secondary'
    end
  end

  def format_duration(seconds)
    return "0s" if seconds.nil? || seconds.zero?
    
    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    remaining_seconds = seconds % 60
    
    if hours > 0
      "#{hours}h #{minutes}m #{remaining_seconds}s"
    elsif minutes > 0
      "#{minutes}m #{remaining_seconds}s"
    else
      "#{remaining_seconds}s"
    end
  end

  def format_cost(cost)
    "$#{cost.round(4)}" if cost
  end
end