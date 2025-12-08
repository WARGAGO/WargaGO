"""
API route handlers
"""

import os
import time
import json
import cv2
from fastapi import APIRouter, File, UploadFile, HTTPException, Query, WebSocket, WebSocketDisconnect
from PIL import Image
import io
import numpy as np
from typing import List

from api.models.pcvk_models import (
    PredictionResponse,
    HealthResponse,
    ClassesResponse,
    ModelsInfoResponse,
    ModelInfo,
    BatchPredictionResponse,
    BatchPredictionResult,
    UnloadModelResponse,
    WebSocketPredictionResponse,
    WebSocketErrorResponse,
    WebSocketStatusResponse
)
from api.configs.pcvk_config import (
    CLASS_NAMES,
    DEVICE,
    MODEL_PATHS,
    VALID_SEGMENTATION_METHODS
)
from api.services.classification.model_loader import model_manager
from api.services.classification.inference import predict_image


# Create router
router = APIRouter(prefix="/pcvk", tags=["PCVK"])


@router.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    available_models = model_manager.get_loaded_models()
    
    return HealthResponse(
        status="healthy" if len(available_models) > 0 else "unhealthy",
        device=str(DEVICE),
        num_classes=len(CLASS_NAMES),
        class_names=CLASS_NAMES,
        available_models=available_models
    )


@router.get("/classes", response_model=ClassesResponse)
async def get_classes():
    """Get list of available classes"""
    return ClassesResponse(classes=CLASS_NAMES)


@router.get("/models", response_model=ModelsInfoResponse)
async def get_models_info():
    """Get information about available models"""
    models_info = {}
    
    for model_type in MODEL_PATHS.keys():
        model_loaded = model_manager.is_loaded(model_type)
        
        info_dict = {
            "loaded": model_loaded,
        }
        
        if model_type == "mlpv2":
            info_dict["architecture"] = "MLP with Residual Connections"
            info_dict["hidden_layers"] = "256 -> 512 -> 256 -> 128"
            info_dict["dropout"] = "Progressive (0.3 -> 0.15 -> 0.075 -> 0.0375)"
            info_dict["features"] = ["Residual Blocks", "BatchNorm", "Kaiming Init"]
        elif model_type == "mlpv2_auto-clahe":
            info_dict["architecture"] = "MLP with Residual Connections + Auto-CLAHE"
            info_dict["hidden_layers"] = "256 -> 512 -> 256 -> 128"
            info_dict["dropout"] = "Progressive (0.3 -> 0.15 -> 0.075 -> 0.0375)"
            info_dict["features"] = ["Residual Blocks", "BatchNorm", "Kaiming Init", "Auto Brightness/Contrast", "CLAHE Enhancement"]
        elif model_type == "efficientnetv2":
            info_dict["architecture"] = "EfficientNetV2-S"
            info_dict["hidden_layers"] = "CNN-based (no hidden layers)"
            info_dict["dropout"] = 0.3
            info_dict["features"] = ["Direct Image Processing", "No Segmentation", "No Preprocessing", "ImageNet Normalization"]
        
        models_info[model_type] = ModelInfo(**info_dict)
    
    return ModelsInfoResponse(
        available_models=model_manager.get_loaded_models(),
        total_models=len(MODEL_PATHS),
        models=models_info
    )


@router.post("/predict", response_model=PredictionResponse)
async def predict(
    file: UploadFile = File(..., description="Image file to classify"),
    use_segmentation: bool = Query(True, description="Whether to use segmentation"),
    seg_method: str = Query("u2netp", description="Segmentation method: hsv, grabcut, adaptive, u2netp, none"),
    model_type: str = Query("mlpv2_auto-clahe", description="Model type to use: mlpv2, mlpv2_auto-clahe, efficientnetv2"),
    apply_brightness_contrast: bool = Query(True, description="Apply brightness and contrast enhancement (CLAHE)")
):
    """
    Predict vegetable class from image
    
    Args:
        file: Image file (JPG, PNG, etc.)
        use_segmentation: Whether to apply segmentation
        seg_method: Segmentation method (hsv, grabcut, adaptive, u2netp, none)
        model_type: Type of model to use for prediction 
    
    Returns:
        Prediction results with confidence scores
    """
    # Load model if not already loaded
    if not model_manager.is_loaded(model_type):
        print(f"Model {model_type} not loaded, loading now...")
        success = model_manager.load_model(model_type)
        if not success:
            raise HTTPException(
                status_code=503,
                detail=f"Failed to load model '{model_type}'"
            )
    
    # Validate file type
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    # Validate segmentation method
    if seg_method not in VALID_SEGMENTATION_METHODS:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid segmentation method. Must be one of: {VALID_SEGMENTATION_METHODS}"
        )
    
    try:
        # Start timing
        start_time = time.time()
        
        # Read image
        image_bytes = await file.read()
        image = Image.open(io.BytesIO(image_bytes))
        
        # Get model
        model = model_manager.get_model(model_type)
        is_onnx = model_manager.get_model_type(model_type) == 'onnx'
        
        # Perform prediction
        predicted_class, confidence_value, all_confidences, _ = predict_image(
            model=model,
            image=image,
            use_segmentation=use_segmentation,
            seg_method=seg_method,
            apply_brightness_contrast=apply_brightness_contrast,
            model_type=model_type,
            return_segmented_image=False,
            is_onnx=is_onnx
        )
        
        # Calculate prediction time
        prediction_time_ms = (time.time() - start_time) * 1000
        
        return PredictionResponse(
            filename=file.filename,
            predicted_class=predicted_class,
            confidence=confidence_value,
            all_confidences=all_confidences,
            device=str(DEVICE),
            model_type=model_type,
            segmentation_used=use_segmentation,
            segmentation_method=seg_method if use_segmentation else None,
            apply_brightness_contrast=apply_brightness_contrast,
            prediction_time_ms=prediction_time_ms
        )
    
    except Exception as e:
        print(f"Error during prediction: {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Error during prediction: {str(e)}")


