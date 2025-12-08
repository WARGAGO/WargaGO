import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:camera/camera.dart';

class CameraSettingsPanel extends StatelessWidget {
  final bool hasMultipleCameras;
  final bool isSwitchingCamera;
  final int currentCameraIndex;
  final ResolutionPreset currentResolution;
  final int? currentFps;

  // Model settings
  final bool useSegmentation;
  final String segMethod;
  final bool applyBrightnessContrast;
  final bool returnProcessedImage;

  // HSV settings
  final double hsvHueMin;
  final double hsvHueMax;
  final double hsvSatMin;
  final double hsvSatMax;
  final double hsvValMin;
  final double hsvValMax;

  // Callbacks
  final VoidCallback? onSwitchCamera;
  final Function(ResolutionPreset) onResolutionChange;
  final Function(int?) onFpsChange;
  final Function(bool) onSegmentationChange;
  final Function(String) onSegMethodChange;
  final Function(bool) onBrightnessContrastChange;
  final Function(bool) onReturnProcessedImageChange;
  final Function(double, double, double, double, double, double) onHsvChange;
  final VoidCallback onClose;

  final bool showModelSimpleSettings;

  const CameraSettingsPanel({
    super.key,
    required this.hasMultipleCameras,
    required this.isSwitchingCamera,
    required this.currentCameraIndex,
    required this.currentResolution,
    required this.currentFps,
    required this.useSegmentation,
    required this.segMethod,
    required this.applyBrightnessContrast,
    required this.returnProcessedImage,
    required this.hsvHueMin,
    required this.hsvHueMax,
    required this.hsvSatMin,
    required this.hsvSatMax,
    required this.hsvValMin,
    required this.hsvValMax,
    required this.onSwitchCamera,
    required this.onResolutionChange,
    required this.onFpsChange,
    required this.onSegmentationChange,
    required this.onSegMethodChange,
    required this.onBrightnessContrastChange,
    required this.onReturnProcessedImageChange,
    required this.onHsvChange,
    required this.onClose,
    required this.showModelSimpleSettings,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 106),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pengaturan Kamera',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        _buildSettingItem(
                          context: context,
                          icon: Remix.hd_fill,
                          title: 'Kualitas',
                          subtitle: _getResolutionName(currentResolution),
                          onTap: () => _showResolutionPicker(context),
                          isLoading: isSwitchingCamera,
                        ),
                        _buildSettingItem(
                          context: context,
                          icon: Remix.speed_fill,
                          title: 'FPS',
                          subtitle: currentFps == null
                              ? 'Auto'
                              : '$currentFps FPS',
                          onTap: () => _showFpsPicker(context),
                          isLoading: isSwitchingCamera,
                        ),

