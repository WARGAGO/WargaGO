import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/providers/tagihan_provider.dart';
import '../../../core/providers/jenis_iuran_provider.dart';
import '../../../core/models/tagihan_model.dart';

class AddTagihanPage extends StatefulWidget {
  const AddTagihanPage({Key? key}) : super(key: key);

  @override
  State<AddTagihanPage> createState() => _AddTagihanPageState();
}

class _AddTagihanPageState extends State<AddTagihanPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedJenisIuranId;
  String? _selectedJenisIuranName;
  double _nominal = 0;
  String _periode = '';
  DateTime _periodeTanggal = DateTime.now();

  // Controllers untuk input keluarga
  final TextEditingController _keluargaIdController = TextEditingController();
  final TextEditingController _keluargaNameController = TextEditingController();
  String? _catatan;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔵 Loading jenis iuran list...');
      context.read<JenisIuranProvider>().fetchAllJenisIuran();
    });
  }

  @override
  void dispose() {
    _keluargaIdController.dispose();
    _keluargaNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tagihan'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Jenis Iuran Dropdown
            Consumer<JenisIuranProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.allJenisIuranList.isEmpty) {
                  return Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.warning, color: Colors.orange[700], size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada jenis iuran',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Silakan tambahkan jenis iuran terlebih dahulu',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  initialValue: _selectedJenisIuranId,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Iuran',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: provider.allJenisIuranList.map((ji) {
                    return DropdownMenuItem(
                      value: ji.id,
                      child: Text(ji.namaIuran),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final selected = provider.allJenisIuranList.firstWhere((ji) => ji.id == value);
                    setState(() {
                      _selectedJenisIuranId = value;
                      _selectedJenisIuranName = selected.namaIuran;
                      _nominal = selected.jumlahIuran;
                    });
                    print('✅ Selected jenis iuran: $_selectedJenisIuranName (Rp $_nominal)');
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih jenis iuran';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Nominal (Auto-filled dari jenis iuran)
            TextFormField(
              key: ValueKey(_nominal),
              initialValue: _nominal == 0 ? '' : _nominal.toStringAsFixed(0),
              decoration: const InputDecoration(
                labelText: 'Nominal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              readOnly: true,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            // Periode
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Periode (contoh: November 2025)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_month),
              ),
              onChanged: (value) {
                setState(() {
                  _periode = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan periode';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tanggal Jatuh Tempo
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _periodeTanggal,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() {
                    _periodeTanggal = date;
                  });
                  print('✅ Selected date: $_periodeTanggal');
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal Jatuh Tempo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
                child: Text(
                  '${_periodeTanggal.day}/${_periodeTanggal.month}/${_periodeTanggal.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Keluarga ID
            TextFormField(
              controller: _keluargaIdController,
              decoration: const InputDecoration(
                labelText: 'ID Keluarga',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.family_restroom),
                hintText: 'Contoh: kel_001',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan ID keluarga';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Keluarga Name
            TextFormField(
              controller: _keluargaNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Keluarga',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                hintText: 'Contoh: Keluarga Budi',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan nama keluarga';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Catatan (Optional)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
              onChanged: (value) {
                _catatan = value.isEmpty ? null : value;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _selectedJenisIuranId != null
                    ? () => _createTagihan()
                    : null,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Buat Tagihan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // TEST BUTTON - Direct Firestore Write (DEBUGGING)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _testDirectFirestore(),
                icon: const Icon(Icons.bug_report),
                label: const Text(
                  'TEST: Direct Firestore Write',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _createTagihan() async {
    print('\n🔵 ========== START CREATE TAGIHAN ==========');

    // Validate form
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Mohon lengkapi semua field yang wajib diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('✅ Form validation passed');

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      print('\n🔵 Step 1: Preparing data...');
      print('   - Jenis Iuran ID: $_selectedJenisIuranId');
      print('   - Jenis Iuran Name: $_selectedJenisIuranName');
      print('   - Keluarga ID: ${_keluargaIdController.text.trim()}');
      print('   - Keluarga Name: ${_keluargaNameController.text.trim()}');
      print('   - Nominal: $_nominal');
      print('   - Periode: $_periode');
      print('   - Periode Tanggal: $_periodeTanggal');
      print('   - Catatan: $_catatan');

      // Create TagihanModel
      final tagihan = TagihanModel(
        id: '', // Will be generated by Firestore
        kodeTagihan: '', // Will be auto-generated by service
        jenisIuranId: _selectedJenisIuranId!,
        jenisIuranName: _selectedJenisIuranName!,
        keluargaId: _keluargaIdController.text.trim(),
        keluargaName: _keluargaNameController.text.trim(),
        nominal: _nominal,
        periode: _periode,
        periodeTanggal: _periodeTanggal,
        status: 'Belum Dibayar',
        createdBy: 'admin@example.com',
        catatan: _catatan,
        isActive: true,
      );

      print('✅ TagihanModel created');
      print('\n🔵 Step 2: Converting to Map...');

      final dataMap = tagihan.toMap();
      print('✅ Data Map created:');
      dataMap.forEach((key, value) {
        print('   $key: $value');
      });

      print('\n🔵 Step 3: Calling TagihanProvider.createTagihan()...');

      // Create tagihan via provider
      final success = await context.read<TagihanProvider>().createTagihan(tagihan);

      print('\n🔵 Step 4: Provider returned: $success');

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
        print('✅ Loading dialog closed');
      }

      if (success && mounted) {
        print('\n✅ ========== SUCCESS! ==========');
        print('✅ Tagihan berhasil dibuat dan tersimpan ke Firestore!');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tagihan berhasil dibuat!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Close form page
        Navigator.pop(context);
        print('✅ Form closed, returning to list\n');
      } else if (mounted) {
        print('\n❌ ========== FAILED! ==========');
        // Show error message
        final error = context.read<TagihanProvider>().error ?? 'Unknown error';
        print('❌ Error from provider: $error\n');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('\n❌ ========== EXCEPTION! ==========');
      print('❌ Exception: $e');
      print('❌ StackTrace:\n$stackTrace\n');

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// TEST METHOD - Direct Firestore Write (Bypass all layers)
  Future<void> _testDirectFirestore() async {
    print('\n🔥 ===== TEST: DIRECT FIRESTORE WRITE =====');

    try {
      final firestore = FirebaseFirestore.instance;

      // Very simple test data - NO VALIDATION
      final testData = {
        'kodeTagihan': 'TEST_${DateTime.now().millisecondsSinceEpoch}',
        'jenisIuranId': 'test_iuran_id',
        'jenisIuranName': 'Test Iuran',
        'keluargaId': 'test_kel_001',
        'keluargaName': 'Test Keluarga',
        'nominal': 50000,
        'periode': 'November 2025',
        'periodeTanggal': Timestamp.fromDate(DateTime(2025, 11, 30)),
        'status': 'Belum Dibayar',
        'createdBy': 'test@test.com',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('📤 Writing directly to Firestore...');
      print('📊 Collection: tagihan');

      // DIRECT WRITE
      final docRef = await firestore.collection('tagihan').add(testData);

      print('✅ SUCCESS! Document created!');
      print('✅ Document ID: ${docRef.id}');

      // Show success to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ TEST SUCCESS! Doc ID: ${docRef.id}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      print('🔥 ===== TEST COMPLETED =====\n');

    } catch (e, stackTrace) {
      print('❌ ===== TEST FAILED =====');
      print('❌ Error: $e');
      print('❌ StackTrace:\n$stackTrace\n');

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ERROR: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

