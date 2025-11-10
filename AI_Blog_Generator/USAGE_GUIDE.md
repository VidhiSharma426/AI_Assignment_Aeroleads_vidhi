# 🤖 AI Blog Generator - Complete Usage Guide

## 🚀 Quick Start

### 1. Setup
```bash
cd AI_Blog_Generator
python setup.py                    # Setup environment and dependencies
python setup.py --help-keys       # Get API key instructions
```

### 2. Configure API Keys
Edit `config/api_keys.env` with your actual API keys:
```env
GEMINI_API_KEY=your_actual_gemini_key
PERPLEXITY_API_KEY=your_actual_perplexity_key
OPENAI_API_KEY=your_actual_openai_key
DEFAULT_AI_PROVIDER=gemini
```

### 3. Test Connections
```bash
python blog_generator.py --test
```

### 4. Generate Sample Articles
```bash
python blog_generator.py --sample --provider gemini
```

## 📝 Usage Modes

### 🎯 Interactive Mode (Recommended for Beginners)
```bash
python blog_generator.py --interactive
```
- Step-by-step article creation
- Enter multiple article titles
- Choose AI provider
- Automatic generation and saving

### 📚 Sample Articles Mode
```bash
python blog_generator.py --sample --provider gemini
```
Generates 10 pre-defined programming articles:
- FastAPI REST APIs
- React Hooks Deep Dive
- Docker for Node.js
- Advanced JavaScript Async
- Spring Boot Microservices
- GraphQL vs REST
- ML Model Deployment
- CSS Grid & Flexbox
- Database Design Patterns
- GitHub Actions CI/CD

### 🎯 Single Article Mode
```bash
python blog_generator.py --title "Your Article Title" --description "Optional description" --provider gemini
```

### 📋 Custom Article List
Create a JSON file with your articles:
```json
[
  {
    "title": "Building Modern Web Apps with Vue.js 3",
    "description": "Complete guide covering Composition API, reactive data, component design, routing, state management with Pinia, and deployment strategies."
  },
  {
    "title": "Python Data Science: Pandas and NumPy Essentials", 
    "description": "Comprehensive tutorial on data manipulation, analysis, visualization, and statistical operations with practical examples and real datasets."
  }
]
```

Then modify `blog_generator.py` to load your custom list.

## 🔧 AI Provider Options

### 🟢 Gemini (Google) - **Recommended**
- **Free for Indians** ✅
- **Best for**: Technical content, code examples
- **Strengths**: Accurate code, good explanations
- **Setup**: Get key from https://makersuite.google.com/app/apikey

### 🟣 Perplexity Pro
- **Free for Indians** ✅
- **Best for**: Research-heavy content, current information
- **Strengths**: Up-to-date info, citations
- **Setup**: Sign up at https://perplexity.ai

### 🟠 ChatGPT (OpenAI)
- **Paid after free tier** 💰
- **Best for**: Creative content, conversational tone
- **Strengths**: Natural language, creativity
- **Setup**: Get key from https://platform.openai.com/api-keys

## 📁 Output Structure

Generated articles are saved in `generated_articles/` as:

```
generated_articles/
├── 20240115_143022_building_restful_apis_with_fastapi.json    # Raw data
├── 20240115_143022_building_restful_apis_with_fastapi.md      # Markdown
├── 20240115_143022_building_restful_apis_with_fastapi.html    # Ready-to-publish HTML
└── blog_generator.log                                         # Generation logs
```

### 📄 File Formats

**JSON**: Complete article data including metadata
**Markdown**: Clean markdown for platforms like GitHub, Dev.to
**HTML**: Beautiful, responsive web pages ready for hosting

## 🎨 Customization

### 🖼️ HTML Template
Edit `templates/blog_template.html` to customize:
- Styling and colors
- Layout structure  
- Social sharing buttons
- Author information
- SEO meta tags