                        if (showModelSimpleSettings)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _divider(),
                              // Model Settings Section
                              Text(
                                'Pengaturan Model (Model Simple)',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildSwitchItem(
                                context: context,
                                icon: Remix.scan_2_fill,
                                title: 'Gunakan Segmentasi',
                                value: useSegmentation,
                                onChanged: onSegmentationChange,
                              ),
                              if (useSegmentation)
                                _buildSettingItem(
                                  context: context,
                                  icon: Remix.palette_fill,
                                  title: 'Metode Segmentasi',
                                  subtitle: _getSegMethodName(segMethod),
                                  onTap: () => _showSegMethodPicker(context),
                                ),
                              if (useSegmentation && segMethod == 'hsv')
                                _buildHsvSliders(context),
                              _buildSwitchItem(
                                context: context,
                                icon: Remix.contrast_2_fill,
                                title:
                                    'Brightness & Contrast Enhancement (CLAHE)',
                                value: applyBrightnessContrast,
                                onChanged: onBrightnessContrastChange,
                              ),
                              _buildSwitchItem(
                                context: context,
                                icon: Remix.image_fill,
                                title:
                                    'Kembalikan Gambar Proses (Live Preview)',
                                value: returnProcessedImage,
                                onChanged: onReturnProcessedImageChange,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column _divider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Remix.arrow_right_s_line, color: Colors.black38, size: 20),
          ],
        ),
      ),
    );
  }

  String _getResolutionName(ResolutionPreset preset) {
    switch (preset) {
      case ResolutionPreset.low:
        return 'Rendah (320p)';
      case ResolutionPreset.medium:
        return 'Sedang (480p)';
      case ResolutionPreset.high:
        return 'Tinggi (720p)';
      case ResolutionPreset.veryHigh:
        return 'Sangat Tinggi (1080p)';
      case ResolutionPreset.ultraHigh:
        return 'Ultra Tinggi (2160p)';
      case ResolutionPreset.max:
        return 'Maksimal';
    }
  }

  void _showResolutionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih Kualitas',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              ResolutionPreset.low,
              ResolutionPreset.medium,
              ResolutionPreset.high,
              ResolutionPreset.veryHigh,
              ResolutionPreset.ultraHigh,
              ResolutionPreset.max,
            ].map(
              (preset) => ListTile(
                leading: Icon(
                  preset == ResolutionPreset.ultraHigh ||
                          preset == ResolutionPreset.max
                      ? Remix.a_4k_fill
                      : Remix.hd_fill,
                  color: currentResolution == preset
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                title: Text(
                  _getResolutionName(preset),
                  style: GoogleFonts.poppins(
                    fontWeight: currentResolution == preset
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: currentResolution == preset
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                  ),
                ),
                trailing: currentResolution == preset
                    ? Icon(
                        Remix.check_line,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
                onTap: () {
                  onResolutionChange(preset);
                  Navigator.pop(context);
                  onClose();
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showFpsPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih FPS',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              {'value': null, 'label': 'Auto'},
              {'value': 30, 'label': '30 FPS'},
              {'value': 60, 'label': '60 FPS (Jika ada)'},
            ].map((option) {
              final int? value = option['value'] as int?;
              final String label = option['label'] as String;
              return ListTile(
                leading: Icon(
                  Remix.speed_fill,
                  color: currentFps == value
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                title: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: currentFps == value
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: currentFps == value
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                  ),
                ),
                trailing: currentFps == value
                    ? Icon(
                        Remix.check_line,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
                onTap: () {
                  onFpsChange(value);
                  Navigator.pop(context);
                  onClose();
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getSegMethodName(String method) {
    switch (method) {
      case 'u2netp':
        return 'U2-Net P (Deep Learning)';
      case 'hsv':
        return 'HSV (Color Based)';
      case 'grabcut':
        return 'GrabCut';
      case 'adaptive':
        return 'Adaptive Threshold';
      default:
        return method;
    }
  }

  Widget _buildSwitchItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  void _showSegMethodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih Metode Segmentasi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              'u2netp',
              // 'hsv',
              'grabcut', 'adaptive',
            ].map((method) {
              return ListTile(
                leading: Icon(
                  Remix.palette_fill,
                  color: segMethod == method
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                title: Text(
                  _getSegMethodName(method),
                  style: GoogleFonts.poppins(
                    fontWeight: segMethod == method
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: segMethod == method
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                  ),
                ),
                trailing: segMethod == method
                    ? Icon(
                        Remix.check_line,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
                onTap: () {
                  onSegMethodChange(method);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHsvSliders(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengaturan HSV',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              // Color Preview
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _hsvToColor(hsvHueMin, hsvSatMin, hsvValMin),
                      _hsvToColor(
                        (hsvHueMin + hsvHueMax) / 2,
                        (hsvSatMin + hsvSatMax) / 2,
                        (hsvValMin + hsvValMax) / 2,
                      ),
                      _hsvToColor(hsvHueMax, hsvSatMax, hsvValMax),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHsvRangeSlider(
            context: context,
            label: 'Hue',
            min: 0,
            max: 180,
            currentMin: hsvHueMin,
            currentMax: hsvHueMax,
            onChanged: (min, max) {
              onHsvChange(min, max, hsvSatMin, hsvSatMax, hsvValMin, hsvValMax);
            },
          ),
          _buildHsvRangeSlider(
            context: context,
            label: 'Saturation',
            min: 0,
            max: 255,
            currentMin: hsvSatMin,
            currentMax: hsvSatMax,
            onChanged: (min, max) {
              onHsvChange(hsvHueMin, hsvHueMax, min, max, hsvValMin, hsvValMax);
            },
          ),
          _buildHsvRangeSlider(
            context: context,
            label: 'Value',
            min: 0,
            max: 255,
            currentMin: hsvValMin,
            currentMax: hsvValMax,
            onChanged: (min, max) {
              onHsvChange(hsvHueMin, hsvHueMax, hsvSatMin, hsvSatMax, min, max);
            },
          ),
        ],
      ),
    );
  }

  Color _hsvToColor(double hue, double saturation, double value) {
    // Convert HSV to RGB
    // Hue is in range 0-180 (OpenCV format), convert to 0-360
    final h = (hue / 180.0) * 360.0;
    final s = saturation / 255.0;
    final v = value / 255.0;

    return HSVColor.fromAHSV(1.0, h, s, v).toColor();
  }

  Widget _buildHsvRangeSlider({
    required BuildContext context,
    required String label,
    required double min,
    required double max,
    required double currentMin,
    required double currentMax,
    required Function(double, double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              '${currentMin.toInt()} - ${currentMax.toInt()}',
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(currentMin, currentMax),
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          activeColor: Theme.of(context).primaryColor,
          onChanged: (values) {
            onChanged(values.start, values.end);
          },
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
