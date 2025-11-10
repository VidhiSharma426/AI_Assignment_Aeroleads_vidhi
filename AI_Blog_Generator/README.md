# 🤖 AI Blog Generator

An automated blog content generation system that creates programming articles using AI APIs.

## 🚀 Features

- **Multiple AI Providers**: Supports Gemini, Perplexity Pro, and ChatGPT APIs
- **Batch Generation**: Generate multiple articles from a list of titles
- **Structured Output**: Creates organized blog posts with proper formatting
- **Web Integration**: Ready-to-use HTML templates for web deployment
- **Customizable Prompts**: Tailored prompts for programming content

## 📁 Structure

```
AI_Blog_Generator/
├── blog_generator.py          # Main blog generation script
├── api_clients/              # API client implementations
│   ├── gemini_client.py      # Google Gemini API client
│   ├── perplexity_client.py  # Perplexity Pro API client
│   └── chatgpt_client.py     # OpenAI ChatGPT API client
├── templates/                # HTML templates for blog posts
├── generated_articles/       # Output directory for articles
├── config/                   # Configuration files
└── requirements.txt          # Python dependencies
```

## 🛠️ Setup

1. Install dependencies: `pip install -r requirements.txt`
2. Configure API keys in `config/api_keys.env`
3. Run: `python blog_generator.py`

## 📝 Usage

Simply provide a list of article titles and the system will generate complete blog posts!