@router.post("/batch-predict", response_model=BatchPredictionResponse)
async def batch_predict(
    files: List[UploadFile] = File(..., description="Multiple image files to classify"),
    use_segmentation: bool = Query(True, description="Whether to use segmentation"),
    seg_method: str = Query("u2netp", description="Segmentation method: hsv, grabcut, adaptive, u2netp, none"),
    model_type: str = Query("mlpv2_auto-clahe", description="Model type to use: mlpv2, mlpv2_auto-clahe, efficientnetv2"),
    apply_brightness_contrast: bool = Query(True, description="Apply brightness and contrast enhancement (CLAHE)")
):
    """
    Predict multiple images at once
    
    Args:
        files: List of image files
        use_segmentation: Whether to apply segmentation
        seg_method: Segmentation method
        model_type: Type of model to use for prediction
    
    Returns:
        List of prediction results
    """
    # Load model if not already loaded
    if not model_manager.is_loaded(model_type):
        print(f"Model {model_type} not loaded, loading now...")
        success = model_manager.load_model(model_type)
        if not success:
            raise HTTPException(
                status_code=503,
                detail=f"Failed to load model '{model_type}'"
            )
    
    # Get model
    model = model_manager.get_model(model_type)
    is_onnx = model_manager.get_model_type(model_type) == 'onnx'
    
    # Start timing for total batch
    batch_start_time = time.time()
    
    results = []
    
    for file in files:
        try:
            # Validate file type
            if not file.content_type.startswith("image/"):
                results.append(BatchPredictionResult(
                    filename=file.filename,
                    error="File must be an image"
                ))
                continue
            
            # Start timing for individual prediction
            pred_start_time = time.time()
            
            # Read and process image
            image_bytes = await file.read()
            image = Image.open(io.BytesIO(image_bytes))
            
            # Perform prediction
            predicted_class, confidence_value, all_confidences, _ = predict_image(
                model=model,
                image=image,
                use_segmentation=use_segmentation,
                seg_method=seg_method,
                apply_brightness_contrast=apply_brightness_contrast,
                model_type=model_type,
                return_segmented_image=False,
                is_onnx=is_onnx
            )
            
            # Calculate prediction time
            prediction_time_ms = (time.time() - pred_start_time) * 1000
            
            results.append(BatchPredictionResult(
                filename=file.filename,
                predicted_class=predicted_class,
                confidence=confidence_value,
                all_confidences=all_confidences,
                device=str(DEVICE),
                model_type=model_type,
                segmentation_used=use_segmentation,
                segmentation_method=seg_method if use_segmentation else None,
                apply_brightness_contrast=apply_brightness_contrast,
                prediction_time_ms=prediction_time_ms
            ))
        
        except Exception as e:
            results.append(BatchPredictionResult(
                filename=file.filename,
                error=str(e),
                predicted_class="",
                confidence=0.0,
                all_confidences={},
                device=str(DEVICE),
                model_type=model_type,
                segmentation_used=use_segmentation,
                segmentation_method=seg_method if use_segmentation else None,
                apply_brightness_contrast=apply_brightness_contrast,
                prediction_time_ms=0.0
            ))
    
    # Calculate total batch time
    total_time_ms = (time.time() - batch_start_time) * 1000
    
    return BatchPredictionResponse(results=results, total_time_ms=total_time_ms)


