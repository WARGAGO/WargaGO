"""
PyTorch to ONNX Converter Script

This script converts PyTorch models (.pth) to ONNX format (.onnx) for deployment
and cross-platform inference.

Usage:
    python pth_to_onnx.py --model_path path/to/model.pth --output_path path/to/output.onnx
    
    # For MLP models
    python pth_to_onnx.py --model_path mlpv2.pth --model_type mlpv2 --num_features 44 --num_classes 4
    
    # For EfficientNetV2 models
    python pth_to_onnx.py --model_path effnet.pth --model_type efficientnet --input_size 224
"""

import argparse
import sys
import os
from pathlib import Path

import torch
import torch.onnx

# Add parent directory to path to import custom models
sys.path.append(str(Path(__file__).parent.parent))

from lib.model_v2 import ModelMLPV2
from lib.model_effnet import EfficientNetV2Model


def load_model(model_path, model_type, **kwargs):
    """
    Load PyTorch model from checkpoint.
    
    Args:
        model_path: Path to the .pth file
        model_type: Type of model ('mlpv2', 'efficientnet')
        **kwargs: Additional model parameters
    
    Returns:
        Loaded PyTorch model in eval mode
    """
    print(f"Loading model from: {model_path}")
    
    # Initialize model based on type
    if model_type == "mlpv2":
        model = ModelMLPV2(
            num_features=kwargs.get("num_features", 44),
            num_classes=kwargs.get("num_classes", 5),
            hidden_dims=kwargs.get("hidden_dims", [256, 512, 256, 128]),
            dropout_rate=kwargs.get("dropout_rate", 0.3),
            use_residual=kwargs.get("use_residual", True),
        )
    elif model_type == "efficientnet":
        model = EfficientNetV2Model(
            num_classes=kwargs.get("num_classes", 5),
            dropout_rate=kwargs.get("dropout_rate", 0.5),
            pretrained=False,  # We're loading weights from checkpoint
        )
    else:
        raise ValueError(f"Unknown model type: {model_type}")
    
    # Load checkpoint
    checkpoint = torch.load(model_path, map_location="cpu")
    
    # Handle different checkpoint formats
    if isinstance(checkpoint, dict):
        if "model_state_dict" in checkpoint:
            model.load_state_dict(checkpoint["model_state_dict"])
            print(f"Loaded model state dict (epoch: {checkpoint.get('epoch', 'N/A')})")
        elif "state_dict" in checkpoint:
            model.load_state_dict(checkpoint["state_dict"])
        else:
            model.load_state_dict(checkpoint)
    else:
        model.load_state_dict(checkpoint)
    
    model.eval()
    print(f"Model loaded successfully and set to evaluation mode")
    
    return model


def convert_to_onnx(
    model,
    dummy_input,
    output_path,
    opset_version=11,
    dynamic_axes=None,
    input_names=None,
    output_names=None,
):
    """
    Convert PyTorch model to ONNX format.
    
    Args:
        model: PyTorch model to convert
        dummy_input: Example input tensor for tracing
        output_path: Path to save the ONNX model
        opset_version: ONNX opset version (default: 11)
        dynamic_axes: Dictionary of dynamic axes for inputs/outputs
        input_names: List of input tensor names
        output_names: List of output tensor names
    """
    print(f"\nConverting to ONNX format...")
    print(f"Opset version: {opset_version}")
    
    # Default names if not provided
    if input_names is None:
        input_names = ["input"]
    if output_names is None:
        output_names = ["output"]
    
    # Export to ONNX
    torch.onnx.export(
        model,
        dummy_input,
        output_path,
        export_params=True,
        opset_version=opset_version,
        do_constant_folding=True,
        input_names=input_names,
        output_names=output_names,
        dynamic_axes=dynamic_axes,
        external_data=False
    )
    
    print(f"ONNX model saved to: {output_path}")


def verify_onnx_model(onnx_path, dummy_input):
    """
    Verify the exported ONNX model.
    
    Args:
        onnx_path: Path to the ONNX model
        dummy_input: Example input tensor for verification
    """
    try:
        import onnx
        import onnxruntime as ort
        
        print(f"\nVerifying ONNX model...")
        
        # Check model
        onnx_model = onnx.load(onnx_path)
        onnx.checker.check_model(onnx_model)
        print("✓ ONNX model is valid")
        
        # Test inference
        ort_session = ort.InferenceSession(onnx_path)
        input_name = ort_session.get_inputs()[0].name
        
        # Prepare input
        if isinstance(dummy_input, torch.Tensor):
            input_data = dummy_input.numpy()
        else:
            input_data = dummy_input
        
        outputs = ort_session.run(None, {input_name: input_data})
        print(f"✓ ONNX Runtime inference successful")
        print(f"  Output shape: {outputs[0].shape}")
        
        return True
        
    except ImportError as e:
        print(f"⚠ Warning: Could not verify ONNX model - {e}")
        print("  Install onnx and onnxruntime to enable verification:")
        print("  pip install onnx onnxruntime")
        return False
    except Exception as e:
        print(f"✗ Error during verification: {e}")
        return False


