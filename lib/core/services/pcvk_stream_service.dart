import 'dart:async';
import 'dart:convert';
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
  StreamSubscription? _channelSubscription;

  // Ping tracking
  int? _lastPingTimeMs;
  int? get lastPingTimeMs => _lastPingTimeMs;
  DateTime? _frameSentTime;
  Timer? _pingTimer;

  // Configuration
  final int chunkSize = 64 * 1024;
  final int jpegQuality = 80;

  WebSocketConfig? webSocketConfig;

  // Callbacks
  Function(WebSocketPredictResponse result)? onPredictionResult;
  Function(String message)? onStatusMessage;
  Function(String message)? onError;
  Function(Uint8List uint8List)? onProcessedImage;

  PCVKStreamService({
    CameraController? cameraController,
    this.onPredictionResult,
    this.onStatusMessage,
    this.onError,
    this.onProcessedImage,
  }) {
    _cameraController = cameraController;

    _channel = WebSocketChannel.connect(
      UrlPCVKAPI.buildWebSocketEndpoint('pcvk/ws/predict'),
    );

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
      },
    );
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
      if (_isProcessingFrame) return;

      _isProcessingFrame = true;

      try {
        await _processAndSendFrame(image);
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

  Future<void> _processAndSendFrame(CameraImage image) async {
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
    };

    final Uint8List? jpegBytes = await compute(
      _convertToJpegBackground,
      isolateData,
    );

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
    if (kDebugMode) {
      print('Sent complete');
    }
  }

  void _handleServerMessage(dynamic message) {
    try {
      if (message is String) {
        final data = jsonDecode(message);

        if (data.containsKey('pong') && _frameSentTime != null) {
          _lastPingTimeMs = DateTime.now()
              .difference(_frameSentTime!)
              .inMilliseconds;
          return;
        }

        if (data.containsKey('message')) {
          onStatusMessage?.call(data['message']);
          if (kDebugMode) {
            print('Server: ${data['message']}');
          }
        } else if (data.containsKey('predicted_class')) {
          onPredictionResult?.call(WebSocketPredictResponse.fromJson(data));
        } else if (data.containsKey('error')) {
          onError?.call(data['error']);
          if (kDebugMode) {
            print('Error: ${data['error']}');
          }
        }
      } else if (message is List<int>) {
        onProcessedImage?.call(Uint8List.fromList(message));
        if (kDebugMode) {
          print('Received processed image: ${message.length} bytes');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling server message: $e');
      }
      onError?.call(e.toString());
    }
  }
}

Future<Uint8List?> _convertToJpegBackground(Map<String, dynamic> data) async {
  try {
    var format = data['format'];
    int width = data['width'];
    int height = data['height'];
    int quality = data['quality'];
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
      // Resize if needed here to save more bandwidth
      // img = imglib.copyResize(img, width: 320);
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
  final img = imglib.Image(width: width, height: height);

  for (int y = 0; y < height; y++) {
    final int uvRowIndex = uvRowStride * (y >> 1);
    final int yp = y * bytesPerRow;

    for (int x = 0; x < width; x++) {
      final int uvIndex = uvPixelStride * (x >> 1) + uvRowIndex;
      final int ypIndex = yp + x;

      final int yVal = plane0[ypIndex] & 0xFF;
      final int uVal = plane1[uvIndex] & 0xFF;
      final int vVal = plane2[uvIndex] & 0xFF;

      int r = (yVal + (1.370705 * (vVal - 128))).round();
      int g = (yVal - (0.337633 * (uVal - 128)) - (0.698001 * (vVal - 128)))
          .round();
      int b = (yVal + (1.732446 * (uVal - 128))).round();

      img.setPixelRgb(x, y, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
    }
  }
  return img;
}
