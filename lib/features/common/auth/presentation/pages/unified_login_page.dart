import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:wargago/core/constants/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:wargago/core/providers/auth_provider.dart';
import 'package:wargago/features/common/auth/presentation/widgets/auth_widgets.dart';
import 'package:wargago/features/common/classification/widgets/inkwell_iconbutton.dart';

class UnifiedLoginPage extends StatelessWidget {
  const UnifiedLoginPage({
    super.key,
  });

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
              // Header with back button, "Don't have account", and "Get Started"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    // Back button - Navigate to preAuth (keluar dari login)
                    InkWellIconButton(
                      onTap: () => context.go(AppRoutes.preAuth),
                      icon: Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                      color: Colors.transparent,
                    ),
                    Spacer(),
                    // "Don't have an account?"
                    Text(
                      "Don't have an account?",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(width: 12),
                    // "Get Started" button
                    TextButton(
                      onPressed: () {
                        // Navigate to register warga
                        context.push(AppRoutes.wargaRegister);
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
                        'Get Started',
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
              // Login body content
              Expanded(child: const _LoginBody()),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
                     MediaQuery.of(context).padding.top -
                     MediaQuery.of(context).padding.bottom,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // Logo Only
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/icons/icon.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.home_work,
                        size: 48,
                        color: Color(0xFF2F80ED),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // White Card with Login Form
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(28),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LoginIntro(),
                    SizedBox(height: 24),
                    _LoginFields(),
                  ],
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LOGIN INTRO WIDGET
// ============================================================================
/// Intro text dengan info kredensial default
class _LoginIntro extends StatelessWidget {
  const _LoginIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Welcome Back',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your details below',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// LOGIN FIELDS WIDGET
// ============================================================================
/// Form login dengan email & password fields
class _LoginFields extends StatefulWidget {
  const _LoginFields();

  @override
  State<_LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<_LoginFields> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login process dengan auto-detect role berdasarkan email domain
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();

    // Auto-detect role berdasarkan email domain
    final isAdminEmail = email.endsWith('@jawara.com');
    final isBendaharaEmail = email.endsWith('@bendahara.jawara.com');
    final isSekretarisEmail = email.endsWith('@sekretaris.jawara.com');

    final success = await authProvider.signIn(
      email: email,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final user = authProvider.userModel;

      // Validasi: Pastikan email domain sesuai dengan role di database
      if (isAdminEmail && user?.role != 'admin') {
        AuthDialogs.showError(
          context,
          'Login Ditolak',
          'Email @jawara.com hanya untuk admin.',
        );
        await authProvider.signOut();
        return;
      }

      if (isBendaharaEmail && user?.role != 'bendahara') {
        AuthDialogs.showError(
          context,
          'Login Ditolak',
          'Email @bendahara.jawara.com hanya untuk bendahara.',
        );
        await authProvider.signOut();
        return;
      }

      if (isSekretarisEmail && user?.role != 'sekretaris') {
        AuthDialogs.showError(
          context,
          'Login Ditolak',
          'Email @sekretaris.jawara.com hanya untuk sekretaris.',
        );
        await authProvider.signOut();
        return;
      }

      if (!isAdminEmail && !isBendaharaEmail && !isSekretarisEmail &&
          (user?.role == 'admin' || user?.role == 'bendahara' || user?.role == 'sekretaris')) {
        AuthDialogs.showError(
          context,
          'Login Ditolak',
          'Akun ${user?.role} harus menggunakan email khusus',
        );
        await authProvider.signOut();
        return;
      }

      // Redirect berdasarkan role
      if (user?.role == 'admin') {
        // Admin -> Dashboard Admin
        context.go(AppRoutes.adminDashboard);
      } else if (user?.role == 'bendahara') {
        // Bendahara -> Dashboard Bendahara
        context.go(AppRoutes.bendaharaDashboard);
      } else if (user?.role == 'sekretaris') {
        // Sekretaris -> Dashboard Sekretaris
        context.go(AppRoutes.sekretarisDashboard);
      } else if (user?.role == 'warga') {
        // Semua warga (approved, pending, unverified) bisa masuk dashboard
        // Rejected sudah diblokir di AuthProvider
        // Alert di dashboard akan menyesuaikan dengan status
        context.go(AppRoutes.wargaDashboard);
      }
    } else {
      // Show error
      AuthDialogs.showError(
        context,
        'Login Gagal',
        authProvider.errorMessage ?? 'Email atau password salah',
      );
    }
  }

  /// Handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.signInWithGoogle();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        final user = authProvider.userModel;
        final email = user?.email ?? '';

        // Auto-detect role berdasarkan email domain
        final isAdminEmail = email.endsWith('@jawara.com');
        final isBendaharaEmail = email.endsWith('@bendahara.jawara.com');
        final isSekretarisEmail = email.endsWith('@sekretaris.jawara.com');

        // Validasi: Pastikan email domain sesuai dengan role di database
        if (isAdminEmail && user?.role != 'admin') {
          AuthDialogs.showError(
            context,
            'Login Ditolak',
            'Email @jawara.com hanya untuk admin.',
          );
          await authProvider.signOut();
          return;
        }

        if (isBendaharaEmail && user?.role != 'bendahara') {
          AuthDialogs.showError(
            context,
            'Login Ditolak',
            'Email @bendahara.jawara.com hanya untuk bendahara.',
          );
          await authProvider.signOut();
          return;
        }

        if (isSekretarisEmail && user?.role != 'sekretaris') {
          AuthDialogs.showError(
            context,
            'Login Ditolak',
            'Email @sekretaris.jawara.com hanya untuk sekretaris.',
          );
          await authProvider.signOut();
          return;
        }

        if (!isAdminEmail && !isBendaharaEmail && !isSekretarisEmail &&
            (user?.role == 'admin' || user?.role == 'bendahara' || user?.role == 'sekretaris')) {
          AuthDialogs.showError(
            context,
            'Login Ditolak',
            'Akun ${user?.role} harus menggunakan email khusus',
          );
          await authProvider.signOut();
          return;
        }

        // Redirect berdasarkan role
        if (user?.role == 'admin') {
          // Admin -> Dashboard Admin
          context.go(AppRoutes.adminDashboard);
        } else if (user?.role == 'bendahara') {
          // Bendahara -> Dashboard Bendahara
          context.go(AppRoutes.bendaharaDashboard);
        } else if (user?.role == 'sekretaris') {
          // Sekretaris -> Dashboard Sekretaris
          context.go(AppRoutes.sekretarisDashboard);
        } else if (user?.role == 'warga') {
          // Semua warga (approved, pending, unverified) bisa masuk dashboard
          // Rejected sudah diblokir di AuthProvider
          // Alert di dashboard akan menyesuaikan dengan status
          context.go(AppRoutes.wargaDashboard);
        } else {
          // User baru dari Google Sign-In (belum ada role)
          // Redirect ke halaman registrasi untuk melengkapi data
          AuthDialogs.showError(
            context,
            'Akun Belum Terdaftar',
            'Silakan daftar terlebih dahulu sebagai warga.',
          );
          await authProvider.signOut();
        }
      } else {
        // Show error
        AuthDialogs.showError(
          context,
          'Login Gagal',
          authProvider.errorMessage ?? 'Google Sign-In gagal',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AuthDialogs.showError(context, 'Error', 'Terjadi kesalahan: $e');
      }
    }
  }

  /// Handle forgot password
  void _handleForgotPassword() => context.push(AppRoutes.forgotPassword);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field with label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email Address',
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
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: GoogleFonts.poppins(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
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
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Password field with label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
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
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.poppins(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
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
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Login button with gradient
          Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2F80ED), // Primary blue
                  Color(0xFF5B8DEF), // Light blue
                ],
              ),
              borderRadius: BorderRadius.circular(16),
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
                onTap: _isLoading ? null : _handleLogin,
                borderRadius: BorderRadius.circular(16),
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
                          'Sign in',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Forgot password
          Center(
            child: TextButton(
              onPressed: _handleForgotPassword,
              child: Text(
                'Forgot your password?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Divider dengan text "Or sign in with"
          Row(
            children: [
              Expanded(
                child: Divider(color: Colors.grey.shade300, thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or sign in with',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: Colors.grey.shade300, thickness: 1),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Google Sign-In button (Full Width)
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading ? null : _handleGoogleSignIn,
                borderRadius: BorderRadius.circular(16),
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
                      'Sign in with Google',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // const SizedBox(height: AuthSpacing.xl),
        ],
      ),
    );
  }
}

