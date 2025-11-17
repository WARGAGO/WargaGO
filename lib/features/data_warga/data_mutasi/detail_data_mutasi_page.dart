import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'models/mutasi_model.dart';
import 'edit_data_mutasi_page.dart';

/// Detail Data Mutasi Page
class DetailDataMutasiPage extends StatelessWidget {
  final MutasiModel mutasiData;

  const DetailDataMutasiPage({super.key, required this.mutasiData});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'id_ID');

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
          "Detail Data Mutasi",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditDataMutasiPage(mutasiData: mutasiData),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailField("Nama Lengkap", mutasiData.nama),
            _buildDetailField("NIK", mutasiData.nik),
            _buildDetailField("Jenis Mutasi", mutasiData.jenisMutasi),
            _buildDetailField("Tanggal Mutasi", dateFormat.format(mutasiData.tanggalMutasi)),
            _buildDetailField("Alamat Asal", mutasiData.alamatAsal),
            _buildDetailField("Alamat Tujuan", mutasiData.alamatTujuan),
            _buildDetailField("Alasan Mutasi", mutasiData.alasanMutasi),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: value,
            readOnly: true,
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
}
