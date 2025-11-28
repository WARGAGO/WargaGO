import numpy as np
from PIL import Image
from typing import List, Tuple, Optional

from api.configs.ocr_config import OCR_CONFIG


class OCRService:
    """Manages PaddleOCR model loading and inference"""

    def __init__(self):
        self._ocr_instance = None

    def load_model(self) -> bool:
        """
        Load PaddleOCR model

        Returns:
            True if successful, False otherwise
        """
        try:
            if self._ocr_instance is not None:
                print("PaddleOCR model already loaded")
                return True

            print("Loading PaddleOCR model...")
            from paddleocr import PaddleOCR

            # Initialize PaddleOCR with custom configuration
            self._ocr_instance = PaddleOCR(
                **OCR_CONFIG,
            )

            print("PaddleOCR initialized successfully")

            return True

        except Exception as e:
            print(f"Error initializing PaddleOCR: {e}")
            import traceback

            traceback.print_exc()
            return False

    def is_loaded(self) -> bool:
        """Check if OCR model is loaded"""
        return self._ocr_instance is not None

    def get_model(self):
        """
        Get OCR model instance, loading if necessary

        Returns:
            PaddleOCR instance

        Raises:
            RuntimeError: If model fails to load
        """
        if self._ocr_instance is None:
            success = self.load_model()
            if not success:
                raise RuntimeError("Failed to load PaddleOCR model")

        return self._ocr_instance

    def perform_ocr(
        self, image: Image.Image
    ) -> List[Tuple[List[List[float]], Tuple[str, float]]]:
        """
        Perform OCR on an image

        Args:
            image: PIL Image to process

        Returns:
            List of OCR results, each containing:
                - bbox: Bounding box coordinates
                - (text, confidence): Detected text and confidence score
        """
        # Convert to RGB if not already (handles RGBA, L, etc.)
        if image.mode != "RGB":
            image = image.convert("RGB")

        # Convert PIL Image to numpy array
        image_array = np.array(image)

        # Get OCR instance
        ocr = self.get_model()

        # Perform OCR using predict method
        ocr_results = list(ocr.predict(image_array))

        # Handle new PaddleOCR format (returns generator/dict)
        if ocr_results:
            result = ocr_results[0]

            # Check if result is a dictionary (new format)
            if isinstance(result, dict):
                rec_texts = result.get("rec_texts", [])
                rec_scores = result.get("rec_scores", [])
                rec_polys = result.get("rec_polys", result.get("dt_polys", []))

                # Convert to expected format: [(bbox, (text, confidence)), ...]
                formatted_results = []
                for i in range(len(rec_texts)):
                    bbox = rec_polys[i] if i < len(rec_polys) else []
                    text = rec_texts[i] if i < len(rec_texts) else ""
                    score = rec_scores[i] if i < len(rec_scores) else 0.0
                    formatted_results.append((bbox, (text, score)))

                return formatted_results

            # Fallback for old format (if still used)
            return result if isinstance(result, list) else []

        return []

    def unload_model(self) -> bool:
        """
        Unload OCR model from memory

        Returns:
            True if successful
        """
        try:
            if self._ocr_instance is not None:
                del self._ocr_instance
                self._ocr_instance = None
                print("PaddleOCR model unloaded successfully")
            return True

        except Exception as e:
            print(f"Error unloading PaddleOCR model: {e}")
            return False


# Global OCR service instance
ocr_service = OCRService()
