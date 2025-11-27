import gdown
import os
import sys

# Add parent directory to path to allow imports from outside scripts folder
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from api.configs.pcvk_config import MODEL_PATHS


def download_efficientnetv2_model():
    """Download EfficientNetV2 model from Google Drive if it doesn't exist."""
    model_path = MODEL_PATHS["efficientnetv2"]

    # Check if model already exists
    if os.path.exists(model_path):
        print(f"Model already exists at: {model_path}")
        return

    # Ensure the directory exists
    os.makedirs(os.path.dirname(model_path), exist_ok=True)

    # Google Drive file ID
    file_id = "1JY_hvS_66gMF6uddRe2eZpsaINxR4zuy"

    print(f"Downloading EfficientNetV2 model to: {model_path}")
    gdown.download(id=file_id, output=model_path, quiet=False)
    print("Download complete!")


if __name__ == "__main__":
    download_efficientnetv2_model()
