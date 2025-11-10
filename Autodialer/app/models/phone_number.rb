class PhoneNumber < ApplicationRecord
  has_many :call_logs, dependent: :destroy
  
  validates :number, presence: true, uniqueness: true
  validates :number, format: { 
    with: /\A(\+91|91|0)?[6-9]\d{9}\z|\A1800\d{6,7}\z/,
    message: "must be a valid Indian phone number (mobile: 10 digits starting with 6-9, toll-free: 1800XXXXXXX)"
  }
  validates :status, inclusion: { in: %w[pending queued calling completed failed] }
  validates :source, inclusion: { in: %w[manual upload paste] }
  
  before_validation :format_phone_number
  after_create :set_formatted_number
  
  scope :pending, -> { where(status: 'pending') }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }
  scope :recent, -> { order(created_at: :desc) }
  
  def self.indian_phone_number?(number)
    # Mobile numbers: 10 digits starting with 6-9
    # Toll-free: 1800 followed by 6-7 digits
    cleaned = number.to_s.gsub(/[^\d]/, '')
    
    # Remove country code if present
    cleaned = cleaned.gsub(/^(\+91|91)/, '')
    cleaned = cleaned.gsub(/^0/, '') if cleaned.length == 11
    
    # Check patterns
    mobile_pattern = /^[6-9]\d{9}$/
    tollfree_pattern = /^1800\d{6,7}$/
    
    mobile_pattern.match?(cleaned) || tollfree_pattern.match?(cleaned)
  end
  
  def self.format_indian_number(number)
    cleaned = number.to_s.gsub(/[^\d]/, '')
    
    # Remove country code if present
    cleaned = cleaned.gsub(/^(\+91|91)/, '')
    cleaned = cleaned.gsub(/^0/, '') if cleaned.length == 11
    
    if cleaned.match?(/^[6-9]\d{9}$/)
      # Mobile number formatting: +91 XXXXX XXXXX
      "+91 #{cleaned[0..4]} #{cleaned[5..9]}"
    elsif cleaned.match?(/^1800\d{6,7}$/)
      # Toll-free formatting: 1800-XXX-XXXX
      if cleaned.length == 10
        "#{cleaned[0..3]}-#{cleaned[4..6]}-#{cleaned[7..9]}"
      else
        "#{cleaned[0..3]}-#{cleaned[4..7]}"
      end
    else
      number
    end
  end
  
  def last_call
    call_logs.order(created_at: :desc).first
  end
  
  def total_calls
    call_logs.count
  end
  
  def successful_calls
    call_logs.where(status: 'completed').count
  end
  
  def can_be_called?
    %w[pending failed].include?(status)
  end
  
  def mark_as_calling!
    update!(status: 'calling', last_called_at: Time.current)
    increment!(:call_attempts)
  end
  
  def mark_as_completed!
    update!(status: 'completed')
  end
  
  def mark_as_failed!
    update!(status: 'failed')
  end
  
  private
  
  def format_phone_number
    return unless number.present?
    
    # Remove all non-digits
    cleaned = number.gsub(/[^\d]/, '')
    
    # Remove country code if present
    cleaned = cleaned.gsub(/^(\+91|91)/, '')
    cleaned = cleaned.gsub(/^0/, '') if cleaned.length == 11
    
    self.number = cleaned
  end
  
  def set_formatted_number
    self.update_column(:formatted_number, self.class.format_indian_number(number))
  end
end