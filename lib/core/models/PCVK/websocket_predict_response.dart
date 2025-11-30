import 'package:wargago/core/enums/predict_class_enum.dart';
import 'package:wargago/core/enums/pcvk_modeltype.dart';

class WebSocketPredictResponse {
  final String type;
  final PredictClass predictedClass;
  final double confidence;
  final Map<String, double> allConfidences;
  final String device;
  final PcvkModelType modelType;
  final bool segmentationUsed;
  final String? segmentationMethod;
  final bool applyBrightnessContrast;
  final double predictionTimeMs;
  final bool hasSegmentationImage;

  WebSocketPredictResponse({
    required this.type,
    required this.predictedClass,
    required this.confidence,
    required this.allConfidences,
    required this.device,
    required this.modelType,
    required this.segmentationUsed,
    this.segmentationMethod,
    required this.applyBrightnessContrast,
    required this.predictionTimeMs,
    required this.hasSegmentationImage,
  });

  factory WebSocketPredictResponse.fromJson(Map<String, dynamic> json) {
    final predictedClassString = json['predicted_class'] as String;
    final predictedClass = PredictClass.values.firstWhere(
      (e) => e.displayName == predictedClassString,
      orElse: () => PredictClass.sayurAkar,
    );

    return WebSocketPredictResponse(
      type: json['type'] as String,
      predictedClass: predictedClass,
      confidence: (json['confidence'] as num).toDouble(),
      allConfidences: Map<String, double>.from(
        json['all_confidences'] as Map<String, dynamic>,
      ),
      device: json['device'] as String,
      modelType: PcvkModelType.fromString(json['model_type'] as String),
      segmentationUsed: json['segmentation_used'] as bool,
      segmentationMethod: json['segmentation_method'] as String?,
      applyBrightnessContrast: json['apply_brightness_contrast'] as bool,
      predictionTimeMs: (json['prediction_time_ms'] as num).toDouble(),
      hasSegmentationImage: json['has_segmentation_image'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'predicted_class': predictedClass.displayName,
      'confidence': confidence,
      'all_confidences': allConfidences,
      'device': device,
      'model_type': modelType.value,
      'segmentation_used': segmentationUsed,
      'segmentation_method': segmentationMethod,
      'apply_brightness_contrast': applyBrightnessContrast,
      'prediction_time_ms': predictionTimeMs,
      'has_segmentation_image': hasSegmentationImage,
    };
  }

  @override
  String toString() {
    return 'WebSocketPredictionResponse(type: $type, predictedClass: $predictedClass, confidence: $confidence, device: $device, modelType: $modelType, predictionTime: ${predictionTimeMs}ms)';
  }
}
