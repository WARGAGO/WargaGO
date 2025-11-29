class OcrHealthResponse {
  final String status;
  final bool modelLoaded;
  final String detectionModel;
  final String recognitionModel;

  OcrHealthResponse({
    required this.status,
    required this.modelLoaded,
    required this.detectionModel,
    required this.recognitionModel,
  });

  factory OcrHealthResponse.fromJson(Map<String, dynamic> json) {
    return OcrHealthResponse(
      status: json['status'] as String,
      modelLoaded: json['model_loaded'] as bool,
      detectionModel: json['detection_model'] as String,
      recognitionModel: json['recognition_model'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'model_loaded': modelLoaded,
      'detection_model': detectionModel,
      'recognition_model': recognitionModel,
    };
  }
}
