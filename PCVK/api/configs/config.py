"""
Configuration settings for the FastAPI application
"""

# API configuration
API_TITLE = "Vegetable Classification API"
API_DESCRIPTION = "API untuk klasifikasi sayuran menggunakan MLP dengan ekstraksi fitur"
API_VERSION = "1.0.0"

# Server configuration
SERVER_HOST = "0.0.0.0"
SERVER_PORT = 8000

# CORS configuration
CORS_ORIGINS = ["*"]  # Adjust this in production
CORS_CREDENTIALS = True
CORS_METHODS = ["*"]
CORS_HEADERS = ["*"]