@router.post("/unload", response_model=UnloadModelResponse)
async def unload_model(
    model_type: str = Query("", description="Model type to unload (mlpv2, mlpv2_auto-clahe, efficientnetv2). Empty to unload all")
):
    """
    Unload model(s) from memory
    
    Args:
        model_type: Type of model to unload. If empty, unloads all models.
    
    Returns:
        Unload status and information
    """
    unloaded = []
    
    try:
        if model_type == "":
            # Unload all models
            unloaded = model_manager.get_loaded_models().copy()
            success = model_manager.unload_all_models()
            message = "All models unloaded successfully" if success else "Failed to unload all models"
        else:
            # Validate model type
            if model_type not in MODEL_PATHS:
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid model type '{model_type}'. Valid types: {list(MODEL_PATHS.keys())}"
                )
            
            # Unload specific model
            if model_manager.is_loaded(model_type):
                success = model_manager.unload_model(model_type)
                if success:
                    unloaded = [model_type]
                    message = f"Model '{model_type}' unloaded successfully"
                else:
                    message = f"Failed to unload model '{model_type}'"
            else:
                success = True
                message = f"Model '{model_type}' was not loaded"
        
        return UnloadModelResponse(
            success=success,
            message=message,
            unloaded_models=unloaded,
            remaining_models=model_manager.get_loaded_models()
        )
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error unloading model: {str(e)}")


