"""
Gradio web interface for vegetable classification
"""

import os
import time
import gradio as gr
import cv2
import numpy as np
from PIL import Image

from api.services.classification.model_loader import model_manager
from api.services.classification.inference import predict_image


def unload_all_models():
    """
    Unload all models from memory
    """
    try:
        loaded_models = model_manager.get_loaded_models().copy()
        if len(loaded_models) == 0:
            return "No models are currently loaded."
        
        success = model_manager.unload_all_models()
        if success:
            return f"Successfully unloaded {len(loaded_models)} model(s): {', '.join(loaded_models)}"
        else:
            return "Failed to unload models."
    except Exception as e:
        return f"Error unloading models: {str(e)}"


def gradio_predict(
    image,
    use_segmentation,
    seg_method,
    model_type,
    use_custom_params,
    hsv_h_lower,
    hsv_s_lower,
    hsv_v_lower,
    hsv_h_upper,
    hsv_s_upper,
    hsv_v_upper,
    grabcut_iterations,
    adaptive_kernel_size,
    apply_brightness_contrast,
):
    """
    Wrapper function for Gradio interface
    """
    try:
        # Start timing
        start_time = time.time()
        
        # Load model if not already loaded
        if not model_manager.is_loaded(model_type):
            print(f"Model {model_type} not loaded, loading now...")
            success = model_manager.load_model(model_type)
            if not success:
                return f"Error: Failed to load model '{model_type}'", {}, None
        
        # Get model
        model = model_manager.get_model(model_type)
        is_onnx = model_manager.get_model_type(model_type) == 'onnx'
        
        # EfficientNetV2 uses direct image without preprocessing
        if model_type == "efficientnetv2":
            # Convert to PIL Image if needed
            if not isinstance(image, Image.Image):
                image = Image.fromarray(image)
            
            # Perform prediction (no segmentation, no preprocessing)
            predicted_class, confidence_value, all_confidences, _ = predict_image(
                model=model,
                image=image,
                use_segmentation=False,
                seg_method="none",
                apply_brightness_contrast=False,
                model_type=model_type,
                is_onnx=is_onnx
            )
            
            # Calculate prediction time
            prediction_time_ms = (time.time() - start_time) * 1000
            
            # Format output
            result_text = f"**Prediksi:** {predicted_class}\n\n**Confidence:** {confidence_value:.2%}\n\n**Model:** {model_type.upper()}\n\n**Waktu Prediksi:** {prediction_time_ms:.2f} ms"
            
            # Return original image as "segmented" output
            return result_text, all_confidences, np.array(image)
        
        # Feature-based models (MLP variants)
        # Convert PIL Image to numpy array (BGR for OpenCV)
        if isinstance(image, Image.Image):
            image_np = np.array(image)
            image_bgr = cv2.cvtColor(image_np, cv2.COLOR_RGB2BGR)
            image_bgr = cv2.resize(image_bgr, (224, 224))
        else:
            image_bgr = image

        # Apply segmentation if enabled
        if use_segmentation and seg_method != "none":
            if seg_method == "hsv":
                import sys
                sys.path.append(os.path.join(os.path.dirname(__file__), ".."))
                from lib.segment import segment_hsv_color, apply_clahe, apply_automatic_brightness_contrast
                segmented_img = segment_hsv_color(
                    image_bgr.copy(),
                    lower_bound=(
                        (hsv_h_lower, hsv_s_lower, hsv_v_lower)
                        if use_custom_params
                        else (20, 40, 40)
                    ),
                    upper_bound=(
                        (hsv_h_upper, hsv_s_upper, hsv_v_upper)
                        if use_custom_params
                        else (180, 255, 255)
                    ),
                )
                if apply_brightness_contrast:
                    segmented_img = apply_clahe(apply_automatic_brightness_contrast(segmented_img))
            elif seg_method == "grabcut":
                import sys
                sys.path.append(os.path.join(os.path.dirname(__file__), ".."))
                from lib.segment import segment_grabcut, apply_clahe, apply_automatic_brightness_contrast
                segmented_img = segment_grabcut(
                    image_bgr.copy(),
                    iterations=grabcut_iterations if use_custom_params else 5,
                )
                if apply_brightness_contrast:
                    segmented_img = apply_clahe(apply_automatic_brightness_contrast(segmented_img))
            elif seg_method == "adaptive":
                import sys
                sys.path.append(os.path.join(os.path.dirname(__file__), ".."))
                from lib.segment import segment_adaptive_threshold, apply_clahe, apply_automatic_brightness_contrast
                segmented_img = segment_adaptive_threshold(
                    image_bgr.copy(),
                    kernel_size=adaptive_kernel_size if use_custom_params else 5,
                )
                if apply_brightness_contrast:
                    segmented_img = apply_clahe(apply_automatic_brightness_contrast(segmented_img))
            else:
                import sys
                sys.path.append(os.path.join(os.path.dirname(__file__), ".."))
                from lib.segment import auto_segment
                segmented_img = auto_segment(image_bgr.copy(), method=seg_method, applyBrightContClahe=apply_brightness_contrast)
        else:
            segmented_img = image_bgr.copy()

        # Convert to PIL Image for prediction
        segmented_pil = Image.fromarray(cv2.cvtColor(segmented_img, cv2.COLOR_BGR2RGB))
        
        # Perform prediction
        predicted_class, confidence_value, all_confidences, _ = predict_image(
            model=model,
            image=segmented_pil,
            use_segmentation=False,  # Already segmented above
            seg_method="none",
            apply_brightness_contrast=False,
            model_type=model_type,
            is_onnx=is_onnx
        )

        # Calculate prediction time
        prediction_time_ms = (time.time() - start_time) * 1000

        # Format output
        result_text = f"**Prediksi:** {predicted_class}\n\n**Confidence:** {confidence_value:.2%}\n\n**Model:** {model_type.upper()}\n\n**Waktu Prediksi:** {prediction_time_ms:.2f} ms"

        # Convert segmented image back to RGB for display
        segmented_rgb = cv2.cvtColor(segmented_img, cv2.COLOR_BGR2RGB)

        return result_text, all_confidences, segmented_rgb

    except Exception as e:
        print(f"Error during prediction: {e}")
        import traceback
        traceback.print_exc()
        return f"Error: {str(e)}", {}, None


