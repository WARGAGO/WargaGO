import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ⭐ ADDED for user authentication
import 'package:wargago/core/providers/tagihan_provider.dart';
import 'package:wargago/core/models/tagihan_model.dart';
import '../widgets/tagihan_card.dart';
import '../widgets/tagihan_filter_bar.dart';
import '../widgets/tagihan_statistics_card.dart';
import 'add_tagihan_page.dart';
import 'tagihan_detail_page.dart';

class TagihanPage extends StatefulWidget {
  const TagihanPage({Key? key}) : super(key: key);

  @override
  State<TagihanPage> createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TagihanProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Manajemen Tagihan'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TagihanProvider>().loadTagihan();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<TagihanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadTagihan(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              provider.loadTagihan();
              provider.loadStatistics();
            },
            child: CustomScrollView(
              slivers: [
                // Statistics Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TagihanStatisticsCard(
                      statistics: provider.statistics,
                    ),
                  ),
                ),

                // Filter Bar
                SliverToBoxAdapter(
                  child: TagihanFilterBar(
                    selectedStatus: provider.selectedStatus,
                    onStatusChanged: (status) {
                      if (status == 'Semua') {
                        provider.resetFilters();
                      } else {
                        provider.loadTagihanByStatus(status);
                      }
                    },
                    onFilterPressed: () => _showFilterDialog(context),
                  ),
                ),

                // Tagihan List
                provider.tagihan.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada tagihan',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tekan tombol + untuk menambah tagihan',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final tagihan = provider.tagihan[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TagihanCard(
                                  tagihan: tagihan,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TagihanDetailPage(tagihan: tagihan),
                                      ),
                                    );
                                  },
                                  onMarkAsPaid: () {
                                    _showPaymentDialog(context, tagihan);
                                  },
                                  onDelete: () {
                                    _showDeleteConfirmation(context, tagihan);
                                  },
                                ),
                              );
                            },
                            childCount: provider.tagihan.length,
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTagihanPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tagihan'),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Tagihan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.all_inclusive),
                title: const Text('Semua Tagihan'),
                onTap: () {
                  context.read<TagihanProvider>().resetFilters();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.pending_actions, color: Colors.red[700]),
                title: const Text('Belum Dibayar'),
                onTap: () {
                  context.read<TagihanProvider>().loadTagihanByStatus('Belum Dibayar');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green[700]),
                title: const Text('Lunas'),
                onTap: () {
                  context.read<TagihanProvider>().loadTagihanByStatus('Lunas');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.warning, color: Colors.orange[700]),
                title: const Text('Terlambat'),
                onTap: () {
                  context.read<TagihanProvider>().loadTagihanByStatus('Terlambat');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.schedule, color: Colors.blue[700]),
                title: const Text('Jatuh Tempo'),
                onTap: () {
                  context.read<TagihanProvider>().loadTagihanJatuhTempo();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentDialog(BuildContext context, TagihanModel tagihan) {
    String metodePembayaran = 'Cash';
    String? catatan;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pembayaran'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tagihan: ${tagihan.kodeTagihan}'),
                  Text('Nominal: ${tagihan.formattedNominal}'),
                  const SizedBox(height: 16),
                  const Text('Metode Pembayaran:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: metodePembayaran,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: ['Cash', 'Transfer', 'E-Wallet']
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        metodePembayaran = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Catatan (Opsional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      catatan = value.isEmpty ? null : value;
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                // ⭐ Get current user ID
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error: User tidak terautentikasi'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                final success = await context.read<TagihanProvider>().markAsLunas(
                      tagihan.id,
                      metodePembayaran: metodePembayaran,
                      userId: currentUser.uid, // ⭐ ADDED: Pass current user ID
                      catatan: catatan,
                    );
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tagihan berhasil dibayar'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, TagihanModel tagihan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Tagihan?'),
          content: Text(
            'Apakah Anda yakin ingin menghapus tagihan ${tagihan.kodeTagihan}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success =
                    await context.read<TagihanProvider>().deleteTagihan(tagihan.id);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tagihan berhasil dihapus'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}

