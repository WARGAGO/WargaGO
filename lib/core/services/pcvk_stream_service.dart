import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as imglib;
import 'package:wargago/core/configs/url_pcvk_api.dart';
import 'package:wargago/core/models/PCVK/websocket_config.dart';
import 'package:wargago/core/models/PCVK/websocket_predict_response.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PCVKStreamService {
  CameraController? _cameraController;
  WebSocketChannel? _channel;
  bool _isStreaming = false;
  get isStreaming => _isStreaming;
  bool _isProcessingFrame = false;
  bool _isWaitingForPrediction = false;
  StreamSubscription? _channelSubscription;

  // Ping tracking
  int? _lastPingTimeMs;
  int? get lastPingTimeMs => _lastPingTimeMs;
  DateTime? _frameSentTime;
  Timer? _pingTimer;

  // Configuration
  final int chunkSize = 64 * 1024;
  final int jpegQuality = 80;

  // Frame skipping for smoother performance
  int _frameSkipCount = 0;
  int _frameSkipThreshold = 2; // Skip every N frames initially
  // DateTime? _lastFrameProcessedTime;

  WebSocketConfig? webSocketConfig;

  // Processed image accumulation - using Uint8List builder for better performance
  final List<Uint8List> _processedImageChunks = [];
  bool _isReceivingProcessedImage = false;
  // ignore: unused_field
  int _processedImageTotalSize = 0;

  // Callbacks
  Function(WebSocketPredictResponse result)? onPredictionResult;
  Function(String message)? onStatusMessage;
  Function(String message)? onError;
  Function(Uint8List uint8List)? onProcessedImage;
  Function()? onConnectionClosed;
  Function()? onConnected;

  PCVKStreamService({
    CameraController? cameraController,
    this.onPredictionResult,
    this.onStatusMessage,
    this.onError,
    this.onProcessedImage,
    this.onConnectionClosed,
    this.onConnected,
  }) {
    _cameraController = cameraController;
    wsConnect();
  }

  void wsConnect() {
    try {
      _channel = WebSocketChannel.connect(
        UrlPCVKAPI.buildWebSocketEndpoint('pcvk/ws/predict'),
      );
      onConnected?.call();
      _channelSubscription = _channel!.stream.listen(
        (message) {
          _handleServerMessage(message);
        },
        onError: (error) {
          if (kDebugMode) {
            print('WebSocket error: $error');
          }
          onError?.call(error.toString());
        },
        onDone: () {
          if (kDebugMode) {
            print('WebSocket connection closed');
          }
          onConnectionClosed?.call();
        },
      );
    } catch (_) {
      onConnectionClosed?.call();
    }
  }

  void wsReconnect() {
    Future.delayed(Duration(microseconds: 500), () {
      wsConnect();
    });
  }

  Future<void> initCamera({
    CameraController? cameraController,
    Map<String, dynamic>? config,
  }) async {
    if (cameraController != null) {
      _cameraController = cameraController;
    } else {
      _cameraController = CameraController(
        (await availableCameras()).first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
    }
    await _cameraController!.initialize();
  }

  void dispose({bool disploseCamera = true}) {
    stopStreaming();
    _pingTimer?.cancel();
    _channelSubscription?.cancel();
    _channel?.sink.close();
    if (disploseCamera) {
      _cameraController?.dispose();
    }
  }

  // Update camera controller (for camera switching)
  void updateCameraController(CameraController? newController) {
    _cameraController = newController;
  }

  Future<void> startStreaming(webSocketConfig) async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isStreaming) {
      return;
    }

    sendConfig(webSocketConfig);

    _isStreaming = true;

    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      sendPing();
    });

    await _cameraController!.startImageStream((CameraImage image) async {
      if (_isProcessingFrame || _isWaitingForPrediction) return;

      // Frame skipping logic for smoother performance
      _frameSkipCount++;
      if (_frameSkipCount < _frameSkipThreshold) {
        return; // Skip this frame
      }
      _frameSkipCount = 0;

      _isProcessingFrame = true;

      try {
        await _processAndSendFrame(image);
        // _lastFrameProcessedTime = DateTime.now();
      } catch (e) {
        if (kDebugMode) {
          print("Error processing frame: $e");
        }
      } finally {
        _isProcessingFrame = false;
      }
    });
  }

  Future<void> stopStreaming() async {
    if (_isStreaming) {
      await _cameraController?.stopImageStream();
      _isStreaming = false;
      _isWaitingForPrediction = false;
      _pingTimer?.cancel();
      _pingTimer = null;
    }
  }

  Future<void> sendConfig(WebSocketConfig config) async {
    if (_channel == null) return;

    final configJson = jsonEncode(config.toJson());
    _channel!.sink.add(configJson);

    if (kDebugMode) {
      print('Sent config: $configJson');
    }
  }

  void sendPing() {
    if (_channel == null) return;

    _frameSentTime = DateTime.now();
    final pingMessage = jsonEncode({'ping': true});
    _channel!.sink.add(pingMessage);

    if (kDebugMode) {
      print('Sent ping');
    }
  }

  Future<Uint8List?> processImage(CameraImage image) async {
    final isolateData = {
      'planes': image.planes
          .map(
            (p) => {
              'bytes': p.bytes,
              'bytesPerRow': p.bytesPerRow,
              'bytesPerPixel': p.bytesPerPixel,
            },
          )
          .toList(),
      'width': image.width,
      'height': image.height,
      'format': image.format.group,
      'quality': jpegQuality,
      'sensorOrientation':
          _cameraController?.description.sensorOrientation ?? 0,
    };

    final Uint8List? jpegBytes = await compute(
      _convertToJpegBackground,
      isolateData,
    );

    return jpegBytes;
  }

  Future<void> _processAndSendFrame(CameraImage image) async {
    final jpegBytes = await processImage(image);

    if (jpegBytes != null && _channel != null) {
      await _sendInChunks(jpegBytes);
    }
  }

  Future<void> _sendInChunks(Uint8List bytes) async {
    int totalLen = bytes.length;
    int offset = 0;

    if (kDebugMode) {
      print('Sending image in chunks: $totalLen bytes');
    }

    while (offset < totalLen) {
      int end = offset + chunkSize;
      if (end > totalLen) end = totalLen;

      _channel?.sink.add(bytes.sublist(offset, end));
      offset = end;
    }

    final completeSignal = jsonEncode({'complete': true});
    _channel?.sink.add(completeSignal);

    _isWaitingForPrediction = true;
  }

  void _handleServerMessage(dynamic message) {
    try {
      if (message is String) {
        final data = jsonDecode(message);

        if (data.containsKey('pong') && _frameSentTime != null) {
          _lastPingTimeMs = DateTime.now()
              .difference(_frameSentTime!)
              .inMilliseconds;

          // Adaptive frame skipping based on latency
          _adjustFrameSkipping();
          return;
        }

        if (data.containsKey('message')) {
          final statusMessage = data['message'] as String;

          // Check if server is starting to send processed image
          if (statusMessage.startsWith('Sending processed image')) {
            _isReceivingProcessedImage = true;
            _processedImageChunks.clear();
            _processedImageTotalSize = 0;
          } else if (statusMessage == 'Processed image transfer complete') {
            _isReceivingProcessedImage = false;
            if (_processedImageChunks.isNotEmpty) {
              // Combine chunks in background isolate to avoid UI jank
              _combineImageChunks();
            }
          }

          onStatusMessage?.call(statusMessage);
          if (kDebugMode) {
            print('Server: $statusMessage');
          }
        } else if (data.containsKey('predicted_class')) {
          onPredictionResult?.call(WebSocketPredictResponse.fromJson(data));
          _isWaitingForPrediction = false;
        } else if (data.containsKey('error')) {
          onError?.call(data['error']);
          if (kDebugMode) {
            print('Error: ${data['error']}');
          }
        }
      } else if (message is List<int>) {
        // Accumulate binary chunks if receiving processed image
        if (_isReceivingProcessedImage) {
          // Store as Uint8List to avoid repeated conversions
          final chunk = message is Uint8List
              ? message
              : Uint8List.fromList(message);
          _processedImageChunks.add(chunk);
          _processedImageTotalSize += chunk.length;

          // Optional: Log progress
          // if (kDebugMode) {
          //   print(
          //     'Received chunk: ${chunk.length} bytes, total: $_processedImageTotalSize',
          //   );
          // }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling server message: $e');
      }
      onError?.call(e.toString());
    }
  }

  // Adjust frame skipping based on network latency
  void _adjustFrameSkipping() {
    if (_lastPingTimeMs == null) return;

    // Adjust threshold based on latency
    if (_lastPingTimeMs! < 100) {
      // Low latency: process more frames
      _frameSkipThreshold = 1;
    } else if (_lastPingTimeMs! < 200) {
      // Medium latency: skip some frames
      _frameSkipThreshold = 2;
    } else if (_lastPingTimeMs! < 400) {
      // High latency: skip more frames
      _frameSkipThreshold = 3;
    } else {
      // Very high latency: skip most frames
      _frameSkipThreshold = 5;
    }

    if (kDebugMode) {
      print(
        'Adjusted frame skip threshold to $_frameSkipThreshold (latency: ${_lastPingTimeMs}ms)',
      );
    }
  }

  // Combine image chunks in background isolate to avoid blocking UI
  Future<void> _combineImageChunks() async {
    try {
      final combinedData = {'chunks': _processedImageChunks};

      final Uint8List? combined = await compute(
        _combineChunksBackground,
        combinedData,
      );

      if (combined != null) {
        onProcessedImage?.call(combined);
      }

      _processedImageChunks.clear();
      _processedImageTotalSize = 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error combining image chunks: $e');
      }
      onError?.call(e.toString());
    }
  }
}

