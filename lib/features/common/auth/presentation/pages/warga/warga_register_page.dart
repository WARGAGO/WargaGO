// ============================================================================
// WARGA REGISTER PAGE
// ============================================================================
// Halaman registrasi untuk warga dengan dua metode:
// 1. Google Sign-In
// 2. Manual dengan email & password
//
// Setelah registrasi, status = 'unverified'
// Warga harus upload dokumen KYC untuk verifikasi
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wargago/core/constants/app_routes.dart';
import 'package:wargago/core/providers/auth_provider.dart';
import 'package:wargago/features/common/auth/presentation/widgets/auth_widgets.dart';
import 'package:wargago/features/common/classification/widgets/inkwell_iconbutton.dart';

class WargaRegisterPage extends StatelessWidget {
  const WargaRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E5CB8), // Deep blue
              Color(0xFF2F80ED), // Primary blue Wargago
              Color(0xFF5B8DEF), // Light blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button, "Already have account", and "Sign In"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    // Back button - Navigate to preAuth (keluar dari register)
                    InkWellIconButton(
                      onTap: () => context.go(AppRoutes.preAuth),
                      icon: Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                      color: Colors.transparent,
                    ),
                    Spacer(),
                    // "Already have an account?"
                    Text(
                      "Already have an account?",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(width: 12),
                    // "Sign In" button
                    TextButton(
                      onPressed: () {
                        // Navigate to login page
                        context.go(AppRoutes.login);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Register body content
              Expanded(child: const _RegisterBody()),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterBody extends StatefulWidget {
  const _RegisterBody();

  @override
  State<_RegisterBody> createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<_RegisterBody> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle Google Sign In
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Navigate based on user status
      if (authProvider.userModel?.status == 'unverified') {
        // New user - redirect to KYC upload
        context.go(AppRoutes.wargaKYC);
      } else {
        // Existing verified user - redirect to dashboard
        context.go(AppRoutes.wargaDashboard);
      }
    } else {
      AuthDialogs.showError(
        context,
        'Login Gagal',
        authProvider.errorMessage ??
            'Terjadi kesalahan saat login dengan Google',
      );
    }
  }

  /// Handle manual registration
  Future<void> _handleRegister() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Validate password match
    if (_passwordController.text != _confirmPasswordController.text) {
      AuthDialogs.showError(
        context,
        'Error',
        'Password dan konfirmasi password tidak sama',
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Call registerWarga from AuthProvider
    // registerWarga already auto-login user, no need to call signIn again
    final success = await authProvider.registerWarga(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nama: _namaController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // User already logged in after registerWarga
      // Show success dialog then redirect to KYC upload
      AuthDialogs.showSuccess(
        context,
        'Registrasi Berhasil',
        'Akun Anda berhasil dibuat. Silakan lengkapi verifikasi KYC untuk mengakses semua fitur.',
        buttonText: 'Upload KYC Sekarang',
        onPressed: () {
          Navigator.pop(context); // Close dialog
          context.go(AppRoutes.wargaKYC);
        },
      );
    } else {
      AuthDialogs.showError(
        context,
        'Registrasi Gagal',
        authProvider.errorMessage ?? 'Terjadi kesalahan saat registrasi',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 100,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),

              // Logo Only
              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/icons/icon.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.home_work,
                        size: 40,
                        color: Color(0xFF2F80ED),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 24),

              // White Card with Register Form
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign up to get started',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Nama Lengkap field
                          _buildTextField(
                            controller: _namaController,
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama lengkap harus diisi';
                              }
                              if (value.length < 3) {
                                return 'Nama minimal 3 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Email field
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email harus diisi';
                              }
                              if (!value.contains('@')) {
                                return 'Email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password field
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password harus diisi';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Confirm Password field
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            hint: 'Re-enter your password',
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Konfirmasi password harus diisi';
                              }
                              if (value != _passwordController.text) {
                                return 'Password tidak sama';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Register button with gradient
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF2F80ED), // Primary blue
                                  Color(0xFF5B8DEF), // Light blue
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF2F80ED).withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _isLoading ? null : _handleRegister,
                                borderRadius: BorderRadius.circular(14),
                                child: Center(
                                  child: _isLoading
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          'Sign up',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Divider dengan text "Or sign up with"
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Colors.grey.shade300, thickness: 1),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Or sign up with',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Colors.grey.shade300, thickness: 1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Google Sign-In button (Full Width)
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _isLoading ? null : _handleGoogleSignIn,
                                borderRadius: BorderRadius.circular(14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/icons/google_icon.png',
                                      height: 24,
                                      width: 24,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.g_mobiledata,
                                          size: 32,
                                          color: Color(0xFF4285F4),
                                        );
                                      },
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Sign up with Google',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Build text field dengan style yang sama seperti login
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: suffixIcon,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}




