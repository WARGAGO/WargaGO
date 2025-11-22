"""
Azure Configuration for Blob Storage and Firebase Authentication
"""

import base64
import json
import os
from pathlib import Path


# Azure Blob Storage Configuration
AZURE_STORAGE_CONNECTION_STRING = os.getenv("AZURE_STORAGE_CONNECTION_STRING", "")
AZURE_STORAGE_CONTAINER_NAME = os.getenv("AZURE_STORAGE_CONTAINER_NAME", "vegetable-images")

# Firebase Configuration
FIREBASE_CREDENTIALS = None

firebase_base64 = os.getenv("FIREBASE_CREDENTIALS_BASE64")
if firebase_base64:
    try:
        decoded_bytes = base64.b64decode(firebase_base64)
        FIREBASE_CREDENTIALS = json.loads(decoded_bytes)
    except Exception as e:
        print(f"Failed to load Firebase from Base64: {e}")
else:
    print("FIREBASE_CREDENTIALS_BASE64 not set in environment")

# Image Storage Configuration
ALLOWED_IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}
MAX_IMAGE_SIZE_MB = 10
WEBP_QUALITY = 85  # Quality for WebP conversion (1-100)

# Validate configuration
def validate_azure_config() -> bool:
    """Validate Azure configuration"""    
    if not AZURE_STORAGE_CONTAINER_NAME:
        print("WARNING: Azure Storage container name not configured")
        return False
    
    return True


def validate_firebase_config() -> bool:
    """Validate Firebase configuration"""    
    if FIREBASE_CREDENTIALS is None:
        print(f"WARNING: Firebase credentials are not set")
        return False
    
    return True
