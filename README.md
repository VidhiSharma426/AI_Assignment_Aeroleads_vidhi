# 🚀 AI Assignment Portfolio - Complete Project Guide

A comprehensive collection of three innovative applications showcasing AI integration, web automation, and full-stack development skills. This portfolio demonstrates proficiency in Python, Ruby on Rails, web scraping, and AI API integration.

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Quick Start Guide](#-quick-start-guide)
- [Project 1: AI Blog Generator](#-project-1-ai-blog-generator)
- [Project 2: Autodialer Application](#-project-2-autodialer-application)
- [Project 3: LinkedIn Profile Scraper](#-project-3-linkedin-profile-scraper)
- [System Requirements](#-system-requirements)
- [Installation Summary](#-installation-summary)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

## 🎯 Project Overview

This repository contains three distinct applications, each demonstrating different aspects of modern software development:

| Project | Technology Stack | Purpose | Complexity |
|---------|-----------------|---------|------------|
| **AI Blog Generator** | Python, Multiple AI APIs | Automated content creation | ⭐⭐⭐ |
| **Autodialer** | Ruby on Rails, SQLite | Telephony simulation system | ⭐⭐⭐⭐ |
| **LinkedIn Scraper** | Python, Selenium, BeautifulSoup | Ethical data extraction | ⭐⭐ |

### 🔧 Technologies Demonstrated:
- **Backend Development**: Python, Ruby on Rails
- **AI Integration**: OpenAI, Google Gemini, Perplexity APIs
- **Web Automation**: Selenium WebDriver
- **Data Processing**: pandas, BeautifulSoup, CSV handling
- **Database Management**: SQLite, ActiveRecord ORM
- **Web Technologies**: HTML, CSS, Bootstrap, ERB templates
- **DevOps**: Virtual environments, dependency management

## ⚡ Quick Start Guide

### Prerequisites for All Projects:
- **Python 3.8+** (for AI Blog Generator & LinkedIn Scraper)
- **Ruby 3.4.7** (for Autodialer)
- **Google Chrome** (for LinkedIn Scraper)
- **Git** (for cloning/contributing)

### 30-Second Setup:
```bash
# Clone or navigate to the workspace
cd /path/to/workspace

# Quick test - check versions
python --version  # Should be 3.8+
ruby --version    # Should be 3.4.7

# Choose your project and follow specific setup below
```

---

# 🤖 Project 1: AI Blog Generator

**Automated blog content generation using multiple AI providers for high-quality programming articles.**

## 📊 Project Stats:
- **Language**: Python 3.8+
- **APIs**: OpenAI GPT, Google Gemini, Perplexity Pro
- **Output Formats**: Markdown, HTML, JSON
- **Dependencies**: 10+ packages
- **Estimated Setup Time**: 5-10 minutes

## ✨ Key Features:
- **Multi-AI Support**: Switch between ChatGPT, Gemini, and Perplexity
- **Batch Processing**: Generate multiple articles from JSON lists
- **Rich Formatting**: Professional HTML templates with Bootstrap
- **Error Handling**: Robust retry mechanisms and graceful failures
- **Interactive CLI**: Beautiful console interface with progress bars

## 🚀 Quick Setup:

### Step 1: Navigate and Install
```bash
cd AI_Blog_Generator
pip install -r requirements.txt
```

### Step 2: Configure API Keys
```bash
# Edit config/api_keys.env
GEMINI_API_KEY=your_gemini_key_here
OPENAI_API_KEY=your_openai_key_here
PERPLEXITY_API_KEY=your_perplexity_key_here
DEFAULT_AI_PROVIDER=gemini
```

### Step 3: Generate Content
```bash
# Interactive mode
python blog_generator.py

# Batch mode with samples
python blog_generator.py --batch sample_articles.json --provider gemini

# Single article
python blog_generator.py --title "Building REST APIs with FastAPI" --provider chatgpt
```

## 📁 File Structure:
```
AI_Blog_Generator/
├── blog_generator.py          # Main application
├── api_clients/               # AI provider integrations
│   ├── gemini_client.py       # Google Gemini API
│   ├── chatgpt_client.py      # OpenAI ChatGPT API
│   └── perplexity_client.py   # Perplexity Pro API
├── config/api_keys.env        # API configuration
├── generated_articles/        # Output directory
├── templates/blog_template.html # HTML styling
├── sample_articles.json       # Demo content ideas
└── requirements.txt           # Dependencies
```

## 🎯 Expected Output:
- **Markdown Files**: Clean, formatted blog posts
- **HTML Files**: Web-ready articles with Bootstrap styling
- **JSON Metadata**: Generation stats and metadata
- **Success Rate**: 95%+ with proper API keys

### Sample Commands:
```bash
# Generate programming tutorials
python blog_generator.py --title "Python Async Programming Guide"

# Create multiple articles
python blog_generator.py --batch sample_articles.json --limit 5

# Use specific AI provider
python blog_generator.py --title "Docker Best Practices" --provider perplexity
```

---

# 📞 Project 2: Autodialer Application

**Ruby on Rails web application simulating autodialer functionality for educational purposes.**

## 📊 Project Stats:
- **Framework**: Ruby on Rails 7.0.4
- **Database**: SQLite3
- **Frontend**: ERB templates, Bootstrap 5
- **Background Jobs**: Rails Active Job
- **Estimated Setup Time**: 15-20 minutes

## ✨ Key Features:
- **Phone Management**: Add, import, validate Indian phone numbers
- **Call Simulation**: Realistic autodialer simulation (no real calls)
- **Dashboard**: Real-time statistics and call monitoring
- **Bulk Operations**: CSV upload, batch processing
- **API Endpoints**: RESTful API for programmatic access
- **Validation**: Indian mobile and toll-free number validation

## 🚀 Quick Setup:

### Step 1: Navigate and Install
```bash
cd Autodialer
bundle install
```

### Step 2: Database Setup
```bash
rails db:create
rails db:migrate
rails db:seed
```

### Step 3: Start Application
```bash
rails server
# Visit: http://localhost:3000
```

## 📁 File Structure:
```
Autodialer/
├── app/
│   ├── controllers/           # Application logic
│   │   ├── dashboard_controller.rb
│   │   ├── phone_numbers_controller.rb
│   │   └── call_logs_controller.rb
│   ├── models/               # Data models
│   │   ├── phone_number.rb   # Phone number validation
│   │   ├── call_log.rb       # Call history tracking
│   │   └── ai_command.rb     # Voice command simulation
│   ├── views/                # HTML templates
│   ├── jobs/                 # Background processing
│   └── services/             # Business logic
├── config/
│   ├── routes.rb             # URL routing
│   └── database.yml          # Database config
├── db/
│   ├── migrate/              # Database schemas
│   └── seeds.rb              # Sample data
└── Gemfile                   # Ruby dependencies
```

## 🎯 Expected Features:
- **Dashboard**: http://localhost:3000 - Overview and statistics
- **Phone Numbers**: Add/manage contacts with Indian number validation
- **Call Logs**: View simulated call history with various statuses
- **Bulk Import**: CSV file upload for multiple numbers
- **API Access**: RESTful endpoints for integration

### Sample Phone Numbers (Pre-loaded):
- `9468448087` - Your number (added during setup)
- `9876543210` - Demo contact 1
- `8123456789` - Demo contact 2
- Various test numbers with different statuses

### Indian Phone Number Format:
- **Mobile**: 10 digits starting with 6, 7, 8, or 9
- **Valid**: `9468448087`, `8765432109`
- **Invalid**: `1234567890`, `5987654321`

---

# 🕵️‍♂️ Project 3: LinkedIn Profile Scraper

**Ethical web scraping application for extracting publicly available LinkedIn profile data.**

## 📊 Project Stats:
- **Language**: Python 3.11+
- **Web Automation**: Selenium WebDriver
- **Data Parsing**: BeautifulSoup4
- **Output**: CSV, structured data
- **Estimated Setup Time**: 10-15 minutes

## ✨ Key Features:
- **Ethical Scraping**: Only public profiles, respects rate limits
- **Automated Browser**: Chrome WebDriver with automatic management
- **Data Extraction**: Name, headline, location, about, experience
- **Error Handling**: Graceful failures, retry mechanisms
- **Pre-configured**: Includes virtual environment and URL list

## 🚀 Quick Setup:

### Step 1: Navigate and Activate Environment
```bash
cd Linkedin_scrapper
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate
```

### Step 2: Install Dependencies
```bash
pip install selenium webdriver-manager beautifulsoup4 pandas
```

### Step 3: Run Scraper
```bash
# Use improved version (recommended)
python improved_scrapper.py

# Or basic version
python Scrapper.py
```

## 📁 File Structure:
```
Linkedin_scrapper/
├── improved_scrapper.py      # Enhanced scraper (recommended)
├── Scrapper.py              # Basic scraper
├── urls.txt                 # Pre-configured LinkedIn URLs
├── venv/                    # Python virtual environment
├── outputs/                 # Results directory
│   ├── profiles.csv         # Extracted data
│   └── improved_scraper.log # Process logs
└── requirements.txt         # Dependencies
```

## 🎯 Expected Output:

### CSV Data Structure:
| Field | Description | Example |
|-------|-------------|---------|
| name | Full name | "John Doe" |
| headline | Job title | "Senior Software Engineer at TechCorp" |
| location | Geographic location | "New York, United States" |
| about | Professional summary | "Experienced developer with 5+ years..." |
| current_position | Current role | "Senior Software Engineer" |
| current_company | Current employer | "TechCorp Inc." |
| profile_url | Source URL | "https://linkedin.com/in/johndoe" |
| scraping_date | Extraction timestamp | "2025-01-04 14:30:22" |
| success_status | Extraction result | "SUCCESS" or "FAILED" |

### Success Metrics:
- **Success Rate**: 60-80% (depends on profile accessibility)
- **Processing Time**: 2-3 minutes per profile
- **Data Quality**: High accuracy for public profiles
- **Output Files**: CSV data + detailed logs

### Pre-configured URLs (Sample):
```text
https://in.linkedin.com/in/jaskaran-singh-9b3937169
https://in.linkedin.com/in/lakhvir-singh-3158291b3
https://in.linkedin.com/in/shanu-mittal-ba4083104
https://in.linkedin.com/in/pushpraj-patel-4006ba18a
https://in.linkedin.com/in/kannan-india-32359a14a
# ... 15+ more profiles ready to scrape
```

---

# 💻 System Requirements

## Hardware Requirements:
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 2GB free space for all projects
- **Internet**: Stable connection for APIs and scraping

## Software Requirements:

### For All Projects:
- **Operating System**: Windows 10+, macOS 10.14+, or Linux
- **Git**: Latest version for repository management

### For AI Blog Generator:
- **Python**: 3.8, 3.9, 3.10, or 3.11
- **pip**: Latest version
- **Internet**: For AI API calls

### For Autodialer:
- **Ruby**: Exactly 3.4.7 (critical requirement)
- **Rails**: 7.0.4 (installed via bundle)
- **SQLite3**: Included with Rails

### For LinkedIn Scraper:
- **Python**: 3.11+ recommended
- **Google Chrome**: Latest version
- **ChromeDriver**: Auto-managed by webdriver-manager

## 📦 Installation Summary

### Complete Environment Setup:
```bash
# Step 1: Verify prerequisites
python --version    # Should be 3.8+
ruby --version      # Should be 3.4.7
chrome --version    # Any recent version

# Step 2: Install project dependencies
cd AI_Blog_Generator && pip install -r requirements.txt && cd ..
cd Autodialer && bundle install && cd ..
cd Linkedin_scrapper && venv\Scripts\activate && pip install -r requirements.txt && cd ..

# Step 3: Configure API keys (AI Blog Generator only)
# Edit AI_Blog_Generator/config/api_keys.env

# Step 4: Setup databases (Autodialer only)
cd Autodialer && rails db:create && rails db:migrate && rails db:seed && cd ..

# Step 5: Test each project
cd AI_Blog_Generator && python blog_generator.py --help
cd ../Autodialer && rails server --help
cd ../Linkedin_scrapper && python improved_scrapper.py --help
```

---

# 🐛 Troubleshooting

## Common Issues Across All Projects:

### 1. Python Version Issues
```bash
# Error: Python version incompatibility
python --version  # Check current version

# Solution: Install correct Python version
# Windows: Use Python installer from python.org
# macOS: brew install python@3.11
# Linux: apt install python3.11
```

### 2. Ruby Version Issues (Autodialer)
```bash
# Error: Wrong Ruby version
ruby --version  # Must be 3.4.7

# Solution: Use Ruby version manager
# Windows: Use RubyInstaller
# macOS/Linux: Use rbenv or rvm
```

### 3. Virtual Environment Issues
```bash
# Error: Virtual environment activation fails
# Solution for Windows:
python -m venv new_venv
new_venv\Scripts\activate

# Solution for macOS/Linux:
python3 -m venv new_venv
source new_venv/bin/activate
```

### 4. API Key Issues (AI Blog Generator)
```bash
# Error: Invalid API key
# Solution:
# 1. Get valid API keys from providers
# 2. Check config/api_keys.env format
# 3. Ensure no extra spaces or quotes
```

### 5. Chrome/ChromeDriver Issues (LinkedIn Scraper)
```bash
# Error: ChromeDriver not found
# Solution:
pip install --upgrade webdriver-manager
# Or download manually from chromedriver.chromium.org
```

### 6. Database Issues (Autodialer)
```bash
# Error: Database migration failures
# Solution:
rails db:reset  # Recreates entire database
```

### 7. Permission Issues
```bash
# Error: Permission denied
# Windows Solution:
# Run command prompt as Administrator

# macOS/Linux Solution:
sudo chown -R $USER:$USER /path/to/project
```

## Project-Specific Troubleshooting:

### AI Blog Generator:
- **Network Issues**: Check internet connection for API calls
- **Rate Limiting**: Switch AI providers or add delays
- **Output Errors**: Verify write permissions in generated_articles/

### Autodialer:
- **Native Gem Compilation**: Use alternative gems (already configured)
- **Bootstrap Issues**: Disabled to avoid Windows compilation errors
- **Route Errors**: Restart Rails server after configuration changes

### LinkedIn Scraper:
- **Profile Access**: Use only public LinkedIn profiles
- **Rate Limiting**: Increase delays between requests
- **Browser Crashes**: Enable headless mode for stability

---

# 🎯 Usage Examples

## Scenario 1: Content Creator Workflow
```bash
# Generate blog content with AI
cd AI_Blog_Generator
python blog_generator.py --batch sample_articles.json --provider gemini

# Expected: 10+ blog posts ready for publishing
```

## Scenario 2: Autodialer Demo Setup
```bash
# Set up complete autodialer system
cd Autodialer
bundle install && rails db:setup
rails server

# Visit: http://localhost:3000
# Add phone numbers and simulate calls
```

## Scenario 3: LinkedIn Research Project
```bash
# Extract professional data from LinkedIn
cd Linkedin_scrapper
venv\Scripts\activate
python improved_scrapper.py

# Expected: CSV file with professional profiles
```

## Scenario 4: Full Portfolio Demo
```bash
# Terminal 1: AI Blog Generator
cd AI_Blog_Generator
python blog_generator.py --title "Building Microservices" --provider chatgpt

# Terminal 2: Autodialer Server
cd Autodialer
rails server

# Terminal 3: LinkedIn Scraper
cd Linkedin_scrapper
python improved_scrapper.py

# Demo all three applications simultaneously
```

---

# 📊 Project Comparison

| Feature | AI Blog Generator | Autodialer | LinkedIn Scraper |
|---------|------------------|------------|------------------|
| **Primary Language** | Python | Ruby | Python |
| **Framework** | Custom CLI | Ruby on Rails | Selenium |
| **Database** | File-based | SQLite3 | CSV Output |
| **User Interface** | Command Line | Web Interface | Command Line |
| **External APIs** | Multiple AI APIs | None | None |
| **Authentication** | API Keys | None | None |
| **Data Output** | MD/HTML/JSON | Web Dashboard | CSV |
| **Complexity Level** | Medium | High | Low-Medium |
| **Setup Time** | 5-10 min | 15-20 min | 10-15 min |
| **Use Case** | Content Creation | Call Center Sim | Data Research |

---

# 🤝 Contributing

## How to Contribute:

### 1. Choose a Project:
- **AI Blog Generator**: Add new AI providers, improve prompts
- **Autodialer**: Add features, improve UI, enhance simulation
- **LinkedIn Scraper**: Improve extraction, add data fields

### 2. Development Setup:
```bash
# Fork the repository
git clone your-fork-url
cd project-directory

# Create feature branch
git checkout -b feature/new-feature

# Make changes and test
# Follow project-specific setup instructions above

# Commit and push
git add .
git commit -m "Add new feature: description"
git push origin feature/new-feature

# Create pull request
```

### 3. Contribution Guidelines:
- **Code Quality**: Follow existing code style and patterns
- **Documentation**: Update README files for new features
- **Testing**: Test your changes thoroughly
- **Ethics**: Ensure all contributions respect legal and ethical standards

### 4. Areas for Improvement:
- **AI Blog Generator**: Additional output formats, more AI providers
- **Autodialer**: Real-time features, advanced call simulation
- **LinkedIn Scraper**: Enhanced data extraction, better error handling

---

# 📄 License & Legal

## License Information:
- **AI Blog Generator**: MIT License - Open source, educational use
- **Autodialer**: Educational License - Simulation purposes only
- **LinkedIn Scraper**: Educational License - Ethical scraping only

## Legal Considerations:

### AI Blog Generator:
- ✅ Respect AI provider terms of service
- ✅ Use API keys responsibly
- ✅ Credit AI providers when publishing content

### Autodialer:
- ✅ SIMULATION ONLY - No real telephony connections
- ✅ Educational purposes only
- ✅ Do not use for actual autodialing

### LinkedIn Scraper:
- ✅ Public profiles only
- ✅ Respect LinkedIn's robots.txt
- ✅ Comply with data protection laws
- ❌ No login bypass or private data access

## Disclaimers:
- **Educational Purpose**: All projects are for learning and demonstration
- **No Warranty**: Software provided as-is without guarantees
- **User Responsibility**: Users must comply with all applicable laws
- **Ethical Use**: Maintain ethical standards in all usage

---

# 🆘 Support & Resources

## Getting Help:

### 1. Documentation:
- **This Master Guide**: Comprehensive overview
- **Project-Specific READMEs**: Detailed setup for each project
- **Code Comments**: Inline documentation in source files

### 2. Troubleshooting Process:
1. **Check Prerequisites**: Verify all system requirements
2. **Review Error Messages**: Read complete error output
3. **Check Project Logs**: Look for detailed error information
4. **Try Minimal Setup**: Test with simplest configuration
5. **Search Issues**: Look for similar problems online

### 3. Support Channels:
- **GitHub Issues**: Report bugs and feature requests
- **Documentation**: Refer to individual project README files
- **Stack Overflow**: Search for technology-specific questions

### 4. Useful Resources:

#### AI Blog Generator:
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Google AI Studio](https://makersuite.google.com/)
- [Perplexity API Docs](https://docs.perplexity.ai/)

#### Autodialer:
- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [Rails API Documentation](https://api.rubyonrails.org/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)

#### LinkedIn Scraper:
- [Selenium Documentation](https://selenium-python.readthedocs.io/)
- [BeautifulSoup Documentation](https://www.crummy.com/software/BeautifulSoup/bs4/doc/)
- [LinkedIn Developer Policies](https://www.linkedin.com/developers/)

---

# 🚀 Next Steps

## After Successful Setup:

### 1. Explore Each Project:
- **AI Blog Generator**: Generate your first blog post
- **Autodialer**: Add your phone number and explore dashboard
- **LinkedIn Scraper**: Extract a few sample profiles

### 2. Customization Opportunities:
- **Modify AI prompts** for different content styles
- **Add new phone number sources** to autodialer
- **Extend LinkedIn data extraction** fields

### 3. Integration Possibilities:
- **Combine Projects**: Use AI Blog Generator to create content about scraped data
- **API Development**: Build APIs connecting the projects
- **Data Pipeline**: Create workflow from scraping → AI processing → content

### 4. Portfolio Enhancement:
- **Documentation**: Add your own use cases and examples
- **Deployment**: Host the autodialer application online
- **Analytics**: Add metrics and monitoring to all projects

---

## 🎯 Project Summary

This portfolio demonstrates:

✅ **Full-Stack Development**: Frontend (Rails views) + Backend (Rails controllers, Python scripts)  
✅ **AI Integration**: Multiple AI providers with robust error handling  
✅ **Web Automation**: Professional web scraping with ethical considerations  
✅ **Database Management**: Migrations, validations, and seed data  
✅ **API Development**: RESTful endpoints and client implementations  
✅ **Error Handling**: Comprehensive troubleshooting and user guidance  
✅ **Documentation**: Professional README files and code comments  
✅ **Legal Compliance**: Ethical use guidelines and disclaimers  

**Total Development Time**: Approximately 40-60 hours across all three projects  
**Technology Breadth**: 15+ different technologies and frameworks  
**Practical Applications**: Real-world use cases in content creation, telecommunications, and data research

---

**Ready to explore these projects? Choose your starting point and follow the setup instructions above! 🚀✨**

---
