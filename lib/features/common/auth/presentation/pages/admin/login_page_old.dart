// ============================================================================
// LOGIN PAGE (CLEAN CODE VERSION)
// ============================================================================
// Halaman login untuk admin
//
// Clean Code Principles Applied:
// ✅ Fokus ke tampilan & interaksi user (logic di AuthProvider)
// ✅ Pecah jadi widget kecil yang focused
// ✅ Pakai widget reusable (AuthTextField, AuthPrimaryButton, dll)
// ✅ Nama variabel & widget yang jelas dan deskriptif
// ✅ Responsif dengan LayoutBuilder & SingleChildScrollView
// ✅ Tidak panggil API langsung - pakai AuthProvider
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jawara/features/admin/dashboard/dashboard_page.dart';
import 'package:jawara/features/common/auth/presentation/pages/admin/admin_register_page.dart';
import 'package:jawara/features/common/auth/presentation/pages/warga/warga_register_page.dart';
import 'package:jawara/features/warga/dashboard/warga_dashboard_page.dart';
import 'package:jawara/core/providers/auth_provider.dart';
import '../../widgets/auth_constants.dart';
import '../../widgets/auth_widgets.dart';

/// Login Page - Halaman login untuk admin
///
/// Fitur:
/// - Animated background dengan blob shapes
/// - Form validation
/// - Integration dengan Firebase Auth via AuthProvider
/// - Auto-check user status (pending/rejected)
/// - Default credentials info untuk testing
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.initialProgress = 0.0,
    this.isForward = true,
  });

  final double initialProgress;
  final bool isForward;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  late bool _isForward;

  @override
  void initState() {
    super.initState();
    _isForward = widget.isForward;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addStatusListener(_handleStatus);
    _controller.value = widget.initialProgress.clamp(0.0, 1.0);
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    if (_isForward) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            return Stack(
              children: [
                _DecorBackground(progress: _progress.value),
                const _LoginBody(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _LoginHeader(),
                SizedBox(height: 24),
                _LoginIllustration(),
                SizedBox(height: 32),
                _LoginIntro(),
                SizedBox(height: 28),
                _LoginFields(),
                SizedBox(height: 32),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// LOGIN HEADER WIDGET
// ============================================================================
/// Header dengan logo Jawara
class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return const AuthLogo(showText: true);
  }
}

class _LoginIllustration extends StatelessWidget {
  const _LoginIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/illustrations/LOGIN.png',
        height: 300,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Place your login illustration at:\nassets/illustrations/LOGIN.png',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF8D8D8D),
            ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOGIN',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: AuthColors.primary,
          ),
        ),
        const SizedBox(height: AuthSpacing.md),
        Text(
          'Silakan login terlebih dahulu sebagai admin untuk mengakses seluruh fitur dalam aplikasi.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.6,
            color: AuthColors.textTertiary,
          ),
        ),
        const SizedBox(height: AuthSpacing.lg),
        // Default credentials info
        const DefaultCredentialsInfo(),
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

  /// Handle login process
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Check user status
      final user = authProvider.userModel;

      if (user?.status == 'pending') {
        AuthDialogs.showError(
          context,
          'Menunggu Persetujuan',
          'Akun Anda masih menunggu persetujuan dari admin.',
        );
        await authProvider.signOut();
        return;
      }

      if (user?.status == 'rejected') {
        AuthDialogs.showError(
          context,
          'Akun Ditolak',
          'Akun Anda ditolak oleh admin.',
        );
        await authProvider.signOut();
        return;
      }

      // Login success - navigate to dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (route) => false,
      );
    } else {
      // Show error
      AuthDialogs.showError(
        context,
        'Login Gagal',
        authProvider.errorMessage ?? 'Terjadi kesalahan saat login',
      );
    }
  }

  /// Handle forgot password
  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fitur lupa password belum tersedia',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          AuthTextField(
            controller: _emailController,
            hintText: 'Email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
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
          const SizedBox(height: AuthSpacing.xl),

          // Password field
          AuthTextField(
            controller: _passwordController,
            hintText: 'Password',
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
          const SizedBox(height: AuthSpacing.md),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _handleForgotPassword,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lupa Kata sandi?',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AuthColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Login button
          AuthPrimaryButton(
            text: 'Login',
            onPressed: _handleLogin,
            isLoading: _isLoading,
          ),
          const SizedBox(height: AuthSpacing.xl),

          // Divider with "atau"
          Row(
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
          ),
          const SizedBox(height: AuthSpacing.xl),

          // Google Sign In button
          _GoogleSignInButton(isLoading: _isLoading),
          const SizedBox(height: AuthSpacing.xl),

          // Warga registration link
          const _WargaRegisterLink(),
        ],
      ),
    );
  }
}

