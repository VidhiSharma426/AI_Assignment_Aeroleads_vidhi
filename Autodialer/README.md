# Autodialer Demo Application

A Ruby on Rails demonstration application that simulates an automated voice calling system with AI command integration. This application is designed for educational and prototyping purposes only - **no real phone calls are made**.

## 🛡️ Safety Notice

**SIMULATION MODE ONLY** - This application operates exclusively in simulation mode:
- No real phone calls are placed
- All API responses are mocked
- Phone numbers are for demonstration purposes only
- Complies with privacy and data protection standards

## 🚀 Features

### Core Functionality
- **Phone Number Management**: Upload, paste, or manually add up to 100 phone numbers
- **Simulated Autodialing**: Automated calling simulation with realistic status progression
- **Call Logging**: Comprehensive tracking of all simulated call attempts
- **Dashboard**: Real-time monitoring of call statistics and system status

### AI Integration
- **AI Command Interface**: Natural language commands for system control
- **Voice Commands**: Simulated speech-to-text input (demo only)
- **Text-to-Speech**: Mock TTS responses for demonstration
- **Smart Parsing**: Interprets commands like "Start calling", "Call 9876543210", "Show logs"

### Telephony Simulation
- **Twilio API Mockup**: Simulates Twilio API responses without real connections
- **Indian Phone Format**: Supports Indian mobile (10-digit) and toll-free (1800XXXXXXX) numbers
- **Realistic Call Flow**: Simulates queued → ringing → in-progress → completed/failed states
- **Cost Calculation**: Mock billing calculations for demonstration

## 🏗️ Architecture

### Models
- **PhoneNumber**: Manages contact information and validation
- **CallLog**: Tracks all call attempts with detailed metadata
- **AiCommand**: Processes and responds to natural language commands
- **SystemSetting**: Configurable application settings

### Services
- **TwilioSimulatorService**: Mocks Twilio API interactions
- **AiVoiceService**: Handles text-to-speech and speech-to-text simulation

### Background Jobs
- **AutodialerJob**: Processes bulk calling operations
- **SingleCallJob**: Handles individual call simulations

## 🛠️ Setup Instructions

### Prerequisites
- Ruby 3.1.0+
- Rails 7.0.4+
- SQLite3 (for development)
- Node.js (for asset compilation)

### Installation

1. **Clone and setup the application:**
```bash
cd Autodialer
bundle install
```

2. **Database setup:**
```bash
rails db:create
rails db:migrate
rails db:seed
```

3. **Start the application:**
```bash
rails server
```

4. **Access the application:**
Open http://localhost:3000 in your browser

### Sample Data Setup

The application includes seed data for demonstration:

```bash
rails db:seed
```

This creates:
- Sample phone numbers
- System settings
- Mock call logs for demonstration

## 📱 Usage Guide

### Adding Phone Numbers

1. **Single Number**: Use the "Add Phone Number" form
2. **Bulk Upload**: Upload CSV/TXT files with phone numbers
3. **Paste Numbers**: Copy and paste multiple numbers at once

**Supported Formats:**
- Mobile: `9876543210`, `+919876543210`
- Toll-free: `18001234567`, `1800-123-4567`

### AI Commands

Type or speak commands in the AI interface:

- `"Start calling"` - Begin autodialing all pending numbers
- `"Call 9876543210"` - Make a call to specific number
- `"Show logs"` - Display call history
- `"Show today's logs"` - Display today's call activity
- `"Statistics"` - Show system statistics
- `"Stop calling"` - Halt the autodialer
- `"Help"` - List available commands

### Dashboard Features

- **Real-time Statistics**: Call success rates, active calls, pending numbers
- **Recent Activity**: Latest calls and system events
- **Quick Actions**: Start calling, view logs, manage numbers
- **AI Assistant**: Voice and text command interface

## 🔧 Configuration

### System Settings

Configure the application through the SystemSetting model:

```ruby
# In Rails console
SystemSetting['simulation_mode'] = true
SystemSetting['max_phone_numbers'] = 100
SystemSetting['call_delay_seconds'] = 2
SystemSetting['ai_voice_enabled'] = true
```

### Environment Variables

Create `.env` file for sensitive configuration:

```env
# Demo Twilio Credentials (not real)
TWILIO_ACCOUNT_SID=demo_account_sid
TWILIO_AUTH_TOKEN=demo_auth_token
DEFAULT_FROM_NUMBER=+918001234567

# AI Service Configuration
OPENAI_API_KEY=demo_key_for_ai_features
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/models/phone_number_spec.rb
bundle exec rspec spec/jobs/autodialer_job_spec.rb
```

### Manual Testing

1. **Phone Number Validation**: Try various phone number formats
2. **Bulk Upload**: Test CSV file uploads with mixed valid/invalid numbers
3. **AI Commands**: Test natural language command processing
4. **Call Simulation**: Verify realistic call flow progression

## 📊 API Documentation

### REST API Endpoints

```bash
# Get call statistics
GET /api/v1/dashboard/stats

# List phone numbers
GET /api/v1/phone_numbers

# Create a call
POST /api/v1/calls
{
  "phone_number": "9876543210"
}

# Get call details
GET /api/v1/calls/:id
```

### AI Command API

```bash
# Process text command
POST /ai_commands/process_text_command
{
  "command": "start calling all numbers"
}

# Process voice command (simulated)
POST /ai_commands/process_voice_command
{
  "audio_text": "show me today's call logs"
}
```

## 🔐 Security & Compliance

### Data Protection
- No real personal data storage
- Simulated phone numbers only
- Local database storage
- No external data transmission

### Privacy Features
- Clear simulation mode indicators
- No recording of actual conversations
- Temporary session data only
- Configurable data retention

### Compliance
- Follows Twilio acceptable use policies
- Adheres to telecommunications regulations
- Educational use disclaimer
- No spam or unwanted calling

## 🚀 Deployment

### Production Considerations

**⚠️ Important**: This application is for demonstration only. Before any production use:

1. Implement proper authentication and authorization
2. Add real Twilio API integration (if needed)
3. Implement proper error handling and logging
4. Add comprehensive input validation
5. Configure proper database (PostgreSQL recommended)
6. Set up monitoring and alerting
7. Implement rate limiting
8. Add audit logging

### Environment Setup

```bash
# Production database setup
RAILS_ENV=production rails db:create
RAILS_ENV=production rails db:migrate

# Asset compilation
RAILS_ENV=production rails assets:precompile

# Start production server
RAILS_ENV=production rails server
```

## 🤝 Contributing

This is a demonstration project. For educational improvements:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

### Development Guidelines

- Maintain simulation-only mode
- Add comprehensive tests
- Follow Rails conventions
- Document new features
- Ensure mobile responsiveness

## 📄 License

This project is for educational and demonstration purposes only. See LICENSE file for details.

## ⚠️ Disclaimers

- **No Real Calls**: This application does not make actual phone calls
- **Demo Data**: All phone numbers and data are simulated
- **Educational Use**: Intended for learning and prototyping only
- **No Warranty**: Provided as-is for demonstration purposes
- **Compliance**: Users responsible for compliance with local regulations

## 🆘 Support

For questions about this demonstration:

1. Check the documentation above
2. Review the code comments
3. Test in the provided demo environment
4. Refer to Rails and Twilio documentation for concepts

---

**Remember**: This is a simulation for educational purposes. No real telephony services are used.