import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/core/constants/app_routes.dart';
import 'package:wargago/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

/// Halaman Profil Bendahara
/// Menampilkan informasi profil pengguna dan menu pengaturan
class BendaharaProfilePage extends StatefulWidget {
  const BendaharaProfilePage({super.key});

  @override
  State<BendaharaProfilePage> createState() => _BendaharaProfilePageState();
}

class _BendaharaProfilePageState extends State<BendaharaProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2F80ED), Color(0xFF1E5BA8)],
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                        // Profile Header Card (inline karena lebih mudah dikustomisasi)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F80ED).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF2F80ED).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.account_balance_wallet,
                                  size: 48,
                                  color: const Color(0xFF2F80ED),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.nama ?? 'Bendahara RW',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Bendahara',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF2F80ED),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.email ?? 'bendahara@wargago.com',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                                value: user?.nik ?? '3201234567890123',
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                icon: Icons.phone_outlined,
                                label: 'Nomor Telepon',
                                value: user?.noTelp ?? '+62 812-3456-7890',
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _showLogoutConfirmation(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE74C3C),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Keluar',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
          child: Icon(icon, color: const Color(0xFF2F80ED), size: 20),
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

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    onPressed: () async {
                      Navigator.pop(context);
                      await authProvider.signOut();
                      if (context.mounted) {
                        context.go(AppRoutes.login);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
}
