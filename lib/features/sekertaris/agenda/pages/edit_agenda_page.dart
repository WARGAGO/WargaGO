import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/agenda_form_field.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/date_picker_field.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/time_picker_field.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/edit_info_card.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/save_button.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/cancel_button.dart';

import '../models/agenda_model.dart';

/// Halaman untuk mengedit agenda kegiatan
class EditAgendaPage extends StatefulWidget {
  final String id;
  final String date;
  final String time;
  final String title;
  final String location;
  final String description;
  final String status;
  final int attendees;

  const EditAgendaPage({
    super.key,
    required this.id,
    required this.date,
    required this.time,
    required this.title,
    required this.location,
    required this.description,
    required this.status,
    required this.attendees,
  });

  @override
  State<EditAgendaPage> createState() => _EditAgendaPageState();
}

class _EditAgendaPageState extends State<EditAgendaPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _attendeesController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _locationController = TextEditingController(text: widget.location);
    _descriptionController = TextEditingController(text: widget.description);
    _attendeesController = TextEditingController(text: widget.attendees.toString());

    // Parse existing date and time
    try {
      _selectedDate = DateFormat('dd MMM yyyy', 'id_ID').parse(widget.date);
    } catch (e) {
      _selectedDate = DateTime.now();
    }

    try {
      final timeParts = widget.time.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    } catch (e) {
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _attendeesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026, 12, 31),
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
      // Buat objek AgendaModel yang sudah diedit
      final updatedAgenda = AgendaModel(
        id: widget.id, // Gunakan ID asli dari widget
        date: DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDate),
        time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        title: _titleController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        status: widget.status, // Pertahankan status yang ada
        attendees: int.parse(_attendeesController.text),
      );
      
      // Kembalikan data yang sudah diedit ke parent
      Navigator.pop(context, updatedAgenda);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Edit Agenda',
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

              // Judul Kegiatan
              AgendaFormField(
                controller: _titleController,
                label: 'Judul Kegiatan',
                hint: 'Masukkan judul kegiatan',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul kegiatan harus diisi';
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
              AgendaFormField(
                controller: _locationController,
                label: 'Lokasi',
                hint: 'Masukkan lokasi kegiatan',
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
              AgendaFormField(
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
                    return 'Jumlah peserta harus berupa angka';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Deskripsi
              AgendaFormField(
                controller: _descriptionController,
                label: 'Deskripsi',
                hint: 'Masukkan deskripsi kegiatan',
                icon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi harus diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Tombol Simpan
              SaveButton(
                onPressed: _saveChanges,
                label: 'Simpan Perubahan',
              ),

              const SizedBox(height: 16),

              // Tombol Batal
              CancelButton(
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
