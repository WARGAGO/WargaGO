// ============================================================================
// ADMIN POLL CREATE PAGE
// ============================================================================
// Form untuk admin membuat polling resmi dengan validasi lengkap
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wargago/core/providers/poll_provider.dart';
import 'package:wargago/core/providers/auth_provider.dart';
import 'package:wargago/core/models/poll_model.dart';
import 'package:wargago/core/models/poll_option_model.dart';

class AdminPollCreatePage extends StatefulWidget {
  const AdminPollCreatePage({super.key});

  @override
  State<AdminPollCreatePage> createState() => _AdminPollCreatePageState();
}

class _AdminPollCreatePageState extends State<AdminPollCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  final List<TextEditingController> _optionDescControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  String _pollType = 'election'; // election, decision, survey
  String _visibilityScope = 'all_rt'; // all_rt, specific_rt, specific_rw
  String? _targetRT;
  String? _targetRW;
  bool _requireKYC = true;
  bool _isAnonymous = false;
  bool _isCreating = false;

  // Validation flags
  bool _dateError = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    for (var controller in _optionDescControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Buat Polling Resmi',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Polling resmi untuk keputusan penting RT/RW',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Title
            _buildSectionTitle('Judul Polling', required: true),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration(
                hint: 'Contoh: Pemilihan Ketua RT 2025',
                icon: Icons.title_rounded,
              ),
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul harus diisi';
                }
                if (value.trim().length < 10) {
                  return 'Judul minimal 10 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Description
            _buildSectionTitle('Deskripsi', required: true),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: _inputDecoration(
                hint: 'Jelaskan detail polling, tujuan, dan informasi penting lainnya...',
                icon: Icons.description_rounded,
              ),
              maxLines: 5,
              maxLength: 500,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Deskripsi harus diisi';
                }
                if (value.trim().length < 20) {
                  return 'Deskripsi minimal 20 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Poll Type
            _buildSectionTitle('Tipe Polling', required: true),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'election',
                    groupValue: _pollType,
                    onChanged: (value) => setState(() => _pollType = value!),
                    title: Text(
                      'Pemilihan',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Untuk memilih kandidat (Ketua RT, Pengurus, dll)',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    value: 'decision',
                    groupValue: _pollType,
                    onChanged: (value) => setState(() => _pollType = value!),
                    title: Text(
                      'Keputusan',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Untuk mengambil keputusan (Ya/Tidak, Setuju/Tidak)',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    value: 'survey',
                    groupValue: _pollType,
                    onChanged: (value) => setState(() => _pollType = value!),
                    title: Text(
                      'Survey',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Untuk mengumpulkan pendapat atau preferensi',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Date Range
            _buildSectionTitle('Periode Polling', required: true),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Mulai',
                    date: _startDate,
                    onTap: () => _selectStartDate(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    label: 'Berakhir',
                    date: _endDate,
                    onTap: () => _selectEndDate(),
                    error: _dateError,
                  ),
                ),
              ],
            ),
            if (_dateError)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  'Tanggal berakhir harus setelah tanggal mulai',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Visibility Scope
            _buildSectionTitle('Target Warga', required: true),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'all_rt',
                    groupValue: _visibilityScope,
                    onChanged: (value) {
                      setState(() {
                        _visibilityScope = value!;
                        _targetRT = null;
                        _targetRW = null;
                      });
                    },
                    title: Text(
                      'Semua RT/RW',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    value: 'specific_rt',
                    groupValue: _visibilityScope,
                    onChanged: (value) {
                      setState(() {
                        _visibilityScope = value!;
                        _targetRW = null;
                      });
                    },
                    title: Text(
                      'RT Tertentu',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (_visibilityScope == 'specific_rt')
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        decoration: _inputDecoration(
                          hint: 'Nomor RT (contoh: 001)',
                          icon: Icons.location_on_outlined,
                        ),
                        onChanged: (value) => _targetRT = value,
                        validator: _visibilityScope == 'specific_rt'
                            ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nomor RT harus diisi';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings
            _buildSectionTitle('Pengaturan'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _requireKYC,
                    onChanged: (value) => setState(() => _requireKYC = value),
                    title: Text(
                      'Wajib KYC',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Hanya warga dengan KYC approved yang bisa vote',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _isAnonymous,
                    onChanged: (value) => setState(() => _isAnonymous = value),
                    title: Text(
                      'Vote Anonim',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Sembunyikan nama voter (hanya untuk survey)',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Options
            _buildSectionTitle('Pilihan Voting', required: true),
            const SizedBox(height: 4),
            Text(
              'Minimal 2 pilihan, maksimal 10 pilihan',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            ..._buildOptionFields(),

            const SizedBox(height: 12),
            if (_optionControllers.length < 10)
              OutlinedButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  'Tambah Pilihan',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                  foregroundColor: const Color(0xFF3B82F6),
                ),
              ),

            const SizedBox(height: 32),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _validateAndCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Buat Polling Resmi',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool required = false}) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFF9CA3AF),
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    bool error = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: error ? Colors.red : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: error ? Colors.red : const Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: error ? Colors.red : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptionFields() {
    return List.generate(_optionControllers.length, (index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _optionControllers[index],
                    decoration: InputDecoration(
                      hintText: 'Nama pilihan/kandidat',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF9CA3AF),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Pilihan ${index + 1} tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
                if (_optionControllers.length > 2)
                  IconButton(
                    onPressed: () => _removeOption(index),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _optionDescControllers[index],
              decoration: InputDecoration(
                hintText: 'Deskripsi (opsional)',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(left: 44),
              ),
              style: GoogleFonts.poppins(fontSize: 12),
              maxLines: 2,
            ),
          ],
        ),
      );
    });
  }

  void _addOption() {
    if (_optionControllers.length < 10) {
      setState(() {
        _optionControllers.add(TextEditingController());
        _optionDescControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionDescControllers[index].dispose();
        _optionControllers.removeAt(index);
        _optionDescControllers.removeAt(index);
      });
    }
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startDate),
      );

      if (time != null) {
        setState(() {
          _startDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          _dateError = _endDate.isBefore(_startDate);
        });
      }
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endDate),
      );

      if (time != null) {
        setState(() {
          _endDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          _dateError = _endDate.isBefore(_startDate);
        });
      }
    }
  }

  Future<void> _validateAndCreate() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mohon lengkapi semua field yang wajib diisi',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate dates
    if (_endDate.isBefore(_startDate)) {
      setState(() => _dateError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tanggal berakhir harus setelah tanggal mulai',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate options
    final filledOptions = _optionControllers
        .where((c) => c.text.trim().isNotEmpty)
        .length;

    if (filledOptions < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimal harus ada 2 pilihan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _createPoll();
  }

  Future<void> _createPoll() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.userModel == null) return;

    setState(() {
      _isCreating = true;
    });

    final user = authProvider.userModel!;

    // Create poll object
    final poll = Poll(
      pollId: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _pollType,
      pollLevel: 'official',
      createdByRole: 'admin',
      createdBy: user.id,
      createdByName: user.nama,
      createdByPhoto: null,
      createdAt: DateTime.now(),
      startDate: _startDate,
      endDate: _endDate,
      status: 'active',
      visibilityScope: _visibilityScope,
      targetRT: _targetRT,
      targetRW: _targetRW,
      requireKYC: _requireKYC,
      isAnonymous: _isAnonymous,
      showResultsRealtime: true,
      showVoterList: !_isAnonymous,
    );

    // Create options
    final options = <PollOption>[];
    for (var i = 0; i < _optionControllers.length; i++) {
      if (_optionControllers[i].text.trim().isNotEmpty) {
        options.add(PollOption(
          optionId: '',
          pollId: '',
          text: _optionControllers[i].text.trim(),
          description: _optionDescControllers[i].text.trim().isNotEmpty
              ? _optionDescControllers[i].text.trim()
              : null,
          order: i,
          lastUpdated: DateTime.now(),
        ));
      }
    }

    // Submit
    final pollProvider = context.read<PollProvider>();
    final pollId = await pollProvider.createPollWithOptions(
      poll: poll,
      options: options,
    );

    setState(() {
      _isCreating = false;
    });

    if (pollId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Polling resmi berhasil dibuat!',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal membuat polling. Silakan coba lagi.',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

