// ============================================================================
// DATA KELUARGA PAGE
// ============================================================================
// Form untuk mengisi data keluarga setelah alamat rumah
// Auto-fill: No KK, RT, RW dari OCR
// User mengisi: nama keluarga, status, jumlah anggota
// Auto-generate: keluargaId
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wargago/core/constants/app_routes.dart';
import 'package:wargago/core/providers/auth_provider.dart' as app_auth;

class DataKeluargaPage extends StatefulWidget {
  final Map<String, dynamic> completeData; // Data dari KYC + Alamat Rumah

  const DataKeluargaPage({
    super.key,
    required this.completeData,
  });

  @override
  State<DataKeluargaPage> createState() => _DataKeluargaPageState();
}

class _DataKeluargaPageState extends State<DataKeluargaPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaKeluargaController = TextEditingController();
  final _nomorKKController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();
  final _jumlahAnggotaController = TextEditingController();

  String _statusKeluarga = 'Aktif';
  final List<String> _statusKeluargaOptions = ['Aktif', 'Tidak Aktif'];

  bool _isLoading = false;
  String? _generatedKeluargaId;

  @override
  void initState() {
    super.initState();
    _prefillData();
  }

  void _prefillData() {
    debugPrint('\n🔍 [DataKeluarga] Pre-filling data...');
    debugPrint('📦 Complete data received: ${widget.completeData}');

    // Auto-fill dari OCR KK
    final nomorKK = widget.completeData['nomorKK']?.toString() ?? '';
    final rt = widget.completeData['rt']?.toString() ?? '';
    final rw = widget.completeData['rw']?.toString() ?? '';

    debugPrint('✅ No KK from OCR: "$nomorKK"');
    debugPrint('✅ RT from OCR: "$rt"');
    debugPrint('✅ RW from OCR: "$rw"');

    _nomorKKController.text = nomorKK;
    _rtController.text = rt;
    _rwController.text = rw;

    // Auto-fill jumlah anggota dari jumlah penghuni
    _jumlahAnggotaController.text =
        widget.completeData['jumlahPenghuni']?.toString() ?? '1';

    // Auto-fill nama keluarga dari kepala keluarga
    final kepalaKeluarga = widget.completeData['kepalaKeluarga'] ?? '';
    _namaKeluargaController.text =
        kepalaKeluarga.isNotEmpty ? 'Keluarga $kepalaKeluarga' : '';

    debugPrint('📝 Controllers filled:');
    debugPrint('   No KK: "${_nomorKKController.text}"');
    debugPrint('   RT: "${_rtController.text}"');
    debugPrint('   RW: "${_rwController.text}"');
    debugPrint('   Nama Keluarga: "${_namaKeluargaController.text}"');

    // Generate keluargaId preview
    _generateKeluargaId();

    if (_generatedKeluargaId != null) {
      debugPrint('✅ keluargaId generated: $_generatedKeluargaId');
    } else {
      debugPrint('⚠️ keluargaId NOT generated - missing data!');
    }
  }

  void _generateKeluargaId() {
    final noKK = _nomorKKController.text.trim();
    final rt = _rtController.text.trim().padLeft(3, '0');
    final rw = _rwController.text.trim().padLeft(3, '0');

    if (noKK.isNotEmpty && rt.isNotEmpty && rw.isNotEmpty) {
      setState(() {
        _generatedKeluargaId = 'KEL_${noKK}_$rt$rw';
      });
    }
  }

  @override
  void dispose() {
    _namaKeluargaController.dispose();
    _nomorKKController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _jumlahAnggotaController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Generate final keluargaId
    _generateKeluargaId();

    if (_generatedKeluargaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal generate keluargaId')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final firestore = FirebaseFirestore.instance;

      // Prepare complete data
      final finalData = {
        ...widget.completeData,
        'namaKeluarga': _namaKeluargaController.text.trim(),
        'nomorKK': _nomorKKController.text.trim(),
        'rt': _rtController.text.trim(),
        'rw': _rwController.text.trim(),
        'statusKeluarga': _statusKeluarga,
        'jumlahAnggota': int.tryParse(_jumlahAnggotaController.text) ?? 1,
        'keluargaId': _generatedKeluargaId,
        'status': 'Pending', // Admin will approve
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update data_penduduk
      final pendudukQuery = await firestore
          .collection('data_penduduk')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (pendudukQuery.docs.isNotEmpty) {
        // Update existing
        await pendudukQuery.docs.first.reference.update(finalData);
      } else {
        // Create new
        finalData['userId'] = user.uid;
        finalData['createdAt'] = FieldValue.serverTimestamp();
        await firestore.collection('data_penduduk').add(finalData);
      }

      // Update users collection with keluargaId
      await firestore.collection('users').doc(user.uid).update({
        'keluargaId': _generatedKeluargaId,
        'status': 'Pending', // Wait for admin approval
      });

      if (!mounted) return;

      // 🆕 REFRESH AuthProvider to get updated status!
      debugPrint('\n🔄 [DataKeluarga] Refreshing AuthProvider...');
      final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
      await authProvider.refreshUserData();

      // Verify data updated
      final currentUser = authProvider.userModel;
      debugPrint('✅ [DataKeluarga] AuthProvider refreshed!');
      debugPrint('   User status: ${currentUser?.status}');
      debugPrint('   User keluargaId: ${currentUser?.keluargaId}');
      debugPrint('   Expected: status="Pending", keluargaId="$_generatedKeluargaId"');

      // Small delay to ensure UI picks up the change
      await Future.delayed(const Duration(milliseconds: 300));
      debugPrint('✅ [DataKeluarga] Ready to navigate\n');

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
              ),
              const SizedBox(width: 12),
              Text(
                'Berhasil!',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data keluarga Anda telah disimpan.',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2988EA).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID Keluarga Anda:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _generatedKeluargaId!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2988EA),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Silakan tunggu admin untuk memverifikasi data Anda.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context.go(AppRoutes.wargaDashboard);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2988EA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Ke Dashboard'),
            ),
          ],
        ),
      );

    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2988EA),
        elevation: 0,
        title: Text(
          'Data Keluarga',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(step: 3, totalSteps: 3),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon & Title
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2988EA).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.family_restroom_outlined,
                          size: 48,
                          color: Color(0xFF2988EA),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Data Keluarga',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lengkapi informasi keluarga untuk mendapatkan ID Keluarga',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Nama Keluarga
                    _buildTextField(
                      controller: _namaKeluargaController,
                      label: 'Nama Keluarga',
                      hint: 'Keluarga John Doe',
                      icon: Icons.home_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama keluarga harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Nomor KK (Manual input - not from OCR)
                    _buildTextField(
                      controller: _nomorKKController,
                      label: 'Nomor Kartu Keluarga (KK)',
                      hint: '3201234567890123',
                      icon: Icons.credit_card_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _generateKeluargaId(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nomor KK harus diisi';
                        }
                        if (value.length != 16) {
                          return 'Nomor KK harus 16 digit';
                        }
                        return null;
                      },
                      helperText: '📝 Silakan input Nomor KK Anda (16 digit)',
                      helperColor: Colors.blue.shade600,
                    ),
                    const SizedBox(height: 20),

                    // RT & RW (Auto-filled from OCR or manual)
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _rtController,
                            label: 'RT',
                            hint: '001',
                            icon: Icons.location_city_outlined,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _generateKeluargaId(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'RT harus diisi';
                              }
                              return null;
                            },
                            helperText: _rtController.text.isEmpty
                                ? '⚠️ Input manual'
                                : '✓ Dari OCR',
                            helperColor: _rtController.text.isEmpty
                                ? Colors.orange
                                : Colors.green.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _rwController,
                            label: 'RW',
                            hint: '002',
                            icon: Icons.location_city_outlined,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _generateKeluargaId(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'RW harus diisi';
                              }
                              return null;
                            },
                            helperText: _rwController.text.isEmpty
                                ? '⚠️ Input manual'
                                : '✓ Dari OCR',
                            helperColor: _rwController.text.isEmpty
                                ? Colors.orange
                                : Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Status Keluarga
                    Text(
                      'Status Keluarga',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _statusKeluarga,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: _statusKeluargaOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() => _statusKeluarga = newValue);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Jumlah Anggota
                    _buildTextField(
                      controller: _jumlahAnggotaController,
                      label: 'Jumlah Anggota Keluarga',
                      hint: '4',
                      icon: Icons.people_outline,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Jumlah anggota harus diisi';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 1) {
                          return 'Jumlah anggota minimal 1';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Generated keluargaId Preview
                    if (_generatedKeluargaId != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2988EA).withValues(alpha: 0.1),
                              const Color(0xFF2988EA).withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2988EA).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2988EA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.badge_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ID Keluarga Anda',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _generatedKeluargaId!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2988EA),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade600,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2988EA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Simpan & Selesai',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                            color: Colors.amber.shade700,
                            size: 20
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Data Anda akan diverifikasi oleh admin sebelum dapat mengakses semua fitur',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.amber.shade900,
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
        ],
      ),
    );
  }

  Widget _buildProgressIndicator({required int step, required int totalSteps}) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index < step;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF2988EA)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < totalSteps - 1) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
    String? helperText,
    Color? helperColor,
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            helperText: helperText,
            helperStyle: GoogleFonts.poppins(
              fontSize: 11,
              color: helperColor ?? Colors.green.shade600,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2988EA), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

