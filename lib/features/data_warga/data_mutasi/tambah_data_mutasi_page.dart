import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/mutasi_model.dart';
import 'repositories/mutasi_repository.dart';
import '../../../core/models/keluarga_model.dart';
import '../../../core/repositories/keluarga_repository.dart';
import '../../../core/models/rumah_model.dart';
import '../../../core/repositories/rumah_repository.dart';

class TambahDataMutasiPage extends StatefulWidget {
  const TambahDataMutasiPage({super.key});

  @override
  State<TambahDataMutasiPage> createState() => _TambahDataMutasiPageState();
}

class _TambahDataMutasiPageState extends State<TambahDataMutasiPage> {
  final _formKey = GlobalKey<FormState>();
  final MutasiRepository _mutasiRepo = MutasiRepository();
  final KeluargaRepository _keluargaRepo = KeluargaRepository();
  final RumahRepository _rumahRepo = RumahRepository();

  // Controllers
  final TextEditingController _alasanMutasiController = TextEditingController();
  final TextEditingController _alamatTujuanController = TextEditingController();

  // Selected data
  String? _selectedJenisMutasi;
  String? _selectedKeluargaNomorKK; // Changed to String (nomorKK)
  String? _selectedRumahSekarangId; // Changed to String (id)
  String? _selectedRumahBaruId; // Changed to String (id)
  DateTime? _selectedTanggalMutasi;

  bool _isLoading = false;

  // List data untuk dropdown
  final List<String> _jenisMutasiList = [
    'Mutasi Masuk',
    'Keluar Perumahan',
    'Pindah Rumah',
  ];


