import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jawara/core/providers/keluarga_provider.dart';
import '../widgets/keluarga_expandable_card.dart';

/// List widget untuk menampilkan daftar data keluarga
///
/// Principles:
/// - Uses Provider for state management
/// - Real-time data from Firebase via KeluargaProvider
/// - Clean separation of concerns
class KeluargaList extends StatefulWidget {
  const KeluargaList({super.key});

  @override
  State<KeluargaList> createState() => _KeluargaListState();
}

class _KeluargaListState extends State<KeluargaList> {
  @override
  void initState() {
    super.initState();
    // Fetch data when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KeluargaProvider>().fetchKeluarga();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F7FA), Colors.white],
        ),
      ),
      child: Consumer<KeluargaProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat data',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage,
                    style: GoogleFonts.poppins(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchKeluarga(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (provider.keluargaList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.family_restroom,
                    color: Colors.grey,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data keluarga',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data keluarga akan muncul setelah warga ditambahkan',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Data list
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: provider.keluargaList.length,
              itemBuilder: (context, index) {
                final keluarga = provider.keluargaList[index];
                return KeluargaExpandableCard(
                  namaKepalaKeluarga: keluarga.namaKepalaKeluarga,
                  alamat: keluarga.fullAddress,
                  status: keluarga.status,
                  nomorKK: keluarga.nomorKK,
                  jumlahAnggota: keluarga.jumlahAnggota,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

