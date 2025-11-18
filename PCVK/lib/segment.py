# @markdown ### Segment.py - Image Segmentation Functions
import cv2
import numpy as np
import torch
from torchvision import transforms
from PIL import Image
import os


def apply_clahe(img, clip_limit=2.0, tile_grid_size=(8, 8)):
    """
    Apply CLAHE (Contrast Limited Adaptive Histogram Equalization)
    State-of-the-art adaptive contrast enhancement method

    Args:
        img: Input image (BGR)
        clip_limit: Threshold for contrast limiting (higher = more contrast)
        tile_grid_size: Size of grid for histogram equalization

    Returns:
        Enhanced image with improved contrast
    """
    # Convert to LAB color space for better color preservation
    lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
    l, a, b = cv2.split(lab)

    # Apply CLAHE to L-channel only
    clahe = cv2.createCLAHE(clipLimit=clip_limit, tileGridSize=tile_grid_size)
    cl = clahe.apply(l)

    # Merge channels and convert back to BGR
    enhanced_lab = cv2.merge((cl, a, b))
    enhanced = cv2.cvtColor(enhanced_lab, cv2.COLOR_LAB2BGR)

    return enhanced


def apply_automatic_brightness_contrast(img, clip_hist_percent=1):
    """
    Automatic brightness and contrast optimization

    Args:
        img: Input image (BGR)
        clip_hist_percent: Percentage of histogram to clip

    Returns:
        Optimized image
    """
    # Convert to YUV color space
    yuv = cv2.cvtColor(img, cv2.COLOR_BGR2YUV)

    # Calculate grayscale histogram
    gray = yuv[:, :, 0]
    hist = cv2.calcHist([gray], [0], None, [256], [0, 256])
    hist_size = len(hist)

    # Calculate cumulative distribution
    accumulator = []
    accumulator.append(float(hist[0]))
    for index in range(1, hist_size):
        accumulator.append(accumulator[index - 1] + float(hist[index]))

    # Locate points to clip
    maximum = accumulator[-1]
    clip_hist_percent *= maximum / 100.0
    clip_hist_percent /= 2.0

    # Locate left cut
    minimum_gray = 0
    while accumulator[minimum_gray] < clip_hist_percent:
        minimum_gray += 1

    # Locate right cut
    maximum_gray = hist_size - 1
    while accumulator[maximum_gray] >= (maximum - clip_hist_percent):
        maximum_gray -= 1

    # Calculate alpha and beta values
    alpha = 255 / (maximum_gray - minimum_gray)
    beta = -minimum_gray * alpha

    # Apply brightness and contrast
    yuv[:, :, 0] = cv2.convertScaleAbs(yuv[:, :, 0], alpha=alpha, beta=beta)

    # Convert back to BGR
    enhanced = cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR)

    return enhanced


def segment_grabcut(img, iterations=5):
    """
    Segment image using GrabCut algorithm

    Args:
        img: Input image (BGR)
        iterations: Number of GrabCut iterations

    Returns:
        Segmented image with background removed
    """
    # Create mask
    mask = np.zeros(img.shape[:2], np.uint8)

    # Background and foreground models (required by GrabCut)
    bgd_model = np.zeros((1, 65), np.float64)
    fgd_model = np.zeros((1, 65), np.float64)

    # Define rectangle around the object (with 10% margin)
    h, w = img.shape[:2]
    margin = int(min(h, w) * 0.1)
    rect = (margin, margin, w - 2 * margin, h - 2 * margin)

    # Apply GrabCut
    cv2.grabCut(
        img, mask, rect, bgd_model, fgd_model, iterations, cv2.GC_INIT_WITH_RECT
    )

    # Create binary mask (0: background, 1: foreground)
    mask2 = np.where((mask == 2) | (mask == 0), 0, 1).astype("uint8")

    # Apply mask to image
    segmented = img * mask2[:, :, np.newaxis]

    return segmented


def segment_adaptive_threshold(img, kernel_size=5):
    """
    Segment image using adaptive thresholding and morphological operations

    Args:
        img: Input image (BGR)
        kernel_size: Size of morphological kernel

    Returns:
        Segmented image with background removed
    """
    # Convert to grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Apply Gaussian blur to reduce noise
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)

    # Adaptive thresholding
    thresh = cv2.adaptiveThreshold(
        blurred, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 11, 2
    )

    # Morphological operations to clean up mask
    kernel = np.ones((kernel_size, kernel_size), np.uint8)
    thresh = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)
    thresh = cv2.morphologyEx(thresh, cv2.MORPH_OPEN, kernel)

    # Find largest contour (assumed to be the vegetable)
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    if contours:
        # Get largest contour
        largest_contour = max(contours, key=cv2.contourArea)

        # Create mask from largest contour
        mask = np.zeros_like(gray)
        cv2.drawContours(mask, [largest_contour], -1, 255, -1)

        # Apply mask to original image
        segmented = cv2.bitwise_and(img, img, mask=mask)
    else:
        segmented = img

    return segmented


