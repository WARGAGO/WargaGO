import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditBroadcastPage extends StatefulWidget {
  const EditBroadcastPage({super.key});

  @override
  State<EditBroadcastPage> createState() => _EditBroadcastPageState();
}

class _EditBroadcastPageState extends State<EditBroadcastPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _judulController = TextEditingController(
    text: "Pengumuman",
  );
  final TextEditingController _isiController = TextEditingController(
    text: "Donor Darah di posko...",
  );

  String? _selectedImageFileName = "poster_donor.jpg";
  String? _selectedDocumentFileName = "surat_undangan.pdf";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      _selectedImageFileName = "gambar_baru.png";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logika ganti gambar belum diimplementasikan.'),
      ),
    );
  }

  Future<void> _pickDocument() async {
    setState(() {
      _selectedDocumentFileName = "dokumen_baru.docx";
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
                    'Belum ada file dipilih',
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
                              "Edit Broadcast",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Perbarui informasi broadcast",
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
                      controller: _judulController,
                      label: "Judul Broadcast",
                      hint: "Masukkan judul broadcast",
                      validator: (v) => v == null || v.isEmpty
                          ? 'Judul tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _isiController,
                      label: "Isi Broadcast",
                      hint: "Masukkan isi broadcast",
                      maxLines: 5,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Isi broadcast tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildFileUploadArea(
                      label: "Lampiran Gambar",
                      buttonText: _selectedImageFileName == null
                          ? "Upload Gambar"
                          : "Ganti Gambar",
                      buttonIcon: Icons.image_rounded,
                      onUploadPressed: _pickImage,
                      selectedFileName: _selectedImageFileName,
                    ),
                    const SizedBox(height: 20),
                    _buildFileUploadArea(
                      label: "Lampiran Dokumen",
                      buttonText: _selectedDocumentFileName == null
                          ? "Upload Dokumen PDF"
                          : "Ganti Dokumen",
                      buttonIcon: Icons.description_rounded,
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
                                      'Broadcast berhasil diperbarui!',
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