def create_gradio_interface():
    """
    Create Gradio interface for the web UI
    """
    with gr.Blocks(title="Klasifikasi Sayuran") as demo:
        gr.Markdown(
            """
            # 🥬 Sistem Klasifikasi Sayuran
            
            Upload gambar sayuran untuk mengklasifikasikannya ke dalam 5 kategori:
            - **Sayur Akar** (wortel, kentang, lobak)
            - **Sayur Buah** (tomat, pepaya, labu, timun, pare, cabai cina)
            - **Sayur Bunga** (brocoli, kembang kol)
            - **Sayur Daun** (kubis)
            - **Sayur Polong** (buncis)            
          
            """
        )

        with gr.Row():
            with gr.Column():
                input_image = gr.Image(type="pil", label="Upload Gambar Sayuran")

                predict_btn = gr.Button("🔍 Klasifikasi", variant="primary", size="lg")
                
                with gr.Row():
                    unload_btn = gr.Button("🗑️ Unload All Models", variant="secondary", size="sm")
                
                unload_status = gr.Textbox(label="Status", interactive=False, visible=False)
                with gr.Accordion("Pengaturan Model dan Segmentasi", open=True):
                    # Model selection
                    model_type = gr.Radio(
                        choices=["mlpv2", "mlpv2_auto-clahe", "efficientnetv2"],
                        value="mlpv2_auto-clahe",
                        label="Pilih Model",
                        info="MLPv2: Advanced with residual connections, MLPv2 Auto-CLAHE: MLPv2 trained with automatic brightness/contrast enhancement, EfficientNetV2: CNN-based direct image processing (no preprocessing)"
                    )
                    
                    use_seg = gr.Checkbox(
                        value=True,
                        label="Gunakan Segmentasi",
                        info="Memisahkan objek dari background",
                    )
                    seg_method = gr.Radio(
                        choices=["hsv", "grabcut", "adaptive", "u2netp", "none"],
                        value="u2netp",
                        label="Metode Segmentasi",
                        info="HSV: berdasarkan warna, GrabCut: berbasis grafik, Adaptive: threshold adaptif, U2Net-P: deep learning",
                    )
                    
                    # Brightness & Contrast Enhancement
                    apply_brightness_contrast = gr.Checkbox(
                        value=True,
                        label="Gunakan Brightness & Contrast Enhancement (CLAHE)",
                        info="Menerapkan peningkatan kecerahan dan kontras adaptif",
                    )

                    use_custom_params = gr.Checkbox(
                        value=False,
                        label="Gunakan Parameter Custom",
                        info="Centang untuk mengatur parameter secara manual",
                    )

                    # HSV Parameters
                    with gr.Group(visible=True) as hsv_params:
                        gr.Markdown("**Parameter HSV**")
                        with gr.Row():
                            hsv_h_lower = gr.Slider(
                                minimum=0,
                                maximum=179,
                                value=20,
                                step=1,
                                label="Hue Lower",
                                info="Batas bawah Hue (0-179)",
                                interactive=False,
                            )
                            hsv_h_upper = gr.Slider(
                                minimum=0,
                                maximum=179,
                                value=179,
                                step=1,
                                label="Hue Upper",
                                info="Batas atas Hue (0-179)",
                                interactive=False,
                            )
                        with gr.Row():
                            hsv_s_lower = gr.Slider(
                                minimum=0,
                                maximum=255,
                                value=40,
                                step=1,
                                label="Saturation Lower",
                                info="Batas bawah Saturasi (0-255)",
                                interactive=False,
                            )
                            hsv_s_upper = gr.Slider(
                                minimum=0,
                                maximum=255,
                                value=255,
                                step=1,
                                label="Saturation Upper",
                                info="Batas atas Saturasi (0-255)",
                                interactive=False,
                            )
                        with gr.Row():
                            hsv_v_lower = gr.Slider(
                                minimum=0,
                                maximum=255,
                                value=40,
                                step=1,
                                label="Value Lower",
                                info="Batas bawah Value (0-255)",
                                interactive=False,
                            )
                            hsv_v_upper = gr.Slider(
                                minimum=0,
                                maximum=255,
                                value=255,
                                step=1,
                                label="Value Upper",
                                info="Batas atas Value (0-255)",
                                interactive=False,
                            )

                    # GrabCut Parameters
                    with gr.Group(visible=False) as grabcut_params:
                        gr.Markdown("**Parameter GrabCut**")
                        grabcut_iterations = gr.Slider(
                            minimum=1,
                            maximum=10,
                            value=5,
                            step=1,
                            label="Iterasi",
                            info="Jumlah iterasi GrabCut (1-10)",
                            interactive=False,
                        )

                    # Adaptive Threshold Parameters
                    with gr.Group(visible=False) as adaptive_params:
                        gr.Markdown("**Parameter Adaptive Threshold**")
                        adaptive_kernel_size = gr.Slider(
                            minimum=3,
                            maximum=15,
                            value=5,
                            step=2,
                            label="Kernel Size",
                            info="Ukuran kernel morfologi (ganjil)",
                            interactive=False,
                        )

                    # Update parameter visibility based on selected method
                    def update_params_visibility(method):
                        return {
                            hsv_params: gr.update(visible=(method == "hsv")),
                            grabcut_params: gr.update(visible=(method == "grabcut")),
                            adaptive_params: gr.update(visible=(method == "adaptive")),
                        }

                    # Update slider interactivity based on custom params checkbox
                    def update_sliders_interactivity(use_custom):
                        return [
                            gr.update(interactive=use_custom),  # hsv_h_lower
                            gr.update(interactive=use_custom),  # hsv_h_upper
                            gr.update(interactive=use_custom),  # hsv_s_lower
                            gr.update(interactive=use_custom),  # hsv_s_upper
                            gr.update(interactive=use_custom),  # hsv_v_lower
                            gr.update(interactive=use_custom),  # hsv_v_upper
                            gr.update(interactive=use_custom),  # grabcut_iterations
                            gr.update(interactive=use_custom),  # adaptive_kernel_size
                        ]

                    seg_method.change(
                        fn=update_params_visibility,
                        inputs=[seg_method],
                        outputs=[hsv_params, grabcut_params, adaptive_params],
                    )

                    use_custom_params.change(
                        fn=update_sliders_interactivity,
                        inputs=[use_custom_params],
                        outputs=[
                            hsv_h_lower,
                            hsv_h_upper,
                            hsv_s_lower,
                            hsv_s_upper,
                            hsv_v_lower,
                            hsv_v_upper,
                            grabcut_iterations,
                            adaptive_kernel_size,
                        ],
                    )                   

                

            with gr.Column():
                result_text = gr.Markdown(label="Hasil Prediksi")
                confidence_plot = gr.Label(label="Confidence Score", num_top_classes=4)
                segmented_output = gr.Image(label="Gambar Setelah Segmentasi")

        # Connect buttons to functions
        predict_btn.click(
            fn=gradio_predict,
            inputs=[
                input_image,
                use_seg,
                seg_method,
                model_type,
                use_custom_params,
                hsv_h_lower,
                hsv_s_lower,
                hsv_v_lower,
                hsv_h_upper,
                hsv_s_upper,
                hsv_v_upper,
                grabcut_iterations,
                adaptive_kernel_size,
                apply_brightness_contrast,
            ],
            outputs=[result_text, confidence_plot, segmented_output],
        )
        
        unload_btn.click(
            fn=unload_all_models,
            inputs=[],
            outputs=[unload_status],
        ).then(
            fn=lambda: gr.update(visible=True),
            outputs=[unload_status],
        )
        
        gr.Markdown("""
        ---
        ### API Documentation**: [/docs](/docs)
        """)

    return demo