### 📝 Content Prompts
Modify prompts in API client files:
- `api_clients/gemini_client.py`
- `api_clients/perplexity_client.py`
- `api_clients/chatgpt_client.py`

### ⚙️ Generation Settings
Edit `config/api_keys.env`:
```env
MAX_TOKENS=4000         # Article length
TEMPERATURE=0.7         # Creativity level (0.0-1.0)
TOP_P=0.9              # Response diversity
OUTPUT_FORMAT=html      # html, markdown, or both
```

## 🔨 Advanced Usage

### 🧪 Batch Processing
Create a Python script to process multiple article lists:

```python
from blog_generator import BlogGenerator

generator = BlogGenerator()

# Load articles from multiple sources
tech_articles = load_json('tech_articles.json')
tutorial_articles = load_json('tutorial_articles.json')

# Generate with different providers
generator.generate_batch_articles(tech_articles, 'gemini')
generator.generate_batch_articles(tutorial_articles, 'perplexity')
```

### 📊 Analytics & Monitoring
Check `generated_articles/blog_generator.log` for:
- Generation success rates
- API response times
- Error details
- Usage statistics

### 🔄 Automation
Set up scheduled generation with cron jobs:
```bash
# Generate daily articles at 9 AM
0 9 * * * cd /path/to/AI_Blog_Generator && python blog_generator.py --sample
```

## 🎯 Best Practices

### 📝 Writing Effective Prompts
- **Be specific**: Include target audience, article length, key topics
- **Add context**: Mention related technologies, use cases
- **Request structure**: Ask for specific sections, examples, code snippets

Example:
```
"Building REST APIs with FastAPI: Complete guide for intermediate Python developers including authentication, database integration with SQLAlchemy, testing with pytest, and deployment on AWS. Include 5+ code examples."
```

### 🔍 Content Quality Tips
1. **Review generated content** before publishing
2. **Test code examples** to ensure they work
3. **Add personal insights** and experiences
4. **Update links and references** for accuracy
5. **Optimize for SEO** with proper meta descriptions

### ⚡ Performance Optimization
- Use **Gemini for technical content** (faster, free)
- Use **Perplexity for research-heavy** topics
- **Batch generate** multiple articles to optimize API calls
- **Cache results** to avoid regenerating similar content

## 🐛 Troubleshooting

### Common Issues

**❌ "No AI clients available"**
- Check API keys in `config/api_keys.env`
- Ensure keys are valid and active
- Test individual connections with `--test`

**❌ "Rate limit exceeded"**
- Switch to different AI provider
- Add delays between requests
- Check API quotas and limits

**❌ "Template not found"**
- Ensure `templates/blog_template.html` exists
- Check file permissions
- Reinstall with `python setup.py`

**❌ "Poor content quality"**
- Improve article descriptions and prompts
- Try different AI providers
- Adjust temperature settings (lower = more focused)

### 🔧 Debug Mode
Enable detailed logging:
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

## 🌐 Integration Ideas

### 📱 Blog Platforms
- **WordPress**: Use generated HTML/markdown
- **Ghost**: Import markdown files
- **Gatsby/Next.js**: Use JSON data for static sites
- **Dev.to**: Publish markdown directly

### 🔗 Workflow Integration
- **GitHub Actions**: Auto-generate and commit articles
- **Zapier**: Trigger generation from spreadsheets
- **Discord/Slack**: Generate articles from chat commands
- **CMS Integration**: Auto-populate content management systems

## 📈 Scaling Up

### 🏭 Enterprise Usage
- Set up dedicated API keys for each team member
- Implement content review workflows
- Create custom templates for brand consistency
- Set up automated publishing pipelines

### 📊 Content Strategy
- Generate article series on related topics
- Create different content types (tutorials, reviews, news)
- Target different skill levels (beginner, intermediate, advanced)
- Cover trending technologies and frameworks

---

## 🎉 You're Ready to Generate!

Start with:
```bash
python blog_generator.py --interactive
```

Happy blogging! 🚀✨