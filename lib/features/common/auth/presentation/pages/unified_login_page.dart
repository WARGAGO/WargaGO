// ============================================================================
// UNIFIED LOGIN PAGE
// ============================================================================
// Halaman login untuk SEMUA USER (Admin & Warga)
// Sistem otomatis deteksi role dari database
//
// Konsep:
// - Admin: Tidak perlu daftar (sudah ada di sistem)
// - Warga: Bisa daftar dengan tombol "Belum punya akun? Daftar"
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jawara/core/providers/auth_provider.dart';
import 'package:jawara/core/constants/app_routes.dart';
import 'package:jawara/features/admin/dashboard/dashboard_page.dart';
import 'package:jawara/features/warga/dashboard/warga_dashboard_page.dart';
import '../widgets/auth_constants.dart';
import '../widgets/auth_widgets.dart';

/// Unified Login Page - Satu halaman login untuk Admin & Warga
class UnifiedLoginPage extends StatefulWidget {
  const UnifiedLoginPage({super.key});

  @override
  State<UnifiedLoginPage> createState() => _UnifiedLoginPageState();
}

class _UnifiedLoginPageState extends State<UnifiedLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        final user = authProvider.userModel;

        // Auto-detect role dan redirect
        if (user?.role == 'admin') {
          // Admin → Dashboard Admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        } else if (user?.role == 'warga') {
          // Warga → Check status verifikasi
          if (user?.status == 'approved') {
            // Warga approved → Dashboard Warga
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WargaDashboardPage()),
            );
          } else if (user?.status == 'pending') {
            // Warga pending → Halaman waiting approval
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.pending,
              (route) => false,
            );
          } else if (user?.status == 'rejected') {
            // Warga rejected
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.rejected,
              (route) => false,
            );
          } else {
            // Status unverified → Belum upload KYC
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.wargaKYC,
              (route) => false,
            );
          }
        }
      } else {
        _showError(authProvider.errorMessage ?? 'Login gagal');
      }
    } catch (e) {
      if (mounted) {
        _showError('Terjadi kesalahan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AuthColors.primary,
              AuthColors.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo & Title
                    const AuthLogo(),
                    const SizedBox(height: 16),

                    Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Masukkan email dan password Anda',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Email Field
                    AuthTextField(
                      controller: _emailController,
                      hintText: 'email@example.com',
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@')) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    AuthTextField(
                      controller: _passwordController,
                      hintText: '••••••••',
                      labelText: 'Password',
                      obscureText: !_isPasswordVisible,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur lupa password belum tersedia'),
                            ),
                          );
                        },
                        child: Text(
                          'Lupa Password?',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    AuthPrimaryButton(
                      text: 'Login',
                      onPressed: _isLoading ? null : _handleLogin,
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white.withOpacity(0.3),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'atau',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white.withOpacity(0.3),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Register Link (Khusus Warga)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.wargaRegister);
                        },
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            children: [
                              const TextSpan(text: 'Belum punya akun? '),
                              TextSpan(
                                text: 'Daftar Sekarang',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info untuk Admin
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white.withOpacity(0.9),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Admin sudah terdaftar di sistem.\nWarga dapat mendaftar dengan tombol di atas.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.5,
                              ),
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
        ),
      ),
    );
  }
}