// Background isolate function to combine chunks efficiently
Future<Uint8List?> _combineChunksBackground(Map<String, dynamic> data) async {
  try {
    final List<Uint8List> chunks = (data['chunks'] as List).cast<Uint8List>();

    if (chunks.isEmpty) return null;

    // Pre-allocate the exact size needed
    final BytesBuilder builder = BytesBuilder(copy: false);

    for (final chunk in chunks) {
      builder.add(chunk);
    }

    return builder.takeBytes();
  } catch (e) {
    if (kDebugMode) {
      print('Error in _combineChunksBackground: $e');
    }
    return null;
  }
}

Future<Uint8List?> _convertToJpegBackground(Map<String, dynamic> data) async {
  try {
    var format = data['format'];
    int width = data['width'];
    int height = data['height'];
    int quality = data['quality'];
    int sensorOrientation = data['sensorOrientation'] ?? 0;
    List<Map<String, dynamic>> planes = (data['planes'] as List)
        .cast<Map<String, dynamic>>();

    imglib.Image? img;

    if (format == ImageFormatGroup.yuv420) {
      img = _convertYUV420ToImage(
        planes[0]['bytes'] as Uint8List,
        planes[1]['bytes'] as Uint8List,
        planes[2]['bytes'] as Uint8List,
        planes[0]['bytesPerRow'] as int,
        planes[1]['bytesPerRow'] as int,
        planes[1]['bytesPerPixel'] as int,
        width,
        height,
      );
    } else if (format == ImageFormatGroup.bgra8888) {
      img = imglib.Image.fromBytes(
        width: width,
        height: height,
        bytes: (planes[0]['bytes'] as Uint8List).buffer,
        order: imglib.ChannelOrder.bgra,
      );
    }

    if (img != null) {
      // Apply rotation based on sensor orientation
      if (sensorOrientation == 90) {
        img = imglib.copyRotate(img, angle: 90);
      } else if (sensorOrientation == 180) {
        img = imglib.copyRotate(img, angle: 180);
      } else if (sensorOrientation == 270) {
        img = imglib.copyRotate(img, angle: 270);
      }

      // img = imglib.copyResize(img, width: 224, height: 224);
      return Uint8List.fromList(imglib.encodeJpg(img, quality: quality));
    }
  } catch (e) {
    if (kDebugMode) {
      print("Isolate Error: $e");
    }
  }
  return null;
}