  @override
  void dispose() {
    _alasanMutasiController.dispose();
    _alamatTujuanController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedJenisMutasi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jenis mutasi terlebih dahulu')),
      );
      return;
    }

    if (_selectedKeluargaNomorKK == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih keluarga terlebih dahulu')),
      );
      return;
    }

    if (_selectedTanggalMutasi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mutasi terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Fetch keluarga data by nomorKK
      final keluarga = await _keluargaRepo.getKeluargaByNomorKK(_selectedKeluargaNomorKK!);
      if (keluarga == null) {
        throw Exception('Data keluarga tidak ditemukan');
      }

      // Fetch rumah data by ID if selected
      RumahModel? rumahSekarang;
      RumahModel? rumahBaru;

      if (_selectedRumahSekarangId != null) {
        rumahSekarang = await _rumahRepo.getRumahById(_selectedRumahSekarangId!);
      }

      if (_selectedRumahBaruId != null) {
        rumahBaru = await _rumahRepo.getRumahById(_selectedRumahBaruId!);
      }

      // Tentukan alamat asal dan tujuan berdasarkan jenis mutasi
      String alamatAsal;
      String alamatTujuan;

      if (_selectedJenisMutasi == 'Mutasi Masuk') {
        // Mutasi Masuk: dari alamat tujuan input ke rumah yang dipilih
        alamatAsal = _alamatTujuanController.text;
        alamatTujuan = rumahSekarang != null
            ? '${rumahSekarang.alamat}, RT ${rumahSekarang.rt} RW ${rumahSekarang.rw}'
            : 'Alamat di perumahan';
      } else if (_selectedJenisMutasi == 'Pindah Rumah') {
        // Pindah Rumah: dari rumah sekarang ke rumah baru
        alamatAsal = rumahSekarang != null
            ? '${rumahSekarang.alamat}, RT ${rumahSekarang.rt} RW ${rumahSekarang.rw}'
            : 'Rumah lama';
        alamatTujuan = rumahBaru != null
            ? '${rumahBaru.alamat}, RT ${rumahBaru.rt} RW ${rumahBaru.rw}'
            : 'Rumah baru';
      } else {
        // Keluar Perumahan: dari rumah sekarang ke alamat tujuan input
        alamatAsal = rumahSekarang != null
            ? '${rumahSekarang.alamat}, RT ${rumahSekarang.rt} RW ${rumahSekarang.rw}'
            : 'Rumah di perumahan';
        alamatTujuan = _alamatTujuanController.text;
      }

      // Get kepala keluarga info
      final kepalaKeluargaNama = keluarga.namaKepalaKeluarga;
      final kepalaKeluargaNik = keluarga.nomorKK; // Use nomorKK as NIK placeholder

      final mutasi = MutasiModel(
        nama: kepalaKeluargaNama,
        nik: kepalaKeluargaNik,
        jenisMutasi: _selectedJenisMutasi!,
        tanggalMutasi: _selectedTanggalMutasi!,
        alamatAsal: alamatAsal,
        alamatTujuan: alamatTujuan,
        alasanMutasi: _alasanMutasiController.text,
        keluargaId: keluarga.nomorKK, // Use nomorKK as keluargaId
        rumahId: rumahSekarang?.id,
        createdBy: 'admin', // TODO: Get from auth
      );

      final result = await _mutasiRepo.createMutasi(mutasi);

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data mutasi berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        throw Exception('Gagal menyimpan data');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          'Tambah Mutasi Keluarga',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1F1F1F),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Jenis Mutasi
                    _buildDropdownField(
                      label: 'Jenis Mutasi',
                      hint: 'Pilih jenis mutasi',
                      value: _selectedJenisMutasi,
                      items: _jenisMutasiList,
                      onChanged: (value) {
                        setState(() {
                          _selectedJenisMutasi = value;
                          // Reset related fields
                          _selectedRumahSekarangId = null;
                          _selectedRumahBaruId = null;
                          _alamatTujuanController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Keluarga - StreamBuilder
                    _buildKeluargaDropdown(),
                    const SizedBox(height: 16),

                    // Rumah Sekarang (untuk semua jenis mutasi) - StreamBuilder
                    if (_selectedJenisMutasi != null && _selectedJenisMutasi != 'Mutasi Masuk') ...[
                      _buildRumahDropdown(
                        label: 'Rumah Sekarang',
                        hint: 'Pilih rumah sekarang',
                        selectedRumahId: _selectedRumahSekarangId,
                        onChanged: (rumahId) {
                          setState(() {
                            _selectedRumahSekarangId = rumahId;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Rumah Baru (khusus untuk Pindah Rumah) - StreamBuilder
                    if (_selectedJenisMutasi == 'Pindah Rumah') ...[
                      _buildRumahDropdown(
                        label: 'Rumah Baru',
                        hint: 'Pilih rumah tujuan',
                        selectedRumahId: _selectedRumahBaruId,
                        onChanged: (rumahId) {
                          setState(() {
                            _selectedRumahBaruId = rumahId;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Alamat Tujuan (untuk Mutasi Masuk dan Keluar Perumahan)
                    if (_selectedJenisMutasi == 'Mutasi Masuk' || _selectedJenisMutasi == 'Keluar Perumahan') ...[
                      _buildTextField(
                        controller: _alamatTujuanController,
                        label: _selectedJenisMutasi == 'Mutasi Masuk' ? 'Alamat Asal' : 'Alamat Tujuan',
                        hint: _selectedJenisMutasi == 'Mutasi Masuk'
                            ? 'Masukkan alamat asal sebelum pindah'
                            : 'Masukkan alamat tujuan',
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tanggal Mutasi
                    _buildDateField(
                      label: 'Tanggal Mutasi',
                      hint: 'mm/dd/yyyy',
                      value: _selectedTanggalMutasi,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedTanggalMutasi ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF2988EA),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedTanggalMutasi = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Alasan Mutasi
                    _buildTextArea(
                      controller: _alasanMutasiController,
                      label: 'Alasan Mutasi',
                      hint: 'Masukkan alasan mutasi keluarga',
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Button
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hint,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF757575),
                size: 24,
              ),
              isExpanded: true,
              dropdownColor: Colors.white,
              menuMaxHeight: 300,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF1F1F1F),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF1F1F1F),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        // Validation message
        if (value == null && _formKey.currentState?.validate() == false)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Pilih $label',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FC),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2988EA), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Masukkan $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required String hint,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8EAF2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null
                      ? '${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}/${value.year}'
                      : hint,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: value != null
                        ? const Color(0xFF1F1F1F)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FC),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2988EA), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Masukkan $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  // NEW: Keluarga Dropdown with StreamBuilder
  Widget _buildKeluargaDropdown() {
    return StreamBuilder<List<KeluargaModel>>(
      stream: _keluargaRepo.getAllKeluarga(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Keluarga',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8EAF2)),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }

        final keluargaList = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Keluarga',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedKeluargaNomorKK,
                  hint: Text(
                    'Pilih keluarga',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF757575),
                    size: 24,
                  ),
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  menuMaxHeight: 300,
                  items: keluargaList.map((KeluargaModel keluarga) {
                    return DropdownMenuItem<String>(
                      value: keluarga.nomorKK,
                      child: Text(
                        keluarga.namaKepalaKeluarga,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF1F1F1F),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedKeluargaNomorKK = value;
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // NEW: Rumah Dropdown with StreamBuilder
  Widget _buildRumahDropdown({
    required String label,
    required String hint,
    required String? selectedRumahId,
    required Function(String?) onChanged,
  }) {
    return StreamBuilder<List<RumahModel>>(
      stream: _rumahRepo.getAllRumah(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8EAF2)),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }

        final rumahList = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedRumahId,
                  hint: Text(
                    hint,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF757575),
                    size: 24,
                  ),
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  menuMaxHeight: 300,
                  items: rumahList.map((RumahModel rumah) {
                    return DropdownMenuItem<String>(
                      value: rumah.id,
                      child: Text(
                        '${rumah.alamat} - RT ${rumah.rt} RW ${rumah.rw}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF1F1F1F),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _submitData,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2988EA),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Simpan',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
