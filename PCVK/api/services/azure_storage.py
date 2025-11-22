"""
Azure Blob Storage service for storing images
"""

import io
import uuid
from datetime import datetime, timedelta, timezone
from typing import Optional, Tuple
from PIL import Image
from azure.storage.blob import (
    BlobServiceClient,
    BlobSasPermissions,
    generate_blob_sas,
    BlobClient,
    ContentSettings,
)
from azure.core.exceptions import AzureError

from api.configs.azure_config import (
    AZURE_STORAGE_CONNECTION_STRING,
    AZURE_STORAGE_CONTAINER_NAME,
    WEBP_QUALITY,
    validate_azure_config,
)


class AzureBlobStorage:
    """Service for managing image storage in Azure Blob Storage"""

    def __init__(self):
        """Initialize Azure Blob Storage client"""
        self.enabled = validate_azure_config()

        if not self.enabled:
            print("Azure Blob Storage is disabled due to missing configuration")
            self.blob_service_client = None
            self.container_client = None
            return

        try:
            # Initialize blob service client
            self.blob_service_client = BlobServiceClient.from_connection_string(
                AZURE_STORAGE_CONNECTION_STRING
            )

            # Get container client
            self.container_client = self.blob_service_client.get_container_client(
                AZURE_STORAGE_CONTAINER_NAME
            )

            # Create container if it doesn't exist
            try:
                self.container_client.create_container()
                print(f"Created container: {AZURE_STORAGE_CONTAINER_NAME}")
            except AzureError:
                # Container already exists
                pass

            print(f"Azure Blob Storage initialized: {AZURE_STORAGE_CONTAINER_NAME}")

        except Exception as e:
            print(f"Error initializing Azure Blob Storage: {e}")
            self.enabled = False
            self.blob_service_client = None
            self.container_client = None

    def convert_to_webp(self, image: Image.Image) -> bytes:
        """
        Convert PIL Image to WebP format

        Args:
            image: PIL Image object

        Returns:
            WebP image bytes
        """
        # Convert RGBA to RGB if necessary
        if image.mode in ("RGBA", "LA", "P"):
            background = Image.new("RGB", image.size, (255, 255, 255))
            if image.mode == "P":
                image = image.convert("RGBA")
            background.paste(
                image, mask=image.split()[-1] if image.mode in ("RGBA", "LA") else None
            )
            image = background

        # Save to WebP format
        output = io.BytesIO()
        image.save(output, format="WEBP", quality=WEBP_QUALITY, method=6)
        output.seek(0)
        return output.getvalue()

    def upload_image(
        self,
        image: Image.Image,
        user_id: str,
        filename: Optional[str] = None,
        custom_name: Optional[str] = None,
        metadata: Optional[dict] = None,
    ) -> Tuple[Optional[str], Optional[str]]:
        """
        Upload image to Azure Blob Storage as WebP

        Args:
            image: PIL Image object
            user_id: User ID from Firebase auth
            filename: Optional original filename
            custom_name: Optional custom name for the blob (without extension)
            metadata: Optional metadata dictionary

        Returns:
            Tuple of (blob_name, blob_url) or (None, None) if failed
        """
        if not self.enabled or not self.container_client:
            print("Azure Blob Storage is not enabled")
            return None, None

        try:
            # Generate unique blob name
            if custom_name:
                # Use custom name, ensure it ends with .webp
                safe_name = custom_name.replace("/", "_").replace("\\", "_")
                if not safe_name.endswith(".webp"):
                    safe_name = (
                        safe_name.rsplit(".", 1)[0] if "." in safe_name else safe_name
                    )
                    safe_name += ".webp"
                blob_name = f"{user_id}/{safe_name}"
            else:
                # Generate timestamp-based name
                timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
                unique_id = str(uuid.uuid4())[:8]
                blob_name = f"{user_id}/{timestamp}_{unique_id}.webp"

            # Convert image to WebP
            webp_bytes = self.convert_to_webp(image)

            # Prepare metadata
            blob_metadata = {
                "user_id": user_id,
                "uploaded_at": datetime.now(timezone.utc).isoformat(),
                "format": "webp",
                "original_filename": filename or "unknown",
            }

            if metadata:
                blob_metadata.update(metadata)

            # Upload to Azure Blob Storage
            blob_client = self.container_client.get_blob_client(blob_name)
            blob_client.upload_blob(
                webp_bytes,
                overwrite=True,
                metadata=blob_metadata,
                content_settings=ContentSettings(content_type="image/webp"),
            )

            # Get blob URL
            blob_url = blob_client.url

            print(f"Uploaded image to Azure: {blob_name}")
            return blob_name, blob_url

        except Exception as e:
            print(f"Error uploading image to Azure: {e}")
            return None, None

    def get_blob_url_with_sas(
        self, blob_name: str, expiry_hours: int = 24
    ) -> Optional[str]:
        """
        Get blob URL with SAS token for temporary access

        Args:
            blob_name: Name of the blob
            expiry_hours: Hours until SAS token expires

        Returns:
            URL with SAS token or None if failed
        """
        if not self.enabled or not self.container_client:
            return None

        try:
            # Get blob client
            blob_client = self.container_client.get_blob_client(blob_name)

            # Generate SAS token using the blob client's credential
            # This method works with connection strings
            start_time = datetime.now(timezone.utc)
            expiry_time = start_time + timedelta(hours=expiry_hours)

            sas_token = generate_blob_sas(
                account_name=self.blob_service_client.account_name,
                container_name=AZURE_STORAGE_CONTAINER_NAME,
                blob_name=blob_name,
                account_key=self.blob_service_client.credential.account_key,
                permission=BlobSasPermissions(read=True),
                expiry=expiry_time,
                start=start_time,
            )

            # Construct URL with SAS
            blob_url_with_sas = f"{blob_client.url}?{sas_token}"

            return blob_url_with_sas

        except Exception as e:
            print(f"Error generating SAS URL: {e}")
            return None

    def delete_blob(self, blob_name: str) -> bool:
        """
        Delete blob from storage

        Args:
            blob_name: Name of the blob to delete

        Returns:
            True if successful, False otherwise
        """
        if not self.enabled or not self.container_client:
            return False

        try:
            blob_client = self.container_client.get_blob_client(blob_name)
            blob_client.delete_blob()
            print(f"Deleted blob: {blob_name}")
            return True

        except Exception as e:
            print(f"Error deleting blob: {e}")
            return False

    def list_user_blobs(self, user_id: str = None) -> list:
        """
        List all blobs for a specific user

        Args:
            user_id: User ID from Firebase auth

        Returns:
            List of blob names
        """
        if not self.enabled or not self.container_client:
            return []

        try:
            if user_id is None:
                blobs = self.container_client.list_blobs()
            else:
                blobs = self.container_client.list_blobs(name_starts_with=f"{user_id}/")
            return [blob.name for blob in blobs]

        except Exception as e:
            print(f"Error listing blobs: {e}")
            return []


# Global instance
azure_storage = AzureBlobStorage()
