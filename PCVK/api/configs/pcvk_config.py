import os
import torch
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Model configuration
_MODEL_BASE_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
    "models",
)

# ONNX preference from environment
PREFER_ONNX = os.getenv("PREFER_ONNX", "false").lower() == "true"

# PyTorch model paths
MODEL_PATHS = {
    "mlpv2": os.path.join(_MODEL_BASE_DIR, "classification", "mlpv2.pth"),
    "mlpv2_auto-clahe": os.path.join(_MODEL_BASE_DIR, "classification", "mlpv2_auto-clahe.pth"),
    "efficientnetv2": os.path.join(_MODEL_BASE_DIR, "classification", "efficientnetv2.pth"),
    "u2netp": os.path.join(_MODEL_BASE_DIR, "u2netp.onnx"),
}

# ONNX model paths
ONNX_MODEL_PATHS = {
    "mlpv2": os.path.join(_MODEL_BASE_DIR, "classification", "mlpv2.onnx"),
    "mlpv2_auto-clahe": os.path.join(_MODEL_BASE_DIR, "classification", "mlpv2_auto-clahe.onnx"),
    "efficientnetv2": os.path.join(_MODEL_BASE_DIR, "classification", "efficientnetv2.onnx"),
}

CLASS_NAMES = ["Sayur Akar", "Sayur Buah", "Sayur Bunga", "Sayur Daun", "Sayur Polong"]

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Validation
VALID_SEGMENTATION_METHODS = ["hsv", "grabcut", "adaptive", "u2netp", "none"]
VALID_MODEL_TYPES = list(MODEL_PATHS.keys())

# Feature extraction
NUM_FEATURES = 44  # Total features extracted
