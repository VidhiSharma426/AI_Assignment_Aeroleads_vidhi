#!/usr/bin/env python3
"""
AI Blog Generator - Automated Programming Blog Content Creation
Supports Gemini, Perplexity Pro, and ChatGPT APIs
"""

import os
import sys
import json
import logging
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional
import markdown
from jinja2 import Environment, FileSystemLoader
from dotenv import load_dotenv
import click
from rich.console import Console
from rich.table import Table
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.prompt import Prompt, Confirm

# Add current directory to path for imports
sys.path.append(str(Path(__file__).parent))

# Import API clients
from api_clients.gemini_client import GeminiClient
from api_clients.perplexity_client import PerplexityClient
from api_clients.chatgpt_client import ChatGPTClient

# Initialize rich console
console = Console()

class BlogGenerator:
    """Main blog generation class."""
    
    def __init__(self, config_dir: str = "config"):
        self.config_dir = Path(config_dir)
        self.output_dir = Path("generated_articles")
        self.templates_dir = Path("templates")
        
        # Create directories
        self.output_dir.mkdir(exist_ok=True)
        self.config_dir.mkdir(exist_ok=True)
        
        # Load environment variables
        env_file = self.config_dir / "api_keys.env"
        if env_file.exists():
            load_dotenv(env_file)
        
        # Setup logging
        self._setup_logging()
        
        # Initialize clients
        self.clients = {}
        self._initialize_clients()
        
        # Setup Jinja2 for templates
        self.jinja_env = Environment(loader=FileSystemLoader(self.templates_dir))
        
        console.print("🤖 AI Blog Generator initialized!", style="green bold")
    
    def _setup_logging(self):
        """Setup logging configuration."""
        log_file = self.output_dir / "blog_generator.log"
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def _initialize_clients(self):
        """Initialize available AI clients."""
        console.print("🔧 Initializing AI clients...", style="yellow")
        
        # Try to initialize each client
        try:
            self.clients['gemini'] = GeminiClient()
            console.print("✅ Gemini client ready", style="green")
        except Exception as e:
            console.print(f"❌ Gemini client failed: {e}", style="red")
        
        try:
            self.clients['perplexity'] = PerplexityClient()
            console.print("✅ Perplexity client ready", style="green")
        except Exception as e:
            console.print(f"❌ Perplexity client failed: {e}", style="red")
        
        try:
            self.clients['chatgpt'] = ChatGPTClient()
            console.print("✅ ChatGPT client ready", style="green")
        except Exception as e:
            console.print(f"❌ ChatGPT client failed: {e}", style="red")
        
        if not self.clients:
            console.print("❌ No AI clients available! Please check your API keys.", style="red bold")
            sys.exit(1)
    
    def test_connections(self):
        """Test all AI client connections."""
        console.print("\n🧪 Testing AI client connections...", style="yellow bold")
        
        results = {}
        for name, client in self.clients.items():
            try:
                with console.status(f"Testing {name}..."):
                    result = client.test_connection()
                    results[name] = result
                    status = "✅ Working" if result else "❌ Failed"
                    console.print(f"{name.title()}: {status}")
            except Exception as e:
                results[name] = False
                console.print(f"{name.title()}: ❌ Error - {e}")
        
        return results
    
    def generate_single_article(self, title: str, description: str = "", provider: str = None) -> Dict:
        """Generate a single article."""
        # Choose provider
        if not provider:
            provider = os.getenv('DEFAULT_AI_PROVIDER', 'gemini')
        
        if provider not in self.clients:
            available = list(self.clients.keys())
            console.print(f"❌ Provider '{provider}' not available. Using '{available[0]}'", style="yellow")
            provider = available[0]
        
        client = self.clients[provider]
        
        console.print(f"📝 Generating article with {provider.title()}...", style="blue")
        
        try:
            # Generate article
            with console.status(f"Generating '{title}'..."):
                article_data = client.generate_article(title, description)
            
            # Add metadata
            article_data.update({
                'generated_at': datetime.now().isoformat(),
                'provider': provider,
                'author': os.getenv('BLOG_AUTHOR', 'AI Blog Generator'),
                'website': os.getenv('BLOG_WEBSITE', 'https://yourblog.com')
            })
            
            # Convert markdown to HTML
            article_data['content_html'] = markdown.markdown(
                article_data['content'],
                extensions=['codehilite', 'fenced_code', 'tables', 'toc']
            )
            
            # Save article
            self._save_article(article_data)
            
            console.print(f"✅ Generated: {title}", style="green")
            return article_data
            
        except Exception as e:
            self.logger.error(f"Error generating article '{title}': {e}")
            console.print(f"❌ Failed to generate '{title}': {e}", style="red")
            return None
    
    def generate_batch_articles(self, article_list: List[Dict], provider: str = None) -> List[Dict]:
        """Generate multiple articles from a list."""
        console.print(f"\n🚀 Generating {len(article_list)} articles...", style="blue bold")
        
        results = []
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console
        ) as progress:
            
            task = progress.add_task("Generating articles...", total=len(article_list))
            
            for i, article_info in enumerate(article_list, 1):
                title = article_info.get('title', '')
                description = article_info.get('description', '')
                
                progress.update(task, description=f"[{i}/{len(article_list)}] {title[:50]}...")
                
                result = self.generate_single_article(title, description, provider)
                if result:
                    results.append(result)
                
                progress.advance(task)
        
        console.print(f"\n✅ Successfully generated {len(results)}/{len(article_list)} articles!", style="green bold")
        return results
    
    def _save_article(self, article_data: Dict):
        """Save article to files."""
        # Create safe filename
        safe_title = "".join(c for c in article_data['title'] if c.isalnum() or c in (' ', '-', '_')).rstrip()
        safe_title = safe_title.replace(' ', '_').lower()
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{timestamp}_{safe_title}"
        
        # Save as JSON
        json_file = self.output_dir / f"{filename}.json"
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump(article_data, f, indent=2, ensure_ascii=False)
        
        # Save as Markdown
        md_file = self.output_dir / f"{filename}.md"
        with open(md_file, 'w', encoding='utf-8') as f:
            f.write(f"# {article_data['title']}\n\n")
            f.write(f"**Generated:** {article_data['generated_at']}\n")
            f.write(f"**Provider:** {article_data['provider'].title()}\n")
            f.write(f"**Tags:** {', '.join(article_data.get('tags', []))}\n\n")
            if article_data.get('summary'):
                f.write(f"**Summary:** {article_data['summary']}\n\n")
            f.write("---\n\n")
            f.write(article_data['content'])
        
        # Save as HTML using template
        try:
            template = self.jinja_env.get_template('blog_template.html')
            html_content = template.render(
                title=article_data['title'],
                content_html=article_data['content_html'],
                summary=article_data.get('summary', ''),
                tags=article_data.get('tags', []),
                meta_description=article_data.get('meta_description', ''),
                author=article_data.get('author', 'AI Blog Generator'),
                provider=article_data.get('provider', 'AI'),
                date=datetime.now().strftime("%B %d, %Y"),
                current_year=datetime.now().year,
                url=f"#{safe_title}"
            )
            
            html_file = self.output_dir / f"{filename}.html"
            with open(html_file, 'w', encoding='utf-8') as f:
                f.write(html_content)
                
        except Exception as e:
            self.logger.warning(f"Could not generate HTML: {e}")
    
    def interactive_mode(self):
        """Interactive mode for article generation."""
        console.print("\n🎯 Interactive Article Generation Mode", style="blue bold")
        
        articles = []
        
        while True:
            console.print("\n📝 Enter article details:")
            
            title = Prompt.ask("Article title")
            if not title:
                break
                
            description = Prompt.ask("Description/requirements (optional)", default="")
            
            articles.append({
                'title': title,
                'description': description
            })
            
            if not Confirm.ask("Add another article?"):
                break
        
        if articles:
            # Choose provider
            available_providers = list(self.clients.keys())
            if len(available_providers) > 1:
                console.print(f"\nAvailable providers: {', '.join(available_providers)}")
                provider = Prompt.ask("Choose provider", choices=available_providers, default=available_providers[0])
            else:
                provider = available_providers[0]
            
            # Generate articles
            self.generate_batch_articles(articles, provider)
        else:
            console.print("No articles to generate.", style="yellow")