def get_dummy_input(model_type, **kwargs):
    """
    Create dummy input tensor for model export.
    
    Args:
        model_type: Type of model
        **kwargs: Additional parameters (batch_size, num_features, input_size, etc.)
    
    Returns:
        Dummy input tensor
    """
    batch_size = kwargs.get("batch_size", 1)
    
    if model_type in ["mlpv2"]:
        num_features = kwargs.get("num_features", 44)
        return torch.randn(batch_size, num_features)
    elif model_type == "efficientnet":
        input_size = kwargs.get("input_size", 224)
        return torch.randn(batch_size, 3, input_size, input_size)
    else:
        raise ValueError(f"Unknown model type: {model_type}")


def main():
    parser = argparse.ArgumentParser(
        description="Convert PyTorch model (.pth) to ONNX format"
    )
    
    # Required arguments
    parser.add_argument(
        "--model_path",
        type=str,
        required=True,
        help="Path to the PyTorch model (.pth file)",
    )
    parser.add_argument(
        "--output_path",
        type=str,
        help="Path to save the ONNX model (default: same as input with .onnx extension)",
    )
    
    # Model configuration
    parser.add_argument(
        "--model_type",
        type=str,
        default="mlpv2",
        choices=["mlpv2", "efficientnet"],
        help="Type of model to convert",
    )
    
    # MLP-specific arguments
    parser.add_argument(
        "--num_features",
        type=int,
        default=44,
        help="Number of input features for MLP models",
    )
    parser.add_argument(
        "--num_classes",
        type=int,
        default=5,
        help="Number of output classes",
    )
    parser.add_argument(
        "--hidden_dims",
        type=int,
        nargs="+",
        default=[256, 512, 256, 128],
        help="Hidden layer dimensions for MLP",
    )
    parser.add_argument(
        "--hidden_dim",
        type=int,
        default=256,
        help="Hidden dimension for Attention MLP",
    )
    
    # EfficientNet-specific arguments
    parser.add_argument(
        "--input_size",
        type=int,
        default=224,
        help="Input image size for EfficientNet",
    )
    
    # ONNX export arguments
    parser.add_argument(
        "--opset_version",
        type=int,
        default=20,
        help="ONNX opset version (default: 20, recommended range: 11-20)",
    )
    parser.add_argument(
        "--batch_size",
        type=int,
        default=1,
        help="Batch size for dummy input",
    )
    parser.add_argument(
        "--dynamic_batch",
        action="store_true",
        help="Enable dynamic batch size in ONNX model",
    )
    parser.add_argument(
        "--verify",
        action="store_true",
        default=True,
        help="Verify the exported ONNX model",
    )
    parser.add_argument(
        "--no_verify",
        action="store_true",
        help="Skip ONNX model verification",
    )
    
    args = parser.parse_args()
    
    # Set output path
    if args.output_path is None:
        args.output_path = Path(args.model_path).with_suffix(".onnx")
    
    # Create output directory if needed
    os.makedirs(os.path.dirname(args.output_path) or ".", exist_ok=True)
    
    # Load model
    model = load_model(
        args.model_path,
        args.model_type,
        num_features=args.num_features,
        num_classes=args.num_classes,
        hidden_dims=args.hidden_dims,
        hidden_dim=args.hidden_dim,
        input_size=args.input_size,
    )
    
    # Create dummy input
    dummy_input = get_dummy_input(
        args.model_type,
        batch_size=args.batch_size,
        num_features=args.num_features,
        input_size=args.input_size,
    )
    
    print(f"Dummy input shape: {dummy_input.shape}")
    
    # Set up dynamic axes if requested
    dynamic_axes = None
    if args.dynamic_batch:
        dynamic_axes = {
            "input": {0: "batch_size"},
            "output": {0: "batch_size"},
        }
        print("Dynamic batch size enabled")
    
    # Convert to ONNX
    convert_to_onnx(
        model,
        dummy_input,
        args.output_path,
        opset_version=args.opset_version,
        dynamic_axes=dynamic_axes,
        input_names=["input"],
        output_names=["output"],
    )
    
    # Verify ONNX model
    if args.verify and not args.no_verify:
        verify_onnx_model(args.output_path, dummy_input)
    
    print(f"\n✓ Conversion complete!")
    print(f"  Model saved to: {args.output_path}")
    
    # Print model info
    model_size = os.path.getsize(args.output_path) / (1024 * 1024)
    print(f"  Model size: {model_size:.2f} MB")


if __name__ == "__main__":
    main()
