"""
Azure-specific API routes with Firebase authentication
"""

from fastapi import APIRouter, File, UploadFile, HTTPException, Depends
from typing import Optional
from PIL import Image
import io

from api.models.azure_models import StorageResponse, UserImagesResponse
from api.services.firebase_auth import get_current_user
from api.services.azure_storage import azure_storage


# Create router
azure_router = APIRouter(prefix="/azure", tags=["Azure Blob Storage"])


@azure_router.post("/upload", response_model=StorageResponse)
async def upload_image(
    file: UploadFile = File(..., description="Image file to store"),
    custom_name: Optional[str] = None,
    user_info: dict = Depends(get_current_user),
):
    """
    Upload image to Azure Blob Storage without prediction (requires authentication)

    Requires: Bearer token in Authorization header
    """
    # Validate file type
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")

    try:
        # Read and open image
        image_bytes = await file.read()
        image = Image.open(io.BytesIO(image_bytes))

        # Upload to Azure
        user_id = user_info.get("uid", "unknown")
        blob_name, blob_url = azure_storage.upload_image(
            image=image, user_id=user_id, filename=file.filename, custom_name=custom_name
        )

        if not blob_name:
            raise HTTPException(status_code=500, detail="Failed to upload image")

        # Get SAS URL
        sas_url = azure_storage.get_blob_url_with_sas(blob_name, expiry_hours=24)

        return StorageResponse(
            success=True,
            blob_name=blob_name,
            blob_url=sas_url,
            message="Image uploaded successfully",
        )

    except HTTPException:
        raise
    except Exception as e:
        print(f"Error uploading image: {e}")
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")


@azure_router.get("/get-images")
async def get_images(uid: Optional[str] = None):
    """
    Get list of images by user ID (no authentication required)
    
    Args:
        uid: Optional user ID. If not provided, returns all images.
    
    Returns:
        List of images with their URLs
    """
    try:
        if uid:
            # Get images for specific user
            blob_names = azure_storage.list_user_blobs(uid)
        else:
            # Get all images
            blob_names = azure_storage.list_user_blobs()
        
        # Generate SAS URLs for each blob
        images = []
        for blob_name in blob_names:
            sas_url = azure_storage.get_blob_url_with_sas(blob_name, expiry_hours=24)
            if sas_url:
                images.append({"blob_name": blob_name, "url": sas_url})
        
        return {
            "user_id": uid if uid else "all",
            "count": len(images),
            "images": images
        }
    
    except Exception as e:
        print(f"Error listing images: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to list images: {str(e)}")


@azure_router.get("/my-images", response_model=UserImagesResponse)
async def get_user_images(user_info: dict = Depends(get_current_user)):
    """
    Get list of all images uploaded by the authenticated user

    Requires: Bearer token in Authorization header
    """
    try:
        user_id = user_info.get("uid", "unknown")
        blob_names = azure_storage.list_user_blobs(user_id)

        # Generate SAS URLs for each blob
        images = []
        for blob_name in blob_names:
            sas_url = azure_storage.get_blob_url_with_sas(blob_name, expiry_hours=24)
            if sas_url:
                images.append({"blob_name": blob_name, "url": sas_url})

        return UserImagesResponse(user_id=user_id, count=len(images), images=images)

    except Exception as e:
        print(f"Error listing user images: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to list images: {str(e)}")


@azure_router.delete("/image/{blob_name:path}")
async def delete_image(blob_name: str, user_info: dict = Depends(get_current_user)):
    """
    Delete an image from Azure Blob Storage

    Requires: Bearer token in Authorization header
    Only allows deletion of user's own images
    """
    try:
        user_id = user_info.get("uid", "unknown")

        # Verify the blob belongs to the user
        if not blob_name.startswith(f"{user_id}/"):
            raise HTTPException(
                status_code=403, detail="You can only delete your own images"
            )

        # Delete the blob
        success = azure_storage.delete_blob(blob_name)

        if not success:
            raise HTTPException(status_code=500, detail="Failed to delete image")

        return {
            "success": True,
            "message": "Image deleted successfully",
            "blob_name": blob_name,
        }

    except HTTPException:
        raise
    except Exception as e:
        print(f"Error deleting image: {e}")
        raise HTTPException(status_code=500, detail=f"Delete failed: {str(e)}")