@router.websocket("/ws/predict")
async def websocket_predict(websocket: WebSocket):
    """
    WebSocket endpoint for real-time predictions
    
    Protocol:
    1. Client sends configuration as JSON text: {"use_segmentation": true, "seg_method": "u2netp", "model_type": "mlpv2_auto-clahe", "apply_brightness_contrast": true, "return_processed_image": false}
    2. Client sends image data as binary bytes
    3. Server responds with prediction results as JSON
    4. Optionally sends processed image as binary JPEG if return_processed_image is true and model is not efficientnetv2
    """
    await websocket.accept()
    
    config = {
        "use_segmentation": True,
        "seg_method": "u2netp",
        "model_type": "mlpv2_auto-clahe",
        "apply_brightness_contrast": True,
        "return_processed_image": False
    }
    
    # Buffer for chunked image data - using BytesIO for better performance
    image_buffer = None
    
    try:
        await websocket.send_json(
            WebSocketStatusResponse(
                message="Connected. Send config (JSON), image chunks (binary), or {\"complete\": true} to process."
            ).model_dump()
        )
        
        while True:
            try:
                message = await websocket.receive()
                
                if "text" in message:
                    data = message["text"]
                    try:
                        received_data = json.loads(data)
                        
                        # Handle ping/pong
                        if "ping" in received_data and received_data["ping"]:
                            await websocket.send_json({"pong": True})
                            continue
                        
                        if "complete" in received_data and received_data["complete"]:
                            if image_buffer is None or image_buffer.tell() == 0:
                                await websocket.send_json(
                                    WebSocketErrorResponse(
                                        message="No image chunks received"
                                    ).model_dump()
                                )
                                continue
                            
                            # Get complete image from buffer
                            image_bytes = image_buffer.getvalue()
                            image_buffer.close()
                            image_buffer = None
                            
                            await websocket.send_json(
                                WebSocketStatusResponse(
                                    message=f"Processing image ({len(image_bytes)} bytes)..."
                                ).model_dump()
                            )
                            # Fall through to image processing
                        else:
                            # Configuration update           
                            if "use_segmentation" in received_data:
                                config["use_segmentation"] = received_data["use_segmentation"]
                            if "seg_method" in received_data:
                                if received_data["seg_method"] not in VALID_SEGMENTATION_METHODS:
                                    await websocket.send_json(
                                        WebSocketErrorResponse(
                                            message=f"Invalid segmentation method. Must be one of: {VALID_SEGMENTATION_METHODS}"
                                        ).model_dump()
                                    )
                                    continue
                                config["seg_method"] = received_data["seg_method"]
                            if "model_type" in received_data:
                                if received_data["model_type"] not in MODEL_PATHS:
                                    await websocket.send_json(
                                        WebSocketErrorResponse(
                                            message=f"Invalid model type. Must be one of: {list(MODEL_PATHS.keys())}"
                                        ).model_dump()
                                    )
                                    continue
                                config["model_type"] = received_data["model_type"]
                            if "apply_brightness_contrast" in received_data:
                                config["apply_brightness_contrast"] = received_data["apply_brightness_contrast"]
                            if "return_processed_image" in received_data:
                                config["return_processed_image"] = received_data["return_processed_image"]
                            
                            await websocket.send_json(
                                WebSocketStatusResponse(
                                    message=f"Configuration updated: {config}"
                                ).model_dump()
                            )
                            continue
                    except json.JSONDecodeError:
                        await websocket.send_json(
                            WebSocketErrorResponse(
                                message="Invalid JSON format"
                            ).model_dump()
                        )
                        continue
                
                elif "bytes" in message:
                    chunk = message["bytes"]                
                    if image_buffer is None:
                        image_buffer = io.BytesIO()
                    
                    image_buffer.write(chunk)
                    await websocket.send_json(
                        WebSocketStatusResponse(
                            message=f"Chunk received ({len(chunk)} bytes, total: {image_buffer.tell()} bytes)"
                        ).model_dump()
                    )
                    continue
                else:
                    continue
                
                # If we reach here, image_bytes should be set from completion signal
                if 'image_bytes' not in locals():
                    continue
                
                # Process image data
                start_time = time.time()
                
                # Load model if not already loaded
                model_type = config["model_type"]
                if not model_manager.is_loaded(model_type):
                    print(f"Model {model_type} not loaded, loading now...")
                    success = model_manager.load_model(model_type)
                    if not success:
                        await websocket.send_json(
                            WebSocketErrorResponse(
                                message=f"Failed to load model '{model_type}'"
                            ).model_dump()
                        )
                        continue
                
                # Decode image from bytes
                try:
                    image = Image.open(io.BytesIO(image_bytes))
                except Exception as e:
                    await websocket.send_json(
                        WebSocketErrorResponse(
                            message=f"Invalid image data: {str(e)}"
                        ).model_dump()
                    )
                    continue
                
                # Get model
                model = model_manager.get_model(model_type)
                is_onnx = model_manager.get_model_type(model_type) == 'onnx'
                
                # Determine if we should return processed image
                return_processed = config["return_processed_image"] and model_type != "efficientnetv2"
                
                # Perform prediction
                predicted_class, confidence_value, all_confidences, processed_img = predict_image(
                    model=model,
                    image=image,
                    use_segmentation=config["use_segmentation"],
                    seg_method=config["seg_method"],
                    apply_brightness_contrast=config["apply_brightness_contrast"],
                    model_type=model_type,
                    return_segmented_image=return_processed,
                    is_onnx=is_onnx
                )
                
                # Calculate prediction time
                prediction_time_ms = (time.time() - start_time) * 1000
                
                # Prepare response
                response = WebSocketPredictionResponse(
                    predicted_class=predicted_class,
                    confidence=confidence_value,
                    all_confidences=all_confidences,
                    device=str(DEVICE),
                    model_type=model_type,
                    segmentation_used=config["use_segmentation"],
                    segmentation_method=config["seg_method"] if config["use_segmentation"] else None,
                    apply_brightness_contrast=config["apply_brightness_contrast"],
                    prediction_time_ms=prediction_time_ms,
                    has_processed_image=return_processed and processed_img is not None
                )
                
                # Send prediction response as JSON
                await websocket.send_json(response.model_dump())
                
                # Send processed image as binary if requested and available
                if return_processed and processed_img is not None:
                    # Convert BGR to RGB for proper encoding
                    processed_img_rgb = cv2.cvtColor(processed_img, cv2.COLOR_BGR2RGB)
                    # Encode as JPEG
                    _, buffer = cv2.imencode('.jpg', processed_img_rgb)
                    processed_bytes = buffer.tobytes()
                    
                    # Send processed image in chunks
                    chunk_size = 65536  # 64KB chunks
                    total_size = len(processed_bytes)
                    offset = 0
                    
                    # Notify client that processed image chunks are coming
                    await websocket.send_json(
                        WebSocketStatusResponse(
                            message=f"Sending processed image ({total_size} bytes) in chunks..."
                        ).model_dump()
                    )
                    
                    while offset < total_size:
                        chunk = processed_bytes[offset:offset + chunk_size]
                        await websocket.send_bytes(chunk)
                        offset += chunk_size
                    
                    # Send completion signal
                    await websocket.send_json(
                        WebSocketStatusResponse(
                            message="Processed image transfer complete"
                        ).model_dump()
                    )
                
            except WebSocketDisconnect:
                print("WebSocket client disconnected")
                break
            except Exception as e:
                print(f"Error during WebSocket prediction: {e}")
                import traceback
                traceback.print_exc()
                await websocket.send_json(
                    WebSocketErrorResponse(
                        message=f"Error during prediction: {str(e)}"
                    ).model_dump()
                )
    
    except WebSocketDisconnect:
        print("WebSocket connection closed")
    except Exception as e:
        print(f"WebSocket error: {e}")
        import traceback
        traceback.print_exc()
