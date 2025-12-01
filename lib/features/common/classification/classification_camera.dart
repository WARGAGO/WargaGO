import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wargago/core/enums/pcvk_modeltype.dart';
import 'package:wargago/core/models/PCVK/predict_response.dart';
import 'package:wargago/core/models/PCVK/websocket_config.dart';
import 'package:wargago/core/services/pcvk_service.dart';
import 'package:wargago/core/services/pcvk_stream_service.dart';
import 'package:wargago/features/common/classification/widgets/inkwell_iconbutton.dart';
import 'package:wargago/features/common/classification/widgets/white_button.dart';
import 'package:wargago/features/common/classification/widgets/camera_settings_panel.dart';
import 'package:wargago/features/common/classification/utils/veggie_rotation_manager.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:remixicon/remixicon.dart';

class ClassificationCameraPage extends StatefulWidget {
  const ClassificationCameraPage({super.key});

  @override
  State<ClassificationCameraPage> createState() =>
      _ClassificationCameraPageState();
}

class _ClassificationCameraPageState extends State<ClassificationCameraPage> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  late final Future<void> _initializeCameraFuture;
  bool _isProcessing = false;
  int _currentCameraIndex = 0; // Track current camera index
  bool _isSwitchingCamera = false; // Track switching state
  bool _showSettingsPanel = false; // Track settings panel visibility

  late final ImagePicker _imagePicker;
  bool? _useEfficient;

  // Camera settings
  ResolutionPreset _resolutionPreset = ResolutionPreset.high;
  int? _targetFps;

  // Model settings
  bool _useSegmentation = true;
  String _segMethod = 'u2netp';
  bool _applyBrightnessContrast = true;
  bool _returnProcessedImage = false;

  // HSV settings (for HSV segmentation method)
  double _hsvHueMin = 0;
  double _hsvHueMax = 180;
  double _hsvSatMin = 0;
  double _hsvSatMax = 255;
  double _hsvValMin = 0;
  double _hsvValMax = 255;

  late final PcvkService _pcvkService;
  late final PCVKStreamService _pcvkStreamService;
  late final VeggieRotationManager _veggieRotationManager;

  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(
        _cameras[_currentCameraIndex], // Use current camera index
        _resolutionPreset,
        enableAudio: false,
        fps: _targetFps,
      );
      _pcvkStreamService = PCVKStreamService(
        cameraController: _cameraController,
        onPredictionResult: (result) {
          _result = PredictResponse(
            fileName: '',
            predictedClass: result.predictedClass,
            confidence: result.confidence,
            allConfidences: result.allConfidences,
            device: result.device,
            applyBrightnessContrast: result.applyBrightnessContrast,
            modelType: result.modelType,
            segmentationUsed: result.segmentationUsed,
            segmentationMethod: result.segmentationMethod ?? 'none',
            predictionTimeMs: result.predictionTimeMs,
          );
          _veggieRotationManager.startRotation(_result!.predictedClass);
          setState(() {});
        },
        onProcessedImage: (uint8List) {
          if (!_pcvkStreamService.isStreaming) {
            setState(() => _processedImageBytes = null);
            return;
          }
          setState(() => _processedImageBytes = uint8List);
        },
      );
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
        default:
          if (kDebugMode) {
            print('Error initializing controller: $e');
          }
          break;
      }
    }
  }

  @override
  void initState() {
    _initializeCameraFuture = _initializeCameras().catchError((e) {
      if (kDebugMode) {
        debugPrint(e);
      }
    });
    super.initState();
    _imagePicker = ImagePicker();
    _pcvkService = PcvkService();
    _veggieRotationManager = VeggieRotationManager(
      onUpdate: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _veggieRotationManager.dispose();
    _cameraController?.dispose();
    _pcvkStreamService.dispose(disploseCamera: false);
    super.dispose();
  }

  bool _isFlashOn = false;
  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
        setState(() => _isFlashOn = false);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
        setState(() => _isFlashOn = true);
      }
    } on CameraException catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  // Switch camera function (front ↔️ back)
  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isSwitchingCamera) {
      return; // No other camera available or already switching
    }

    setState(() => _isSwitchingCamera = true);

    try {
      // Stop streaming if active
      if (_pcvkStreamService.isStreaming) {
        await _pcvkStreamService.stopStreaming();
      }

      // Turn off flash if it's on
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
        _isFlashOn = false;
      }

      // Dispose old controller
      await Future.delayed(const Duration(milliseconds: 500));
      await _cameraController?.dispose();

      // Switch to next camera
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;

      // Initialize new camera controller
      _cameraController = CameraController(
        _cameras[_currentCameraIndex],
        _resolutionPreset,
        enableAudio: false,
        fps: _targetFps,
      );

      // Update stream service with new controller
      _pcvkStreamService.updateCameraController(_cameraController);

      // Initialize the new camera
      await _cameraController!.initialize();

      if (mounted) {
        setState(() => _isSwitchingCamera = false);
      }
    } on CameraException catch (e) {
      debugPrint('Error switching camera: $e');
      if (mounted) {
        setState(() => _isSwitchingCamera = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      await _pcvkStreamService.stopStreaming();
      setState(() => _processedImageBytes = null);
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null && mounted) {
        _processImage(File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _processedImageBytes = null;
    });
    await _pcvkStreamService.stopStreaming();

    try {
      final XFile image = await _cameraController!.takePicture();
      _cameraController!.pausePreview();
      if (mounted) {
        _processImage(File(image.path));
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      setState(() => _isProcessing = false);
    }
  }

  void _setPictureNull() async {
    _cameraController!.resumePreview();
    setState(() => _picture = null);
  }

  File? _picture;
  PredictResponse? _result;
  Uint8List? _processedImageBytes;

  void _processImage(File imageFile) async {
    setState(() {
      _isProcessing = true;
      _picture = imageFile;
    });

    _result = await _pcvkService.predict(
      _picture!,
      modelType: _useEfficient! ? 'efficientnetv2' : 'mlpv2_auto-clahe',
      useSegmentation: _useSegmentation,
      segMethod: _segMethod,
      applyBrightnessContrast: _applyBrightnessContrast,
    );

    _veggieRotationManager.startRotation(_result!.predictedClass);

    setState(() => _isProcessing = false);
  }

  void _handleStreaming() async {
    setState(() => _processedImageBytes = null);
    if (_pcvkStreamService.isStreaming) {
      await _pcvkStreamService.stopStreaming();
    } else {
      await _pcvkStreamService.startStreaming(
        WebSocketConfig(
          modelType: _useEfficient!
              ? PcvkModelType.efficientnetv2
              : PcvkModelType.mlpv2AutoClahe,
          useSegmentation: _useSegmentation,
          segMethod: _segMethod,
          applyBrightnessContrast: _applyBrightnessContrast,
          returnProcessedImage: _returnProcessedImage,
        ),
      );
    }
    setState(() {});
  }

  String get _currentVeggie => _veggieRotationManager.currentVeggie;

  Future<void> _changeResolution(ResolutionPreset preset) async {
    if (_resolutionPreset == preset) return;

    setState(() => _isSwitchingCamera = true);

    try {
      if (_pcvkStreamService.isStreaming) {
        await _pcvkStreamService.stopStreaming();
        // await Future.delayed(const Duration(milliseconds: 500));
      }

      await _cameraController?.dispose();
      await Future.delayed(const Duration(milliseconds: 300));

      _resolutionPreset = preset;

      _cameraController = CameraController(
        _cameras[_currentCameraIndex],
        _resolutionPreset,
        enableAudio: false,
        fps: _targetFps,
      );

      _pcvkStreamService.updateCameraController(_cameraController);
      await _cameraController!.initialize();

      if (mounted) {
        setState(() => _isSwitchingCamera = false);
      }
    } catch (e) {
      debugPrint('Error changing resolution: $e');
      if (mounted) {
        setState(() => _isSwitchingCamera = false);
      }
    }
  }

  Future<void> _changeFps(int? fps) async {
    if (_targetFps == fps) return;

    setState(() => _isSwitchingCamera = true);

    try {
      if (_pcvkStreamService.isStreaming) {
        await _pcvkStreamService.stopStreaming();
      }

      await _cameraController?.dispose();
      await Future.delayed(const Duration(milliseconds: 300));

      _targetFps = fps;

      _cameraController = CameraController(
        _cameras[_currentCameraIndex],
        _resolutionPreset,
        enableAudio: false,
        fps: _targetFps,
      );

      _pcvkStreamService.updateCameraController(_cameraController);
      await _cameraController!.initialize();

      if (mounted) {
        setState(() => _isSwitchingCamera = false);
      }
    } catch (e) {
      debugPrint('Error changing FPS: $e');
      if (mounted) {
        setState(() => _isSwitchingCamera = false);
      }
    }
  }

  Future<void> _restartStreaming() async {
    if (_pcvkStreamService.isStreaming) {
      await _pcvkStreamService.stopStreaming();
      await Future.delayed(Duration(milliseconds: 500));

      await _pcvkStreamService.startStreaming(
        WebSocketConfig(
          modelType: _useEfficient!
              ? PcvkModelType.efficientnetv2
              : PcvkModelType.mlpv2AutoClahe,
          useSegmentation: _useSegmentation,
          segMethod: _segMethod,
          applyBrightnessContrast: _applyBrightnessContrast,
          returnProcessedImage: _returnProcessedImage,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _picture != null
              ? Image.file(
                  _picture!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : _cameraPreview(),
          _controls(context),
          if (_showSettingsPanel)
            CameraSettingsPanel(
              isSwitchingCamera: _isSwitchingCamera,
              currentCameraIndex: _currentCameraIndex,
              currentResolution: _resolutionPreset,
              currentFps: _targetFps,
              hasMultipleCameras: _cameras.length > 1,
              // Model settings
              useSegmentation: _useSegmentation,
              segMethod: _segMethod,
              applyBrightnessContrast: _applyBrightnessContrast,
              returnProcessedImage: _returnProcessedImage,
              // HSV settings
              hsvHueMin: _hsvHueMin,
              hsvHueMax: _hsvHueMax,
              hsvSatMin: _hsvSatMin,
              hsvSatMax: _hsvSatMax,
              hsvValMin: _hsvValMin,
              hsvValMax: _hsvValMax,
              // Callbacks
              onSwitchCamera: null, // Not used anymore
              onResolutionChange: (preset) {
                _changeResolution(preset);
                setState(() => _showSettingsPanel = false);
              },
              onFpsChange: (fps) {
                _changeFps(fps);
                setState(() => _showSettingsPanel = false);
              },
              onSegmentationChange: (value) {
                setState(() => _useSegmentation = value);
              },
              onSegMethodChange: (method) {
                setState(() => _segMethod = method);
              },
              onBrightnessContrastChange: (value) {
                setState(() => _applyBrightnessContrast = value);
              },
              onReturnProcessedImageChange: (value) {
                setState(() => _returnProcessedImage = value);
              },
              onHsvChange: (hueMin, hueMax, satMin, satMax, valMin, valMax) {
                setState(() {
                  _hsvHueMin = hueMin;
                  _hsvHueMax = hueMax;
                  _hsvSatMin = satMin;
                  _hsvSatMax = satMax;
                  _hsvValMin = valMin;
                  _hsvValMax = valMax;
                });
              },
              onClose: () {
                setState(() => _showSettingsPanel = false);
                _restartStreaming();
              },
            ),
        ],
      ),
    );
  }

  SafeArea _controls(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _header(context),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(0, 0.2),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                              child: child,
                            ),
                          );
                        },
                    child: _picture != null
                        ? _resultCard(context)
                        : Column(
                            children: [
                              _modelStatus(context),
                              _cameraControls(context),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rotating vegetable emoji
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: _isProcessing
                            ? const CircularProgressIndicator()
                            : Text(
                                _currentVeggie,
                                style: const TextStyle(fontSize: 48),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _isProcessing
                                    ? '...'
                                    : _result?.predictedClass.displayName
                                              .replaceAll('_', ' ') ??
                                          '-',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              InkWell(
                                onTap: _setPictureNull,
                                child: Icon(Remix.close_fill),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isProcessing
                                ? '...\n...'
                                : 'Kepercayaan: ${((_result?.confidence ?? 0) * 100).toStringAsFixed(2)}%\nWaktu prediksi: ${(_result?.predictionTimeMs ?? 0).toStringAsFixed(2)} ms',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                WhiteButton(
                  onTap: _isProcessing ? null : () {},
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(
                        MingCuteIcons.mgc_ai_fill,
                        color: Colors.white,
                        size: 20,
                      ),
                      Text(
                        'Cari Dengan AI',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modelStatus(BuildContext context) {
    if (_useEfficient == null) return const SizedBox.shrink();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WhiteButton(
                onTap: () async {
                  await _pcvkStreamService.stopStreaming();
                  setState(() => _useEfficient = null);
                },
                color: Colors.white.withValues(alpha: 0.75),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 13,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      MingCuteIcons.mgc_ai_fill,
                      size: 24,
                      color: Theme.of(context).primaryColor,
                    ),
                    Row(
                      spacing: 2,
                      children: [
                        Text(
                          'Menggunakan:',
                          style: GoogleFonts.poppins().copyWith(
                            fontSize: 13,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          _useEfficient! ? 'Effisien' : 'Simpel',
                          style: GoogleFonts.poppins().copyWith(
                            fontSize: 15,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Icon(Remix.close_fill),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cameraControls(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        );
      },
      child: _useEfficient == null
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: WhiteButton(
                      maxWidth: 162,
                      onTap: () => setState(() => _useEfficient = false),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 13,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            MingCuteIcons.mgc_ai_fill,
                            size: 24,
                            color: Theme.of(context).primaryColor,
                          ),
                          Text(
                            'Simpel',
                            style: GoogleFonts.poppins().copyWith(
                              fontSize: 15,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: WhiteButton(
                      maxWidth: 162,
                      onTap: () => setState(() => _useEfficient = true),
                      child: Row(
                        spacing: 13,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            MingCuteIcons.mgc_ai_fill,
                            size: 24,
                            color: Theme.of(context).primaryColor,
                          ),
                          Text(
                            'Efisien',
                            style: GoogleFonts.poppins().copyWith(
                              fontSize: 15,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              key: const ValueKey('controls'),
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery button
                  WhiteButton(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white.withValues(alpha: 0.75),
                    onTap: _pickFromGallery,
                    child: Icon(Remix.gallery_fill),
                  ),
                  // Shutter button
                  GestureDetector(
                    onTap: _isProcessing ? null : _takePicture,
                    child: SizedBox(
                      width: 88,
                      height: 88,
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.6),
                                  Colors.white.withValues(alpha: 0.6),
                                  Colors.white.withValues(alpha: 0.3),
                                ],
                                stops: const [0.0, 0.7, 1.0],
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _isProcessing
                                      ? Colors.grey
                                      : Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: _isProcessing
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Camera Switch Button (Right) - Symmetry with gallery
                  _cameras.length > 1
                      ? WhiteButton(
                          padding: const EdgeInsets.all(16),
                          color: Colors.white.withValues(alpha: 0.75),
                          onTap: _isSwitchingCamera
                              ? null
                              : () {
                                  _initializeCameraFuture = _switchCamera();
                                },
                          child: _isSwitchingCamera
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF2F80ED),
                                  ),
                                )
                              : Icon(
                                  _currentCameraIndex == 0
                                      ? Remix.camera_switch_fill
                                      : Remix.camera_switch_line,
                                  color: const Color(0xFF2F80ED),
                                ),
                        )
                      : const SizedBox(width: 56),
                ],
              ),
            ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FutureBuilder(
        future: _initializeCameraFuture,
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
            ? const SizedBox.shrink()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Settings Button (Left)
                  InkWellIconButton(
                    onTap: () {
                      setState(() => _showSettingsPanel = !_showSettingsPanel);
                    },
                    icon: Icon(
                      size: 24,
                      _showSettingsPanel
                          ? Remix.settings_3_fill
                          : Remix.settings_3_line,
                      color: Colors.white,
                    ),
                  ),
                  // InkWellIconButton(
                  //   onTap: () => setState(() => _picture = null),
                  //   padding: 16,
                  //   icon: const Icon(
                  //     size: 16,
                  //     Icons.arrow_back_ios_new_rounded,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  if (_useEfficient != null && _picture == null)
                    Flexible(
                      child: WhiteButton(
                        color: Colors.black.withValues(alpha: 0.5),
                        padding: EdgeInsets.all(8),
                        maxWidth: 165,
                        onTap: _handleStreaming,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pcvkStreamService.isStreaming
                                  ? '${_result?.predictedClass ?? "..."} $_currentVeggie\nKepercayaan: ${((_result?.confidence ?? 0) * 100).toStringAsFixed(0)}%'
                                  : 'Aktifkan\nLive Preview',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins().copyWith(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_pcvkStreamService.isStreaming)
                              Text(
                                'Ping: ${_pcvkStreamService.lastPingTimeMs?.toStringAsFixed(0) ?? '...'}ms\nPredict: ${_result?.predictionTimeMs.toStringAsFixed(0) ?? '...'}ms',
                                style: GoogleFonts.poppins().copyWith(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  // Flash Button (Right)
                  InkWellIconButton(
                    onTap: _toggleFlash,
                    icon: Icon(
                      size: 24,
                      _isFlashOn
                          ? RemixIcons.flashlight_fill
                          : RemixIcons.flashlight_line,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  FutureBuilder<void> _cameraPreview() {
    return FutureBuilder(
      future: _initializeCameraFuture,
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.done
          ? _cameraController == null
                ? Center(
                    child: Text(
                      'Tidak ada Camera🥀🥀',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    child: _isSwitchingCamera
                        ? Container(
                            key: const ValueKey('switching'),
                            color: Colors.black,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : _processedImageBytes != null &&
                              _pcvkStreamService.isStreaming
                        ? Image.memory(
                            _processedImageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            gaplessPlayback: true,
                          )
                        : LayoutBuilder(
                            key: ValueKey(
                              _currentCameraIndex,
                            ), // Key for animation
                            builder: (context, constraints) {
                              final mediaSize = MediaQuery.of(context).size;
                              final scale =
                                  1 /
                                  (_cameraController!.value.aspectRatio *
                                      mediaSize.aspectRatio);
                              return ClipRect(
                                clipper: _MediaSizeClipper(mediaSize),
                                child: Transform.scale(
                                  scale: scale,
                                  alignment: Alignment.topCenter,
                                  child: CameraPreview(_cameraController!),
                                ),
                              );
                            },
                          ),
                  )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