def load_sample_articles():
    """Load sample programming article ideas."""
    return [
        {
            "title": "Building RESTful APIs with FastAPI and Python",
            "description": "Complete guide covering FastAPI setup, routing, authentication, database integration, and deployment. Include practical examples with SQLAlchemy and Pydantic."
        },
        {
            "title": "React Hooks Deep Dive: useState, useEffect, and Custom Hooks",
            "description": "Comprehensive tutorial on React Hooks with practical examples, best practices, and common pitfalls. Show real-world use cases and performance optimization."
        },
        {
            "title": "Docker Containerization for Node.js Applications",
            "description": "Step-by-step guide to containerizing Node.js apps with Docker, including multi-stage builds, optimization, and Docker Compose for development."
        },
        {
            "title": "Advanced JavaScript: Promises, Async/Await, and Error Handling",
            "description": "Deep dive into asynchronous JavaScript patterns, error handling strategies, and performance considerations. Include practical examples and best practices."
        },
        {
            "title": "Building Scalable Microservices with Spring Boot",
            "description": "Complete guide to creating microservices architecture using Spring Boot, including service discovery, API gateway, and distributed tracing."
        },
        {
            "title": "GraphQL vs REST: When to Use Which API Design",
            "description": "Detailed comparison of GraphQL and REST APIs, with implementation examples, performance considerations, and decision framework for choosing the right approach."
        },
        {
            "title": "Machine Learning Model Deployment with Python and AWS",
            "description": "Practical guide to deploying ML models using Flask, FastAPI, Docker, and AWS services. Include monitoring, scaling, and CI/CD pipelines."
        },
        {
            "title": "Modern CSS Grid and Flexbox Layout Techniques",
            "description": "Comprehensive guide to CSS Grid and Flexbox with practical examples, responsive design patterns, and browser compatibility considerations."
        },
        {
            "title": "Database Design Patterns: SQL vs NoSQL Decision Guide",
            "description": "Deep dive into database design patterns, when to use SQL vs NoSQL, schema design best practices, and performance optimization strategies."
        },
        {
            "title": "CI/CD Pipeline Automation with GitHub Actions",
            "description": "Complete guide to setting up automated CI/CD pipelines using GitHub Actions, including testing, building, deployment, and monitoring strategies."
        }
    ]

