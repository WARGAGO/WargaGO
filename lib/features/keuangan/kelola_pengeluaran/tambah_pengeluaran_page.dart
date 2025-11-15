// Clean Architecture - Presentation Layer
// - Fokus ke tampilan & interaksi user saja (tanpa logic bisnis berat)
// - Menggunakan StatefulWidget untuk state management
// - Widget dipecah menjadi komponen kecil yang reusable
// - Form validation dan user interaction

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'widgets/tambah_pengeluaran_header.dart';
import 'widgets/pengeluaran_image_picker.dart';

class TambahPengeluaranPage extends StatefulWidget {
  const TambahPengeluaranPage({super.key});

  @override
  State<TambahPengeluaranPage> createState() => _TambahPengeluaranPageState();
}

class _TambahPengeluaranPageState extends State<TambahPengeluaranPage> {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _namaPengeluaranController = TextEditingController();
  final _nominalController = TextEditingController();

  // State variables
  DateTime? _selectedDate;
  String? _selectedKategori;
  File? _buktiPengeluaran;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> _kategoriList = [
    {
      'value': 'operasional',
      'label': 'Operasional RT/RW',
      'icon': Icons.settings_outlined,
      'color': const Color(0xFF3B82F6),
    },
    {
      'value': 'kegiatan_sosial',
      'label': 'Kegiatan Sosial',
      'icon': Icons.volunteer_activism_outlined,
      'color': const Color(0xFF10B981),
    },
    {
      'value': 'pemeliharaan',
      'label': 'Pemeliharaan Fasilitas',
      'icon': Icons.build_outlined,
      'color': const Color(0xFFF59E0B),
    },
    {
      'value': 'pembangunan',
      'label': 'Pembangunan',
      'icon': Icons.construction_outlined,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'value': 'kegiatan_warga',
      'label': 'Kegiatan Warga',
      'icon': Icons.groups_outlined,
      'color': const Color(0xFF06B6D4),
    },
    {
      'value': 'keamanan_kebersihan',
      'label': 'Keamanan & Kebersihan',
      'icon': Icons.security_outlined,
      'color': const Color(0xFFEC4899),
    },
    {
      'value': 'lainnya',
      'label': 'Lainnya',
      'icon': Icons.more_horiz_outlined,
      'color': const Color(0xFF6B7280),
    },
  ];

  @override
  void dispose() {
    _namaPengeluaranController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2988EA),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2988EA),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pilih Sumber Gambar',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceOption(
                    'Kamera',
                    Icons.camera_alt_outlined,
                    const Color(0xFF2988EA),
                    () async {
                      Navigator.pop(context);
                      final XFile? image = await _picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() {
                          _buktiPengeluaran = File(image.path);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageSourceOption(
                    'Galeri',
                    Icons.photo_library_outlined,
                    const Color(0xFF10B981),
                    () async {
                      Navigator.pop(context);
                      final XFile? image = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() {
                          _buktiPengeluaran = File(image.path);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _simpanPengeluaran() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Silakan pilih tanggal pengeluaran',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      if (_selectedKategori == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Silakan pilih kategori pengeluaran',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      if (_buktiPengeluaran == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Silakan upload bukti pengeluaran',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF10B981),
                  size: 64,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Berhasil!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pengeluaran berhasil ditambahkan',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2988EA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'OK',
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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2988EA),
      body: Column(
        children: [
          const TambahPengeluaranHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNamaPengeluaranField(),
                      const SizedBox(height: 24),
                      _buildTanggalField(),
                      const SizedBox(height: 24),
                      _buildKategoriField(),
                      const SizedBox(height: 24),
                      _buildNominalField(),
                      const SizedBox(height: 24),
                      _buildBuktiPengeluaranField(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
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

  // Widget builder methods
  Widget _buildNamaPengeluaranField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Nama Pengeluaran', Icons.description_outlined),
        const SizedBox(height: 12),
        TextFormField(
          controller: _namaPengeluaranController,
          decoration: _buildInputDecoration(
            'Masukkan nama pengeluaran',
            Icons.edit_outlined,
          ),
          style: GoogleFonts.poppins(fontSize: 15),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama pengeluaran tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTanggalField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Tanggal Pengeluaran', Icons.calendar_today_outlined),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedDate != null
                    ? const Color(0xFF2988EA).withValues(alpha: 0.3)
                    : const Color(0xFFE8EAF2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2988EA).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF2988EA),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate!)
                        : 'Pilih tanggal pengeluaran',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: _selectedDate != null ? FontWeight.w600 : FontWeight.w400,
                      color: _selectedDate != null
                          ? const Color(0xFF1F2937)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKategoriField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Kategori Pengeluaran', Icons.category_outlined),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _selectedKategori != null
                  ? const Color(0xFF2988EA).withValues(alpha: 0.3)
                  : const Color(0xFFE8EAF2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedKategori,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            hint: Text(
              'Pilih kategori pengeluaran',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            dropdownColor: Colors.white,
            isExpanded: true,
            items: _kategoriList.map((kategori) {
              return DropdownMenuItem<String>(
                value: kategori['value'],
                child: Text(
                  kategori['label'],
                  style: GoogleFonts.poppins(fontSize: 15),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedKategori = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNominalField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Nominal', Icons.attach_money_outlined),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nominalController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _buildInputDecoration(
            'Masukkan nominal pengeluaran',
            Icons.payments_outlined,
          ),
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              final number = int.tryParse(value.replaceAll('.', ''));
              if (number != null) {
                final formatted = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: '',
                  decimalDigits: 0,
                ).format(number);
                _nominalController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nominal tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBuktiPengeluaranField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Bukti Pengeluaran', Icons.image_outlined),
        const SizedBox(height: 12),
        PengeluaranImagePicker(
          image: _buktiPengeluaran,
          onTap: _pickImage,
          onRemove: () {
            setState(() {
              _buktiPengeluaran = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _simpanPengeluaran,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2988EA),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save_outlined, size: 22),
            const SizedBox(width: 12),
            Text(
              'Simpan Pengeluaran',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF2988EA).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF2988EA),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 15,
        color: const Color(0xFF9CA3AF),
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2988EA).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2988EA),
            size: 20,
          ),
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE8EAF2), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE8EAF2), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2988EA), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

