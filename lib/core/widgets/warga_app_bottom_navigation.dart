import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/core/constants/app_routes.dart';
import 'package:wargago/core/providers/auth_provider.dart';
import 'package:wargago/core/services/kyc_service.dart';
import 'package:provider/provider.dart';

/// Unified Bottom Navigation Bar untuk semua halaman
/// Menggunakan desain modern dengan gradient pada active state
class WargaAppBottomNavigation extends StatefulWidget {
  final StatefulNavigationShell? navigationShell;
  final Widget? child;
  const WargaAppBottomNavigation({super.key, this.navigationShell, this.child});

  @override
  State<WargaAppBottomNavigation> createState() =>
      _WargaAppBottomNavigationState();
}

class _WargaAppBottomNavigationState extends State<WargaAppBottomNavigation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  bool _isAnimating = false;

  final KYCService _kycService = KYCService();
  late final AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _fade = CurvedAnimation(
      parent: ReverseAnimation(_controller),
      curve: Curves.easeOutSine,
      reverseCurve: Curves.easeInSine,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _kycService.initializationDone,
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
          ? const CircularProgressIndicator()
          : Scaffold(
              body:
                  widget.child ??
                  FadeTransition(opacity: _fade, child: widget.navigationShell),
              bottomNavigationBar: _buildBottomNavigationBar(
                authProvider.userModel!.id,
              ),
            ),
    );
  }

  // Build bottom navigation bar with KYC check
  Widget _buildBottomNavigationBar(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: userId.isNotEmpty
          ? _kycService.getUserKYCDocuments(userId)
          : null,
      builder: (context, snapshot) {
        // Check KYC status
        bool isKYCVerified = false;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final docs = snapshot.data!.docs;
          final ktpDoc = docs
              .where((doc) => doc['documentType'] == 'ktp')
              .firstOrNull;
          final kkDoc = docs
              .where((doc) => doc['documentType'] == 'kk')
              .firstOrNull;

          if (ktpDoc != null && kkDoc != null) {
            final ktpStatus = ktpDoc['status'] ?? 'pending';
            final kkStatus = kkDoc['status'] ?? 'pending';
            isKYCVerified = ktpStatus == 'approved' && kkStatus == 'approved';
          }
        }

        return _buildBottomNav(isKYCVerified);
      },
    );
  }

  Widget _buildBottomNav(bool isKYCVerified) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Bottom nav bar dengan curved notch
        CustomPaint(
          painter: _BottomNavPainter(),
          child: Container(
            height: 70,
            padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  enabled: true, // Always enabled
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.store_outlined,
                  activeIcon: Icons.store_rounded,
                  label: 'Marketplace',
                  enabled: isKYCVerified, // Perlu KYC
                ),
                // Spacer untuk scan button yang floating
                const SizedBox(width: 60),
                _buildNavItem(
                  index: 2,
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet_rounded,
                  label: 'Iuran',
                  enabled: isKYCVerified, // Perlu KYC
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Akun',
                  enabled: true, // Always enabled
                ),
              ],
            ),
          ),
        ),
        // Scan button floating di tengah atas - requires KYC
        Positioned(top: -25, child: _buildScanButton(true)),
      ],
    );
  }

  Widget _buildScanButton(bool isKYCVerified) {
    return GestureDetector(
      onTap: () {
        if (!isKYCVerified) {
          _showKYCRequiredDialog();
        } else {
          context.push(AppRoutes.wargaClassificationCamera);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: isKYCVerified
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF5B8DEF), Color(0xFF2F80ED)],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF9CA3AF).withValues(alpha: 0.5),
                        const Color(0xFF6B7280).withValues(alpha: 0.5),
                      ],
                    ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isKYCVerified
                      ? const Color(0xFF2F80ED).withValues(alpha: 0.4)
                      : const Color(0xFF9CA3AF).withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.qr_code_scanner_rounded,
              color: isKYCVerified ? Colors.white : Colors.white70,
              size: 30,
            ),
          ),
          if (!isKYCVerified)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock, color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
    );
  }

  void _showKYCRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFF59E0B),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'KYC Diperlukan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Untuk mengakses fitur ini, Anda perlu melengkapi verifikasi KYC terlebih dahulu.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dokumen yang dibutuhkan:',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRequirementItem('KTP (Kartu Tanda Penduduk)'),
                  _buildRequirementItem('KK (Kartu Keluarga)'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Nanti',
              style: GoogleFonts.poppins(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              context.push(AppRoutes.wargaKYC);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F80ED),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Upload Sekarang',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Color(0xFF2F80ED),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    bool enabled = true,
  }) {
    final currentIndex = widget.navigationShell?.currentIndex ?? -1;
    final isActive = currentIndex == index;

    return SizedBox(
      width: 65,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _goTo(index),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 24,
                  color: isActive
                      ? const Color(0xFF2F80ED)
                      : const Color(0xFF9CA3AF),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? const Color(0xFF2F80ED)
                        : const Color(0xFF9CA3AF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _goTo(int index) async {
    if (widget.navigationShell == null) {
      switch (index) {
        case 1:
          context.go(AppRoutes.wargaMarketplace);
          break;
        case 2:
          context.go(AppRoutes.wargaIuran);
          break;
        case 3:
          context.go(AppRoutes.wargaAkun);
          break;
        case 4:
          if (ModalRoute.of(context)?.settings.name !=
              AppRoutes.wargaClassificationCamera) {
            context.go(AppRoutes.wargaClassificationCamera);
          }
          break;
        case 0:
        default:
          context.go(AppRoutes.wargaDashboard);
          break;
      }
    } else {
      final isReselect = index == widget.navigationShell!.currentIndex;
      if (_isAnimating && !isReselect) return; // avoid overlapping animations

      if (isReselect) {
        widget.navigationShell!.goBranch(index, initialLocation: true);
        return;
      }

      try {
        _isAnimating = true;
        // Fade out current content
        await _controller.forward();
        if (!mounted) return;

        // Switch branch while content is invisible
        widget.navigationShell!.goBranch(index, initialLocation: true);

        // Give a frame for the new content to layout before fade-in
        await Future.delayed(const Duration(milliseconds: 16));
      } finally {
        if (mounted) {
          await _controller.reverse(); // Fade in new content
        }
        _isAnimating = false;
      }
    }
  }
}

class _BottomNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();

    // Mulai dari kiri bawah
    path.moveTo(0, size.height);

    // Naik ke kiri atas
    path.lineTo(0, 0);

    // Garis horizontal kiri sampai sebelum notch
    path.lineTo(size.width * 0.38, 0);

    // Curve turun ke notch (sisi kiri)
    path.quadraticBezierTo(
      size.width * 0.42, // control point x
      0, // control point y
      size.width * 0.44, // end point x
      15, // end point y (depth of curve)
    );

    // Curve ke tengah notch
    path.quadraticBezierTo(
      size.width * 0.48, // control point x
      25, // control point y (bottom of notch)
      size.width * 0.50, // end point x (center)
      25, // end point y
    );

    // Curve dari tengah ke kanan notch
    path.quadraticBezierTo(
      size.width * 0.52, // control point x
      25, // control point y
      size.width * 0.56, // end point x
      15, // end point y
    );

    // Curve naik dari notch (sisi kanan)
    path.quadraticBezierTo(
      size.width * 0.58, // control point x
      0, // control point y
      size.width * 0.62, // end point x
      0, // end point y
    );

    // Garis horizontal kanan
    path.lineTo(size.width, 0);

    // Turun ke kanan bawah
    path.lineTo(size.width, size.height);

    // Garis bawah
    path.lineTo(0, size.height);

    path.close();

    // Draw shadow first
    canvas.drawPath(path, shadowPaint);

    // Draw main shape on top
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
