import google.generativeai as genai
import os
from typing import Dict, Optional
import logging

class GeminiClient:
    """Google Gemini API client for content generation."""
    
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.getenv('GEMINI_API_KEY')
        if not self.api_key:
            raise ValueError("Gemini API key not found. Set GEMINI_API_KEY environment variable.")
        
        # Configure Gemini
        genai.configure(api_key=self.api_key)
        # Try the latest available models
        try:
            self.model = genai.GenerativeModel('gemini-2.5-flash')
        except:
            try:
                self.model = genai.GenerativeModel('gemini-pro')
            except:
                # Fallback to basic model
                self.model = genai.GenerativeModel('models/text-bison-001')
        
        logging.info("✅ Gemini client initialized successfully")
    
    def generate_article(self, title: str, description: str = "", **kwargs) -> Dict[str, str]:
        """
        Generate a programming article using Gemini API.
        
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
            
            # Generate content
            response = self.model.generate_content(
                prompt,
                generation_config=genai.types.GenerationConfig(
                    temperature=kwargs.get('temperature', 0.7),
                    max_output_tokens=kwargs.get('max_tokens', 4000),
                    top_p=kwargs.get('top_p', 0.9),
                )
            )
            
            content = response.text
            
            # Extract sections from generated content
            sections = self._parse_generated_content(content)
            
            return {
                'title': title,
                'content': sections.get('content', content),
                'summary': sections.get('summary', ''),
                'tags': sections.get('tags', []),
                'meta_description': sections.get('meta_description', ''),
                'provider': 'gemini'
            }
            
        except Exception as e:
            logging.error(f"❌ Error generating content with Gemini: {e}")
            return {
                'title': title,
                'content': f"Error generating content: {str(e)}",
                'summary': '',
                'tags': [],
                'meta_description': '',
                'provider': 'gemini'
            }
    
    def _build_prompt(self, title: str, description: str) -> str:
        """Build comprehensive prompt for article generation."""
        
        base_prompt = f"""
You are an expert technical writer specializing in programming and software development. 
Write a comprehensive, engaging blog article with the following specifications:

**ARTICLE TITLE:** {title}

**ADDITIONAL REQUIREMENTS:** {description if description else "Write a comprehensive guide suitable for intermediate developers."}

**STRUCTURE REQUIREMENTS:**
Please structure your response EXACTLY as follows:

---SUMMARY---
[Write a compelling 2-3 sentence summary of what readers will learn]

---META_DESCRIPTION---
[Write a 150-160 character SEO meta description]

---TAGS---
[List 5-8 relevant tags separated by commas: programming, python, javascript, etc.]

---CONTENT---
[Write the main article content here following these guidelines:]

# {title}

## Introduction
- Hook the reader with an interesting opening
- Explain why this topic matters
- Preview what they'll learn

## Main Content Sections
- Use clear headings (##, ###)
- Include practical code examples with syntax highlighting
- Add real-world use cases
- Explain complex concepts step-by-step
- Include best practices and common pitfalls

## Code Examples
- Provide working, well-commented code
- Use realistic examples
- Show both basic and advanced implementations
- Include error handling where appropriate

## Practical Applications
- Real-world scenarios where this is useful
- Industry use cases
- Performance considerations

## Conclusion
- Summarize key takeaways
- Suggest next steps for learning
- Encourage experimentation

**CONTENT GUIDELINES:**
- Write in a conversational, engaging tone
- Target intermediate-level developers
- Include 3-5 practical code examples
- Make it actionable and informative
- Length: 1500-2500 words
- Use markdown formatting for code blocks
- Include inline code snippets where relevant
- Add tips, warnings, or notes in callout format

**CODE FORMATTING:**
- Use ```language syntax for code blocks
- Include comments in code examples
- Show imports and complete examples
- Use realistic variable names

Generate the article now:
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
        """Test if the Gemini API connection works."""
        try:
            response = self.model.generate_content("Test connection")
            return bool(response.text)
        except Exception as e:
            logging.error(f"❌ Gemini connection test failed: {e}")
            return False