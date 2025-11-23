import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:jawara/core/providers/pemasukan_lain_provider.dart';
import 'package:jawara/core/models/pemasukan_lain_model.dart';

class PemasukanNonIuranPage extends StatefulWidget {
  const PemasukanNonIuranPage({super.key});

  @override
  State<PemasukanNonIuranPage> createState() => _PemasukanNonIuranPageState();
}

class _PemasukanNonIuranPageState extends State<PemasukanNonIuranPage> {
  final TextEditingController _namaPemasukanController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedKategori;

  final List<String> _kategoriList = [
    'Donasi',
    'Dana Bantuan Pemerintah',
    'Sumbangan Swadaya',
    'Hasil Usaha Kampung',
    'Pendapatan Lainnya',
  ];

  @override
  void dispose() {
    _namaPemasukanController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _namaPemasukanController.text.isNotEmpty &&
        _selectedDate != null &&
        _selectedKategori != null &&
        _nominalController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F1F1F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pemasukan Non Iuran Baru',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama Pemasukan
            Text(
              'Nama Pemasukan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _namaPemasukanController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Masukkan nama pemasukan',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF9CA3AF),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE8EAF2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE8EAF2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1E54F4),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF1F1F1F),
              ),
            ),

            const SizedBox(height: 24),

            // Tanggal
            Text(
              'tanggal',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showDatePicker(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE8EAF2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? DateFormat('d MMMM yyyy').format(_selectedDate!)
                          : 'Pilih Tanggal',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _selectedDate != null
                            ? const Color(0xFF1F1F1F)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Kategori Pemasukan
            Text(
              'Kategori Pemasukan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE8EAF2),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedKategori,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      'Pilih Kategori',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  items: _kategoriList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          value,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF1F1F1F),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedKategori = newValue;
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return _kategoriList.map((String value) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF1F1F1F),
                            ),
                          ),
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Nominal
            Text(
              'Nominal',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nominalController,
              onChanged: (value) => setState(() {}),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: 'Masukkan nama pemasukan',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF9CA3AF),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE8EAF2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE8EAF2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1E54F4),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF1F1F1F),
              ),
            ),

            const SizedBox(height: 24),

            // Bukti Pemasukan
            Text(
              'Bukti Pemasukan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                // Handle file upload
                _showUploadDialog();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE8EAF2),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_outlined,
                        color: const Color(0xFF1E54F4),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Bukti',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Bottom Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9CA3AF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Kembali',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isFormValid()
                        ? () {
                            _submitPemasukan();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E54F4),
                      disabledBackgroundColor: const Color(0xFFE8EAF2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Lanjut',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isFormValid()
                            ? Colors.white
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
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

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E54F4),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1F1F1F),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Upload Bukti Pemasukan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Fitur upload bukti akan segera hadir.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: const Color(0xFF1E54F4),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitPemasukan() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Menyimpan data...',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final nominal = double.tryParse(_nominalController.text) ?? 0;
      
      // Create pemasukan model
      final pemasukan = PemasukanLainModel(
        id: '', // Will be auto-generated by Firestore
        name: _namaPemasukanController.text,
        category: _selectedKategori!,
        nominal: nominal,
        tanggal: _selectedDate!,
        status: 'Menunggu', // Default status
        createdBy: '', // Will be set by service if user is logged in
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Save to Firebase
      final provider = context.read<PemasukanLainProvider>();
      final success = await provider.createPemasukanLain(pemasukan);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (success) {
        // Format nominal untuk display
        final formatter = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        // Tampilkan dialog sukses
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF3B82F6),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Berhasil!',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pemasukan Non Iuran berhasil ditambahkan',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _namaPemasukanController.text,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F1F1F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatter.format(nominal),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context, true); // Back to previous page with result
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E54F4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'OK',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      } else {
        // Show error dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Gagal',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEF4444),
                ),
              ),
              content: Text(
                provider.error ?? 'Terjadi kesalahan saat menyimpan data',
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'OK',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1E54F4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);
      
      // Show error
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Error',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEF4444),
              ),
            ),
            content: Text(
              'Terjadi kesalahan: $e',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1E54F4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }
}
