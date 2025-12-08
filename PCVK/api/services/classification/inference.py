"""
Inference logic for vegetable classification
"""

import cv2
import numpy as np
import torch
import torchvision.transforms as T
from PIL import Image
import sys
import os
from typing import Tuple, Dict, Union

# Add lib directory to path
lib_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'lib')
if lib_path not in sys.path:
    sys.path.append(lib_path)

from lib.extract_features import extract_all_features
from lib.segment import apply_automatic_brightness_contrast, apply_clahe, auto_segment
from api.configs.pcvk_config import CLASS_NAMES, DEVICE
from api.services.classification.onnx_utils import (
    ONNXInferenceSession,
    predict_onnx_mlp,
    predict_onnx_efficientnet
)


def preprocess_image(image: Image.Image, target_size: Tuple[int, int] = (224, 224)) -> np.ndarray:
    """
    Preprocess image for inference
    
    Args:
        image: PIL Image
        target_size: Target size for resizing
    
    Returns:
        Preprocessed image as BGR numpy array
    """
    # Convert PIL Image to numpy array (RGB)
    image_np = np.array(image.convert('RGB'))
    
    # Convert RGB to BGR for OpenCV
    image_bgr = cv2.cvtColor(image_np, cv2.COLOR_RGB2BGR)
    
    # Resize to target size
    image_bgr = cv2.resize(image_bgr, target_size)
    
    return image_bgr


def apply_segmentation(image: np.ndarray, method: str = "hsv", apply_brightness_contrast: bool = True) -> np.ndarray:
    """
    Apply segmentation to image
    
    Args:
        image: Input image (BGR)
        method: Segmentation method
        apply_brightness_contrast: Whether to apply brightness and contrast enhancement
    
    Returns:
        Segmented image
    """
    if method == "none":
        return image.copy()
    
    return auto_segment(image.copy(), method=method, applyBrightContClahe=apply_brightness_contrast)


def extract_features_from_image(image: np.ndarray) -> np.ndarray:
    """
    Extract features from image
    
    Args:
        image: Input image (BGR)
    
    Returns:
        Feature vector as numpy array
    """
    features = extract_all_features(
        image,
        use_segmentation=False,  # Already segmented if needed
        seg_method="none"
    )
    return features


def predict_from_features(
    model: Union[torch.nn.Module, ONNXInferenceSession],
    features: np.ndarray,
    is_onnx: bool = False
) -> Tuple[str, float, Dict[str, float]]:
    """
    Perform prediction from features
    
    Args:
        model: PyTorch model or ONNX session
        features: Feature vector
        is_onnx: Whether the model is ONNX
    
    Returns:
        Tuple of (predicted_class, confidence, all_confidences)
    """
    if is_onnx:
        return predict_onnx_mlp(model, features, CLASS_NAMES)
    
    # PyTorch inference
    # Convert to tensor
    features_tensor = torch.tensor(features, dtype=torch.float32).unsqueeze(0)
    features_tensor = features_tensor.to(DEVICE)
    
    # Predict
    with torch.no_grad():
        outputs = model(features_tensor)
        probabilities = torch.softmax(outputs, dim=1)
        confidence, predicted = torch.max(probabilities, 1)
        
        # Get all class probabilities
        probs = probabilities[0].cpu().numpy()
    
    # Prepare results
    predicted_class = CLASS_NAMES[predicted.item()]
    confidence_value = float(confidence.item())
    
    # Create confidence dictionary for all classes
    all_confidences = {CLASS_NAMES[i]: float(probs[i]) for i in range(len(CLASS_NAMES))}
    
    return predicted_class, confidence_value, all_confidences


