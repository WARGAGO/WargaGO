import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/features/sekertaris/notulen/widgets/notulen_form_field.dart';
import 'package:wargago/features/sekertaris/notulen/widgets/date_picker_field.dart';
import 'package:wargago/features/sekertaris/notulen/widgets/time_picker_field.dart';
import 'package:wargago/features/sekertaris/notulen/widgets/edit_info_card.dart';
import 'package:wargago/features/sekertaris/notulen/widgets/save_button.dart';
import 'package:wargago/features/sekertaris/notulen/widgets/cancel_button.dart';

/// Halaman untuk mengedit notulen rapat
class EditNotulenPage extends StatefulWidget {
  final String date;
  final String time;
  final String title;
  final String location;
  final int attendees;

  const EditNotulenPage({
    super.key,
    required this.date,
    required this.time,
    required this.title,
    required this.location,
    required this.attendees,
  });

  @override
  State<EditNotulenPage> createState() => _EditNotulenPageState();
}

class _EditNotulenPageState extends State<EditNotulenPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _attendeesController;
  late TextEditingController _agendaController;
  late TextEditingController _discussionController;
  late TextEditingController _decisionsController;
  late TextEditingController _actionItemsController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _locationController = TextEditingController(text: widget.location);
    _attendeesController =
        TextEditingController(text: widget.attendees.toString());

    // Parse date (format: "10 Des 2024")
    final dateParts = widget.date.split(' ');
    final months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'Mei': 5,
      'Jun': 6,
      'Jul': 7,
      'Agu': 8,
      'Sep': 9,
      'Okt': 10,
      'Nov': 11,
      'Des': 12
    };
    _selectedDate = DateTime(
      int.parse(dateParts[2]),
      months[dateParts[1]] ?? 1,
      int.parse(dateParts[0]),
    );

    // Parse time (format: "14:00")
    final timeParts = widget.time.split(':');
    _selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    // Initialize with dummy data for demo
    _agendaController = TextEditingController(
      text: '1. Pembukaan dan sambutan ketua\n'
          '2. Laporan kegiatan bulan lalu\n'
          '3. Pembahasan program kerja baru',
    );
    _discussionController = TextEditingController(
      text:
          'Diskusi mengenai rencana program kerja untuk kuartal pertama 2025...',
    );
    _decisionsController = TextEditingController(
      text: '1. Menyetujui proposal program kerja\n'
          '2. Mengalokasikan anggaran sebesar Rp 15.000.000',
    );
    _actionItemsController = TextEditingController(
      text: 'Finalisasi proposal program kerja oleh Tim Program',
    );
  }

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

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // TODO: Update database

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Perubahan berhasil disimpan',
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
          'Edit Notulen',
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
              const EditInfoCard(),

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
                hint: 'Tuliskan agenda rapat...',
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
                hint: 'Tuliskan keputusan yang diambil...',
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
                      onPressed: _saveChanges,
                      label: 'Simpan Perubahan',
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
