import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jawara/core/models/warga_model.dart';
import 'package:jawara/core/providers/warga_provider.dart';

class EditDataWargaPage extends StatefulWidget {
  final WargaModel warga;

  const EditDataWargaPage({super.key, required this.warga});

  @override
  State<EditDataWargaPage> createState() => _EditDataWargaPageState();
}

class _EditDataWargaPageState extends State<EditDataWargaPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late final TextEditingController _namaController;
  late final TextEditingController _nikController;
  late final TextEditingController _nomorKKController;
  late final TextEditingController _teleponController;
  late final TextEditingController _namaKeluargaController;
  late final TextEditingController _tempatLahirController;
  late final TextEditingController _namaIbuController;
  late final TextEditingController _namaAyahController;
  late final TextEditingController _rtController;
  late final TextEditingController _rwController;
  late final TextEditingController _alamatController;
  late final TextEditingController _kewarganegaraanController;

  // Dropdown values
  String? _jenisKelamin;
  String? _agama;
  String? _golonganDarah;
  String? _pendidikan;
  String? _pekerjaan;
  String? _statusPerkawinan;
  String? _statusPenduduk;
  String? _statusHidup;
  String? _peranKeluarga;
  DateTime? _tanggalLahir;

  @override
  void initState() {
    super.initState();

    try {
      // Initialize controllers with existing data (with null safety)
      _namaController = TextEditingController(text: widget.warga.name ?? '');
      _nikController = TextEditingController(text: widget.warga.nik ?? '');
      _nomorKKController = TextEditingController(text: widget.warga.nomorKK ?? '');
      _teleponController = TextEditingController(text: widget.warga.phone ?? '');
      _namaKeluargaController = TextEditingController(text: widget.warga.namaKeluarga ?? '');
      _tempatLahirController = TextEditingController(text: widget.warga.tempatLahir ?? '');
      _namaIbuController = TextEditingController(text: widget.warga.namaIbu ?? '');
      _namaAyahController = TextEditingController(text: widget.warga.namaAyah ?? '');
      _rtController = TextEditingController(text: widget.warga.rt ?? '');
      _rwController = TextEditingController(text: widget.warga.rw ?? '');
      _alamatController = TextEditingController(text: widget.warga.alamat ?? '');
      _kewarganegaraanController = TextEditingController(text: widget.warga.kewarganegaraan ?? 'Indonesia');

      // Define valid options for each dropdown
      final validJenisKelamin = ["Laki-laki", "Perempuan"];
      final validAgama = ["Islam", "Kristen", "Katolik", "Hindu", "Buddha", "Konghucu"];
      final validGolonganDarah = ["A", "B", "AB", "O"];
      final validPendidikan = ["Tidak Sekolah", "SD", "SMP", "SMA", "Diploma", "Sarjana", "Pascasarjana"];
      final validPekerjaan = ["Tidak Bekerja", "Pelajar/Mahasiswa", "Ibu Rumah Tangga", "PNS", "TNI/Polri", "Pegawai Swasta", "Wiraswasta", "Petani", "Buruh", "Lainnya"];
      final validStatusPerkawinan = ["Belum Kawin", "Kawin", "Cerai Hidup", "Cerai Mati"];
      final validStatusPenduduk = ["Aktif", "Nonaktif"];
      final validStatusHidup = ["Hidup", "Wafat"];
      final validPeranKeluarga = ["Kepala Keluarga", "Istri", "Anak", "Menantu", "Cucu", "Orang Tua", "Mertua", "Anggota Keluarga Lain"];

      // Helper function to validate dropdown value
      String? _validateDropdownValue(String? value, List<String> validOptions) {
        if (value == null || value.isEmpty || value == '-') return null;
        return validOptions.contains(value) ? value : null;
      }

      // Initialize dropdown values - ONLY set if value exists in valid options
      _jenisKelamin = _validateDropdownValue(widget.warga.jenisKelamin, validJenisKelamin);
      _agama = _validateDropdownValue(widget.warga.agama, validAgama);
      _golonganDarah = _validateDropdownValue(widget.warga.golonganDarah, validGolonganDarah);
      _pendidikan = _validateDropdownValue(widget.warga.pendidikan, validPendidikan);
      _pekerjaan = _validateDropdownValue(widget.warga.pekerjaan, validPekerjaan);
      _statusPerkawinan = _validateDropdownValue(widget.warga.statusPerkawinan, validStatusPerkawinan);
      _peranKeluarga = _validateDropdownValue(widget.warga.peranKeluarga, validPeranKeluarga);

      // Status penduduk dan status hidup dengan default values
      final statusPendudukValue = _validateDropdownValue(widget.warga.statusPenduduk, validStatusPenduduk);
      _statusPenduduk = statusPendudukValue ?? 'Aktif'; // Default ke Aktif jika tidak valid

      final statusHidupValue = _validateDropdownValue(widget.warga.statusHidup, validStatusHidup);
      _statusHidup = statusHidupValue ?? 'Hidup'; // Default ke Hidup jika tidak valid


      _tanggalLahir = widget.warga.birthDate;

      print('✅ InitState success - Dropdown values initialized');
    } catch (e) {
      print('❌ Error in initState: $e');
      // Initialize with empty/default values if error occurs
      _namaController = TextEditingController(text: '');
      _nikController = TextEditingController(text: '');
      _nomorKKController = TextEditingController(text: '');
      _teleponController = TextEditingController(text: '');
      _namaKeluargaController = TextEditingController(text: '');
      _tempatLahirController = TextEditingController(text: '');
      _namaIbuController = TextEditingController(text: '');
      _namaAyahController = TextEditingController(text: '');
      _rtController = TextEditingController(text: '');
      _rwController = TextEditingController(text: '');
      _alamatController = TextEditingController(text: '');
      _kewarganegaraanController = TextEditingController(text: 'Indonesia');

      // Set dropdowns to null/default
      _jenisKelamin = null;
      _agama = null;
      _golonganDarah = null;
      _pendidikan = null;
      _pekerjaan = null;
      _statusPerkawinan = null;
      _statusPenduduk = 'Aktif';
      _statusHidup = 'Hidup';
      _peranKeluarga = null;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _nomorKKController.dispose();
    _teleponController.dispose();
    _namaKeluargaController.dispose();
    _tempatLahirController.dispose();
    _namaIbuController.dispose();
    _namaAyahController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _alamatController.dispose();
    _kewarganegaraanController.dispose();
    super.dispose();
  }

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
          "Edit Data Warga",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    try {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Nama Lengkap", _namaController, required: true),
              _buildTextField("NIK", _nikController, keyboardType: TextInputType.number, required: true),
              _buildTextField("Nomor KK", _nomorKKController, keyboardType: TextInputType.number),
              _buildTextField("Nomor Telepon", _teleponController, keyboardType: TextInputType.phone),
              _buildTextField("Nama Keluarga", _namaKeluargaController),
              _buildTextField("Tempat Lahir", _tempatLahirController),
              _buildDateField("Tanggal Lahir", _tanggalLahir),
              _buildTextField("Nama Ibu", _namaIbuController),
              _buildTextField("Nama Ayah", _namaAyahController),

              _buildDropdown("Jenis Kelamin", _jenisKelamin, ["Laki-laki", "Perempuan"],
                (value) => setState(() => _jenisKelamin = value), required: true),

              _buildDropdown("Agama", _agama, ["Islam", "Kristen", "Katolik", "Hindu", "Buddha", "Konghucu"],
                (value) => setState(() => _agama = value)),

              _buildDropdown("Golongan Darah", _golonganDarah, ["A", "B", "AB", "O"],
                (value) => setState(() => _golonganDarah = value)),

              _buildDropdown("Pendidikan Terakhir", _pendidikan,
                ["Tidak Sekolah", "SD", "SMP", "SMA", "Diploma", "Sarjana", "Pascasarjana"],
                (value) => setState(() => _pendidikan = value)),

              _buildDropdown("Pekerjaan", _pekerjaan,
                ["Tidak Bekerja", "Pelajar/Mahasiswa", "Ibu Rumah Tangga", "PNS", "TNI/Polri", "Pegawai Swasta", "Wiraswasta", "Petani", "Buruh", "Lainnya"],
                (value) => setState(() => _pekerjaan = value)),

              _buildDropdown("Status Perkawinan", _statusPerkawinan,
                ["Belum Kawin", "Kawin", "Cerai Hidup", "Cerai Mati"],
                (value) => setState(() => _statusPerkawinan = value)),

              _buildDropdown("Peran Keluarga", _peranKeluarga,
                ["Kepala Keluarga", "Istri", "Anak", "Menantu", "Cucu", "Orang Tua", "Mertua", "Anggota Keluarga Lain"],
                (value) => setState(() => _peranKeluarga = value)),

              _buildDropdown("Status Hidup", _statusHidup, ["Hidup", "Wafat"],
                (value) => setState(() => _statusHidup = value)),

              _buildDropdown("Status Penduduk", _statusPenduduk, ["Aktif", "Nonaktif"],
                (value) => setState(() => _statusPenduduk = value)),

              _buildTextField("RT", _rtController),
              _buildTextField("RW", _rwController),
              _buildTextField("Alamat", _alamatController, maxLines: 3),
              _buildTextField("Kewarganegaraan", _kewarganegaraanController),

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
                  onPressed: _isLoading ? null : _saveChanges,
                  child: Text(
                    "Simpan Perubahan",
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
      );
    } catch (e) {
      print('❌ Error building form: $e');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error memuat data warga',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Terjadi kesalahan saat memuat form edit.\n$e',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Kembali', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate required fields
    if (_jenisKelamin == null) {
      _showErrorSnackbar('Jenis kelamin harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    final updatedWarga = widget.warga.copyWith(
      name: _namaController.text.trim(),
      nik: _nikController.text.trim(),
      nomorKK: _nomorKKController.text.trim(),
      phone: _teleponController.text.trim(),
      namaKeluarga: _namaKeluargaController.text.trim(),
      tempatLahir: _tempatLahirController.text.trim(),
      birthDate: _tanggalLahir,
      namaIbu: _namaIbuController.text.trim(),
      namaAyah: _namaAyahController.text.trim(),
      jenisKelamin: _jenisKelamin!,
      agama: _agama ?? '',
      golonganDarah: _golonganDarah ?? '',
      pendidikan: _pendidikan ?? '',
      pekerjaan: _pekerjaan ?? '',
      statusPerkawinan: _statusPerkawinan ?? '',
      peranKeluarga: _peranKeluarga ?? '',
      statusHidup: _statusHidup ?? 'Hidup',
      statusPenduduk: _statusPenduduk ?? 'Aktif',
      rt: _rtController.text.trim(),
      rw: _rwController.text.trim(),
      alamat: _alamatController.text.trim(),
      kewarganegaraan: _kewarganegaraanController.text.trim(),
    );

    final provider = context.read<WargaProvider>();
    final success = await provider.updateWarga(widget.warga.id, updatedWarga);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data warga berhasil diupdate', style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorSnackbar(provider.errorMessage ?? 'Gagal mengupdate data warga');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _tanggalLahir = picked);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                suffixIcon: const Icon(Icons.calendar_today, size: 18),
              ),
              child: Text(
                value != null ? '${value.day}/${value.month}/${value.year}' : 'Pilih tanggal',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label + (required ? ' *' : ''),
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
            validator: required ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label harus diisi';
              }
              return null;
            } : null,
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

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label + (required ? ' *' : ''),
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
            validator: required ? (value) {
              if (value == null || value.isEmpty) {
                return '$label harus dipilih';
              }
              return null;
            } : null,
          ),
        ],
      ),
    );
  }
}