def segment_hsv_color(img, lower_bound=(20, 40, 40), upper_bound=(180, 255, 255)):
    """
    Segment image using HSV color space filtering
    Useful for removing white/bright backgrounds

    Args:
        img: Input image (BGR)
        lower_bound: Lower HSV threshold (H, S, V)
        upper_bound: Upper HSV threshold (H, S, V)

    Returns:
        Segmented image with background removed
    """
    # Convert to HSV color space
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # Create mask based on HSV range
    mask = cv2.inRange(hsv, np.array(lower_bound), np.array(upper_bound))

    # Morphological operations to refine mask
    kernel = np.ones((5, 5), np.uint8)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)

    # Apply mask to original image
    segmented = cv2.bitwise_and(img, img, mask=mask)

    return segmented


def segment_u2netp(img, model_path=None):
    """
    Segment image using U2Net-P (Portrait) model

    Args:
        img: Input image (BGR format from OpenCV)
        model_path: Path to U2Net-P model weights (optional, will download if not provided)

    Returns:
        Segmented image with background removed
    """
    try:
        # Import U2Net model
        from torchvision.models import detection

        # Lazy load model
        global _u2netp_model
        if "_u2netp_model" not in globals():
            _u2netp_model = None

        if _u2netp_model is None:
            # Load or download U2Net-P model
            device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

            # Try to import rembg (which includes U2Net models)

            from rembg import remove, new_session

            # Use rembg for easier implementation
            img_pil = Image.fromarray(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
            output = remove(img_pil, session=new_session("u2netp"))
            # Convert back to OpenCV format
            output_np = np.array(output)
            # If output has alpha channel, apply it as mask
            if output_np.shape[2] == 4:
                # Extract RGB and alpha
                rgb = output_np[:, :, :3]
                alpha = output_np[:, :, 3]
                # Apply alpha channel as mask
                mask = alpha.astype(float) / 255.0
                segmented = (rgb * mask[:, :, np.newaxis]).astype(np.uint8)
                # Convert back to BGR
                segmented = cv2.cvtColor(segmented, cv2.COLOR_RGB2BGR)
            else:
                segmented = cv2.cvtColor(output_np, cv2.COLOR_RGB2BGR)
            return segmented

        # Manual implementation (if rembg is not available)
        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

        # Preprocess image
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img_pil = Image.fromarray(img_rgb)

        # Define transforms
        transform = transforms.Compose(
            [
                transforms.Resize((224, 224)),
                transforms.ToTensor(),
                transforms.Normalize(
                    mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]
                ),
            ]
        )

        input_tensor = transform(img_pil).unsqueeze(0).to(device)

        # Get prediction
        with torch.no_grad():
            output = _u2netp_model(input_tensor)

            # U2Net returns multiple outputs, use the first one
            if isinstance(output, tuple) or isinstance(output, list):
                pred = output[0]
            else:
                pred = output

            # Normalize prediction to [0, 1]
            pred = torch.sigmoid(pred)
            pred = pred.squeeze().cpu().numpy()

        # Resize mask to original image size
        h, w = img.shape[:2]
        mask = cv2.resize(pred, (w, h))

        # Threshold mask
        mask = (mask > 0.5).astype(np.uint8) * 255

        # Apply morphological operations to refine mask
        kernel = np.ones((3, 3), np.uint8)
        mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
        mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)

        # Apply mask to original image
        segmented = cv2.bitwise_and(img, img, mask=mask)

        return segmented

    except Exception as e:
        print(f"U2Net-P segmentation failed: {e}")
        print("Falling back to HSV segmentation...")
        return segment_hsv_color(img)


def auto_segment(img, method="grabcut", applyBrightContClahe=True):
    """
    Automatic segmentation with multiple method options

    Args:
        img: Input image (BGR)
        method: 'grabcut', 'adaptive', 'hsv', 'u2netp', or 'none'

    Returns:
        Segmented image
    """
    img = cv2.resize(img, (224, 224))

    if method == "grabcut":
        result = segment_grabcut(img)
    elif method == "adaptive":
        result = segment_adaptive_threshold(img)
    elif method == "hsv":
        result = segment_hsv_color(img)
    elif method == "u2netp":
        result = segment_u2netp(img)
    else:
        result = img

    if applyBrightContClahe:
        return apply_clahe(apply_automatic_brightness_contrast(result))
    return result
