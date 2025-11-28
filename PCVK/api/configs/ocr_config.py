"""
OCR Configuration
"""

import os

# Model configuration
_MODEL_BASE_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
    "models",
    "PaddleOCR"
)

# PaddleOCR model paths
OCR_MODEL_PATHS = {
    "detection": os.path.join(_MODEL_BASE_DIR, "PP-OCRv5_mobile_det"),
    "recognition": os.path.join(_MODEL_BASE_DIR, "PP-OCRv5_mobile_rec"),
}

# PaddleOCR configuration
OCR_CONFIG = {
    "use_doc_orientation_classify": False,
    "use_doc_unwarping": False,
    "use_textline_orientation": False,
    "text_detection_model_name": "PP-OCRv5_mobile_det",
    "text_recognition_model_name": "PP-OCRv5_mobile_rec",
    "text_detection_model_dir": OCR_MODEL_PATHS["detection"],
    "text_recognition_model_dir": OCR_MODEL_PATHS["recognition"],
}
