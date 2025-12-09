// ============================================================================
// MASTER JENIS IURAN PAGE
// ============================================================================
// Manage jenis-jenis iuran (CRUD operations)
// Moved from Kelola Pemasukan to dedicated Kelola Iuran menu
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/jenis_iuran_provider.dart';
import '../../../../core/models/jenis_iuran_model.dart';
import 'add_jenis_iuran_page.dart';

class MasterJenisIuranPage extends StatefulWidget {
  const MasterJenisIuranPage({super.key});

  @override
  State<MasterJenisIuranPage> createState() => _MasterJenisIuranPageState();
}

class _MasterJenisIuranPageState extends State<MasterJenisIuranPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JenisIuranProvider>().fetchAllJenisIuran();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Master Jenis Iuran',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2988EA),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<JenisIuranProvider>().fetchAllJenisIuran();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddJenisIuranPage()),
          );
        },
        backgroundColor: const Color(0xFF2988EA),
        icon: const Icon(Icons.add),
        label: Text(
          'Tambah Jenis',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<JenisIuranProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchAllJenisIuran(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (provider.jenisIuranList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada jenis iuran',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Klik tombol + untuk menambah',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchAllJenisIuran(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.jenisIuranList.length,
              itemBuilder: (context, index) {
                final jenisIuran = provider.jenisIuranList[index];
                return _buildJenisIuranCard(jenisIuran);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildJenisIuranCard(JenisIuranModel jenisIuran) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetailDialog(jenisIuran),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2988EA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.category,
                      color: Color(0xFF2988EA),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jenisIuran.namaIuran,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Kategori: ${_formatKategori(jenisIuran.kategoriIuran)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editJenisIuran(jenisIuran);
                      } else if (value == 'delete') {
                        _deleteJenisIuran(jenisIuran);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  _buildInfoChip(
                    'Nominal',
                    'Rp ${_formatNumber(jenisIuran.jumlahIuran)}',
                    Icons.payments,
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    'Kategori',
                    _formatKategori(jenisIuran.kategoriIuran),
                    Icons.category_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2988EA).withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF2988EA)),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(JenisIuranModel jenisIuran) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          jenisIuran.namaIuran,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nominal:', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            Text('Rp ${_formatNumber(jenisIuran.jumlahIuran)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text('Kategori:', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            Text(_formatKategori(jenisIuran.kategoriIuran), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editJenisIuran(jenisIuran);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _editJenisIuran(JenisIuranModel jenisIuran) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddJenisIuranPage(jenisIuran: jenisIuran),
      ),
    );
  }

  void _deleteJenisIuran(JenisIuranModel jenisIuran) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Jenis Iuran?', style: GoogleFonts.poppins()),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${jenisIuran.namaIuran}"?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<JenisIuranProvider>();
              final success = await provider.deleteJenisIuran(jenisIuran.id);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Jenis iuran berhasil dihapus' : 'Gagal menghapus jenis iuran',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatKategori(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'bulanan':
        return 'Bulanan';
      case 'khusus':
        return 'Khusus';
      default:
        return kategori;
    }
  }
}

