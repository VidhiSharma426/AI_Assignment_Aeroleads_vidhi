# 🤖 AI Blog Generator - Complete Setup Guide

An automated blog content generation system that creates high-quality programming articles using multiple AI APIs (Gemini, ChatGPT, Perplexity Pro).

## 📋 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Project Structure](#-project-structure)
- [API Configuration](#-api-configuration)
- [Troubleshooting](#-troubleshooting)
- [Examples](#-examples)

## ✨ Features

- **Multiple AI Providers**: Supports Google Gemini, OpenAI ChatGPT, and Perplexity Pro APIs
- **Batch Generation**: Generate multiple articles from a list of titles
- **Structured Output**: Creates organized blog posts with proper formatting
- **Multiple Formats**: Outputs in Markdown, HTML, and JSON formats
- **Web Integration**: Ready-to-use HTML templates for web deployment
- **Customizable Prompts**: Tailored prompts for programming content
- **Rich Console Output**: Beautiful progress indicators and colored output
- **Error Handling**: Robust error handling with retry mechanisms

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

- **Python 3.8 or higher**
- **pip** (Python package installer)
- **Git** (for cloning the repository)

### Check Your Python Version
```bash
python --version
# or
python3 --version
```

## 📦 Installation

### Step 1: Navigate to the Project Directory
```bash
cd AI_Blog_Generator
```

### Step 2: Create a Virtual Environment (Recommended)
```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate
```

### Step 3: Install Required Dependencies
```bash
pip install -r requirements.txt
```

### Dependencies Installed:
- `requests` - For HTTP API calls
- `python-dotenv` - For environment variable management
- `google-generativeai` - For Gemini API
- `openai` - For ChatGPT API
- `httpx` - For Perplexity API
- `beautifulsoup4` - For HTML processing
- `jinja2` - For HTML template rendering
- `rich` - For beautiful console output
- `click` - For CLI interface
- `pydantic` - For data validation

## ⚙️ Configuration

### Step 1: Set Up API Keys

Create or edit the file `config/api_keys.env` with your API keys:

```bash
# Copy the example file
cp config/api_keys.env.example config/api_keys.env
```

Edit `config/api_keys.env`:
```env
# Google Gemini API Key
GEMINI_API_KEY=your_gemini_api_key_here

# OpenAI API Key
OPENAI_API_KEY=your_openai_api_key_here

# Perplexity API Key
PERPLEXITY_API_KEY=your_perplexity_api_key_here

# Default AI Provider (gemini, chatgpt, or perplexity)
DEFAULT_AI_PROVIDER=gemini
```

### Step 2: Get Your API Keys

#### Google Gemini API Key:
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new project or select existing one
3. Generate an API key
4. Copy the key to your `api_keys.env` file

#### OpenAI API Key:
1. Visit [OpenAI Platform](https://platform.openai.com/api-keys)
2. Sign in to your account
3. Create a new secret key
4. Copy the key to your `api_keys.env` file

#### Perplexity API Key:
1. Go to [Perplexity API](https://www.perplexity.ai/settings/api)
2. Sign up for an account
3. Generate an API key
4. Copy the key to your `api_keys.env` file

## 🚀 Usage

### Method 1: Basic Usage (Interactive Mode)
```bash
python blog_generator.py
```

Follow the interactive prompts to:
1. Choose your AI provider
2. Enter article titles
3. Generate articles

### Method 2: Command Line Arguments
```bash
# Generate a single article
python blog_generator.py --title "Building RESTful APIs with FastAPI" --provider gemini

# Generate multiple articles from JSON file
python blog_generator.py --batch sample_articles.json --provider chatgpt

# Specify output directory
python blog_generator.py --title "Python Async Programming" --output ./my_articles
```

### Method 3: Using Sample Articles
```bash
# Generate all sample articles
python blog_generator.py --batch sample_articles.json

# Generate specific number of articles
python blog_generator.py --batch sample_articles.json --limit 5
```

### Command Line Options:
- `--title` : Single article title to generate
- `--batch` : JSON file with multiple article titles
- `--provider` : AI provider (gemini, chatgpt, perplexity)
- `--output` : Output directory for generated articles
- `--limit` : Limit number of articles to generate
- `--format` : Output format (markdown, html, json, all)

## 📁 Project Structure

```
AI_Blog_Generator/
├── blog_generator.py          # Main application script
├── api_clients/               # API client implementations
│   ├── __init__.py
│   ├── gemini_client.py       # Google Gemini API client
│   ├── perplexity_client.py   # Perplexity Pro API client
│   └── chatgpt_client.py      # OpenAI ChatGPT API client
├── templates/                 # HTML templates
│   └── blog_template.html     # Blog post HTML template
├── generated_articles/        # Output directory
│   ├── *.md                   # Markdown files
│   ├── *.html                 # HTML files
│   └── *.json                 # JSON metadata files
├── config/                    # Configuration files
│   └── api_keys.env          # API keys and settings
├── sample_articles.json       # Sample article titles
├── requirements.txt           # Python dependencies
├── setup.py                  # Package setup file
├── USAGE_GUIDE.md            # Detailed usage guide
└── README.md                 # This file
```

## 🔍 API Configuration Details

### Gemini Configuration:
- Model: `gemini-1.5-flash`
- Temperature: 0.7 (creative but focused)
- Max tokens: 8192

### ChatGPT Configuration:
- Model: `gpt-3.5-turbo` or `gpt-4`
- Temperature: 0.7
- Max tokens: 4096

### Perplexity Configuration:
- Model: `pplx-7b-online` or `pplx-70b-online`
- Temperature: 0.7
- Max tokens: 4096

## 🐛 Troubleshooting

### Common Issues and Solutions:

#### 1. API Key Errors
```bash
Error: Invalid API key
```
**Solution**: 
- Verify your API keys in `config/api_keys.env`
- Ensure no extra spaces or quotes
- Check if the API key is active and has sufficient credits

#### 2. Module Not Found Errors
```bash
ModuleNotFoundError: No module named 'requests'
```
**Solution**:
```bash
pip install -r requirements.txt
```

#### 3. Permission Denied Errors
```bash
PermissionError: [Errno 13] Permission denied
```
**Solution**:
- Run with administrator privileges (Windows)
- Use `sudo` on macOS/Linux
- Check file/folder permissions

#### 4. Network Connection Issues
```bash
ConnectionError: Failed to establish connection
```
**Solution**:
- Check your internet connection
- Verify firewall/proxy settings
- Try using a different AI provider

#### 5. Rate Limiting
```bash
Error: Rate limit exceeded
```
**Solution**:
- Wait a few minutes before retrying
- Use a different AI provider
- Check your API usage limits

### Debugging Mode:
```bash
python blog_generator.py --debug
```

## 📝 Examples

### Example 1: Generate a Single Article
```bash
python blog_generator.py --title "Building RESTful APIs with FastAPI and Python" --provider gemini
```

### Example 2: Batch Generate Articles
```bash
python blog_generator.py --batch sample_articles.json --provider chatgpt --limit 3
```

### Example 3: Custom Output Directory
```bash
python blog_generator.py --title "Docker Containerization for Node.js" --output ./my_blog_posts
```

## 📊 Output Files

For each generated article, you'll get:

1. **Markdown File** (`.md`):
   - Clean, formatted text
   - Perfect for static site generators like Jekyll, Hugo

2. **HTML File** (`.html`):
   - Styled web page
   - Ready for direct web hosting
   - Includes Bootstrap CSS for responsive design

3. **JSON Metadata** (`.json`):
   - Article metadata
   - Generation timestamp
   - AI provider used
   - Word count and other stats

### Sample Output Structure:
```
generated_articles/
├── 20250104_143022_building_restful_apis.md
├── 20250104_143022_building_restful_apis.html
├── 20250104_143022_building_restful_apis.json
└── blog_generator.log
```

## 🎯 Advanced Usage

### Custom Prompts:
Edit the prompt in `blog_generator.py` to customize the article style:

```python
BLOG_PROMPT = """
Your custom prompt here...
"""
```

### Environment Variables:
```bash
# Set via command line
export GEMINI_API_KEY="your_key_here"
export DEFAULT_AI_PROVIDER="gemini"

# Or add to your shell profile
echo 'export GEMINI_API_KEY="your_key_here"' >> ~/.bashrc
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

If you encounter any issues:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Review the `USAGE_GUIDE.md` for detailed examples
3. Check the generated log files in `generated_articles/blog_generator.log`
4. Create an issue on GitHub with error details

## 🚀 Quick Start Summary

```bash
# 1. Navigate to project
cd AI_Blog_Generator

# 2. Install dependencies
pip install -r requirements.txt

# 3. Configure API keys
# Edit config/api_keys.env with your keys

# 4. Run the generator
python blog_generator.py

# 5. Follow interactive prompts or use CLI options
python blog_generator.py --batch sample_articles.json --provider gemini
```

**Happy blogging! 🎉✨**