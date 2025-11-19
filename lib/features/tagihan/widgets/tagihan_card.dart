import 'package:flutter/material.dart';
import '../../../core/models/tagihan_model.dart';

class TagihanCard extends StatelessWidget {
  final TagihanModel tagihan;
  final VoidCallback onTap;
  final VoidCallback? onMarkAsPaid;
  final VoidCallback? onDelete;

  const TagihanCard({
    Key? key,
    required this.tagihan,
    required this.onTap,
    this.onMarkAsPaid,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Kode & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tagihan.kodeTagihan,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 12),

              // Jenis Iuran
              Row(
                children: [
                  const Icon(Icons.category, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tagihan.jenisIuranName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Keluarga
              Row(
                children: [
                  const Icon(Icons.family_restroom, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tagihan.keluargaName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Periode
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    tagihan.periode,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: tagihan.isOverdue ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tagihan.formattedPeriodeTanggal,
                    style: TextStyle(
                      fontSize: 14,
                      color: tagihan.isOverdue ? Colors.red : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Nominal & Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tagihan.formattedNominal,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  Row(
                    children: [
                      if (tagihan.status != 'Lunas' && onMarkAsPaid != null)
                        IconButton(
                          icon: const Icon(Icons.payment, color: Colors.blue),
                          onPressed: onMarkAsPaid,
                          tooltip: 'Tandai Lunas',
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: onDelete,
                          tooltip: 'Hapus',
                        ),
                    ],
                  ),
                ],
              ),

              // Warning jika terlambat
              if (tagihan.isOverdue && tagihan.status != 'Lunas')
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, size: 16, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Terlambat ${-tagihan.daysUntilDue} hari',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tagihan.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tagihan.statusColor),
      ),
      child: Text(
        tagihan.status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: tagihan.statusColor,
        ),
      ),
    );
  }
}

