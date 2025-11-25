// ============================================================================
// WARGA MAIN PAGE WITH BOTTOM NAVIGATION
// ============================================================================
// Main page dengan bottom navigation untuk warga
// Includes KYC verification alert and menu restrictions
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home/pages/warga_home_page.dart';
import 'marketplace/pages/warga_marketplace_page.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/kyc_service.dart';
import '../common/auth/presentation/pages/warga/kyc_upload_page.dart';
class WargaMainPage extends StatefulWidget {
  const WargaMainPage({super.key});
  @override
  State<WargaMainPage> createState() => _WargaMainPageState();
}
class _WargaMainPageState extends State<WargaMainPage> {
  int _currentIndex = 0;
  final KYCService _kycService = KYCService();

  // Pages - akan di-restrict berdasarkan KYC status
  late final List<Widget> _allPages;

  @override
  void initState() {
    super.initState();
    _allPages = [
      const WargaHomePage(),           // Index 0: Home
      const WargaMarketplacePage(),    // Index 1: Marketplace (Perlu KYC)
      const _IuranPage(),              // Index 2: Iuran (Perlu KYC)
      const _AkunPage(),               // Index 3: Akun
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.userModel?.id;

    return Scaffold(
      body: Column(
        children: [
          // KYC Alert Banner (if not verified)
          if (userId != null)
            _buildKYCAlertBanner(userId),

          // Main content
          Expanded(
            child: IndexedStack(
              index: _getPageIndex(_currentIndex),
              children: _allPages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: userId != null
          ? _buildBottomNavigationBar(userId)
          : _buildBottomNavigationBar(''),
    );
  }

  // Map navigation index to actual page index
  int _getPageIndex(int navIndex) {
    // Navigation: 0=Home, 1=Marketplace, 2=Scan, 3=Iuran, 4=Akun
    // Pages: 0=Home, 1=Marketplace, 2=Iuran, 3=Akun
    switch (navIndex) {
      case 0: return 0; // Home
      case 1: return 1; // Marketplace
      case 3: return 2; // Iuran
      case 4: return 3; // Akun
      default: return 0;
    }
  }

  // Build KYC Alert Banner
  Widget _buildKYCAlertBanner(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _kycService.getUserKYCDocuments(userId),
      builder: (context, snapshot) {
        // Check if user has completed KYC
        bool hasKYC = false;
        bool isVerified = false;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          // Check if all required documents are uploaded and approved
          final docs = snapshot.data!.docs;
          final ktpDoc = docs.where((doc) => doc['documentType'] == 'ktp').firstOrNull;
          final kkDoc = docs.where((doc) => doc['documentType'] == 'kk').firstOrNull;

          hasKYC = ktpDoc != null && kkDoc != null;

          if (hasKYC) {
            final ktpStatus = ktpDoc['status'] ?? 'pending';
            final kkStatus = kkDoc['status'] ?? 'pending';
            isVerified = ktpStatus == 'approved' && kkStatus == 'approved';
          }
        }

        // Show alert if KYC not completed or not verified
        if (!hasKYC || !isVerified) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFEF3C7),
                  const Color(0xFFFDE68A),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFBBF24),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFF59E0B),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        !hasKYC
                            ? 'Lengkapi Data KYC Anda'
                            : 'Menunggu Verifikasi KYC',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        !hasKYC
                            ? 'Upload KTP & KK untuk mengakses semua fitur'
                            : 'Data Anda sedang diverifikasi admin',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF78350F),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!hasKYC)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KYCUploadPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Upload',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomNavigationBar(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: userId.isNotEmpty ? _kycService.getUserKYCDocuments(userId) : null,
      builder: (context, snapshot) {
        // Check KYC status
        bool isKYCVerified = false;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final docs = snapshot.data!.docs;
          final ktpDoc = docs.where((doc) => doc['documentType'] == 'ktp').firstOrNull;
          final kkDoc = docs.where((doc) => doc['documentType'] == 'kk').firstOrNull;

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
                  index: 3,
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet_rounded,
                  label: 'Iuran',
                  enabled: isKYCVerified, // Perlu KYC
                ),
                _buildNavItem(
                  index: 4,
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
        Positioned(
          top: -25,
          child: _buildScanButton(isKYCVerified),
        ),
      ],
    );
  }

  Widget _buildScanButton(bool isKYCVerified) {
    return GestureDetector(
      onTap: () {
        if (!isKYCVerified) {
          _showKYCRequiredDialog();
        } else {
          // TODO: Implement scan functionality
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Fitur Scan dalam pengembangan',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: const Color(0xFF2F80ED),
              behavior: SnackBarBehavior.floating,
            ),
          );
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
                      colors: [
                        Color(0xFF5B8DEF),
                        Color(0xFF2F80ED),
                      ],
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
                child: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 14,
                ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KYCUploadPage(),
                ),
              );
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
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
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
    final isActive = _currentIndex == index;

    return SizedBox(
      width: 65,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
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
}

// ============================================================================
// IURAN PAGE (Requires KYC)
// ============================================================================
class _IuranPage extends StatelessWidget {
  const _IuranPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Iuran',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 80,
              color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Iuran',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fitur dalam pengembangan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// AKUN PAGE (Always accessible)
// ============================================================================
class _AkunPage extends StatelessWidget {
  const _AkunPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Akun',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_rounded,
              size: 80,
              color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Akun',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fitur dalam pengembangan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ============================================================================
// CUSTOM PAINTER FOR CURVED BOTTOM NAVIGATION
// ============================================================================
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
      0,                 // control point y
      size.width * 0.44, // end point x
      15,                // end point y (depth of curve)
    );

    // Curve ke tengah notch
    path.quadraticBezierTo(
      size.width * 0.48, // control point x
      25,                // control point y (bottom of notch)
      size.width * 0.50, // end point x (center)
      25,                // end point y
    );

    // Curve dari tengah ke kanan notch
    path.quadraticBezierTo(
      size.width * 0.52, // control point x
      25,                // control point y
      size.width * 0.56, // end point x
      15,                // end point y
    );

    // Curve naik dari notch (sisi kanan)
    path.quadraticBezierTo(
      size.width * 0.58, // control point x
      0,                 // control point y
      size.width * 0.62, // end point x
      0,                 // end point y
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


