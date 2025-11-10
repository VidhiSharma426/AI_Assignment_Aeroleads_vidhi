import openai
import os
from typing import Dict, Optional
import logging

class ChatGPTClient:
    """OpenAI ChatGPT API client for content generation."""
    
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.getenv('OPENAI_API_KEY')
        if not self.api_key:
            raise ValueError("OpenAI API key not found. Set OPENAI_API_KEY environment variable.")
        
        # Initialize OpenAI client
        openai.api_key = self.api_key
        self.client = openai.OpenAI(api_key=self.api_key)
        
        logging.info("✅ ChatGPT client initialized successfully")
    
    def generate_article(self, title: str, description: str = "", **kwargs) -> Dict[str, str]:
        """
        Generate a programming article using ChatGPT API.
        
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
            
            # Generate content using ChatGPT
            response = self.client.chat.completions.create(
                model=kwargs.get('model', 'gpt-3.5-turbo'),  # Can use gpt-4 if available
                messages=[
                    {
                        "role": "system",
                        "content": "You are an expert technical writer and senior software developer with extensive experience in creating engaging, comprehensive programming tutorials and articles. You excel at explaining complex concepts clearly and providing practical, real-world examples."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=kwargs.get('temperature', 0.7),
                max_tokens=kwargs.get('max_tokens', 4000),
                top_p=kwargs.get('top_p', 0.9),
            )
            
            content = response.choices[0].message.content
            
            # Extract sections from generated content
            sections = self._parse_generated_content(content)
            
            return {
                'title': title,
                'content': sections.get('content', content),
                'summary': sections.get('summary', ''),
                'tags': sections.get('tags', []),
                'meta_description': sections.get('meta_description', ''),
                'provider': 'chatgpt'
            }
            
        except Exception as e:
            logging.error(f"❌ Error generating content with ChatGPT: {e}")
            return {
                'title': title,
                'content': f"Error generating content: {str(e)}",
                'summary': '',
                'tags': [],
                'meta_description': '',
                'provider': 'chatgpt'
            }
    
    def _build_prompt(self, title: str, description: str) -> str:
        """Build comprehensive prompt for article generation."""
        
        base_prompt = f"""
Create a comprehensive, engaging technical blog article with the title: "{title}"

**ADDITIONAL REQUIREMENTS:** {description if description else "Create a detailed guide suitable for intermediate-level developers with practical examples and real-world applications."}

**OUTPUT FORMAT:**
Please structure your response in the following EXACT format:

---SUMMARY---
[Write a compelling 2-3 sentence summary highlighting the key value and learning outcomes]

---META_DESCRIPTION---
[Create an SEO-optimized meta description (150-160 characters) that would attract developers to click]

---TAGS---
[List 6-8 relevant programming tags, separated by commas - e.g., javascript, react, nodejs, api, tutorial]

---CONTENT---
[Write the complete article content following the structure below]

**ARTICLE STRUCTURE:**

# {title}

## Introduction
- Start with an engaging hook that relates to common developer challenges
- Clearly state what readers will learn and achieve
- Explain the practical value and relevance of this topic
- Provide a brief roadmap of the article

## Prerequisites & Setup
- List any required knowledge or tools
- Include setup instructions if needed
- Link to relevant resources

## Core Concepts Explained
- Break down the fundamental concepts step-by-step
- Use analogies and real-world comparisons when helpful
- Define technical terms clearly
- Build complexity gradually

## Hands-On Implementation
- Provide multiple practical code examples
- Start with basic examples and progress to advanced
- Include complete, runnable code snippets
- Explain each code block thoroughly
- Show different approaches or variations

## Best Practices & Patterns
- Share industry-standard practices
- Explain why certain approaches are preferred
- Include performance considerations
- Discuss maintainability and scalability

## Common Pitfalls & Troubleshooting
- Highlight frequent mistakes developers make
- Provide solutions and debugging strategies
- Include error handling examples
- Share tips for avoiding issues

## Real-World Applications
- Present actual use cases and scenarios
- Include industry examples or case studies
- Discuss when to use vs. when not to use this approach
- Show integration with popular frameworks/tools

## Advanced Techniques (Optional)
- Cover more sophisticated implementations
- Discuss optimization strategies
- Show integration with other technologies
- Include performance benchmarks if relevant

## Conclusion & Next Steps
- Summarize key takeaways and benefits
- Suggest logical next learning steps
- Recommend additional resources
- Encourage readers to experiment and practice

**WRITING GUIDELINES:**
- Target audience: Intermediate developers (2-5 years experience)
- Article length: 2000-2500 words
- Tone: Professional but conversational and engaging
- Include 5-7 practical code examples with detailed explanations
- Use proper markdown formatting throughout
- Include inline code with `backticks` for short snippets
- Use code blocks with ```language syntax for longer examples
- Add comments to all code examples
- Ensure all examples are functional and tested
- Include tips, warnings, or notes where appropriate
- Make content actionable and immediately useful

**CODE REQUIREMENTS:**
- Show complete, working examples (not just fragments)
- Include all necessary imports and dependencies
- Use meaningful variable and function names
- Add comprehensive comments explaining the logic
- Include error handling where appropriate
- Demonstrate both basic and advanced usage patterns
- Show realistic, practical scenarios

Please generate the complete article following this exact structure and format.
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
        """Test if the ChatGPT API connection works."""
        try:
            response = self.client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "user", "content": "Test connection - respond with 'OK'"}
                ],
                max_tokens=10
            )
            return bool(response.choices[0].message.content)
        except Exception as e:
            logging.error(f"❌ ChatGPT connection test failed: {e}")
            return False