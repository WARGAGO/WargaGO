import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/mutasi_model.dart';

/// Edit Data Mutasi Page
class EditDataMutasiPage extends StatefulWidget {
  final MutasiModel mutasiData;

  const EditDataMutasiPage({super.key, required this.mutasiData});

  @override
  State<EditDataMutasiPage> createState() => _EditDataMutasiPageState();
}

class _EditDataMutasiPageState extends State<EditDataMutasiPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk field teks - akan diisi di initState
  late final TextEditingController _namaController;
  late final TextEditingController _nikController;
  late final TextEditingController _alamatController;
  late final TextEditingController _nomorSuratController;
  late final TextEditingController _keteranganController;
  late final TextEditingController _tanggalController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with mutasiData values
    _namaController = TextEditingController(text: widget.mutasiData.nama);
    _nikController = TextEditingController(text: widget.mutasiData.nik);
    _alamatController = TextEditingController(text: widget.mutasiData.alamatTujuan);
    _nomorSuratController = TextEditingController(text: "");
    _keteranganController = TextEditingController(text: widget.mutasiData.alasanMutasi);
    _tanggalController = TextEditingController(
      text: "${widget.mutasiData.tanggalMutasi.day.toString().padLeft(2, '0')}/${widget.mutasiData.tanggalMutasi.month.toString().padLeft(2, '0')}/${widget.mutasiData.tanggalMutasi.year}",
    );
  }

  // Variabel dropdown
  String? _jenisMutasi;
  String? _alasanMutasi;
  String? _statusMutasi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Data Mutasi",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Nama Lengkap", _namaController),
              _buildTextField(
                "NIK",
                _nikController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField("Tanggal Mutasi", _tanggalController),
              _buildTextField("Alamat Asal/Tujuan", _alamatController),
              _buildTextField("Nomor Surat Pengantar", _nomorSuratController),

              _buildDropdown(
                "Jenis Mutasi",
                _jenisMutasi,
                ["Mutasi Masuk", "Mutasi Keluar"],
                (value) {
                  setState(() => _jenisMutasi = value);
                },
              ),

              _buildDropdown(
                "Alasan Mutasi",
                _alasanMutasi,
                ["Pindah Kerja", "Pindah Rumah", "Menikah", "Lainnya"],
                (value) {
                  setState(() => _alasanMutasi = value);
                },
              ),

              _buildDropdown(
                "Status Mutasi",
                _statusMutasi,
                ["Dalam Proses", "Selesai", "Dibatalkan"],
                (value) {
                  setState(() => _statusMutasi = value);
                },
              ),

              _buildTextField("Keterangan", _keteranganController, maxLines: 3),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "Simpan",
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

  // Text Field builder
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
            ),
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Dropdown builder
  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
            ),
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
