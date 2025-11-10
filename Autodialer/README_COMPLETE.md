# 📞 Autodialer - Complete Setup Guide

A Ruby on Rails simulation application that demonstrates autodialer functionality for educational purposes. This application provides a web interface for managing phone numbers, simulating calls, and tracking call logs.

**⚠️ IMPORTANT: This is a SIMULATION APPLICATION for educational purposes only. No real phone calls are made.**

## 📋 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Database Setup](#-database-setup)
- [Running the Application](#-running-the-application)
- [Usage](#-usage)
- [Troubleshooting](#-troubleshooting)
- [Project Structure](#-project-structure)
- [API Documentation](#-api-documentation)

## ✨ Features

- **Phone Number Management**: Add, import, and manage phone numbers
- **Call Simulation**: Simulate autodialer calls (no real calls made)
- **Call Logging**: Track call history, duration, and status
- **AI Commands**: Text and voice command processing simulation
- **Dashboard**: Real-time statistics and overview
- **Bulk Import**: CSV upload for multiple phone numbers
- **Indian Phone Validation**: Validates Indian mobile and toll-free numbers
- **Bootstrap UI**: Modern, responsive web interface

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

- **Ruby 3.4.7** (exact version required)
- **Rails 7.0.4**
- **SQLite3** (included with Rails)
- **Bundler** gem
- **Git** (for cloning if needed)

### Check Your Ruby Version
```powershell
ruby --version
# Should show: ruby 3.4.7
```

### Install Ruby (if needed)
- **Windows**: Download from [Ruby Installer](https://rubyinstaller.org/)
- **macOS**: Use `brew install ruby` or rbenv
- **Linux**: Use rbenv or rvm

## 📦 Installation

### Step 1: Navigate to the Autodialer Directory
```powershell
cd Autodialer
```

### Step 2: Install Bundler (if not already installed)
```powershell
gem install bundler
```

### Step 3: Install Application Dependencies
```powershell
bundle install
```

**Note**: If you encounter native extension compilation errors on Windows, follow the troubleshooting steps below.

## ⚙️ Configuration

### Step 1: Create Required Asset Files
The application needs specific asset configuration files. These are automatically created during setup, but if missing:

```powershell
# Create asset manifest (if needed)
mkdir app\assets\config
echo //= link_directory ../stylesheets .css > app\assets\config\manifest.js
echo //= link application.js >> app\assets\config\manifest.js
echo //= link_tree ../../javascript .js >> app\assets\config\manifest.js
```

### Step 2: Create Application Record (if needed)
Ensure the base model class exists:

**File**: `app/models/application_record.rb`
```ruby
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
```

### Step 3: Create Application Helper (if needed)
Ensure the helper methods exist:

**File**: `app/helpers/application_helper.rb`
```ruby
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
```

## 🗄️ Database Setup

### Step 1: Create the Database
```powershell
rails db:create
```

### Step 2: Run Database Migrations
```powershell
rails db:migrate
```

This creates the following tables:
- `phone_numbers` - Store phone numbers to call
- `call_logs` - Track all call attempts and results
- `ai_commands` - Store AI voice/text commands
- `system_settings` - Application configuration

### Step 3: Seed the Database with Sample Data
```powershell
rails db:seed
```

This creates:
- ✅ Sample phone numbers (including yours: 9468448087)
- ✅ Demo call logs with different statuses
- ✅ AI command examples
- ✅ System settings

## 🚀 Running the Application

### Step 1: Start the Rails Server
```powershell
rails server
```

### Step 2: Access the Application
Open your web browser and navigate to:
```
http://localhost:3000
```

### Step 3: Explore the Features
- **Dashboard**: View overview and statistics
- **Phone Numbers**: Manage your contact list
- **Call Logs**: Review call history
- **AI Commands**: Test voice/text commands

## 🎯 Usage

### Adding Phone Numbers

#### Method 1: Manual Entry
1. Go to **Phone Numbers** → **Add New**
2. Enter a valid Indian phone number
3. Add notes/source information
4. Click **Save**

#### Method 2: Bulk Upload
1. Prepare a CSV file with phone numbers
2. Go to **Phone Numbers** → **Upload CSV**
3. Select your file and upload

#### Method 3: Copy/Paste
1. Go to **Phone Numbers** → **Paste Numbers**
2. Paste multiple numbers (one per line)
3. Click **Process**

### Phone Number Validation Rules
- **Mobile Numbers**: 10 digits starting with 6, 7, 8, or 9
  - ✅ Valid: `9468448087`, `8123456789`, `7999888777`
  - ❌ Invalid: `5123456789`, `123456789`

### Simulating Calls
1. Select phone numbers from your list
2. Click **Start Autodialer**
3. Watch the simulation progress
4. Review results in **Call Logs**

### Call Statuses Explained
- 🟢 **Completed**: Call connected and finished normally
- 🔵 **Queued**: Call waiting to be dialed
- 🔵 **Ringing**: Call in progress, waiting for answer
- 🟡 **Busy**: Number was busy
- 🟡 **No Answer**: Call timed out, no answer
- 🔴 **Failed**: Call failed due to network/technical issues
- 🔴 **Cancelled**: Call was manually stopped

## 🐛 Troubleshooting

### Common Issues and Solutions

#### 1. Ruby Version Errors
```
This application requires Ruby 3.4.7
```
**Solution**: Install the exact Ruby version required
```powershell
# Check current version
ruby --version

# Install Ruby 3.4.7 using Ruby Installer (Windows)
# Or use rbenv/rvm on other platforms
```

#### 2. Native Extension Compilation Errors
```
Error installing sassc-rails, psych, or other native gems
```
**Solutions**:

**Option A**: Use alternative gems (already configured)
- Bootstrap and Sass functionality disabled
- Application works with basic CSS styling

**Option B**: Install development tools
```powershell
# Install MSYS2 development tools
ridk install 3
```

**Option C**: Use WSL (Windows Subsystem for Linux)
```bash
# Install Ruby in WSL environment
sudo apt update
sudo apt install ruby-full
```

#### 3. Database Errors
```
ActiveRecord::RecordInvalid: Validation failed
```
**Solutions**:
```powershell
# Reset database completely
rails db:reset

# Or step by step
rails db:drop
rails db:create
rails db:migrate
rails db:seed
```

#### 4. Asset Pipeline Errors
```
Asset not precompiled or manifest errors
```
**Solution**: Check asset configuration
```powershell
# Verify manifest file exists
type app\assets\config\manifest.js

# Restart server
rails server
```

#### 5. Route Errors
```
undefined method 'some_path'
```
**Solution**: Check routes
```powershell
# View all available routes
rails routes
```

#### 6. Phone Number Validation Errors
```
Number must be a valid Indian phone number
```
**Solution**: Use proper format
- Mobile: 10 digits starting with 6-9
- Example: `9468448087` ✅
- Invalid: `1234567890` ❌

### Getting Help

1. Check the application logs:
   ```powershell
   # View server logs
   tail -f log/development.log
   ```

2. Enable debug mode:
   ```powershell
   # Run with detailed error output
   rails server --environment=development --verbose
   ```

## 📁 Project Structure

```
Autodialer/
├── app/
│   ├── controllers/           # Application controllers
│   │   ├── dashboard_controller.rb
│   │   ├── phone_numbers_controller.rb
│   │   ├── call_logs_controller.rb
│   │   └── ai_commands_controller.rb
│   ├── models/               # Data models
│   │   ├── application_record.rb
│   │   ├── phone_number.rb
│   │   ├── call_log.rb
│   │   ├── ai_command.rb
│   │   └── system_setting.rb
│   ├── views/                # HTML templates
│   │   ├── layouts/
│   │   ├── dashboard/
│   │   ├── phone_numbers/
│   │   └── call_logs/
│   ├── services/             # Business logic
│   │   ├── ai_voice_service.rb
│   │   └── twilio_simulator_service.rb
│   ├── jobs/                 # Background jobs
│   │   ├── autodialer_job.rb
│   │   └── single_call_job.rb
│   └── assets/               # CSS, JS, images
├── config/
│   ├── routes.rb             # URL routing
│   ├── database.yml          # Database configuration
│   └── application.rb        # App configuration
├── db/
│   ├── migrate/              # Database migrations
│   └── seeds.rb              # Sample data
├── Gemfile                   # Ruby dependencies
├── Rakefile                  # Rake tasks
└── README.md                 # This file
```

## 🔌 API Documentation

### REST API Endpoints

#### Phone Numbers API
```
GET    /api/v1/phone_numbers     # List all phone numbers
POST   /api/v1/phone_numbers     # Create new phone number
PUT    /api/v1/phone_numbers/:id # Update phone number
DELETE /api/v1/phone_numbers/:id # Delete phone number
```

#### Calls API
```
GET    /api/v1/calls            # List call logs
POST   /api/v1/calls            # Start new call
PUT    /api/v1/calls/:id        # Update call status
```

#### Dashboard API
```
GET    /api/v1/dashboard        # Get dashboard statistics
```

### Example API Usage

#### Create Phone Number
```bash
curl -X POST http://localhost:3000/api/v1/phone_numbers \
  -H "Content-Type: application/json" \
  -d '{"number": "9468448087", "source": "api", "notes": "Test number"}'
```

#### Start Call
```bash
curl -X POST http://localhost:3000/api/v1/calls \
  -H "Content-Type: application/json" \
  -d '{"phone_number_id": 1, "simulation": true}'
```

## 🎮 Demo Features

### Sample Data Included:
- **Phone Numbers**: Mix of mobile numbers for testing
- **Call Logs**: Various call statuses and durations
- **AI Commands**: Example voice commands and responses
- **System Settings**: Default autodialer configuration

### Test Scenarios:
1. **Successful Call**: Complete call with duration
2. **Failed Call**: Network error simulation
3. **Busy Number**: Subscriber busy scenario
4. **No Answer**: Timeout scenario

## 🔒 Security Notes

- **Simulation Only**: No real calls are made
- **Local Development**: Designed for localhost testing
- **No External APIs**: Doesn't connect to real telephony services
- **Educational Purpose**: For learning autodialer concepts

## 📚 Learning Objectives

This application teaches:
- **Rails MVC Architecture**: Controllers, Models, Views
- **Database Design**: Relationships, validations, migrations
- **Background Jobs**: Asynchronous processing simulation
- **API Development**: RESTful endpoints
- **Form Handling**: File uploads, validations
- **UI/UX Design**: Responsive web interfaces

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is for educational purposes. See LICENSE file for details.

## 🆘 Support

If you need help:

1. Check this README first
2. Review the troubleshooting section
3. Check `USAGE_GUIDE.md` for detailed examples
4. Look at the Rails logs for error details
5. Create an issue with full error messages

## 🚀 Quick Start Summary

```powershell
# 1. Navigate to project
cd Autodialer

# 2. Install dependencies
bundle install

# 3. Setup database
rails db:create
rails db:migrate
rails db:seed

# 4. Start server
rails server

# 5. Open browser
# Visit: http://localhost:3000
```

## 🎉 Success!

If everything is working, you should see:
- ✅ Dashboard loads at `http://localhost:3000`
- ✅ Phone numbers listed (including 9468448087)
- ✅ Call logs with different statuses
- ✅ Interactive buttons and forms working
- ✅ No error messages in console

**Happy autodialing simulation! 📞✨**

---

*Remember: This is a simulation application for educational purposes. No real phone calls are made.*