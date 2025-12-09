// ============================================================================
// ADD/EDIT JENIS IURAN PAGE
// ============================================================================
// Form untuk create/update jenis iuran
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/jenis_iuran_provider.dart';
import '../../../../core/models/jenis_iuran_model.dart';

class AddJenisIuranPage extends StatefulWidget {
  final JenisIuranModel? jenisIuran; // For edit mode

  const AddJenisIuranPage({super.key, this.jenisIuran});

  @override
  State<AddJenisIuranPage> createState() => _AddJenisIuranPageState();
}

class _AddJenisIuranPageState extends State<AddJenisIuranPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nominalController = TextEditingController();

  String _selectedKategori = 'bulanan';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.jenisIuran != null) {
      // Edit mode - populate fields
      _namaController.text = widget.jenisIuran!.namaIuran;
      _nominalController.text = widget.jenisIuran!.jumlahIuran.toStringAsFixed(0);
      _selectedKategori = widget.jenisIuran!.kategoriIuran;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.jenisIuran != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Jenis Iuran' : 'Tambah Jenis Iuran',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2988EA),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Nama Jenis Iuran
            TextFormField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama Jenis Iuran *',
                hintText: 'Contoh: Iuran Sampah',
                prefixIcon: const Icon(Icons.label),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama jenis iuran harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nominal Default
            TextFormField(
              controller: _nominalController,
              decoration: InputDecoration(
                labelText: 'Nominal Default *',
                hintText: 'Contoh: 50000',
                prefixIcon: const Icon(Icons.payments),
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nominal harus diisi';
                }
                final nominal = double.tryParse(value);
                if (nominal == null || nominal <= 0) {
                  return 'Nominal harus lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Kategori
            DropdownButtonFormField<String>(
              value: _selectedKategori,
              decoration: InputDecoration(
                labelText: 'Kategori Iuran *',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: 'bulanan', child: Text('Bulanan')),
                DropdownMenuItem(value: 'khusus', child: Text('Khusus')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedKategori = value!;
                });
              },
            ),
            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2988EA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2988EA).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF2988EA)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nominal default akan digunakan saat membuat tagihan baru. Anda tetap bisa mengubahnya saat buat tagihan.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF2988EA),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2988EA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEditMode ? 'Simpan Perubahan' : 'Tambah Jenis Iuran',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<JenisIuranProvider>();
      final isEditMode = widget.jenisIuran != null;

      final jenisIuran = JenisIuranModel(
        id: isEditMode ? widget.jenisIuran!.id : '',
        namaIuran: _namaController.text.trim(),
        jumlahIuran: double.parse(_nominalController.text),
        kategoriIuran: _selectedKategori,
        isActive: true,
        createdAt: isEditMode ? widget.jenisIuran!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (isEditMode) {
        success = await provider.updateJenisIuran(jenisIuran);
      } else {
        success = await provider.addJenisIuran(jenisIuran);
      }

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditMode
                    ? 'Jenis iuran berhasil diperbarui!'
                    : 'Jenis iuran berhasil ditambahkan!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Terjadi kesalahan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

