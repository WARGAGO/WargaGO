import 'package:jawara/core/models/PCVK/predict_response.dart';

class BatchPerPredictionResponse {
  final String? error;
  String? _fileName;
  PredictModelResponse? _prediction;

  String get fileName => _prediction?.fileName ?? _fileName!;
  String get predictedClass => _prediction?.predictedClass ?? '';
  double get confidence => _prediction?.confidence ?? 0;
  Map<String, double> get allConfidences => _prediction?.allConfidences ?? {};
  String get device => _prediction?.device ?? '';
  String get modelType => _prediction?.modelType ?? '';
  bool get segmentationUsed => _prediction?.segmentationUsed ?? false;
  String? get segmentationMethod => _prediction?.segmentationMethod;
  bool get applyBrightnessContrast =>
      _prediction?.applyBrightnessContrast ?? false;

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
    this.error,
  }) {
    if (error == null) {
      _prediction = PredictModelResponse(
        fileName: fileName,
        predictedClass: predictedClass,
        confidence: confidence,
        allConfidences: allConfidences,
        device: device,
        modelType: modelType,
        segmentationUsed: segmentationUsed,
        segmentationMethod: segmentationMethod,
        applyBrightnessContrast: applyBrightnessContrast,
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

    return BatchPerPredictionResponse(
      fileName: json['filename'] as String,
      predictedClass: json['predicted_class'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      allConfidences: allConfidences,
      device: json['device'] as String,
      modelType: json['model_type'] as String,
      segmentationUsed: json['segmentation_used'] as bool,
      segmentationMethod: json['segmentation_method'] as String,
      applyBrightnessContrast: json['apply_brightness_contrast'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': fileName,
      'predicted_class': predictedClass,
      'confidence': confidence,
      'all_confidences': allConfidences,
      'device': device,
      'model_type': modelType,
      'segmentation_used': segmentationUsed,
      'segmentation_method': segmentationMethod,
      'apply_brightness_contrast': applyBrightnessContrast,
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
