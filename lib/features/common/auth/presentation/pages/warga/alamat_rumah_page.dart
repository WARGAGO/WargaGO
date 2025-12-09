// ============================================================================
// ALAMAT RUMAH PAGE
// ============================================================================
// Form untuk mengisi data alamat rumah setelah KYC
// User mengisi: alamat, kepala keluarga, jumlah penghuni, status kepemilikan
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:wargago/core/constants/app_routes.dart';

class AlamatRumahPage extends StatefulWidget {
  final Map<String, dynamic> kycData; // Data dari KYC (KTP + KK OCR)

  const AlamatRumahPage({
    super.key,
    required this.kycData,
  });

  @override
  State<AlamatRumahPage> createState() => _AlamatRumahPageState();
}

class _AlamatRumahPageState extends State<AlamatRumahPage> {
  final _formKey = GlobalKey<FormState>();
  final _alamatController = TextEditingController();
  final _kepalaKeluargaController = TextEditingController();
  final _jumlahPenghuniController = TextEditingController();

  String _statusKepemilikan = 'Milik Sendiri';
  final List<String> _statusKepemilikanOptions = [
    'Milik Sendiri',
    'Kontrak',
    'Sewa',
    'Menumpang',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill kepala keluarga dengan nama user
    _kepalaKeluargaController.text = widget.kycData['namaLengkap'] ?? '';
  }

  @override
  void dispose() {
    _alamatController.dispose();
    _kepalaKeluargaController.dispose();
    _jumlahPenghuniController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    // Combine KYC data with alamat rumah data
    final completeData = {
      ...widget.kycData,
      'alamatRumah': _alamatController.text.trim(),
      'kepalaKeluarga': _kepalaKeluargaController.text.trim(),
      'jumlahPenghuni': int.tryParse(_jumlahPenghuniController.text) ?? 1,
      'statusKepemilikan': _statusKepemilikan,
    };

    // 🔍 DEBUG: Log data being passed
    debugPrint('\n📤 [Alamat Rumah] Passing data to Data Keluarga:');
    debugPrint('   No KK: "${completeData['nomorKK']}"');
    debugPrint('   RT: "${completeData['rt']}"');
    debugPrint('   RW: "${completeData['rw']}"');
    debugPrint('   Kepala Keluarga: "${completeData['kepalaKeluarga']}"');
    debugPrint('   Jumlah Penghuni: ${completeData['jumlahPenghuni']}');

    // Navigate to data keluarga page
    context.push(AppRoutes.wargaDataKeluarga, extra: completeData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2988EA),
        elevation: 0,
        title: Text(
          'Data Alamat Rumah',
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
          _buildProgressIndicator(step: 2, totalSteps: 3),

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
                          Icons.home_outlined,
                          size: 48,
                          color: Color(0xFF2988EA),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lengkapi Data Rumah',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Isi data alamat rumah dan kepala keluarga untuk melanjutkan',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Alamat Rumah
                    _buildTextField(
                      controller: _alamatController,
                      label: 'Alamat Rumah Lengkap',
                      hint: 'Jl. Merdeka No. 123, RT 001/RW 002',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Alamat rumah harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Kepala Keluarga
                    _buildTextField(
                      controller: _kepalaKeluargaController,
                      label: 'Nama Kepala Keluarga',
                      hint: 'John Doe',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama kepala keluarga harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Jumlah Penghuni
                    _buildTextField(
                      controller: _jumlahPenghuniController,
                      label: 'Jumlah Penghuni',
                      hint: '4',
                      icon: Icons.people_outline,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Jumlah penghuni harus diisi';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 1) {
                          return 'Jumlah penghuni minimal 1';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Status Kepemilikan
                    Text(
                      'Status Kepemilikan',
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
                          value: _statusKepemilikan,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: _statusKepemilikanOptions.map((String value) {
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
                              setState(() => _statusKepemilikan = newValue);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2988EA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Lanjutkan ke Data Keluarga',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
          final isCurrent = index == step - 1;

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
    TextInputType? keyboardType,
    int maxLines = 1,
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
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
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

