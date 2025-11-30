import 'package:wargago/core/enums/pcvk_modeltype.dart';

class WebSocketConfig {
  final bool useSegmentation;
  final String segMethod;
  final PcvkModelType modelType;
  final bool applyBrightnessContrast;
  final bool returnProcessedImage;

  WebSocketConfig({
    this.useSegmentation = true,
    this.segMethod = 'u2netp',
    this.modelType = PcvkModelType.mlpv2AutoClahe,
    this.applyBrightnessContrast = true,
    this.returnProcessedImage = false,
  });

  factory WebSocketConfig.fromJson(Map<String, dynamic> json) {
    return WebSocketConfig(
      useSegmentation: json['use_segmentation'] as bool,
      segMethod: json['seg_method'] as String,
      modelType: PcvkModelType.fromString(json['model_type'] as String),
      applyBrightnessContrast: json['apply_brightness_contrast'] as bool,
      returnProcessedImage: json['return_processed_image'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'use_segmentation': useSegmentation,
      'seg_method': segMethod,
      'model_type': modelType.value,
      'apply_brightness_contrast': applyBrightnessContrast,
      'return_processed_image': returnProcessedImage,
    };
  }
}
