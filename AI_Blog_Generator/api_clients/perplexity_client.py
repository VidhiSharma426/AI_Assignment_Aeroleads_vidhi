import httpx
import os
import json
from typing import Dict, Optional
import logging

class PerplexityClient:
    """Perplexity Pro API client for content generation."""
    
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.getenv('PERPLEXITY_API_KEY')
        if not self.api_key:
            raise ValueError("Perplexity API key not found. Set PERPLEXITY_API_KEY environment variable.")
        
        self.base_url = "https://api.perplexity.ai/chat/completions"
        self.headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        logging.info("✅ Perplexity client initialized successfully")
    
    def generate_article(self, title: str, description: str = "", **kwargs) -> Dict[str, str]:
        """
        Generate a programming article using Perplexity API.
        
        Args:
            title: Article title
            description: Optional description or requirements
            **kwargs: Additional parameters (temperature, max_tokens, etc.)
        
        Returns:
            Dict with 'content', 'title', 'summary' keys
        """
        try:
            # Construct comprehensive prompt
            prompt = self._build_prompt(title, description)
            
            # Prepare request payload
            payload = {
                "model": "llama-3.1-sonar-large-128k-online",  # Perplexity's most capable model
                "messages": [
                    {
                        "role": "system",
                        "content": "You are an expert technical writer and software developer with deep knowledge of programming concepts, best practices, and real-world applications. You write engaging, comprehensive, and practical blog articles for developers."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                "temperature": kwargs.get('temperature', 0.7),
                "max_tokens": kwargs.get('max_tokens', 4000),
                "top_p": kwargs.get('top_p', 0.9),
                "stream": False
            }
            
            # Make API request
            with httpx.Client(timeout=60.0) as client:
                response = client.post(self.base_url, headers=self.headers, json=payload)
                response.raise_for_status()
                
                data = response.json()
                content = data['choices'][0]['message']['content']
                
                # Extract sections from generated content
                sections = self._parse_generated_content(content)
                
                return {
                    'title': title,
                    'content': sections.get('content', content),
                    'summary': sections.get('summary', ''),
                    'tags': sections.get('tags', []),
                    'meta_description': sections.get('meta_description', ''),
                    'provider': 'perplexity'
                }
                
        except Exception as e:
            logging.error(f"❌ Error generating content with Perplexity: {e}")
            return {
                'title': title,
                'content': f"Error generating content: {str(e)}",
                'summary': '',
                'tags': [],
                'meta_description': '',
                'provider': 'perplexity'
            }
    
    def _build_prompt(self, title: str, description: str) -> str:
        """Build comprehensive prompt for article generation."""
        
        base_prompt = f"""
Write a comprehensive, engaging technical blog article about: "{title}"

**ADDITIONAL CONTEXT:** {description if description else "Write a comprehensive guide suitable for intermediate developers with practical examples."}

**RESPONSE FORMAT:**
Structure your response EXACTLY as follows:

---SUMMARY---
[2-3 sentence compelling summary of what readers will learn]

---META_DESCRIPTION---
[SEO-optimized meta description, 150-160 characters]

---TAGS---
[5-8 relevant programming tags, comma-separated]

---CONTENT---
[Main article content following the structure below]

**ARTICLE STRUCTURE:**

# {title}

## Introduction
- Engaging hook that captures attention
- Clear explanation of why this topic is important
- Brief overview of what readers will accomplish

## Background & Context
- Relevant background information
- When and why this technology/concept is used
- Prerequisites or assumed knowledge

## Core Concepts
- Detailed explanation of key concepts
- Step-by-step breakdowns of complex ideas
- Clear definitions of technical terms

## Practical Implementation
- Multiple working code examples with explanations
- Real-world scenarios and use cases
- Best practices and common patterns

## Advanced Techniques
- More sophisticated implementations
- Performance optimizations
- Integration with other technologies

## Common Pitfalls & Solutions
- Frequent mistakes developers make
- How to avoid or fix these issues
- Debugging tips and strategies

## Real-World Applications
- Industry use cases and examples
- Success stories or case studies
- Scalability considerations

## Conclusion & Next Steps
- Key takeaways summary
- Recommended learning path
- Additional resources for further exploration

**CONTENT REQUIREMENTS:**
- Target audience: Intermediate developers
- Length: 1800-2500 words
- Include 4-6 practical code examples with comments
- Use proper markdown formatting
- Include inline code snippets with `backticks`
- Add code blocks with ```language syntax
- Write in conversational, engaging tone
- Include actionable advice and tips
- Ensure all code examples are functional and well-explained

**CODE EXAMPLE GUIDELINES:**
- Show complete, runnable examples
- Include necessary imports and setup
- Add comprehensive comments
- Use meaningful variable names
- Demonstrate both basic and advanced usage
- Include error handling where appropriate

Generate the complete article now with the exact format specified above.
"""
        
        return base_prompt
    
    def _parse_generated_content(self, content: str) -> Dict[str, str]:
        """Parse the generated content into structured sections."""
        sections = {}
        
        try:
            # Split by section markers
            if "---SUMMARY---" in content:
                parts = content.split("---SUMMARY---")
                if len(parts) > 1:
                    summary_part = parts[1].split("---META_DESCRIPTION---")[0].strip()
                    sections['summary'] = summary_part
            
            if "---META_DESCRIPTION---" in content:
                parts = content.split("---META_DESCRIPTION---")
                if len(parts) > 1:
                    meta_part = parts[1].split("---TAGS---")[0].strip()
                    sections['meta_description'] = meta_part
            
            if "---TAGS---" in content:
                parts = content.split("---TAGS---")
                if len(parts) > 1:
                    tags_part = parts[1].split("---CONTENT---")[0].strip()
                    sections['tags'] = [tag.strip() for tag in tags_part.split(',')]
            
            if "---CONTENT---" in content:
                parts = content.split("---CONTENT---")
                if len(parts) > 1:
                    sections['content'] = parts[1].strip()
            
            # If no structured format, use entire content
            if not sections.get('content'):
                sections['content'] = content
                
        except Exception as e:
            logging.warning(f"⚠️ Error parsing content structure: {e}")
            sections['content'] = content
        
        return sections

    def test_connection(self) -> bool:
        """Test if the Perplexity API connection works."""
        try:
            payload = {
                "model": "llama-3.1-sonar-large-128k-online",
                "messages": [
                    {"role": "user", "content": "Test connection - respond with 'OK'"}
                ],
                "max_tokens": 10
            }
            
            with httpx.Client(timeout=30.0) as client:
                response = client.post(self.base_url, headers=self.headers, json=payload)
                response.raise_for_status()
                return True
                
        except Exception as e:
            logging.error(f"❌ Perplexity connection test failed: {e}")
            return False