imglib.Image _convertYUV420ToImage(
  Uint8List plane0,
  Uint8List plane1,
  Uint8List plane2,
  int bytesPerRow,
  int uvRowStride,
  int uvPixelStride,
  int width,
  int height,
) {
  const int targetWidth = 224;
  const int targetHeight = 224;

  final img = imglib.Image(width: targetWidth, height: targetHeight);

  // Calculate scaling factors
  final double scaleX = width / targetWidth;
  final double scaleY = height / targetHeight;

  for (int ty = 0; ty < targetHeight; ty++) {
    final int y = (ty * scaleY).floor();
    final int uvRowIndex = uvRowStride * (y >> 1);
    final int yp = y * bytesPerRow;

    for (int tx = 0; tx < targetWidth; tx++) {
      final int x = (tx * scaleX).floor();
      final int uvIndex = uvPixelStride * (x >> 1) + uvRowIndex;
      final int ypIndex = yp + x;

      final int yVal = plane0[ypIndex] & 0xFF;
      final int uVal = plane1[uvIndex] & 0xFF;
      final int vVal = plane2[uvIndex] & 0xFF;

      int r = (yVal + (1.370705 * (vVal - 128))).round();
      int g = (yVal - (0.337633 * (uVal - 128)) - (0.698001 * (vVal - 128)))
          .round();
      int b = (yVal + (1.732446 * (uVal - 128))).round();

      img.setPixelRgb(
        tx,
        ty,
        b.clamp(0, 255),
        g.clamp(0, 255),
        r.clamp(0, 255),
      );
    }
  }
  return img;
}
