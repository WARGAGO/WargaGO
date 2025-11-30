import '../../enums/predict_class_enum.dart';

class PredictModelResponse {
  final String fileName;
  final PredictClass predictedClass;
  final double confidence;
  final Map<String, double> allConfidences;
  final String device;
  final String modelType;
  final bool segmentationUsed;
  final String segmentationMethod;
  final bool applyBrightnessContrast;
  final double predictionTimeMs;

  PredictModelResponse({
    required this.fileName,
    required this.predictedClass,
    required this.confidence,
    required this.allConfidences,
    required this.device,
    required this.modelType,
    required this.segmentationUsed,
    required this.segmentationMethod,
    required this.applyBrightnessContrast,
    required this.predictionTimeMs,
  });

  factory PredictModelResponse.fromJson(Map<String, dynamic> json) {
    final allConfidencesJson = json['all_confidences'] as Map<String, dynamic>;
    final allConfidences = <String, double>{};

    allConfidencesJson.forEach((key, value) {
      allConfidences[key] = (value as num).toDouble();
    });

    final predictedClassString = json['predicted_class'] as String;
    print(predictedClassString);
    final predictedClass = PredictClass.values.firstWhere(
      (e) => e.displayName == predictedClassString,
      orElse: () => PredictClass.sayurAkar,
    );

    return PredictModelResponse(
      fileName: json['filename'] as String,
      predictedClass: predictedClass,
      confidence: (json['confidence'] as num).toDouble(),
      allConfidences: allConfidences,
      device: json['device'] as String,
      modelType: json['model_type'] as String,
      segmentationUsed: json['segmentation_used'] as bool,
      segmentationMethod: json['segmentation_method'] as String,
      applyBrightnessContrast: json['apply_brightness_contrast'] as bool,
      predictionTimeMs: (json['prediction_time_ms'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': fileName,
      'predicted_class': predictedClass.displayName,
      'confidence': confidence,
      'all_confidences': allConfidences,
      'device': device,
      'model_type': modelType,
      'segmentation_used': segmentationUsed,
      'segmentation_method': segmentationMethod,
      'apply_brightness_contrast': applyBrightnessContrast,
      'prediction_time_ms': predictionTimeMs,
    };
  }

  @override
  String toString() {
    return 'PredictionResponse(predictedClass: $predictedClass, confidence: $confidence, allConfidences: $allConfidences, device: $device, modelType: $modelType, segmentationUsed: $segmentationUsed, segmentationMethod: $segmentationMethod, applyBrightnessContrast: $applyBrightnessContrast, predictionTimeMs: $predictionTimeMs)';
  }
}
