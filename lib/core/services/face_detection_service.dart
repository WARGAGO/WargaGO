// ============================================================================
// FACE DETECTION SERVICE - Google ML Kit
// ============================================================================
// Service untuk melakukan face detection pada foto KTP
// Memastikan foto KTP memiliki wajah yang valid
// ============================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:jawara/core/models/KYC/face_detection.dart';

class FaceDetectionService {
  // Face detector instance with options
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: false,
      minFaceSize: 0.1, // Minimum face size (10% of image)
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  /// Detect faces in image
  Future<FaceDetectionResult?> detectFaces(File imageFile) async {
    try {
      if (kDebugMode) {
        print('👤 Starting face detection...');
        print('Image path: ${imageFile.path}');
      }

      // Create InputImage from file
      final inputImage = InputImage.fromFile(imageFile);

      // Detect faces
      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (kDebugMode) {
        print('👥 Faces detected: ${faces.length}');
      }

      if (faces.isEmpty) {
        return FaceDetectionResult(
          faceDetected: false,
          confidence: 0.0,
          quality: 'no_face',
        );
      }

      // Analyze first face (assuming single person in KTP)
      final face = faces.first;

      // Calculate quality based on various factors
      final quality = _analyzeFaceQuality(face);
      final confidence = _calculateConfidence(face);

      if (kDebugMode) {
        print('✅ Face detection complete');
        print('Confidence: ${(confidence * 100).toStringAsFixed(1)}%');
        print('Quality: $quality');
        print('Smiling probability: ${face.smilingProbability ?? 0}');
        print('Left eye open: ${face.leftEyeOpenProbability ?? 0}');
        print('Right eye open: ${face.rightEyeOpenProbability ?? 0}');
      }

      return FaceDetectionResult(
        faceDetected: true,
        confidence: confidence,
        quality: quality,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error detecting faces: $e');
      }
      return null;
    }
  }

  /// Analyze face quality
  String _analyzeFaceQuality(Face face) {
    // Check eye openness
    final leftEyeOpen = face.leftEyeOpenProbability ?? 0.0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 0.0;

    // Check head pose (Euler angles)
    final headEulerAngleY = face.headEulerAngleY ?? 0.0;
    final headEulerAngleZ = face.headEulerAngleZ ?? 0.0;

    // Quality scoring
    if (leftEyeOpen < 0.5 || rightEyeOpen < 0.5) {
      return 'poor_eyes_closed';
    }

    if (headEulerAngleY.abs() > 20 || headEulerAngleZ.abs() > 20) {
      return 'poor_head_angle';
    }

    // Check bounding box size (face should be reasonably sized)
    final boundingBox = face.boundingBox;
    final faceArea = boundingBox.width * boundingBox.height;

    if (faceArea < 10000) {
      return 'poor_too_small';
    }

    if (faceArea > 1000000) {
      return 'poor_too_large';
    }

    // All checks passed
    return 'good';
  }

  /// Calculate overall confidence score
  double _calculateConfidence(Face face) {
    double score = 0.0;
    int factors = 0;

    // Eye openness (both eyes should be open)
    final leftEyeOpen = face.leftEyeOpenProbability ?? 0.0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 0.0;

    if (leftEyeOpen > 0) {
      score += leftEyeOpen * 25;
      factors++;
    }

    if (rightEyeOpen > 0) {
      score += rightEyeOpen * 25;
      factors++;
    }

    // Head pose (should be straight)
    final headEulerAngleY = face.headEulerAngleY ?? 0.0;
    final headEulerAngleZ = face.headEulerAngleZ ?? 0.0;

    // Penalize for head rotation
    final headPoseScore = (1 - (headEulerAngleY.abs() / 45).clamp(0, 1)) * 25;
    score += headPoseScore;
    factors++;

    final headTiltScore = (1 - (headEulerAngleZ.abs() / 45).clamp(0, 1)) * 25;
    score += headTiltScore;
    factors++;

    // Return average score (0.0 - 1.0)
    return factors > 0 ? (score / 100) : 0.0;
  }

  /// Validate face for KTP (stricter rules)
  bool validateFaceForKTP(FaceDetectionResult? result) {
    if (result == null || !result.faceDetected) {
      return false;
    }

    // Must have good quality
    if (result.quality != 'good') {
      return false;
    }

    // Must have reasonable confidence
    if ((result.confidence ?? 0.0) < 0.6) {
      return false;
    }

    return true;
  }

  /// Get human-readable quality message
  String getQualityMessage(String quality) {
    switch (quality) {
      case 'good':
        return 'Foto wajah berkualitas baik';
      case 'poor_eyes_closed':
        return 'Mata harus terbuka';
      case 'poor_head_angle':
        return 'Posisi kepala harus lurus menghadap kamera';
      case 'poor_too_small':
        return 'Wajah terlalu kecil, foto lebih dekat';
      case 'poor_too_large':
        return 'Wajah terlalu besar, foto lebih jauh';
      case 'no_face':
        return 'Tidak ada wajah terdeteksi';
      default:
        return 'Kualitas foto tidak diketahui';
    }
  }

  /// Check if multiple faces detected (should be only 1 for KTP)
  Future<bool> hasMultipleFaces(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector.processImage(inputImage);
      return faces.length > 1;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking multiple faces: $e');
      }
      return false;
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    await _faceDetector.close();
  }
}
