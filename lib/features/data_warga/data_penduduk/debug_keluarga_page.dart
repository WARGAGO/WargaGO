import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

/// Debug page untuk melihat struktur data warga di Firebase
/// dan memverifikasi data keluarga
class DebugKeluargaPage extends StatefulWidget {
  const DebugKeluargaPage({super.key});

  @override
  State<DebugKeluargaPage> createState() => _DebugKeluargaPageState();
}

class _DebugKeluargaPageState extends State<DebugKeluargaPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _wargaData = [];
  bool _isLoading = true;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _loadDebugData();
  }

  Future<void> _loadDebugData() async {
    setState(() {
      _isLoading = true;
      _debugInfo = '';
    });

    try {
      final querySnapshot = await _firestore.collection('warga').get();

      final data = querySnapshot.docs.map((doc) {
        final docData = doc.data();
        docData['id'] = doc.id;
        return docData;
      }).toList();

      // Analyze data
      final withKK = data.where((d) =>
        (d['nomorKK']?.toString() ?? '').trim().isNotEmpty &&
        d['nomorKK'] != '-'
      ).toList();

      final withoutKK = data.where((d) =>
        (d['nomorKK']?.toString() ?? '').trim().isEmpty ||
        d['nomorKK'] == '-'
      ).toList();

      // Group by KK
      final Map<String, List<Map<String, dynamic>>> groupedByKK = {};
      for (var warga in withKK) {
        final kk = warga['nomorKK'].toString();
        if (!groupedByKK.containsKey(kk)) {
          groupedByKK[kk] = [];
        }
        groupedByKK[kk]!.add(warga);
      }

      setState(() {
        _wargaData = data;
        _isLoading = false;
        _debugInfo = '''
=== DEBUG INFO ===
Total Warga: ${data.length}
Warga dengan Nomor KK: ${withKK.length}
Warga tanpa Nomor KK: ${withoutKK.length}
Total Keluarga (unique KK): ${groupedByKK.length}

=== KELUARGA ===
${groupedByKK.entries.map((e) => '- KK: ${e.key} (${e.value.length} anggota)').join('\n')}

=== SAMPLE DATA ===
${data.take(3).map((w) => '''
ID: ${w['id']}
Nama: ${w['name']}
NIK: ${w['nik']}
Nomor KK: ${w['nomorKK']}
Peran: ${w['peranKeluarga']}
Status: ${w['statusPenduduk']}
---''').join('\n')}
''';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _debugInfo = 'ERROR: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Debug Keluarga Data',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: SelectableText(
                      _debugInfo,
                      style: GoogleFonts.sourceCodePro(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Data Warga (${_wargaData.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._wargaData.map((warga) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        warga['name']?.toString() ?? 'No Name',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NIK: ${warga['nik']}'),
                          Text(
                            'KK: ${warga['nomorKK'] ?? 'Tidak ada'}',
                            style: TextStyle(
                              color: (warga['nomorKK']?.toString() ?? '').isEmpty
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text('Peran: ${warga['peranKeluarga'] ?? '-'}'),
                          Text('Status: ${warga['statusPenduduk'] ?? '-'}'),
                        ],
                      ),
                      trailing: warga['nomorKK']?.toString().isNotEmpty == true
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.warning, color: Colors.orange),
                    ),
                  )),
                ],
              ),
            ),
    );
  }
}

