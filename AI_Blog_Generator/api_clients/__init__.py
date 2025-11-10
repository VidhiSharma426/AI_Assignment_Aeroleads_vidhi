"""
AI Blog Generator API Clients Package

This package contains client implementations for various AI APIs:
- Gemini (Google): Free for Indians, excellent for technical content
- Perplexity Pro: Free for Indians, great for research-heavy content  
- ChatGPT (OpenAI): Paid service, excellent for creative content

Usage:
    from api_clients.gemini_client import GeminiClient
    from api_clients.perplexity_client import PerplexityClient
    from api_clients.chatgpt_client import ChatGPTClient
"""

__version__ = "1.0.0"
__author__ = "AI Blog Generator"

from .gemini_client import GeminiClient
from .perplexity_client import PerplexityClient  
from .chatgpt_client import ChatGPTClient

__all__ = [
    'GeminiClient',
    'PerplexityClient', 
    'ChatGPTClient'
]