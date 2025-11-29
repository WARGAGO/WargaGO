class OcrResponse {
  final String filename;
  final List<OcrResult> results;
  final double processingTimeMs;
  final int numDetections;

  OcrResponse({
    required this.filename,
    required this.results,
    required this.processingTimeMs,
    required this.numDetections,
  });

  factory OcrResponse.fromJson(Map<String, dynamic> json) {
    return OcrResponse(
      filename: json['filename'] as String,
      processingTimeMs: (json['processing_time_ms'] as num).toDouble(),
      numDetections: json['num_detections'] as int,
      results: (json['results'] as List)
          .map((resultJson) => OcrResult.fromJson(resultJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'results': results.map((result) => result.toJson()).toList(),
      'processing_time_ms': processingTimeMs,
      'num_detections': numDetections,
    };
  }
}

class OcrResult {
  final String text;
  final double confidence;
  final List<List<double>> bbox;

  OcrResult({required this.text, required this.confidence, required this.bbox});

  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      text: json['text'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      bbox: (json['bbox'] as List)
          .map((bboxItem) => (bboxItem as List).cast<double>())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'confidence': confidence, 'bbox': bbox};
  }
}
