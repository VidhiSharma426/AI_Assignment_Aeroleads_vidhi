# Autodialer Demo - Quick Start Guide

## 🚀 Getting Started

### 1. Setup the Application

```bash
cd Autodialer
chmod +x bin/setup
./bin/setup
```

This will:
- Install all Ruby gems
- Create and setup the database
- Seed with demo data
- Prepare the application

### 2. Start the Server

```bash
rails server
```

Visit: http://localhost:3000

## 📱 Using the Application

### Dashboard Features

1. **AI Command Interface**: Type commands like:
   - "Start calling all numbers"
   - "Call 9876543210"
   - "Show today's logs"
   - "Help"

2. **Quick Statistics**: View real-time call metrics

3. **Recent Activity**: Monitor latest calls and system events

### Managing Phone Numbers

1. **Add Single Number**:
   - Click "Add Number" 
   - Enter Indian mobile (10 digits) or toll-free (1800XXXXXXX)
   - Add optional notes

2. **Bulk Upload**:
   - Create a CSV/TXT file with one number per line
   - Upload via the bulk upload interface

3. **Paste Numbers**:
   - Copy multiple numbers
   - Paste in the text area
   - System validates and imports

### Making Calls (Simulated)

1. **Individual Calls**:
   - Go to phone number details
   - Click "Call" button
   - Watch simulated call progression

2. **Bulk Calling**:
   - Use "Start Calling All" button
   - Or AI command: "start calling"
   - Monitor progress in dashboard

### Viewing Call Logs

1. **All Calls**: View complete call history
2. **Today's Calls**: Filter to current day
3. **By Status**: Filter by completed, failed, etc.
4. **Call Details**: Click on any call for full details

## 🤖 AI Commands Reference

### Available Commands

| Command | Action | Example |
|---------|--------|---------|
| `start calling` | Begin autodialing all pending numbers | "Start calling all numbers" |
| `call [number]` | Make call to specific number | "Call 9876543210" |
| `show logs` | Display call history | "Show me the call logs" |
| `today logs` | Show today's calls only | "Show today's calls" |
| `statistics` | Display system stats | "Give me statistics" |
| `stop calling` | Halt autodialer | "Stop calling" |
| `help` | List available commands | "Help me" |

### Voice Commands (Simulated)

1. Click the microphone button
2. Speak your command (simulated in demo)
3. System processes and responds

## 📊 Understanding the Interface

### Status Indicators

**Phone Number Statuses:**
- 🟡 **Pending**: Ready to be called
- 🔵 **Calling**: Currently being called
- 🟢 **Completed**: Successfully contacted
- 🔴 **Failed**: Call unsuccessful

**Call Statuses:**
- 🔵 **Queued**: Call initiated
- 🟡 **Ringing**: Phone ringing
- 🔵 **In Progress**: Call connected
- 🟢 **Completed**: Call finished successfully
- 🔴 **Failed**: Call failed (network error, etc.)
- 🟠 **Busy**: Line busy
- 🟣 **No Answer**: No response within timeout

### Dashboard Metrics

- **Total Numbers**: Count of all phone numbers
- **Successful Calls**: Completed calls count
- **Today's Calls**: Calls made today
- **Active Calls**: Currently in progress
- **Success Rate**: Percentage of successful calls

## 🛠️ Demo Features

### Simulation Behavior

The application simulates realistic call behavior:

1. **Call Progression**: Queued → Ringing → In Progress → Completed/Failed
2. **Random Outcomes**: ~60% success rate with realistic failure reasons
3. **Duration Simulation**: Random call durations (10-60 seconds)
4. **Cost Calculation**: Mock billing at $0.02/minute

### Sample Data

The seed data includes:
- 10 demo phone numbers
- 5 sample call logs
- 3 AI command examples
- Configured system settings

## 🔧 Customization

### System Settings

Modify behavior through the Rails console:

```ruby
rails console

# Change maximum phone numbers
SystemSetting['max_phone_numbers'] = 200

# Adjust call delay
SystemSetting['call_delay_seconds'] = 5

# Toggle AI voice
SystemSetting['ai_voice_enabled'] = false
```

### Adding More Demo Data

```ruby
rails console

# Add more phone numbers
PhoneNumber.create!(number: '9123456789', source: 'manual')

# Create test call logs
CallLog.create!(phone_number: phone_number, status: 'completed', duration_seconds: 30)
```

## 🛡️ Safety Features

### Simulation Mode

- **No Real Calls**: All telephony is simulated
- **Mock APIs**: Twilio integration is completely mocked
- **Safe Testing**: No external connections made
- **Demo Data**: All phone numbers are fictional

### Privacy Protection

- **Local Storage**: All data stays on your machine
- **No Recording**: No actual voice recording
- **Temporary Data**: Can be cleared anytime
- **Educational Use**: Designed for learning only

## 📚 Learning Objectives

This demo helps understand:

1. **Rails MVC Architecture**: Models, views, controllers
2. **Background Jobs**: Sidekiq integration
3. **API Design**: RESTful endpoints
4. **Real-time Updates**: Dashboard refreshing
5. **AI Integration**: Natural language processing
6. **Telephony Concepts**: Call flows and statuses
7. **Data Modeling**: Phone numbers and call logs

## 🆘 Troubleshooting

### Common Issues

1. **Database Errors**: Run `rails db:reset db:seed`
2. **Missing Dependencies**: Run `bundle install`
3. **Port Conflicts**: Use `rails server -p 3001`
4. **Asset Issues**: Run `rails assets:precompile`

### Resetting Demo Data

```bash
rails db:reset db:seed
```

This clears all data and recreates sample content.

### Checking System Status

Visit: http://localhost:3000/health

Returns JSON with system status and configuration.

## 📖 Next Steps

### Extending the Demo

1. **Add Authentication**: User accounts and permissions
2. **Real Integration**: Connect to actual Twilio API (carefully!)
3. **Advanced AI**: More sophisticated command processing
4. **Reporting**: Detailed analytics and exports
5. **Scheduling**: Campaign scheduling features

### Production Considerations

⚠️ **Important**: This is a demo only. For production:

1. Add proper authentication and authorization
2. Implement real error handling
3. Add comprehensive logging
4. Use production database (PostgreSQL)
5. Add monitoring and alerting
6. Implement rate limiting
7. Add audit trails
8. Follow telecommunication regulations

---

**Remember**: This is SIMULATION MODE only. No real phone calls are made. This application is for educational and demonstration purposes only.