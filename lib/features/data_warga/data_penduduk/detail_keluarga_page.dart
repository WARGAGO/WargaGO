import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/keluarga_provider.dart';
import '../../../core/models/keluarga_model.dart';

class DetailKeluargaPage extends StatefulWidget {
  final String nomorKK;

  const DetailKeluargaPage({
    super.key,
    required this.nomorKK,
  });

  @override
  State<DetailKeluargaPage> createState() => _DetailKeluargaPageState();
}

class _DetailKeluargaPageState extends State<DetailKeluargaPage> {
  KeluargaModel? _keluarga;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKeluargaData();
  }

  Future<void> _loadKeluargaData() async {
    final provider = context.read<KeluargaProvider>();
    final keluarga = await provider.getKeluargaByNomorKK(widget.nomorKK);

    setState(() {
      _keluarga = keluarga;
      _isLoading = false;
    });
  }

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
          "Detail Data Keluarga",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _keluarga == null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Data keluarga tidak ditemukan',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailField("Nomor KK", _keluarga!.nomorKK),
          _buildDetailField("Kepala Keluarga", _keluarga!.namaKepalaKeluarga),
          _buildDetailField("Alamat", _keluarga!.fullAddress),
          _buildDetailField("RT", _keluarga!.rt.isNotEmpty ? _keluarga!.rt : '-'),
          _buildDetailField("RW", _keluarga!.rw.isNotEmpty ? _keluarga!.rw : '-'),
          _buildDetailField("Status Keluarga", _keluarga!.status),
          _buildDetailField("Jumlah Anggota", '${_keluarga!.jumlahAnggota} orang'),
        ],
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
