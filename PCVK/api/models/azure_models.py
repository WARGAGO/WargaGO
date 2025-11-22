"""
Pydantic models for request/response validation
"""

from typing import Dict, List, Optional, Union, Any
from pydantic import BaseModel


class StorageResponse(BaseModel):
    """Response model for storage operations"""

    success: bool
    blob_name: Optional[str] = None
    blob_url: Optional[str] = None
    message: Optional[str] = None


class UserImagesResponse(BaseModel):
    """Response model for user images list"""

    user_id: str
    count: int
    images: List[Dict[str, str]]
