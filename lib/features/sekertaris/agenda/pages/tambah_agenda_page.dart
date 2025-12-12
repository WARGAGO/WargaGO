import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/agenda_form_field.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/date_picker_field.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/time_picker_field.dart';

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
      // TODO: Simpan ke database
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Agenda berhasil ditambahkan',
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2F80ED).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF2F80ED),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Isi formulir di bawah untuk menambahkan agenda kegiatan baru',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF2F80ED),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveAgenda,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Simpan Agenda',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tombol Batal
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF2F80ED),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2F80ED),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
