import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jawara/core/providers/warga_provider.dart';
import 'package:jawara/core/services/warga_service.dart';

/// Debug Widget untuk memverifikasi bahwa data warga benar-benar dari Firebase
///
/// Menampilkan:
/// - Total data di Firebase vs Provider
/// - Detail setiap warga
/// - Waktu load
/// - Status koneksi
class DebugWargaDataWidget extends StatefulWidget {
  const DebugWargaDataWidget({super.key});

  @override
  State<DebugWargaDataWidget> createState() => _DebugWargaDataWidgetState();
}

class _DebugWargaDataWidgetState extends State<DebugWargaDataWidget> {
  final WargaService _service = WargaService();
  String _debugInfo = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() => _isLoading = true);

    final startTime = DateTime.now();

    try {
      // Direct call to service
      final directData = await _service.getAllWarga();

      final endTime = DateTime.now();
      final loadDuration = endTime.difference(startTime);

      setState(() {
        _debugInfo = '''
=== DEBUG WARGA DATA ===
⏱️ Load Time: ${loadDuration.inMilliseconds}ms

📊 Data dari Firebase (Direct Service Call):
   Total: ${directData.length} warga

${directData.isEmpty ? '⚠️ TIDAK ADA DATA DI FIREBASE!' : '''
📋 Sample Data (3 pertama):
${directData.take(3).map((w) => '''
   - ${w.name}
     NIK: ${w.nik}
     Gender: ${w.jenisKelamin}
     Status: ${w.statusPenduduk}
''').join('\n')}
'''}

✅ KESIMPULAN: ${directData.isEmpty ? 'Data KOSONG' : 'Data DINAMIS dari Firebase'}
''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo = '''
❌ ERROR: $e

Kemungkinan penyebab:
1. Tidak ada koneksi ke Firebase
2. Firebase belum diinisialisasi
3. Collection 'warga' tidak ada
''';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bug_report, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debug Mode',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      'Verifikasi Data Firebase',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadDebugInfo,
                tooltip: 'Reload',
              ),
            ],
          ),
          const Divider(height: 24),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _debugInfo,
                style: GoogleFonts.sourceCodePro(
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          const SizedBox(height: 16),
          _buildProviderInfo(),
        ],
      ),
    );
  }

  Widget _buildProviderInfo() {
    return Consumer<WargaProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📦 Provider State:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '''Total di Provider: ${provider.allWargaList.length}
Filtered: ${provider.wargaList.length}
Loading: ${provider.isLoading}
Error: ${provider.errorMessage ?? 'None'}

✅ Provider Status: ${provider.allWargaList.isEmpty ? 'KOSONG' : 'ADA DATA'}''',
                style: GoogleFonts.sourceCodePro(fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}

