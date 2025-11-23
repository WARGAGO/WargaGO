// ============================================================================
// WARGA LOGIN PAGE
// ============================================================================
// Halaman login untuk warga yang sudah terdaftar dan disetujui
//
// Flow:
// 1. Warga input email & password
// 2. System cek ke Firebase Auth
// 3. Cek status verifikasi di Firestore
// 4. Jika approved -> Warga Dashboard
// 5. Jika pending -> Pending Page
// 6. Jika rejected -> Rejected Page
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jawara/core/providers/auth_provider.dart';
import 'package:jawara/core/constants/app_routes.dart';
import 'package:jawara/features/common/auth/presentation/widgets/auth_constants.dart';
import 'package:jawara/features/common/auth/presentation/widgets/auth_widgets.dart';

/// Warga Login Page - Halaman login khusus untuk warga
class WargaLoginPage extends StatefulWidget {
  const WargaLoginPage({super.key});

  @override
  State<WargaLoginPage> createState() => _WargaLoginPageState();
}

class _WargaLoginPageState extends State<WargaLoginPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  bool _isForward = true;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addStatusListener(_handleStatus);
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward(from: 0.0);
  }

  void _handleStatus(AnimationStatus status) {
    if (!mounted) return;
    if (status == AnimationStatus.completed) {
      _isForward = false;
      _controller.reverse();
    } else if (status == AnimationStatus.dismissed) {
      _isForward = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleStatus);
    _controller.dispose();
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
        final status = user?.status;

        // Cek status verifikasi warga
        if (status == 'approved') {
          // Warga sudah disetujui -> ke dashboard
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.wargaDashboard,
            (route) => false,
          );
        } else if (status == 'pending') {
          // Masih menunggu approval
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.pending,
            (route) => false,
          );
        } else if (status == 'rejected') {
          // Ditolak admin
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.rejected,
            (route) => false,
          );
        } else {
          // Status unverified -> belum upload KYC
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.wargaKYC,
            (route) => false,
          );
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
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _progress,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Animated background
              _BlobBackground(progress: _progress.value),

              // Content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),

                        // Back button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          'Login Warga',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F1F1F),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'Masuk dengan akun warga yang sudah terdaftar',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF8D8D8D),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Email field
                        AuthTextField(
                          controller: _emailController,
                          hintText: 'warga@example.com',
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

                        // Password field
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
                        const SizedBox(height: 32),

                        // Login button
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AuthColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                              textStyle: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Masuk'),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum punya akun? ',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF8D8D8D),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.wargaRegister,
                                );
                              },
                              child: Text(
                                'Daftar di sini',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AuthColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BlobBackground extends StatelessWidget {
  const _BlobBackground({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _BlobPainter(
            baseColor: AuthColors.primary.withOpacity(0.12),
            accentColor: AuthColors.primary.withOpacity(0.35),
            progress: progress,
          ),
        ),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter({
    required this.baseColor,
    required this.accentColor,
    required this.progress,
  });

  final Color baseColor;
  final Color accentColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = baseColor;
    final paint2 = Paint()..color = accentColor;

    final path1 = _createBlobPath(size, progress, 0.0);
    final path2 = _createBlobPath(size, progress, 0.5);

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  Path _createBlobPath(Size size, double t, double offset) {
    final path = Path();
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.3;
    final radius = size.width * 0.4;

    for (var i = 0; i < 360; i += 10) {
      final angle = i * math.pi / 180;
      final r = radius +
          math.sin((angle + t * 2 * math.pi + offset * math.pi) * 3) * 20;
      final x = centerX + r * math.cos(angle);
      final y = centerY + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_BlobPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

