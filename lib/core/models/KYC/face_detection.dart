class FaceDetectionResult {
  final bool faceDetected;
  final double? confidence;
  final String? quality;

  FaceDetectionResult({
    required this.faceDetected,
    this.confidence,
    this.quality,
  });

  factory FaceDetectionResult.fromMap(Map<String, dynamic> map) {
    return FaceDetectionResult(
      faceDetected: map['faceDetected'] ?? false,
      confidence: map['confidence']?.toDouble(),
      quality: map['quality'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'faceDetected': faceDetected,
      'confidence': confidence,
      'quality': quality,
    };
  }
}
