"""
OCR Response Models
"""

from typing import List, Optional
from pydantic import BaseModel


class OCRResult(BaseModel):
    """Single OCR detection result"""

    text: str
    confidence: float
    bbox: List[List[float]]


class OCRResponse(BaseModel):
    """Response model for OCR endpoint"""

    filename: str
    results: List[OCRResult]
    processing_time_ms: float
    num_detections: int


class OCRHealthResponse(BaseModel):
    """Response model for OCR health check endpoint"""

    status: str
    model_loaded: bool
    detection_model: str
    recognition_model: str
