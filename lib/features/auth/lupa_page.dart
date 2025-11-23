import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LupaPage extends StatefulWidget {
  const LupaPage({super.key});

  @override
  State<LupaPage> createState() => _LupaPageState();
}

class _LupaPageState extends State<LupaPage> {
  bool _sended = false;
  bool _isLoading = false;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _handleSend() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();

      await _auth.sendPasswordResetEmail(email: email);

      if (mounted) {
        setState(() {
          _sended = true;
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'Email tidak terdaftar';
          break;
        case 'invalid-email':
          errorMsg = 'Format email tidak valid';
          break;
        case 'too-many-requests':
          errorMsg = 'Terlalu banyak percobaan. Coba lagi nanti';
          break;
        default:
          errorMsg = 'Gagal mengirim email: ${e.message}';
      }

      if (mounted) {
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });

        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Gagal',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(errorMsg, style: GoogleFonts.poppins()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2F80ED),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Terjadi kesalahan',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              _errorMessage ?? 'Terjadi kesalahan: $e',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2F80ED),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2F80ED).withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2F80ED).withOpacity(0.05),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxHeight = constraints.maxHeight;
                return Center(
                  child: Container(
                    constraints: BoxConstraints(minHeight: maxHeight),
                    padding: const EdgeInsets.all(32),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 4,
                            child: SingleChildScrollView(
                              reverse: true,
                              child: Column(
                                children: [
                                  const SizedBox(height: 80),
                                  Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(
                                            0xFF2F80ED,
                                          ).withValues(alpha: 0.1),
                                          const Color(
                                            0xFF1E6FD9,
                                          ).withValues(alpha: 0.05),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF2F80ED,
                                          ).withValues(alpha: 0.1),
                                          blurRadius: 40,
                                          offset: const Offset(0, 20),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 130,
                                        height: 130,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF2F80ED),
                                              Color(0xFF1E6FD9),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          transitionBuilder:
                                              (child, animation) {
                                                return ScaleTransition(
                                                  scale: animation,
                                                  child: child,
                                                );
                                              },
                                          child: Icon(
                                            _sended
                                                ? Icons.check
                                                : Icons.key_off,
                                            key: ValueKey(_sended),
                                            size: 70,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 48),

                                  // Title
                                  Text(
                                    _sended
                                        ? 'Instruksi Terkirim!'
                                        : 'Lupa Password?',
                                    key: ValueKey(_sended),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1F2937),
                                      letterSpacing: -0.5,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Subtitle
                                  Text(
                                    _sended
                                        ? 'Silakan cek email Anda untuk instruksi reset password'
                                        : 'Tenang, kami akan mengirimkan instruksi untuk mengatur ulang password Anda',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _sended
                                      ? const SizedBox.shrink()
                                      : Form(
                                          key: _formKey,
                                          child: TextFormField(
                                            controller: _emailController,
                                            readOnly: _isLoading,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintText: 'Alamat email',
                                              prefixIcon: const Icon(
                                                Icons.email_outlined,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'Masukkan email';
                                              }
                                              final email = value.trim();
                                              final emailRegex = RegExp(
                                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                              );
                                              if (!emailRegex.hasMatch(email)) {
                                                return 'Email tidak valid';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),

                          // Email form
                          const SizedBox(height: 16),

                          // Send instruction button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : _sended
                                  ? () => Navigator.pop(context)
                                  : _handleSend,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2F80ED),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      spacing: 8,
                                      children: [
                                        Text(
                                          _sended ? 'Login' : 'Kirim Instruksi',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Icon(
                                          _sended
                                              ? Icons.arrow_forward_ios
                                              : Icons.send,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Color(0xFF6B7280),
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
