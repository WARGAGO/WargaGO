import 'package:flutter/material.dart';
import '../../../core/models/tagihan_model.dart';

class TagihanDetailPage extends StatelessWidget {
  final TagihanModel tagihan;

  const TagihanDetailPage({
    Key? key,
    required this.tagihan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tagihan'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          Card(
            color: tagihan.statusColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(),
                    size: 64,
                    color: tagihan.statusColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tagihan.status,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: tagihan.statusColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tagihan.formattedNominal,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Detail Information
          _buildInfoCard(
            'Informasi Tagihan',
            [
              _buildInfoRow('Kode Tagihan', tagihan.kodeTagihan),
              _buildInfoRow('Jenis Iuran', tagihan.jenisIuranName),
              _buildInfoRow('Keluarga', tagihan.keluargaName),
              _buildInfoRow('Periode', tagihan.periode),
              _buildInfoRow('Jatuh Tempo', tagihan.formattedPeriodeTanggal),
            ],
          ),
          const SizedBox(height: 16),

          // Payment Information (if paid)
          if (tagihan.status == 'Lunas') ...[
            _buildInfoCard(
              'Informasi Pembayaran',
              [
                if (tagihan.metodePembayaran != null)
                  _buildInfoRow('Metode Pembayaran', tagihan.metodePembayaran!),
                if (tagihan.tanggalBayar != null)
                  _buildInfoRow(
                    'Tanggal Bayar',
                    '${tagihan.tanggalBayar!.day}/${tagihan.tanggalBayar!.month}/${tagihan.tanggalBayar!.year}',
                  ),
                if (tagihan.catatan != null)
                  _buildInfoRow('Catatan', tagihan.catatan!),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Warning if overdue
          if (tagihan.isOverdue && tagihan.status != 'Lunas')
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700], size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tagihan Terlambat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sudah terlambat ${-tagihan.daysUntilDue} hari dari tanggal jatuh tempo',
                            style: TextStyle(
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (tagihan.status) {
      case 'Lunas':
        return Icons.check_circle;
      case 'Belum Dibayar':
        return Icons.pending;
      case 'Terlambat':
        return Icons.warning;
      default:
        return Icons.receipt;
    }
  }
}

