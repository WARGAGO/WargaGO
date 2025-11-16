import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EditKegiatanPage extends StatefulWidget {
  const EditKegiatanPage({super.key});

  @override
  State<EditKegiatanPage> createState() => _EditKegiatanPageState();
}

class _EditKegiatanPageState extends State<EditKegiatanPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController(
    text: "Gotong Royong",
  );
  final TextEditingController _tanggalController = TextEditingController(
    text: "15/10/2025",
  );
  final TextEditingController _lokasiController = TextEditingController(
    text: "Masjid Komplek",
  );
  final TextEditingController _pjController = TextEditingController(
    text: "Pak Rusdi",
  );
  final TextEditingController _deskripsiController = TextEditingController(
    text: "Membersihkan Masjid kita tercinta ini",
  );

  String? _selectedKategori = 'Komunitas & Sosial';
  DateTime? _selectedDate;

  final List<String> _kategoriOptions = [
    'Komunitas & Sosial',
    'Kebersihan & Keamanan',
    'Keagamaan',
    'Pendidikan',
    'Kesehatan & Olahraga',
    'Lainnya',
  ];

  String? _selectedDocumentFileName = "dokumentasi_lama.jpg";

  @override
  void initState() {
    super.initState();
    try {
      _selectedDate = DateFormat('dd/MM/yyyy').parse(_tanggalController.text);
    } catch (e) {
      _selectedDate = DateTime.now();
      _tanggalController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalController.dispose();
    _lokasiController.dispose();
    _pjController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickDocument() async {
    setState(() {
      _selectedDocumentFileName = "dokumentasi_baru.pdf";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logika ganti dokumen belum diimplementasikan.'),
      ),
    );
  }

  // Modern TextField dengan gradient & shadow
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int? maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1F2937),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2988EA).withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF9CA3AF),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFFE8EAF2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFFE8EAF2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  width: 2,
                  color: Color(0xFF2988EA),
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFFEF4444),
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  width: 2,
                  color: Color(0xFFEF4444),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: suffixIcon,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  // Modern DropdownField dengan gradient & shadow
  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1F2937),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2988EA).withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            validator: validator,
            hint: Text(
              hint,
              style: GoogleFonts.poppins(
                color: const Color(0xFF9CA3AF),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFFE8EAF2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFFE8EAF2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  width: 2,
                  color: Color(0xFF2988EA),
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFFEF4444),
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  width: 2,
                  color: Color(0xFFEF4444),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2988EA).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF2988EA),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Modern File Upload Area
  Widget _buildFileUploadArea({
    required String label,
    required String buttonText,
    required IconData buttonIcon,
    required VoidCallback onUploadPressed,
    String? selectedFileName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1F2937),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2988EA).withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                width: 1,
                color: const Color(0xFFE8EAF2),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2988EA).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    selectedFileName != null ? Icons.insert_drive_file_rounded : Icons.upload_file_rounded,
                    size: 32,
                    color: const Color(0xFF2988EA),
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedFileName != null)
                  Text(
                    selectedFileName,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1F2937),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  )
                else
                  Text(
                    'Belum ada dokumentasi',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(buttonIcon, size: 20),
                  label: Text(
                    buttonText,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: onUploadPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2988EA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER dengan gradient modern
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2988EA), Color(0xFF2563EB)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button modern
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                          onPressed: () => Navigator.pop(context),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Edit Kegiatan",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Perbarui informasi kegiatan",
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // FORM dengan scroll
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                  _buildTextField(
                    controller: _namaController,
                    label: "Nama Kegiatan",
                    hint: "Masukkan nama kegiatan",
                    validator: (v) => v == null || v.isEmpty
                        ? 'Nama kegiatan tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdownField(
                    label: "Kategori",
                    hint: "Pilih Kategori",
                    value: _selectedKategori,
                    items: _kategoriOptions,
                    onChanged: (nv) => setState(() => _selectedKategori = nv),
                    validator: (v) =>
                        v == null ? 'Kategori harus dipilih' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _tanggalController,
                    label: "Tanggal",
                    hint: "dd/mm/yyyy",
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    suffixIcon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2988EA).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: Color(0xFF2988EA),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Tanggal tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _lokasiController,
                    label: "Lokasi",
                    hint: "Masukkan lokasi",
                    validator: (v) => v == null || v.isEmpty
                        ? 'Lokasi tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _pjController,
                    label: "Penanggung Jawab",
                    hint: "Masukkan nama Penanggung Jawab",
                    validator: (v) => v == null || v.isEmpty
                        ? 'Penanggung Jawab tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _deskripsiController,
                    label: "Deskripsi",
                    hint: "Masukkan deskripsi kegiatan",
                    maxLines: 3,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Deskripsi tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildFileUploadArea(
                    label: "Dokumentasi",
                    buttonText: _selectedDocumentFileName == null
                        ? "Upload Dokumentasi"
                        : "Ganti Dokumentasi",
                    buttonIcon: Icons.upload_file_rounded,
                    onUploadPressed: _pickDocument,
                    selectedFileName: _selectedDocumentFileName,
                  ),
                  const SizedBox(height: 40),
                  // Button Update dengan gradient modern
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2988EA), Color(0xFF2563EB)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2988EA).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Kegiatan berhasil diperbarui!',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          // Navigate back after delay
                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.save_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Simpan Perubahan",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
