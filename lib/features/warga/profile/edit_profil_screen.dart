// lib/pages/profile/edit_profil_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _nikController;
  late TextEditingController _noTeleponController;
  late TextEditingController _alamatController;
  late TextEditingController _keluargaIdController; // ⭐ ADDED
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false; // ⭐ ADDED

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;

    _namaController = TextEditingController(text: user?.nama ?? '');
    _nikController = TextEditingController(text: user?.nik ?? '');
    _noTeleponController = TextEditingController(text: user?.noTelepon ?? '');
    _alamatController = TextEditingController(text: user?.alamat ?? '');
    _keluargaIdController = TextEditingController(text: user?.keluargaId ?? ''); // ⭐ ADDED

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _noTeleponController.dispose();
    _alamatController.dispose();
    _keluargaIdController.dispose(); // ⭐ ADDED
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Profil', style: GoogleFonts.poppins())),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2F80ED), Color(0xFF1E5BB8)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        // Avatar with camera button
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 47,
                                  backgroundColor: const Color(0xFF2F80ED).withValues(alpha: 0.2),
                                  child: Text(
                                    user.nama.isNotEmpty ? user.nama[0].toUpperCase() : 'U',
                                    style: GoogleFonts.poppins(
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2F80ED),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Fitur upload foto akan segera hadir', style: GoogleFonts.poppins()),
                                        backgroundColor: const Color(0xFF2F80ED),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Edit Profil',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Form Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModernTextField(
                        controller: _namaController,
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildModernTextField(
                        controller: _nikController,
                        label: 'NIK',
                        hint: 'Masukkan NIK (16 digit)',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty && value.length != 16) {
                            return 'NIK harus 16 digit';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildModernTextField(
                        controller: _noTeleponController,
                        label: 'No. Telepon',
                        hint: 'Masukkan nomor telepon',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 16),

                      _buildModernTextField(
                        controller: _alamatController,
                        label: 'Alamat',
                        hint: 'Masukkan alamat lengkap',
                        icon: Icons.location_on_outlined,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),

                      // ⭐ ADDED: Keluarga ID Field
                      _buildModernTextField(
                        controller: _keluargaIdController,
                        label: 'ID Keluarga',
                        hint: 'Contoh: keluarga_001',
                        icon: Icons.family_restroom_rounded,
                        keyboardType: TextInputType.text,
                        helperText: 'ID keluarga diperlukan untuk melihat tagihan iuran.\nHubungi admin jika tidak tahu ID keluarga Anda.',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ID Keluarga tidak boleh kosong';
                          }
                          // Check format (alphanumeric + underscore)
                          if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                            return 'Format tidak valid (hanya huruf, angka, dan underscore)';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Info Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: const Color(0xFF2F80ED),
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Pastikan data yang Anda masukkan benar dan sesuai dengan identitas resmi.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF1F2937),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Save Button
                      _buildSaveButton(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? helperText, // ⭐ ADDED
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: const Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF9CA3AF),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF2F80ED),
                size: 22,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF2F80ED),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: maxLines > 1 ? 16 : 14,
              ),
              helperText: helperText, // ⭐ ADDED
              helperMaxLines: 3, // ⭐ ADDED
              helperStyle: GoogleFonts.poppins( // ⭐ ADDED
                fontSize: 11,
                color: const Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F80ED), Color(0xFF1E5BB8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _saveChanges,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Simpan Perubahan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.userModel;

      if (user == null) {
        throw Exception('User data not found');
      }

      // Update user profile via Firestore
      final updatedUser = user.copyWith(
        nama: _namaController.text.trim(),
        nik: _nikController.text.trim().isEmpty ? null : _nikController.text.trim(),
        noTelepon: _noTeleponController.text.trim().isEmpty ? null : _noTeleponController.text.trim(),
        alamat: _alamatController.text.trim().isEmpty ? null : _alamatController.text.trim(),
        keluargaId: _keluargaIdController.text.trim().isEmpty ? null : _keluargaIdController.text.trim(), // ⭐ ADDED
      );

      // Update to Firestore
      await authProvider.updateUserProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profil berhasil diperbarui',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memperbarui profil: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

