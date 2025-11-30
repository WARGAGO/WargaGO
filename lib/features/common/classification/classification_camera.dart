import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawara/core/enums/predict_class_enum.dart';
import 'package:jawara/core/models/PCVK/predict_response.dart';
import 'package:jawara/core/services/pcvk_service.dart';
import 'package:jawara/features/common/classification/widgets/inkwell_iconbutton.dart';
import 'package:jawara/features/common/classification/widgets/white_button.dart';
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

  late final ImagePicker _imagePicker;
  bool? _useEfficient;

  late final PcvkService _pcvkService;

  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(
        _cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
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
  }

  @override
  void dispose() {
    _veggieTimer?.cancel();
    _cameraController?.dispose();
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

  Future<void> _pickFromGallery() async {
    try {
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

    setState(() => _isProcessing = true);

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
  PredictModelResponse? _result;
  void _processImage(File imageFile) async {
    setState(() {
      _isProcessing = true;
      _picture = imageFile;
    });

    _result = await _pcvkService.predict(
      _picture!,
      modelType: _useEfficient! ? 'efficientnetv2' : 'mlpv2_auto-clahe',
    );

    switch (_result!.predictedClass) {
      case PredictClass.sayurAkar:
        _startVeggieRotation(emojis: ['🥕', '🥔']);
        break;
      case PredictClass.sayurBuah:
        _startVeggieRotation(emojis: ['🫑', "🍅", '🥒', "🎃", '🥭']);
        break;
      case PredictClass.sayurBunga:
        _startVeggieRotation(emojis: ['🥦']);
        break;
      case PredictClass.sayurDaun:
        _startVeggieRotation(emojis: ['🥬']);
      default:
    }

    setState(() => _isProcessing = false);
  }

  List<String> _vegetables = ['🍅', '🌶️', '🥕', '🥬', '🧄', '🧅', '🥒'];
  int _currentVeggieIndex = 0;
  Timer? _veggieTimer;

  void _startVeggieRotation({List<String>? emojis}) {
    _vegetables = emojis!;
    _veggieTimer?.cancel();
    _currentVeggieIndex = 0;
    _veggieTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _currentVeggieIndex = (_currentVeggieIndex + 1) % _vegetables.length;
        });
      }
    });
  }

  String get _currentVeggie => _vegetables[_currentVeggieIndex];

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
                          _isProcessing
                              ? const Text('...')
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _result?.predictedClass.displayName
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
                onTap: () => setState(() => _useEfficient = null),
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
                  // Spacer for symmetry
                  const SizedBox(width: 56),
                ],
              ),
            ),
    );
  }

  Row _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox.shrink(),
        // InkWellIconButton(
        //   onTap: () => setState(() => _picture = null),
        //   padding: 16,
        //   icon: const Icon(
        //     size: 16,
        //     Icons.arrow_back_ios_new_rounded,
        //     color: Colors.white,
        //   ),
        // ),
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
                : LayoutBuilder(
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
