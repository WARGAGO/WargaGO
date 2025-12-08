"""
Model loading and management
"""

import os
import sys
import torch
from typing import Dict, Optional, Union

# Add lib directory to path
lib_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'lib')
if lib_path not in sys.path:
    sys.path.append(lib_path)

from lib.model_v2 import ModelMLPV2
from lib.model_effnet import EfficientNetV2Model
from api.configs.pcvk_config import MODEL_PATHS, ONNX_MODEL_PATHS, CLASS_NAMES, DEVICE, NUM_FEATURES, PREFER_ONNX
from api.services.classification.onnx_utils import ONNXInferenceSession


class ModelManager:
    """Manages loading and accessing ML models"""
    
    def __init__(self):
        self.models: Dict[str, Union[torch.nn.Module, ONNXInferenceSession]] = {}
        self.model_types: Dict[str, str] = {}  # Track whether model is 'pytorch' or 'onnx'
    
    def load_model(self, model_type: str, force_pytorch: bool = False) -> bool:
        """
        Load a specific model
        
        Args:
            model_type: Type of model to load
            force_pytorch: Force loading PyTorch model even if ONNX is preferred
        
        Returns:
            True if successful, False otherwise
        """
        try:
            # Determine whether to use ONNX or PyTorch
            use_onnx = PREFER_ONNX and not force_pytorch and model_type in ONNX_MODEL_PATHS
            
            if use_onnx:
                onnx_path = ONNX_MODEL_PATHS[model_type]
                if os.path.exists(onnx_path):
                    print(f"Loading {model_type} model (ONNX)...")
                    session = ONNXInferenceSession(onnx_path)
                    self.models[model_type] = session
                    self.model_types[model_type] = 'onnx'
                    print(f"ONNX model {model_type} loaded successfully")
                    return True
                else:
                    print(f"ONNX model not found at {onnx_path}, falling back to PyTorch")
                    use_onnx = False
            
            if not use_onnx:
                return self._load_pytorch_model(model_type)
                
        except Exception as e:
            print(f"Error loading model {model_type}: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    def _load_pytorch_model(self, model_type: str) -> bool:
        """
        Load a PyTorch model
        
        Args:
            model_type: Type of model to load
        
        Returns:
            True if successful, False otherwise
        """
        try:
            print(f"Loading {model_type} model (PyTorch)...")
            
            if model_type not in MODEL_PATHS:
                raise ValueError(f"Unknown model type: {model_type}")
            
            model_path = MODEL_PATHS[model_type]
            
            if not os.path.exists(model_path):
                print(f"Warning: Model file not found at {model_path}")
                return False
            
            # Create model instance based on type
            if model_type == "mlpv2":
                model = ModelMLPV2(
                    num_features=NUM_FEATURES,
                    num_classes=len(CLASS_NAMES),
                    hidden_dims=[256, 512, 256, 128],
                    dropout_rate=0.5,
                    use_residual=True
                )
            elif model_type == "mlpv2_auto-clahe":
                model = ModelMLPV2(
                    num_features=NUM_FEATURES,
                    num_classes=len(CLASS_NAMES),
                    hidden_dims=[256, 512, 256, 128],
                    dropout_rate=0.3,
                    use_residual=True
                )
            elif model_type == "efficientnetv2":
                model = EfficientNetV2Model(
                    num_classes=len(CLASS_NAMES),
                    dropout_rate=0.3,
                    pretrained=False,
                    freeze_backbone=False
                )
            else:
                raise ValueError(f"Unknown model type: {model_type}")
            
            # Load checkpoint
            checkpoint = torch.load(model_path, map_location=DEVICE)
            
            # Handle different checkpoint formats
            if isinstance(checkpoint, dict) and 'model_state_dict' in checkpoint:
                model.load_state_dict(checkpoint['model_state_dict'])
            else:
                model.load_state_dict(checkpoint)
            
            model = model.to(DEVICE)
            model.eval()
            self.models[model_type] = model
            self.model_types[model_type] = 'pytorch'
            print(f"PyTorch model {model_type} loaded successfully on {DEVICE}")
            return True
            
        except Exception as e:
            print(f"Error loading PyTorch model {model_type}: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    def load_all_models(self) -> bool:
        """
        Load all available models
        
        Returns:
            True if at least one model loaded successfully
        """
        self.load_model("mlpv2")
        self.load_model("mlpv2_auto-clahe")
        self.load_model("efficientnetv2")
        return True
    
    def get_model(self, model_type: str) -> Optional[Union[torch.nn.Module, ONNXInferenceSession]]:
        """
        Get a loaded model
        
        Args:
            model_type: Type of model to retrieve
        
        Returns:
            Model instance or None if not loaded
        """
        return self.models.get(model_type)
    
    def get_model_type(self, model_type: str) -> Optional[str]:
        """
        Get the type of loaded model (pytorch or onnx)
        
        Args:
            model_type: Type of model
        
        Returns:
            'pytorch', 'onnx', or None if not loaded
        """
        return self.model_types.get(model_type)
    
    def is_loaded(self, model_type: str) -> bool:
        """Check if a model is loaded"""
        return model_type in self.models
    
    def get_loaded_models(self) -> list:
        """Get list of loaded model types"""
        return list(self.models.keys())
    
    def get_models_status(self) -> Dict[str, bool]:
        """Get loading status of all models"""
        return {model_type: self.is_loaded(model_type) for model_type in MODEL_PATHS.keys()}
    
    def _clear_u2netp_session(self) -> None:
        """Clear U2Net-P ONNX session from segment module"""
        try:
            import lib.segment as segment_module
            if hasattr(segment_module, '_u2netp_session') and segment_module._u2netp_session is not None:
                del segment_module._u2netp_session
                segment_module._u2netp_session = None
                print("U2Net-P ONNX session cleared")
        except Exception as e:
            print(f"Error clearing U2Net-P session: {e}")
    
    def unload_model(self, model_type: str) -> bool:
        """
        Unload a specific model from memory
        
        Args:
            model_type: Type of model to unload
        
        Returns:
            True if successful, False otherwise
        """
        try:
            if model_type not in self.models:
                print(f"Model {model_type} is not loaded")
                return False
            
            # Delete the model and free up memory
            del self.models[model_type]
            
            # Clear U2Net-P ONNX session
            self._clear_u2netp_session()
            
            # Clear GPU cache if using CUDA
            if DEVICE == 'cuda':
                torch.cuda.empty_cache()
            
            print(f"Model {model_type} unloaded successfully")
            return True
        
        except Exception as e:
            print(f"Error unloading model {model_type}: {e}")
            return False
    
    def unload_all_models(self) -> bool:
        """
        Unload all models from memory
        
        Returns:
            True if successful
        """
        try:
            model_types = list(self.models.keys())
            for model_type in model_types:
                del self.models[model_type]
            
            # Clear U2Net-P ONNX session
            self._clear_u2netp_session()
            
            # Clear GPU cache if using CUDA
            if DEVICE == 'cuda':
                torch.cuda.empty_cache()
            
            print("All models unloaded successfully")
            return True
        
        except Exception as e:
            print(f"Error unloading all models: {e}")
            return False


# Global model manager instance
model_manager = ModelManager()
