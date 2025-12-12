import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/features/sekertaris/notulen/widgets/notulen_form_field.dart';
import 'package:wargago/features/sekertaris/notulen/widgets/date_picker_field.dart';
import 'package:wargago/features/sekertaris/notulen/widgets/time_picker_field.dart';
import 'package:wargago/features/sekertaris/notulen/widgets/add_info_card.dart';
import 'package:wargago/features/sekertaris/notulen/widgets/save_button.dart';
import 'package:wargago/features/sekertaris/notulen/widgets/cancel_button.dart';

/// Halaman untuk menambahkan notulen rapat baru
class TambahNotulenPage extends StatefulWidget {
  const TambahNotulenPage({super.key});

  @override
  State<TambahNotulenPage> createState() => _TambahNotulenPageState();
}

class _TambahNotulenPageState extends State<TambahNotulenPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _attendeesController = TextEditingController();
  final _agendaController = TextEditingController();
  final _discussionController = TextEditingController();
  final _decisionsController = TextEditingController();
  final _actionItemsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _attendeesController.dispose();
    _agendaController.dispose();
    _discussionController.dispose();
    _decisionsController.dispose();
    _actionItemsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2F80ED),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2F80ED),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveNotulen() {
    if (_formKey.currentState!.validate()) {
      // TODO: Simpan ke database

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Notulen berhasil ditambahkan',
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF27AE60),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Kembali ke halaman sebelumnya
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Tambah Notulen',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2F80ED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              const AddInfoCard(),

              const SizedBox(height: 24),

              // Judul Rapat
              NotulenFormField(
                controller: _titleController,
                label: 'Judul Rapat',
                hint: 'Masukkan judul rapat',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul rapat harus diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Tanggal dan Waktu
              Row(
                children: [
                  Expanded(
                    child: DatePickerField(
                      label: 'Tanggal',
                      selectedDate: _selectedDate,
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TimePickerField(
                      label: 'Waktu',
                      selectedTime: _selectedTime,
                      onTap: () => _selectTime(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Lokasi
              NotulenFormField(
                controller: _locationController,
                label: 'Lokasi',
                hint: 'Masukkan lokasi rapat',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lokasi harus diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Jumlah Peserta
              NotulenFormField(
                controller: _attendeesController,
                label: 'Jumlah Peserta',
                hint: 'Masukkan jumlah peserta',
                icon: Icons.people,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah peserta harus diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Divider dengan label
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey.shade300),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Isi Notulen',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey.shade300),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Agenda Rapat
              NotulenFormField(
                controller: _agendaController,
                label: 'Agenda Rapat',
                hint: 'Tuliskan agenda rapat...\nContoh:\n1. Pembukaan\n2. Laporan kegiatan\n3. Pembahasan program',
                icon: Icons.list_alt,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Agenda rapat harus diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Pembahasan
              NotulenFormField(
                controller: _discussionController,
                label: 'Pembahasan',
                hint: 'Tuliskan rangkuman pembahasan dalam rapat...',
                icon: Icons.topic,
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pembahasan harus diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Keputusan
              NotulenFormField(
                controller: _decisionsController,
                label: 'Keputusan Rapat',
                hint: 'Tuliskan keputusan yang diambil...\nContoh:\n1. Menyetujui proposal\n2. Mengalokasikan anggaran',
                icon: Icons.check_circle_outline,
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Keputusan harus diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Tindak Lanjut
              NotulenFormField(
                controller: _actionItemsController,
                label: 'Tindak Lanjut',
                hint: 'Tuliskan tindak lanjut yang harus dilakukan...',
                icon: Icons.task_alt,
                maxLines: 6,
                isRequired: false,
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CancelButton(
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SaveButton(
                      onPressed: _saveNotulen,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
