import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jawara/core/providers/warga_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/warga_expandable_card.dart';
import '../widgets/debug_warga_data_widget.dart';

/// List widget untuk menampilkan daftar data warga
///
/// Principles:
/// - Connected to WargaProvider for real data
/// - Handles loading, error, and empty states
/// - Uses reusable WargaExpandableCard
class DataWargaList extends StatefulWidget {
  const DataWargaList({super.key});

  @override
  State<DataWargaList> createState() => _DataWargaListState();
}

class _DataWargaListState extends State<DataWargaList> {
  @override
  void initState() {
    super.initState();
    // Load data saat pertama kali
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WargaProvider>().loadWarga();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WargaProvider>(
      builder: (context, provider, child) {
        // Loading state
        if (provider.isLoading && provider.wargaList.isEmpty) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF5F7FA), Colors.white],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Error state
        if (provider.errorMessage != null) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF5F7FA), Colors.white],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.errorMessage}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadWarga(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (provider.wargaList.isEmpty) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF5F7FA), Colors.white],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data warga',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan warga dengan tombol + di bawah',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Data list
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5F7FA), Colors.white],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () => provider.loadWarga(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Debug Widget (optional - can be removed in production)
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Info banner showing data is dynamic
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cloud_done_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Data Dinamis dari Firebase',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${provider.wargaList.length} warga tersinkronisasi',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Uncomment untuk debug mode
                      // const DebugWargaDataWidget(),
                    ],
                  ),
                ),
                // List data warga
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final warga = provider.wargaList[index];
                        return WargaExpandableCard(warga: warga);
                      },
                      childCount: provider.wargaList.length,
                    ),
                  ),
                ),
                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

