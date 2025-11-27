from typing import Dict, List, Optional, Union, Any
from pydantic import BaseModel


class PredictionResponse(BaseModel):
    """Response model for prediction endpoint"""

    filename: str
    predicted_class: str
    confidence: float
    all_confidences: Dict[str, float]
    device: str
    model_type: str
    segmentation_used: bool
    segmentation_method: Optional[str]
    apply_brightness_contrast: bool
    prediction_time_ms: float


class HealthResponse(BaseModel):
    """Response model for health check endpoint"""

    status: str
    device: str
    num_classes: int
    class_names: List[str]
    available_models: List[str]


class ClassesResponse(BaseModel):
    """Response model for classes endpoint"""

    classes: List[str]


class ModelInfo(BaseModel):
    """Information about a single model"""

    loaded: bool
    architecture: Optional[str] = None
    hidden_layers: Optional[str] = None
    dropout: Optional[Union[float, str]] = None
    features: Optional[List[str]] = None


class ModelsInfoResponse(BaseModel):
    """Response model for models info endpoint"""

    available_models: List[str]
    total_models: int
    models: Dict[str, ModelInfo]


class BatchPredictionResult(PredictionResponse):
    """Single result in batch prediction"""

    error: Optional[str] = None


class BatchPredictionResponse(BaseModel):
    """Response model for batch prediction endpoint"""

    results: List[BatchPredictionResult]
    total_time_ms: float


class UnloadModelResponse(BaseModel):
    """Response model for unload model endpoint"""

    success: bool
    message: str
    unloaded_models: List[str]
    remaining_models: List[str]
