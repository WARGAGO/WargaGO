// ============================================================================
// POLL CREATE PAGE
// ============================================================================
// Halaman untuk membuat polling baru (untuk warga - community poll)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wargago/core/providers/poll_provider.dart';
import 'package:wargago/core/providers/auth_provider.dart';
import 'package:wargago/core/models/poll_model.dart';
import 'package:wargago/core/models/poll_option_model.dart';

class PollCreatePage extends StatefulWidget {
  const PollCreatePage({super.key});

  @override
  State<PollCreatePage> createState() => _PollCreatePageState();
}

class _PollCreatePageState extends State<PollCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  String _pollType = 'survey'; // survey, decision, election
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _optionControllers) {
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
          'Buat Polling Komunitas',
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
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Polling komunitas untuk kesepakatan bersama seperti arisan, kerja bakti, dll.',
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
            _buildSectionTitle('Judul Polling'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration(
                hint: 'Contoh: Arisan Bulan Februari',
                icon: Icons.title_rounded,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Description
            _buildSectionTitle('Deskripsi'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: _inputDecoration(
                hint: 'Jelaskan detail polling Anda...',
                icon: Icons.description_rounded,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Deskripsi harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Poll Type
            _buildSectionTitle('Tipe Polling'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonFormField<String>(
                value: _pollType,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'survey',
                    child: Text('Survey', style: GoogleFonts.poppins()),
                  ),
                  DropdownMenuItem(
                    value: 'decision',
                    child: Text('Keputusan', style: GoogleFonts.poppins()),
                  ),
                  DropdownMenuItem(
                    value: 'election',
                    child: Text('Pemilihan', style: GoogleFonts.poppins()),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _pollType = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // End Date
            _buildSectionTitle('Berakhir Pada'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectEndDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Color(0xFF6B7280)),
                    const SizedBox(width: 12),
                    Text(
                      '${_endDate.day}/${_endDate.month}/${_endDate.year} ${_endDate.hour}:${_endDate.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Options
            _buildSectionTitle('Pilihan (Min. 2)'),
            const SizedBox(height: 8),
            ..._buildOptionFields(),

            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Tambah Pilihan',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 32),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createPoll,
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
                        'Buat Polling',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
      ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  List<Widget> _buildOptionFields() {
    return List.generate(_optionControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _optionControllers[index],
                decoration: InputDecoration(
                  hintText: 'Pilihan ${index + 1}',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF9CA3AF),
                  ),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilihan tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ),
            if (_optionControllers.length > 2) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeOption(index),
                icon: const Icon(Icons.delete_rounded, color: Colors.red),
              ),
            ],
          ],
        ),
      );
    });
  }

  void _addOption() {
    if (_optionControllers.length < 10) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
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
        });
      }
    }
  }

  Future<void> _createPoll() async {
    if (!_formKey.currentState!.validate()) return;

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
      pollLevel: 'community',
      createdByRole: 'warga',
      createdBy: user.id,
      createdByName: user.nama,
      createdByPhoto: null, // UserModel doesn't have photo
      createdAt: DateTime.now(),
      startDate: DateTime.now(),
      endDate: _endDate,
      status: 'active',
      visibilityScope: 'all_rt',
      targetRT: null, // Will implement later
      targetRW: null, // Will implement later
      requireKYC: false,
      isAnonymous: false,
      showResultsRealtime: true,
      showVoterList: true,
    );

    // Create options
    final options = _optionControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => PollOption(
              optionId: '',
              pollId: '',
              text: c.text.trim(),
              order: _optionControllers.indexOf(c),
              lastUpdated: DateTime.now(),
            ))
        .toList();

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
            'Polling berhasil dibuat!',
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
            'Gagal membuat polling',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