@click.command()
@click.option('--provider', type=click.Choice(['gemini', 'perplexity', 'chatgpt']), help='AI provider to use')
@click.option('--interactive', '-i', is_flag=True, help='Interactive mode')
@click.option('--sample', is_flag=True, help='Generate sample articles')
@click.option('--test', is_flag=True, help='Test API connections')
@click.option('--title', help='Single article title')
@click.option('--description', help='Single article description')
def main(provider, interactive, sample, test, title, description):
    """AI Blog Generator - Create programming articles with AI."""
    
    console.print("🤖 AI Blog Generator", style="blue bold")
    console.print("=" * 50, style="blue")
    
    # Initialize generator
    generator = BlogGenerator()
    
    # Test connections if requested
    if test:
        generator.test_connections()
        return
    
    # Interactive mode
    if interactive:
        generator.interactive_mode()
        return
    
    # Generate sample articles
    if sample:
        console.print("📚 Generating sample programming articles...", style="green")
        articles = load_sample_articles()
        generator.generate_batch_articles(articles, provider)
        return
    
    # Single article mode
    if title:
        generator.generate_single_article(title, description or "", provider)
        return
    
    # Default: show help and options
    console.print("\n🎯 Choose an option:", style="yellow bold")
    console.print("1. Run with --interactive for step-by-step article creation")
    console.print("2. Run with --sample to generate 10 sample programming articles")
    console.print("3. Run with --test to test API connections")
    console.print("4. Run with --title 'Your Title' for single article generation")
    console.print("\nExample: python blog_generator.py --sample --provider gemini")

if __name__ == "__main__":
    main()