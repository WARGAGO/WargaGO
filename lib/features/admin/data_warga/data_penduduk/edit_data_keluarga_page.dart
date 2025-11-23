import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditDataKeluargaPage extends StatefulWidget {
  const EditDataKeluargaPage({super.key});

  @override
  State<EditDataKeluargaPage> createState() => _EditDataKeluargaPageState();
}

class _EditDataKeluargaPageState extends State<EditDataKeluargaPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk setiap field
  final TextEditingController _namaKeluargaController = TextEditingController(
    text: "Keluarga Rendha Putra Rahmadya",
  );
  final TextEditingController _kepalaKeluargaController = TextEditingController(
    text: "-",
  );
  final TextEditingController _rumahSaatIniController = TextEditingController(
    text: "-",
  );

  String? _statusKepemilikan = "Pemilik";
  String? _statusKeluarga = "Aktif";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Data Keluarga",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Nama Keluarga", _namaKeluargaController),
              _buildTextField("Kepala Keluarga", _kepalaKeluargaController),
              _buildTextField("Rumah Saat Ini", _rumahSaatIniController),

              _buildDropdown(
                "Status Kepemilikan",
                _statusKepemilikan,
                ["Pemilik", "Kontrak", "Menumpang"],
                (value) => setState(() => _statusKepemilikan = value),
              ),
              _buildDropdown(
                "Status Keluarga",
                _statusKeluarga,
                ["Aktif", "Tidak Aktif"],
                (value) => setState(() => _statusKeluarga = value),
              ),

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
                      // Aksi simpan data
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text("Data keluarga disimpan")),
                      // );
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

  // TextField Builder
  Widget _buildTextField(String label, TextEditingController controller) {
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

  // Dropdown Builder
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
            initialValue: value,
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