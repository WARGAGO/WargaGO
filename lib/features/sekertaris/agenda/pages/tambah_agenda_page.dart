import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/agenda_form_field.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/date_picker_field.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/time_picker_field.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/add_info_card.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/save_button.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/cancel_button.dart';
import 'package:wargago/features/sekertaris/agenda/models/agenda_model.dart';
import 'package:intl/intl.dart';

/// Halaman untuk menambahkan agenda kegiatan baru
class TambahAgendaPage extends StatefulWidget {
  const TambahAgendaPage({super.key});

  @override
  State<TambahAgendaPage> createState() => _TambahAgendaPageState();
}

class _TambahAgendaPageState extends State<TambahAgendaPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _attendeesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

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

  void _saveAgenda() {
    if (_formKey.currentState!.validate()) {
      // Buat objek AgendaModel baru
      final newAgenda = AgendaModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate ID unik
        date: DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDate),
        time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        title: _titleController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        status: 'upcoming', // Default status
        attendees: int.parse(_attendeesController.text),
      );
      
      // Kembalikan data ke halaman sebelumnya
      Navigator.pop(context, newAgenda);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Tambah Agenda',
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
                onPressed: _saveAgenda,
                label: 'Simpan Agenda',
                icon: Icons.save,
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
