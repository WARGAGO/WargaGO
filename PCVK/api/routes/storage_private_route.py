"""
Azure-specific API routes with Firebase authentication
"""

from fastapi import APIRouter, File, UploadFile, HTTPException, Depends
from typing import Optional
from PIL import Image
import io

from api.models.azure_models import StorageResponse, UserImagesResponse
from api.services.firebase_auth import get_current_user, firebase_auth
from api.services.azure_storage import AzureBlobStorage
from api.configs.azure_config import AZURE_STORAGE_CONTAINER_PRIVATE_NAME

azure_storage = AzureBlobStorage(
    storage_container_name=AZURE_STORAGE_CONTAINER_PRIVATE_NAME
)

private_storage_router = APIRouter(
    prefix="/storage/private", tags=["Azure Blob Storage (Private)"]
)


@private_storage_router.post("/upload", response_model=StorageResponse)
async def upload_image(
    file: UploadFile = File(..., description="Image file to store"),
    custom_name: Optional[str] = None,
    prefix_name: Optional[str] = None,
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
            image=image,
            user_id=user_id,
            filename=file.filename,
            custom_name=custom_name,
            prefix_name=prefix_name,
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


@private_storage_router.get("/get-images", response_model=UserImagesResponse)
async def get_images(
    uid: Optional[str] = None,
    filename_prefix: Optional[str] = None,
    user_info: dict = Depends(get_current_user),
):
    """
    Get list of images by user ID and/or filename (requires authentication)
    Admins can access all users' images by specifying uid parameter.

    Args:
        uid: Optional user ID. If provided and user is admin, returns that user's images. 
             If not provided, returns current user's images.
        filename_prefix: Optional filename prefix for server-side filtering (searches files starting with this value).

    Returns:
        List of images with their URLs
    """
    try:
        current_uid = user_info.get("uid", "unknown")
        
        # Check if user is admin
        user_role = firebase_auth.get_user_role(current_uid)
        is_admin = user_role == "admin"
        
        # Determine which user's images to retrieve
        if uid and is_admin:
            # Admin can access any user's images
            target_uid = uid
        elif uid and not is_admin:
            # Non-admin cannot access other users' images
            raise HTTPException(
                status_code=403, 
                detail="Only admins can access other users' images"
            )
        else:
            # No uid specified, use current user
            target_uid = current_uid
        
        blob_names = azure_storage.list_user_blobs(
            user_id=target_uid, filename_prefix=filename_prefix
        )

        # Generate SAS URLs for each blob
        images = []
        for blob_name in blob_names:
            sas_url = azure_storage.get_blob_url_with_sas(blob_name, expiry_hours=24)
            if sas_url:
                images.append(
                    StorageResponse(success=True, blob_name=blob_name, blob_url=sas_url)
                )

        return UserImagesResponse(
            user_id=target_uid, count=len(images), images=images
        )

    except HTTPException:
        raise
    except Exception as e:
        print(f"Error listing images: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to list images: {str(e)}")


@private_storage_router.delete("/image/{blob_name:path}")
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
