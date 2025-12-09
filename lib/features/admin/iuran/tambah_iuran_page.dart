// filepath: lib/features/admin/iuran/tambah_iuran_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/iuran_model.dart';
import '../../../core/services/iuran_service.dart';

class TambahIuranPage extends StatefulWidget {
  final IuranModel? iuran; // Untuk edit mode

  const TambahIuranPage({super.key, this.iuran});

  @override
  State<TambahIuranPage> createState() => _TambahIuranPageState();
}

class _TambahIuranPageState extends State<TambahIuranPage> {
  final _formKey = GlobalKey<FormState>();
  final IuranService _iuranService = IuranService();

  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  late TextEditingController _nominalController;

  String _selectedTipe = 'bulanan';
  String _selectedKategori = 'Umum';
  DateTime _tanggalJatuhTempo = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;
  bool get _isEditMode => widget.iuran != null;

  final List<String> _tipeOptions = ['bulanan', 'tahunan', 'insidental'];
  final List<Map<String, dynamic>> _kategoriOptions = [
    {'name': 'Umum', 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFF2F80ED)},
    {'name': 'Kebersihan', 'icon': Icons.cleaning_services_rounded, 'color': Color(0xFF10B981)},
    {'name': 'Keamanan', 'icon': Icons.security_rounded, 'color': Color(0xFFEF4444)},
    {'name': 'Pembangunan', 'icon': Icons.construction_rounded, 'color': Color(0xFFF59E0B)},
    {'name': 'Lainnya', 'icon': Icons.more_horiz_rounded, 'color': Color(0xFF8B5CF6)},
  ];

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.iuran?.judul ?? '');
    _deskripsiController = TextEditingController(text: widget.iuran?.deskripsi ?? '');
    _nominalController = TextEditingController(
      text: widget.iuran != null ? widget.iuran!.nominal.toInt().toString() : '',
    );

    if (widget.iuran != null) {
      _selectedTipe = widget.iuran!.tipe;
      _selectedKategori = widget.iuran!.kategori ?? 'Umum';
      _tanggalJatuhTempo = widget.iuran!.tanggalJatuhTempo;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildJudulField(),
                      const SizedBox(height: 16),
                      _buildDeskripsiField(),
                      const SizedBox(height: 16),
                      _buildNominalField(),
                      const SizedBox(height: 16),
                      _buildTipeField(),
                      const SizedBox(height: 16),
                      _buildKategoriField(),
                      const SizedBox(height: 16),
                      _buildTanggalField(),
                      const SizedBox(height: 24),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2F80ED),
            Color(0xFF1E6FD9),
            Color(0xFF0F5FCC),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              _isEditMode ? Icons.edit_rounded : Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode ? "Edit Iuran" : "Tambah Iuran Baru",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditMode ? "Perbarui data iuran" : "Isi form di bawah dengan lengkap",
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJudulField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Judul Iuran *',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _judulController,
          decoration: InputDecoration(
            hintText: 'Contoh: Iuran Kebersihan Bulanan',
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.title_rounded,
              color: Color(0xFF2F80ED),
              size: 22,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF2F80ED),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Judul harus diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDeskripsiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi *',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _deskripsiController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Jelaskan tentang iuran ini...',
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF2F80ED),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Deskripsi harus diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNominalField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nominal (Rp) *',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nominalController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: '50000',
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.payments_rounded,
              color: Color(0xFF2F80ED),
              size: 22,
            ),
            prefixText: 'Rp ',
            prefixStyle: GoogleFonts.poppins(
              color: const Color(0xFF1F2937),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF2F80ED),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nominal harus diisi';
            }
            if (int.tryParse(value) == null) {
              return 'Nominal harus berupa angka';
            }
            if (int.parse(value) <= 0) {
              return 'Nominal harus lebih dari 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTipeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipe Iuran *',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Row(
            children: _tipeOptions.map((tipe) {
              final isSelected = _selectedTipe == tipe;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTipe = tipe;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        tipe[0].toUpperCase() + tipe.substring(1),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildKategoriField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori *',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _kategoriOptions.map((kategori) {
            final isSelected = _selectedKategori == kategori['name'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedKategori = kategori['name'];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (kategori['color'] as Color).withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? kategori['color']
                        : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      kategori['icon'],
                      size: 18,
                      color: isSelected
                          ? kategori['color']
                          : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      kategori['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? kategori['color']
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTanggalField() {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Jatuh Tempo *',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _tanggalJatuhTempo,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF2F80ED),
                      onPrimary: Colors.white,
                      onSurface: Color(0xFF1F2937),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _tanggalJatuhTempo = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF2F80ED),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dateFormat.format(_tanggalJatuhTempo),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Color(0xFF6B7280),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveIuran,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F80ED),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isEditMode ? Icons.check_circle_outline_rounded : Icons.add_circle_outline_rounded,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isEditMode ? 'Simpan Perubahan' : 'Buat Iuran & Generate Tagihan',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _saveIuran() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final iuran = IuranModel(
        id: widget.iuran?.id ?? '',
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        nominal: double.parse(_nominalController.text.trim()),
        tanggalJatuhTempo: _tanggalJatuhTempo,
        tanggalBuat: widget.iuran?.tanggalBuat ?? DateTime.now(),
        tipe: _selectedTipe,
        status: 'aktif',
        kategori: _selectedKategori,
        createdAt: widget.iuran?.createdAt,
        updatedAt: DateTime.now(),
      );

      if (_isEditMode) {
        // Update existing iuran
        await _iuranService.updateIuran(widget.iuran!.id, iuran);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Iuran berhasil diperbarui',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Create new iuran
        final iuranId = await _iuranService.createIuran(iuran);

        // Generate tagihan for all users
        final count = await _iuranService.generateTagihanForAllUsers(iuranId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Iuran berhasil dibuat! $count tagihan telah di-generate.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan iuran: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

