import 'package:wargago/core/enums/pcvk_modeltype.dart';
import 'package:wargago/core/enums/predict_class_enum.dart';
import 'package:wargago/core/models/PCVK/predict_response.dart';

class BatchPerPredictionResponse {
  final String? error;
  String? _fileName;
  PredictResponse? _prediction;

  String get fileName => _prediction?.fileName ?? _fileName!;
  PredictClass? get predictedClass => _prediction?.predictedClass;
  double get confidence => _prediction?.confidence ?? 0;
  Map<String, double> get allConfidences => _prediction?.allConfidences ?? {};
  String get device => _prediction?.device ?? '';
  PcvkModelType get modelType =>
      _prediction?.modelType ?? PcvkModelType.mlpv2AutoClahe;
  bool get segmentationUsed => _prediction?.segmentationUsed ?? false;
  String? get segmentationMethod => _prediction?.segmentationMethod;
  bool get applyBrightnessContrast =>
      _prediction?.applyBrightnessContrast ?? false;
  double get predictionTimeMs => _prediction?.predictionTimeMs ?? 0;

  BatchPerPredictionResponse({
    fileName,
    predictedClass,
    confidence,
    allConfidences,
    device,
    modelType,
    segmentationUsed,
    segmentationMethod,
    applyBrightnessContrast,
    predictionTimeMs,
    this.error,
  }) {
    if (error == null) {
      _prediction = PredictResponse(
        fileName: fileName,
        predictedClass: predictedClass,
        confidence: confidence,
        allConfidences: allConfidences,
        device: device,
        modelType: modelType,
        segmentationUsed: segmentationUsed,
        segmentationMethod: segmentationMethod,
        applyBrightnessContrast: applyBrightnessContrast,
        predictionTimeMs: predictionTimeMs,
      );
    } else {
      _fileName = fileName;
    }
  }

  factory BatchPerPredictionResponse.fromJson(Map<String, dynamic> json) {
    final String? error = json['error'] as String?;

    if (error != null) {
      return BatchPerPredictionResponse(
        fileName: json['filename'] as String,
        error: error,
      );
    }

    final allConfidencesJson = json['all_confidences'] as Map<String, dynamic>;
    final allConfidences = <String, double>{};

    allConfidencesJson.forEach((key, value) {
      allConfidences[key] = (value as num).toDouble();
    });

    final predictedClassString = json['predicted_class'] as String;
    final predictedClass = PredictClass.values.firstWhere(
      (e) => e.displayName == predictedClassString,
      orElse: () => PredictClass.sayurAkar,
    );

    return BatchPerPredictionResponse(
      fileName: json['filename'] as String,
      predictedClass: predictedClass,
      confidence: (json['confidence'] as num).toDouble(),
      allConfidences: allConfidences,
      device: json['device'] as String,
      modelType: PcvkModelType.fromString(json['model_type'] as String),
      segmentationUsed: json['segmentation_used'] as bool,
      segmentationMethod: json['segmentation_method'] as String,
      applyBrightnessContrast: json['apply_brightness_contrast'] as bool,
      predictionTimeMs: (json['prediction_time_ms'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': fileName,
      'predicted_class': predictedClass?.displayName,
      'confidence': confidence,
      'all_confidences': allConfidences,
      'device': device,
      'model_type': modelType.value,
      'segmentation_used': segmentationUsed,
      'segmentation_method': segmentationMethod,
      'apply_brightness_contrast': applyBrightnessContrast,
      'prediction_time_ms': predictionTimeMs,
      'error': error,
    };
  }
}

class BatchPredictionResponseError implements Exception {}

class BatchPredictionResponse {
  final List<BatchPerPredictionResponse> predictions;

  BatchPredictionResponse({required this.predictions});

  factory BatchPredictionResponse.fromJson(Map<String, dynamic> json) {
    final resultsJson = json['results'] as List<dynamic>?;
    final predictions =
        resultsJson
            ?.map(
              (item) => BatchPerPredictionResponse.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList() ??
        [];

    return BatchPredictionResponse(predictions: predictions);
  }

  Map<String, dynamic> toJson() {
    return {'results': predictions.map((p) => p.toJson()).toList()};
  }
}