def predict_from_tensor(
    model: Union[torch.nn.Module, ONNXInferenceSession],
    image_tensor: Union[torch.Tensor, np.ndarray],
    is_onnx: bool = False
) -> Tuple[str, float, Dict[str, float]]:
    """
    Perform prediction from image tensor (for EfficientNetV2)
    
    Args:
        model: PyTorch model (EfficientNetV2) or ONNX session
        image_tensor: Preprocessed image tensor
        is_onnx: Whether the model is ONNX
    
    Returns:
        Tuple of (predicted_class, confidence, all_confidences)
    """
    if is_onnx:
        # Convert torch tensor to numpy if needed
        if isinstance(image_tensor, torch.Tensor):
            image_tensor = image_tensor.cpu().numpy()
        return predict_onnx_efficientnet(model, image_tensor, CLASS_NAMES)
    
    # PyTorch inference
    # Add batch dimension if needed
    if image_tensor.dim() == 3:
        image_tensor = image_tensor.unsqueeze(0)
    
    image_tensor = image_tensor.to(DEVICE)
    
    # Predict
    with torch.no_grad():
        outputs = model(image_tensor)
        probabilities = torch.softmax(outputs, dim=1)
        confidence, predicted = torch.max(probabilities, 1)
        
        # Get all class probabilities
        probs = probabilities[0].cpu().numpy()
    
    # Prepare results
    predicted_class = CLASS_NAMES[predicted.item()]
    confidence_value = float(confidence.item())
    
    # Create confidence dictionary for all classes
    all_confidences = {CLASS_NAMES[i]: float(probs[i]) for i in range(len(CLASS_NAMES))}
    
    return predicted_class, confidence_value, all_confidences


def predict_image(
    model: Union[torch.nn.Module, ONNXInferenceSession],
    image: Image.Image,
    use_segmentation: bool = True,
    seg_method: str = "hsv",
    apply_brightness_contrast: bool = True,
    model_type: str = "mlpv2",
    return_segmented_image: bool = False,
    is_onnx: bool = False
) -> Tuple[str, float, Dict[str, float], np.ndarray]:
    """
    Complete prediction pipeline
    
    Args:
        model: PyTorch model or ONNX session
        image: PIL Image
        use_segmentation: Whether to apply segmentation
        seg_method: Segmentation method
        apply_brightness_contrast: Whether to apply brightness and contrast enhancement
        model_type: Type of model (mlpv2, mlpv2_auto-clahe, efficientnetv2)
        return_segmented_image: Whether to return the segmented image (only for non-efficientnet models)
        is_onnx: Whether the model is ONNX
    
    Returns:
        Tuple of (predicted_class, confidence, all_confidences, segmented_image)
        segmented_image is None if not requested or if using efficientnetv2
    """
    # EfficientNetV2 uses direct image tensor without feature extraction
    if model_type == "efficientnetv2":
        # Standard ImageNet preprocessing without any segmentation or enhancement
        transform = T.Compose([
            T.Resize((224, 224)),
            T.ToTensor(),
            T.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
        ])
        
        # Convert to RGB if needed
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Transform
        image_tensor = transform(image)
        
        if is_onnx:
            # Convert to numpy for ONNX
            image_np = image_tensor.cpu().numpy()
            predicted_class, confidence, all_confidences = predict_from_tensor(model, image_np, is_onnx=True)
        else:
            # Use torch tensor for PyTorch
            predicted_class, confidence, all_confidences = predict_from_tensor(model, image_tensor, is_onnx=False)
        
        return predicted_class, confidence, all_confidences, None
    
    # Feature-based models (MLP variants)
    # Preprocess image
    image_bgr = preprocess_image(image)
    
    # Apply segmentation if enabled
    if use_segmentation and seg_method != "none":
        segmented_img = apply_segmentation(image_bgr, method=seg_method, apply_brightness_contrast=False)
    else:
        segmented_img = image_bgr        

    if apply_brightness_contrast: #LV2
        segmented_img = apply_clahe(apply_automatic_brightness_contrast(segmented_img))
    
    # Extract features
    # segmented_img = apply_clahe(apply_automatic_brightness_contrast(segmented_img))
    features = extract_features_from_image(segmented_img)
    
    # Predict
    predicted_class, confidence, all_confidences = predict_from_features(model, features, is_onnx=is_onnx)
    
    # Return segmented image if requested
    segmented_result = segmented_img if return_segmented_image else None
    
    return predicted_class, confidence, all_confidences, segmented_result
