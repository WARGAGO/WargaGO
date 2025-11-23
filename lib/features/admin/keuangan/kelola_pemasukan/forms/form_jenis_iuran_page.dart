import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jawara/core/providers/jenis_iuran_provider.dart';
import 'package:jawara/core/providers/auth_provider.dart';
import 'package:jawara/core/models/jenis_iuran_model.dart';

class FormJenisIuranPage extends StatefulWidget {
  final JenisIuranModel? jenisIuran; // null untuk create, ada value untuk edit

  const FormJenisIuranPage({
    super.key,
    this.jenisIuran,
  });

  @override
  State<FormJenisIuranPage> createState() => _FormJenisIuranPageState();
}

class _FormJenisIuranPageState extends State<FormJenisIuranPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaIuranController = TextEditingController();
  final _jumlahIuranController = TextEditingController();

  String _selectedKategori = 'bulanan';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Jika edit mode, isi form dengan data yang ada
    if (widget.jenisIuran != null) {
      _namaIuranController.text = widget.jenisIuran!.namaIuran;
      _jumlahIuranController.text = widget.jenisIuran!.jumlahIuran.toStringAsFixed(0);
      _selectedKategori = widget.jenisIuran!.kategoriIuran;
    }
  }

  @override
  void dispose() {
    _namaIuranController.dispose();
    _jumlahIuranController.dispose();
    super.dispose();
  }

  bool get isEditMode => widget.jenisIuran != null;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final jenisIuranProvider = context.read<JenisIuranProvider>();

    final jenisIuran = JenisIuranModel(
      id: widget.jenisIuran?.id ?? '',
      namaIuran: _namaIuranController.text.trim(),
      jumlahIuran: double.parse(_jumlahIuranController.text.replaceAll('.', '').replaceAll(',', '')),
      kategoriIuran: _selectedKategori,
      createdBy: authProvider.userModel?.email ?? '',
      isActive: true,
    );

    bool success;
    if (isEditMode) {
      success = await jenisIuranProvider.updateJenisIuran(jenisIuran);
    } else {
      success = await jenisIuranProvider.addJenisIuran(jenisIuran);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
              ? 'Jenis iuran berhasil diupdate!'
              : 'Jenis iuran berhasil ditambahkan!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            jenisIuranProvider.errorMessage ?? 'Terjadi kesalahan',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditMode ? 'Edit Jenis Iuran' : 'Tambah Jenis Iuran',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Iuran
              _buildSectionTitle('Nama Jenis Iuran'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _namaIuranController,
                label: 'Contoh: Iuran Kebersihan',
                icon: Icons.payment_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama jenis iuran harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Jumlah Iuran
              _buildSectionTitle('Jumlah Iuran (Rp)'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _jumlahIuranController,
                label: 'Contoh: 50000',
                icon: Icons.money_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah iuran harus diisi';
                  }
                  final amount = int.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Jumlah iuran harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Kategori Iuran
              _buildSectionTitle('Kategori Iuran'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE8EAF2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    _buildRadioTile(
                      title: 'Iuran Bulanan',
                      subtitle: 'Iuran rutin yang dibayarkan setiap bulan',
                      value: 'bulanan',
                      groupValue: _selectedKategori,
                      onChanged: (value) {
                        setState(() {
                          _selectedKategori = value!;
                        });
                      },
                    ),
                    Divider(
                      height: 1,
                      color: const Color(0xFFE8EAF2),
                    ),
                    _buildRadioTile(
                      title: 'Iuran Khusus',
                      subtitle: 'Iuran untuk keperluan khusus atau insidental',
                      value: 'khusus',
                      groupValue: _selectedKategori,
                      onChanged: (value) {
                        setState(() {
                          _selectedKategori = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isEditMode ? 'Update Jenis Iuran' : 'Tambah Jenis Iuran',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8EAF2),
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF9CA3AF),
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF6B7280),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

