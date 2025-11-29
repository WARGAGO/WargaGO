import time
from fastapi import APIRouter, File, UploadFile, HTTPException
from PIL import Image
import io

from api.models.ocr_models import OCRResult, OCRResponse, OCRHealthResponse
from api.services.ocr_service import ocr_service
from api.configs.ocr_config import OCR_CONFIG


# Create router
router = APIRouter(prefix="/ocr", tags=["OCR"])


@router.get("/health", response_model=OCRHealthResponse)
async def ocr_health_check():
    """OCR health check endpoint"""
    model_loaded = ocr_service.is_loaded()

    return OCRHealthResponse(
        status="healthy" if model_loaded else "not_loaded",
        model_loaded=model_loaded,
        detection_model=OCR_CONFIG["text_detection_model_name"],
        recognition_model=OCR_CONFIG["text_recognition_model_name"],
    )


@router.post("/recognize", response_model=OCRResponse)
async def recognize_text(
    file: UploadFile = File(..., description="Image file to perform OCR on")
):
    """
    Perform OCR on an image

    Args:
        file: Image file (JPG, PNG, etc.)

    Returns:
        OCR results with detected text, confidence scores, and bounding boxes
    """
    # Validate file type
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")

    try:
        # Start timing
        start_time = time.time()

        # Read image
        image_bytes = await file.read()
        image = Image.open(io.BytesIO(image_bytes))

        # Perform OCR using service
        ocr_detections = ocr_service.perform_ocr(image)

        # Process results
        results = []
        for detection in ocr_detections:
            bbox = detection[0]  # Bounding box coordinates
            text_info = detection[1]  # (text, confidence)

            results.append(
                OCRResult(text=text_info[0], confidence=float(text_info[1]), bbox=bbox)
            )

        # Calculate processing time
        processing_time_ms = (time.time() - start_time) * 1000

        return OCRResponse(
            filename=file.filename,
            results=results,
            processing_time_ms=processing_time_ms,
            num_detections=len(results),
        )

    except Exception as e:
        print(f"Error during OCR: {e}")
        import traceback

        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Error during OCR: {str(e)}")
