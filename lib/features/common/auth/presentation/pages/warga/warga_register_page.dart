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
import 'package:provider/provider.dart';
import 'package:jawara/core/providers/auth_provider.dart';
import 'package:jawara/features/common/auth/presentation/widgets/auth_constants.dart';
import 'package:jawara/features/common/auth/presentation/widgets/auth_widgets.dart';
import 'package:jawara/features/common/auth/presentation/pages/warga/kyc_upload_page.dart';
import 'package:jawara/features/warga/dashboard/warga_dashboard_page.dart';

class WargaRegisterPage extends StatefulWidget {
  const WargaRegisterPage({super.key});

  @override
  State<WargaRegisterPage> createState() => _WargaRegisterPageState();
}

class _WargaRegisterPageState extends State<WargaRegisterPage> {
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const KYCUploadPage()),
        );
      } else {
        // Existing verified user - redirect to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WargaDashboardPage()),
        );
      }
    } else {
      AuthDialogs.showError(
        context,
        'Login Gagal',
        authProvider.errorMessage ?? 'Terjadi kesalahan saat login dengan Google',
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
    final success = await authProvider.registerWarga(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nama: _namaController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Show success and navigate to KYC upload
      AuthDialogs.showSuccess(
        context,
        'Registrasi Berhasil',
        'Akun Anda berhasil dibuat. Silakan lengkapi verifikasi KYC untuk mengakses fitur lengkap.',
        buttonText: 'Lanjutkan',
        onPressed: () {
          Navigator.pop(context); // Close dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const KYCUploadPage()),
          );
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
    return Scaffold(
      backgroundColor: AuthColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AuthSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AuthSpacing.xxl),
              _buildGoogleSignInButton(),
              const SizedBox(height: AuthSpacing.xl),
              _buildDivider(),
              const SizedBox(height: AuthSpacing.xl),
              _buildManualRegistrationForm(),
              const SizedBox(height: AuthSpacing.xxl),
              _buildRegisterButton(),
              const SizedBox(height: AuthSpacing.xl),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build app bar dengan back button
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AuthColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// Build header dengan logo & title
  Widget _buildHeader() {
    return Column(
      children: [
        const AuthLogo(showText: false),
        const SizedBox(height: AuthSpacing.xl),
        Text(
          'Daftar sebagai Warga',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AuthColors.primary,
          ),
        ),
        const SizedBox(height: AuthSpacing.sm),
        Text(
          'Pilih metode pendaftaran yang Anda inginkan',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AuthColors.textTertiary,
          ),
        ),
      ],
    );
  }

  /// Build Google Sign In button
  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthSpacing.md),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/google_logo.png',
              height: 24,
              width: 24,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.g_mobiledata,
                size: 28,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: AuthSpacing.md),
            Text(
              'Lanjutkan dengan Google',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build divider with "atau"
  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AuthSpacing.md),
          child: Text(
            'atau',
            style: GoogleFonts.poppins(
              color: AuthColors.textTertiary,
              fontSize: 14,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  /// Build manual registration form
  Widget _buildManualRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Nama Lengkap
          AuthTextField(
            controller: _namaController,
            labelText: 'Nama Lengkap',
            hintText: 'Masukkan nama lengkap',
            prefixIcon: Icons.person_outline,
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
          const SizedBox(height: AuthSpacing.lg),

          // Email
          AuthTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'contoh@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email harus diisi';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: AuthSpacing.lg),

          // Password
          AuthTextField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: 'Minimal 6 karakter',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AuthColors.textTertiary,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
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
          const SizedBox(height: AuthSpacing.lg),

          // Confirm Password
          AuthTextField(
            controller: _confirmPasswordController,
            labelText: 'Konfirmasi Password',
            hintText: 'Masukkan password lagi',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: AuthColors.textTertiary,
              ),
              onPressed: () {
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi password harus diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Build register button
  Widget _buildRegisterButton() {
    return AuthPrimaryButton(
      text: 'Daftar',
      onPressed: _isLoading ? null : _handleRegister,
      isLoading: _isLoading,
    );
  }

  /// Build login link
  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: RichText(
          text: TextSpan(
            text: 'Sudah punya akun? ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AuthColors.textSecondary,
            ),
            children: [
              TextSpan(
                text: 'Login di sini',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AuthColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

