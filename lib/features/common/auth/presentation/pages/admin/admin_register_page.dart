// ============================================================================
// REGISTER PAGE (CLEAN CODE VERSION)
// ============================================================================
// Halaman registrasi untuk admin baru
//
// Clean Code Principles Applied:
// ✅ Fokus ke tampilan & interaksi user (logic di AuthProvider)
// ✅ Gunakan StatefulWidget karena perlu state (form controllers)
// ✅ Pakai widget reusable (AuthTextField, AuthPrimaryButton, dll)
// ✅ Nama variabel & widget yang jelas dan deskriptif
// ✅ Responsif dengan SingleChildScrollView
// ✅ Tidak panggil API langsung - pakai AuthProvider
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jawara/core/providers/auth_provider.dart';
import '../../widgets/auth_constants.dart';
import '../../widgets/auth_widgets.dart';

/// Register Page - Halaman registrasi untuk admin baru
///
/// Fitur:
/// - Form lengkap (nama, NIK, email, telepon, jenis kelamin, alamat, password)
/// - Form validation
/// - Integration dengan Firebase Auth via AuthProvider
/// - Auto-navigate ke login setelah berhasil
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _alamatController = TextEditingController();

  String? _jenisKelamin;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  /// Handle registrasi process
  Future<void> _handleRegister() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Validate jenis kelamin
    if (_jenisKelamin == null) {
      AuthDialogs.showError(context, 'Error', 'Silakan pilih jenis kelamin');
      return;
    }

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

    // Call sign up from AuthProvider
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nama: _namaController.text.trim(),
      nik: _nikController.text.trim(),
      jenisKelamin: _jenisKelamin,
      noTelepon: _phoneController.text.trim(),
      alamat: _alamatController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Show success dialog & navigate to login
      AuthDialogs.showSuccess(
        context,
        'Registrasi Berhasil',
        'Akun admin Anda telah berhasil dibuat. Silakan login untuk mengakses aplikasi.',
        buttonText: 'Login Sekarang',
        onPressed: () {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Back to login
        },
      );
    } else {
      // Show error dialog
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AuthSpacing.xxl),
                _buildFormFields(),
                const SizedBox(height: AuthSpacing.xxl),
                _buildRegisterButton(),
                const SizedBox(height: AuthSpacing.xl),
                _buildLoginLink(),
              ],
            ),
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
          'Sign Up',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AuthColors.primary,
          ),
        ),
        const SizedBox(height: AuthSpacing.sm),
        Text(
          'Daftar sebagai admin untuk mengelola data warga',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AuthColors.textTertiary,
          ),
        ),
      ],
    );
  }

  /// Build semua form fields
  Widget _buildFormFields() {
    return Column(
      children: [
        // Nama Lengkap
        AuthTextField(
          controller: _namaController,
          labelText: 'Nama Lengkap',
          hintText: 'Masukkan nama lengkap',
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: AuthSpacing.lg),

        // NIK
        AuthTextField(
          controller: _nikController,
          labelText: 'NIK',
          hintText: 'Masukkan NIK',
          prefixIcon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          maxLength: 16,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'NIK tidak boleh kosong';
            }
            if (value.length != 16) {
              return 'NIK harus 16 digit';
            }
            return null;
          },
        ),
        const SizedBox(height: AuthSpacing.lg),

        // Email
        AuthTextField(
          controller: _emailController,
          labelText: 'Email',
          hintText: 'Masukkan email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
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
        const SizedBox(height: AuthSpacing.lg),

        // No Telepon
        AuthTextField(
          controller: _phoneController,
          labelText: 'No Telepon',
          hintText: 'Masukkan no telepon',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'No telepon tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: AuthSpacing.lg),

        // Jenis Kelamin
        _buildJenisKelaminDropdown(),
        const SizedBox(height: AuthSpacing.lg),

        // Alamat
        AuthTextField(
          controller: _alamatController,
          labelText: 'Alamat',
          hintText: 'Masukkan alamat lengkap',
          prefixIcon: Icons.location_on_outlined,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Alamat tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: AuthSpacing.lg),

        // Password
        AuthTextField(
          controller: _passwordController,
          labelText: 'Password',
          hintText: 'Masukkan password',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: PasswordVisibilityToggle(
            isObscure: _obscurePassword,
            onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
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
        const SizedBox(height: AuthSpacing.lg),

        // Confirm Password
        AuthTextField(
          controller: _confirmPasswordController,
          labelText: 'Konfirmasi Password',
          hintText: 'Masukkan ulang password',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          suffixIcon: PasswordVisibilityToggle(
            isObscure: _obscureConfirmPassword,
            onToggle: () =>
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Konfirmasi password tidak boleh kosong';
            }
            if (value != _passwordController.text) {
              return 'Password tidak sama';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Build jenis kelamin dropdown
  Widget _buildJenisKelaminDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _jenisKelamin,
      decoration: InputDecoration(
        labelText: 'Jenis Kelamin',
        prefixIcon: const Icon(Icons.wc_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthRadius.md),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthRadius.md),
          borderSide: const BorderSide(color: AuthColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthRadius.md),
          borderSide: const BorderSide(
            color: AuthColors.borderFocused,
            width: 2,
          ),
        ),
      ),
      items: ['Laki-laki', 'Perempuan'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _jenisKelamin = value);
      },
      validator: (value) {
        if (value == null) {
          return 'Pilih jenis kelamin';
        }
        return null;
      },
    );
  }

  /// Build register button
  Widget _buildRegisterButton() {
    return AuthPrimaryButton(
      text: 'Daftar',
      onPressed: _handleRegister,
      isLoading: _isLoading,
      height: 50,
      borderRadius: AuthRadius.md,
    );
  }

  /// Build login link
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AuthColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Login',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AuthColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

