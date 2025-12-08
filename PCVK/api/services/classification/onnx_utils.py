"""
ONNX model utilities for inference
"""

import onnxruntime as ort
import numpy as np
from typing import Dict, Tuple
import os


class ONNXInferenceSession:
    """Wrapper for ONNX Runtime inference sessions"""
    
    def __init__(self, model_path: str):
        """
        Initialize ONNX inference session
        
        Args:
            model_path: Path to the ONNX model file
        """
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"ONNX model not found at {model_path}")
        
        # Set up session options
        sess_options = ort.SessionOptions()
        sess_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
        
        # Check for available providers
        providers = ['CPUExecutionProvider']
        if 'CUDAExecutionProvider' in ort.get_available_providers():
            providers.insert(0, 'CUDAExecutionProvider')
        
        # Create session
        self.session = ort.InferenceSession(
            model_path,
            sess_options=sess_options,
            providers=providers
        )
        
        # Get input/output metadata
        self.input_name = self.session.get_inputs()[0].name
        self.output_name = self.session.get_outputs()[0].name
        self.input_shape = self.session.get_inputs()[0].shape
        self.output_shape = self.session.get_outputs()[0].shape
        
        print(f"ONNX model loaded: {model_path}")
        print(f"Input: {self.input_name}, Shape: {self.input_shape}")
        print(f"Output: {self.output_name}, Shape: {self.output_shape}")
        print(f"Providers: {self.session.get_providers()}")
    
    def run(self, input_data: np.ndarray) -> np.ndarray:
        """
        Run inference
        
        Args:
            input_data: Input numpy array
        
        Returns:
            Output numpy array
        """
        # Ensure correct shape
        if input_data.ndim == 1:
            input_data = input_data.reshape(1, -1)
        elif input_data.ndim == 3:
            input_data = input_data.reshape(1, *input_data.shape)
        
        # Ensure float32 dtype
        input_data = input_data.astype(np.float32)
        
        # Run inference
        outputs = self.session.run(
            [self.output_name],
            {self.input_name: input_data}
        )
        
        return outputs[0]
    
    def get_input_shape(self) -> list:
        """Get expected input shape"""
        return self.input_shape
    
    def get_output_shape(self) -> list:
        """Get output shape"""
        return self.output_shape


def softmax(x: np.ndarray) -> np.ndarray:
    """
    Compute softmax values for array
    
    Args:
        x: Input array
    
    Returns:
        Softmax probabilities
    """
    exp_x = np.exp(x - np.max(x, axis=-1, keepdims=True))
    return exp_x / np.sum(exp_x, axis=-1, keepdims=True)


def predict_onnx_mlp(
    session: ONNXInferenceSession,
    features: np.ndarray,
    class_names: list
) -> Tuple[str, float, Dict[str, float]]:
    """
    Perform prediction using ONNX MLP model
    
    Args:
        session: ONNX inference session
        features: Feature vector as numpy array
        class_names: List of class names
    
    Returns:
        Tuple of (predicted_class, confidence, all_confidences)
    """
    # Ensure features are in correct shape and dtype
    if features.ndim == 1:
        features = features.reshape(1, -1)
    features = features.astype(np.float32)
    
    # Run inference
    outputs = session.run(features)
    
    # Apply softmax to get probabilities
    probabilities = softmax(outputs)
    probs = probabilities[0]
    
    # Get prediction
    predicted_idx = np.argmax(probs)
    predicted_class = class_names[predicted_idx]
    confidence_value = float(probs[predicted_idx])
    
    # Create confidence dictionary for all classes
    all_confidences = {class_names[i]: float(probs[i]) for i in range(len(class_names))}
    
    return predicted_class, confidence_value, all_confidences


def predict_onnx_efficientnet(
    session: ONNXInferenceSession,
    image_tensor: np.ndarray,
    class_names: list
) -> Tuple[str, float, Dict[str, float]]:
    """
    Perform prediction using ONNX EfficientNet model
    
    Args:
        session: ONNX inference session
        image_tensor: Preprocessed image tensor as numpy array (C, H, W) or (1, C, H, W)
        class_names: List of class names
    
    Returns:
        Tuple of (predicted_class, confidence, all_confidences)
    """
    # Ensure correct shape (1, C, H, W)
    if image_tensor.ndim == 3:
        image_tensor = image_tensor.reshape(1, *image_tensor.shape)
    
    # Ensure float32 dtype
    image_tensor = image_tensor.astype(np.float32)
    
    # Run inference
    outputs = session.run(image_tensor)
    
    # Apply softmax to get probabilities
    probabilities = softmax(outputs)
    probs = probabilities[0]
    
    # Get prediction
    predicted_idx = np.argmax(probs)
    predicted_class = class_names[predicted_idx]
    confidence_value = float(probs[predicted_idx])
    
    # Create confidence dictionary for all classes
    all_confidences = {class_names[i]: float(probs[i]) for i in range(len(class_names))}
    
    return predicted_class, confidence_value, all_confidences
