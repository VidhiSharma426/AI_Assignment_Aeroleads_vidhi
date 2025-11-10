# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding Autodialer Demo Database..."

# Clear existing data in development
if Rails.env.development?
  puts "🧹 Cleaning existing data..."
  CallLog.destroy_all
  PhoneNumber.destroy_all
  AiCommand.destroy_all
  SystemSetting.destroy_all
end

# Create system settings
puts "⚙️ Creating system settings..."
SystemSetting.seed_defaults

# Create sample phone numbers
puts "📞 Creating sample phone numbers..."

sample_numbers = [
   # User's phone number
    { number: '9468448087', source: 'manual', notes: 'User phone number' },
  # Valid Indian mobile numbers (demo data) - all start with 6-9
  # { number: '9876543210', source: 'manual', notes: 'Demo contact 1' },
  # { number: '9988776655', source: 'manual', notes: 'Demo contact 2' },
  # { number: '8123456789', source: 'upload', notes: 'Bulk upload demo' },
  # { number: '7876543211', source: 'upload', notes: 'Another bulk contact' },
  # { number: '6555666777', source: 'paste', notes: 'Pasted demo number' },
  
  # Additional demo numbers
  # { number: '8111222333', source: 'manual', notes: 'Test contact A' },
  # { number: '7444555666', source: 'paste', notes: 'Test contact B' },
  # { number: '9777888999', source: 'upload', notes: 'Test contact C' },
  
 
]

created_numbers = []
sample_numbers.each do |number_data|
  phone_number = PhoneNumber.create!(number_data)
  created_numbers << phone_number
  puts "  ✅ Created: #{phone_number.formatted_number}"
end

# Create sample call logs for demonstration
puts "📋 Creating sample call logs..."

# Simulate some calls that have already been made - only for your number
sample_calls = [
  {
    phone_number: created_numbers[0],
    status: 'completed',
    duration_seconds: 45,
    started_at: 2.hours.ago,
    answered_at: 2.hours.ago + 3.seconds,
    ended_at: 2.hours.ago + 48.seconds
  },
  {
    phone_number: created_numbers[0],
    status: 'failed',
    error_message: 'Network unreachable',
    started_at: 1.hour.ago,
    ended_at: 1.hour.ago + 10.seconds
  }
]

sample_calls.each do |call_data|
  phone_number = call_data.delete(:phone_number)
  
  call_log = phone_number.call_logs.create!(
    call_data.merge(
      call_sid: "CA#{SecureRandom.hex(16)}",  # Explicitly set call_sid
      to_number: phone_number.number,
      from_number: '+918001234567',
      simulation: true,
      cost: call_data[:duration_seconds] ? (call_data[:duration_seconds] / 60.0 * 0.02).round(4) : 0,
      metadata: {
        demo_call: true,
        created_by: 'seed_data'
      }
    )
  )
  
  # Update phone number status based on call result
  case call_log.status
  when 'completed'
    phone_number.update!(status: 'completed')
  when 'failed', 'busy', 'no-answer'
    phone_number.update!(status: 'failed')
  end
  
  puts "  📞 Call log created: #{phone_number.formatted_number} - #{call_log.status}"
end

# Create sample AI commands
puts "🤖 Creating sample AI commands..."

sample_commands = [
  {
    input_text: 'show me today\'s call logs',
    command_type: 'text',
    parsed_action: 'show_today_logs',
    status: 'processed',
    response_text: 'Today\'s calls: 5 total, 2 completed, 3 failed, 0 in progress.',
    created_at: 1.hour.ago
  },
  {
    input_text: 'start calling all numbers',
    command_type: 'text',
    parsed_action: 'start_calling',
    status: 'processed',
    response_text: 'Started calling 5 phone numbers. You can monitor progress in the dashboard.',
    created_at: 2.hours.ago
  },
  {
    input_text: 'help',
    command_type: 'text',
    parsed_action: 'help',
    status: 'processed',
    response_text: 'Available commands: Start calling, Call [number], Show logs, Statistics, Help',
    created_at: 3.hours.ago
  }
]

sample_commands.each do |command_data|
  ai_command = AiCommand.create!(command_data)
  puts "  🗨️ AI command created: #{ai_command.parsed_action}"
end

# Print summary
puts "\n📊 Seed Summary:"
puts "  • #{PhoneNumber.count} phone numbers created"
puts "  • #{CallLog.count} call logs created"
puts "  • #{AiCommand.count} AI commands created"
puts "  • #{SystemSetting.count} system settings configured"

puts "\n🎯 Demo Statistics:"
puts "  • Pending numbers: #{PhoneNumber.pending.count}"
puts "  • Completed calls: #{CallLog.completed.count}"
puts "  • Failed calls: #{CallLog.failed.count}"
puts "  • Success rate: #{CallLog.count > 0 ? (CallLog.completed.count.to_f / CallLog.count * 100).round(1) : 0}%"

puts "\n🚀 Ready to start! Visit http://localhost:3000 to explore the Autodialer Demo."
puts "🛡️ Remember: This is SIMULATION MODE - no real calls will be made!"