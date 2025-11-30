// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wargago/core/enums/pcvk_modeltype.dart';
import 'package:wargago/core/models/PCVK/batch_predict_response.dart';
import 'package:wargago/core/models/PCVK/health_response.dart';
import 'package:wargago/core/models/PCVK/models_response.dart';
import 'package:wargago/core/models/PCVK/predict_response.dart';
import 'package:wargago/core/services/pcvk_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  group('PcvkService - API Tests', () {
    late PcvkService pcvkService;

    setUp(() {
      pcvkService = PcvkService();
    });

    group('getHealth', () {
      test('returns HealthModelResponse on successful response', () async {
        if (kDebugMode) {
          print('📝 Testing: Get health status from PCVK service');
        }
        // Act
        final result = await pcvkService.getHealth();

        // Assert
        expect(result, isA<HealthModelResponse>());
        expect(result.status, isNotEmpty);
        expect(result.device, isNotEmpty);
        expect(result.numClasses, greaterThan(0));
        expect(result.classNames, isNotEmpty);
        expect(result.availableModels, isNotEmpty);
        if (kDebugMode) {
          print('✅ Passed: Health status retrieved successfully\n');
        }
      });
    });

    group('getClasses', () {
      test('returns list of classes on successful response', () async {
        if (kDebugMode) {
          print('📝 Testing: Get available classes from PCVK service');
        }
        // Act
        final result = await pcvkService.getClasses();

        // Assert
        expect(result, isA<List<String>>());
        expect(result, isNotEmpty);
        expect(result.length, greaterThan(0));
        if (kDebugMode) {
          print('✅ Passed: Classes retrieved successfully\n');
        }
      });
    });

    group('getModels', () {
      test('returns ModelsModelResponse on successful response', () async {
        if (kDebugMode) {
          print('📝 Testing: Get available models from PCVK service');
        }
        // Act
        final result = await pcvkService.getModels();

        // Assert
        expect(result, isA<ModelsModelResponse>());
        expect(result.totalModels, greaterThan(0));
        expect(result.availableModels, isNotEmpty);
        expect(result.models, isNotEmpty);
        if (kDebugMode) {
          print('✅ Passed: Models retrieved successfully\n');
        }
      });
    });

    group('predict', () {
      test('returns PredictModelResponse on successful prediction', () async {
        if (kDebugMode) {
          print('📝 Testing: Predict image class using PCVK service');
        }
        final testImagePath = 'test/fixtures/test_images/1.jpg';
        final testFile = File(testImagePath);

        // Act
        final result = await pcvkService.predict(testFile);

        // Assert
        expect(result, isA<PredictResponse>());
        expect(result.fileName, isNotEmpty);
        expect(result.predictedClass, isNotNull);
        expect(result.confidence, greaterThan(0));
        expect(result.confidence, lessThanOrEqualTo(1));
        expect(result.allConfidences, isNotEmpty);
        expect(result.device, isNotEmpty);
        expect(result.modelType, isA<PcvkModelType>());
        if (kDebugMode) {
          print('✅ Passed: Image prediction successful\n');
        }
      }, skip: false);
    });

    group('batchPredict', () {
      test(
        'returns BatchPredictionResponse on successful batch prediction',
        () async {
          if (kDebugMode) {
            print(
              '📝 Testing: Batch predict multiple images using PCVK service',
            );
          }
          final testImagePaths = [
            'test/fixtures/test_images/1.jpg',
            'test/fixtures/test_images/2.jpeg',
          ];

          final testFiles = testImagePaths.map((path) => File(path)).toList();

          // Act
          final result = await pcvkService.batchPredict(testFiles);

          // Assert
          expect(result, isA<BatchPredictionResponse>());
          expect(result.predictions, isNotEmpty);
          expect(result.predictions.length, testFiles.length);
          if (kDebugMode) {
            print('✅ Passed: Batch prediction successful\n');
          }
        },
        skip: false,
      );
    });
  });
}
