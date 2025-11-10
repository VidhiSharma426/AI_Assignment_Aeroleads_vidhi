#!/usr/bin/env python3
"""
Setup script for AI Blog Generator
"""

import os
import shutil
from pathlib import Path
from rich.console import Console
from rich.prompt import Prompt, Confirm

console = Console()

def setup_environment():
    """Setup the AI Blog Generator environment."""
    
    console.print("🚀 AI Blog Generator Setup", style="blue bold")
    console.print("=" * 40, style="blue")
    
    # Create necessary directories
    directories = [
        "config",
        "generated_articles", 
        "templates",
        "api_clients"
    ]
    
    console.print("\n📁 Creating directories...")
    for directory in directories:
        Path(directory).mkdir(exist_ok=True)
        console.print(f"   ✅ {directory}/")
    
    # Setup API keys configuration
    config_file = Path("config/api_keys.env")
    example_file = Path("config/api_keys.env.example")
    
    if not config_file.exists():
        console.print("\n🔑 Setting up API keys...")
        
        if example_file.exists():
            shutil.copy(example_file, config_file)
            console.print(f"   📋 Copied {example_file} to {config_file}")
        else:
            # Create basic config file
            config_content = """# AI API Configuration
# Add your actual API keys here

# Google Gemini API (Free for Indians)
GEMINI_API_KEY=your_gemini_api_key_here

# Perplexity Pro API (Free for Indians)  
PERPLEXITY_API_KEY=your_perplexity_api_key_here

# OpenAI ChatGPT API
OPENAI_API_KEY=your_openai_api_key_here

# Default AI Provider (gemini, perplexity, or openai)
DEFAULT_AI_PROVIDER=gemini

# Blog Settings
BLOG_AUTHOR=Your Name
BLOG_WEBSITE=https://yourwebsite.com
"""
            with open(config_file, 'w') as f:
                f.write(config_content)
            console.print(f"   📝 Created {config_file}")
        
        console.print(f"\n⚠️  Please edit {config_file} and add your API keys!", style="yellow bold")
        
        if Confirm.ask("Would you like to configure API keys now?"):
            configure_api_keys(config_file)
    else:
        console.print(f"   ✅ {config_file} already exists")
    
    # Install requirements
    console.print("\n📦 Installing Python dependencies...")
    os.system("pip install -r requirements.txt")
    
    console.print("\n✅ Setup complete!", style="green bold")
    console.print("\n🎯 Next steps:", style="yellow bold")
    console.print("1. Edit config/api_keys.env with your API keys")
    console.print("2. Run: python blog_generator.py --test")
    console.print("3. Run: python blog_generator.py --sample")

def configure_api_keys(config_file):
    """Interactive API key configuration."""
    
    console.print("\n🔑 API Key Configuration", style="blue bold")
    
    # Read current config
    config_lines = []
    with open(config_file, 'r') as f:
        config_lines = f.readlines()
    
    # Get API keys from user
    console.print("\n📝 Enter your API keys (press Enter to skip):")
    
    gemini_key = Prompt.ask("Gemini API Key", default="")
    perplexity_key = Prompt.ask("Perplexity API Key", default="")
    openai_key = Prompt.ask("OpenAI API Key", default="")
    
    author = Prompt.ask("Blog Author Name", default="AI Blog Generator")
    website = Prompt.ask("Blog Website URL", default="https://yourblog.com")
    
    # Update config lines
    new_config_lines = []
    for line in config_lines:
        if line.startswith('GEMINI_API_KEY=') and gemini_key:
            new_config_lines.append(f'GEMINI_API_KEY={gemini_key}\n')
        elif line.startswith('PERPLEXITY_API_KEY=') and perplexity_key:
            new_config_lines.append(f'PERPLEXITY_API_KEY={perplexity_key}\n')
        elif line.startswith('OPENAI_API_KEY=') and openai_key:
            new_config_lines.append(f'OPENAI_API_KEY={openai_key}\n')
        elif line.startswith('BLOG_AUTHOR='):
            new_config_lines.append(f'BLOG_AUTHOR={author}\n')
        elif line.startswith('BLOG_WEBSITE='):
            new_config_lines.append(f'BLOG_WEBSITE={website}\n')
        else:
            new_config_lines.append(line)
    
    # Write updated config
    with open(config_file, 'w') as f:
        f.writelines(new_config_lines)
    
    console.print("✅ Configuration updated!", style="green")

def get_api_key_instructions():
    """Display instructions for getting API keys."""
    
    console.print("\n🔗 How to get API keys:", style="blue bold")
    
    console.print("\n1. 🟢 Google Gemini API (Free for Indians):")
    console.print("   - Visit: https://makersuite.google.com/app/apikey")
    console.print("   - Sign in with Google account")
    console.print("   - Click 'Create API Key'")
    console.print("   - Copy the generated key")
    
    console.print("\n2. 🟣 Perplexity Pro API (Free for Indians):")
    console.print("   - Visit: https://perplexity.ai")
    console.print("   - Sign up for Pro account")
    console.print("   - Go to API settings")
    console.print("   - Generate API key")
    
    console.print("\n3. 🟠 OpenAI ChatGPT API:")
    console.print("   - Visit: https://platform.openai.com/api-keys")
    console.print("   - Sign up/Login to OpenAI")
    console.print("   - Click 'Create new secret key'")
    console.print("   - Copy the generated key")
    console.print("   - Note: This has usage charges after free tier")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "--help-keys":
        get_api_key_instructions()
    else:
        setup_environment()