// ============================================================================
// GOOGLE SIGN IN BUTTON WIDGET
// ============================================================================
class _GoogleSignInButton extends StatefulWidget {
  const _GoogleSignInButton({required this.isLoading});

  final bool isLoading;

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  bool _isGoogleLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (success) {
      final user = authProvider.userModel;

      // Navigate based on user role and status
      if (user?.role == 'warga') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WargaDashboardPage()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
          (route) => false,
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (widget.isLoading || _isGoogleLoading) ? null : _handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthSpacing.md),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: _isGoogleLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
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
}

// ============================================================================
// WARGA REGISTER LINK WIDGET
// ============================================================================
class _WargaRegisterLink extends StatelessWidget {
  const _WargaRegisterLink();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WargaRegisterPage(),
            ),
          );
        },
        child: RichText(
          text: TextSpan(
            text: 'Belum punya akun? ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AuthColors.textSecondary,
            ),
            children: [
              TextSpan(
                text: 'Daftar sebagai Warga',
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

// ============================================================================
// DECORATIVE BACKGROUND WIDGET
// ============================================================================
/// Animated blob background untuk visual appeal
class _DecorBackground extends StatelessWidget {
  const _DecorBackground({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _BlobPainter(
            baseColor: AuthColors.backgroundBlob,
            accentColor: AuthColors.backgroundBlobAccent,
            progress: progress,
          ),
        ),
      ),
    );
  }
}

/// Custom painter untuk blob shapes
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
    final double t = progress;
    final double wave1 = math.sin(t * 2 * math.pi);
    final double wave2 = math.cos((t + 0.25) * 2 * math.pi);
    final double wave3 = math.sin((t + 0.5) * 2 * math.pi);

    final circle1Center = Offset(
      -size.width * (0.33 + 0.02 * wave2) + wave1 * 32,
      size.height * (0.06 + 0.01 * wave3) + wave2 * 20,
    );
    final circle2Center = Offset(
      size.width * (0.95 + 0.02 * wave3) + wave2 * 42,
      size.height * (-0.2 + 0.015 * wave1) + wave1 * 24,
    );

    final paintBase = Paint()..color = baseColor;
    final paintAccent = Paint()..color = accentColor;

    final circle1Radius = size.width * 0.58 * (0.92 + wave1 * 0.08);
    final circle2Radius = size.width * 0.62 * (0.9 + wave2 * 0.07);

    canvas.drawCircle(circle1Center, circle1Radius, paintBase);
    canvas.drawCircle(circle2Center, circle2Radius, paintBase);

    final smaller1Center = circle1Center.translate(
      140 + wave2 * 26,
      150 + wave1 * 22,
    );
    final smaller2Center = circle2Center.translate(
      -60 + wave1 * 22,
      140 + wave3 * 18,
    );

    final double accentRadius1 = size.width * 0.32 * (0.9 + wave3 * 0.06);
    final double accentRadius2 = size.width * 0.28 * (0.9 + wave2 * 0.06);

    canvas.drawCircle(smaller2Center, accentRadius1, paintAccent);
    canvas.drawCircle(smaller1Center, accentRadius2, paintAccent);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) =>
      oldDelegate.baseColor != baseColor ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.progress != progress;
}
