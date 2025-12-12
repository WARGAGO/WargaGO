import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/features/sekertaris/profil/widgets/profile_header.dart';
import 'package:wargago/features/sekertaris/profil/widgets/logout_button.dart';

/// Halaman Profil Sekretaris
/// Menampilkan informasi profil pengguna dan menu pengaturan
class SekretarisProfilePage extends StatefulWidget {
  const SekretarisProfilePage({super.key});

  @override
  State<SekretarisProfilePage> createState() => _SekretarisProfilePageState();
}

class _SekretarisProfilePageState extends State<SekretarisProfilePage> {
  // TODO: Get from auth service

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2F80ED),
              Color(0xFF1E5BA8),
            ],
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      'Profil',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Profile Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header Card
                        const ProfileHeader(
                          userName: 'Rafa Fadil Aras',
                          userRole: 'Sekretaris',
                          userEmail: 'sekretaris@sekretaris.jawara.com',
                        ),
                        const SizedBox(height: 24),
                        
                        // Info Section
                        Text(
                          'Informasi Akun',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF2F80ED).withAlpha(13),
                                const Color(0xFF2F80ED).withAlpha(5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF2F80ED).withAlpha(51),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                icon: Icons.badge_outlined,
                                label: 'NIK',
                                value: '3201234567890123',
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                icon: Icons.phone_outlined,
                                label: 'Nomor Telepon',
                                value: '+62 812-3456-7890',
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                icon: Icons.location_on_outlined,
                                label: 'Alamat',
                                value: 'Jl. Merdeka No. 123, RT 02/RW 05',
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                icon: Icons.work_outline,
                                label: 'Masa Jabatan',
                                value: '2024 - 2026',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Logout Button
                        LogoutButton(
                          onPressed: () {
                            _showLogoutConfirmation(context);
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Info Row
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2F80ED).withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2F80ED),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF718096),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Show Logout Confirmation Dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout,
                size: 48,
                color: Color(0xFFE74C3C),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Keluar dari Akun?',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Anda akan keluar dari akun dan harus login kembali untuk mengakses aplikasi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF718096),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A5568),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _performLogout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Keluar',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

  /// Perform Logout
  void _performLogout() {
    // TODO: Implement actual logout logic (clear auth, navigate to login)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Berhasil keluar dari akun',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF27AE60),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    
    // TODO: Navigate to login page
    // Navigator.pushReplacementNamed(context, '/login');
  }
}
