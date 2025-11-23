// ============================================================================
// KYC VERIFICATION PAGE - Admin
// ============================================================================
// Halaman untuk admin melihat, approve, atau reject KYC documents dari warga
// ============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jawara/core/models/kyc_document_model.dart';
import 'package:jawara/core/services/kyc_service.dart';
import 'package:jawara/features/admin/core_widgets/kyc_document_preview.dart';
import 'package:intl/intl.dart';
import 'ocr_test_page.dart';

class KYCVerificationPage extends StatefulWidget {
  const KYCVerificationPage({super.key});

  @override
  State<KYCVerificationPage> createState() => _KYCVerificationPageState();
}

class _KYCVerificationPageState extends State<KYCVerificationPage> {
  final KYCService _kycService = KYCService();
  String _selectedStatus = 'all'; // all, pending, approved, rejected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi KYC'),
        actions: [
          // Test OCR Button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OCRTestPage()),
              );
            },
            icon: const Icon(Icons.document_scanner),
            tooltip: 'Test OCR',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Semua')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'approved', child: Text('Approved')),
              const PopupMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getKYCStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada dokumen KYC',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              final data = doc.data() as Map<String, dynamic>;
              final kycDoc = KYCDocumentModel.fromMap(data, doc.id);

              return _buildKYCCard(kycDoc, doc.id);
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getKYCStream() {
    Query query = FirebaseFirestore.instance
        .collection('kyc_documents')
        .orderBy('uploadedAt', descending: true);

    if (_selectedStatus != 'all') {
      query = query.where('status', isEqualTo: _selectedStatus);
    }

    return query.snapshots();
  }

  Widget _buildKYCCard(KYCDocumentModel kycDoc, String docId) {
    Color statusColor;
    IconData statusIcon;

    switch (kycDoc.status) {
      case KYCStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case KYCStatus.approved:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case KYCStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              border: Border(
                left: BorderSide(color: statusColor, width: 4),
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDocumentTypeName(kycDoc.documentType),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'User ID: ${kycDoc.userId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    kycDoc.status.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Document Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.access_time,
                  'Uploaded',
                  DateFormat('dd MMM yyyy, HH:mm').format(kycDoc.uploadedAt),
                ),
                if (kycDoc.verifiedAt != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.verified,
                    'Verified',
                    DateFormat('dd MMM yyyy, HH:mm').format(kycDoc.verifiedAt!),
                  ),
                ],
                if (kycDoc.verifiedBy != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.person,
                    'Verified By',
                    kycDoc.verifiedBy!,
                  ),
                ],
                if (kycDoc.rejectionReason != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.info_outline,
                    'Alasan Ditolak',
                    kycDoc.rejectionReason!,
                    isError: true,
                  ),
                ],
              ],
            ),
          ),

          // Document Preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: KYCDocumentPreview(
              document: kycDoc,
              height: 200,
              onTap: () async {
                // Get fresh URL untuk view
                final url = await _kycService.getDocumentUrl(kycDoc.id!);
                if (url != null) {
                  _viewDocument(url);
                }
              },
            ),
          ),

          // Action Buttons (only for pending status)
          if (kycDoc.status == KYCStatus.pending) ...[
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectDocument(docId, kycDoc),
                      icon: const Icon(Icons.close),
                      label: const Text('Tolak'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveDocument(docId),
                      icon: const Icon(Icons.check),
                      label: const Text('Setujui'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isError = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: isError ? Colors.red : Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isError ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDocumentTypeName(KYCDocumentType type) {
    switch (type) {
      case KYCDocumentType.ktp:
        return 'KTP (Kartu Tanda Penduduk)';
      case KYCDocumentType.kk:
        return 'KK (Kartu Keluarga)';
      case KYCDocumentType.akteKelahiran:
        return 'Akte Kelahiran';
    }
  }

  void _viewDocument(String url) {
    // TODO: Implement document viewer (full screen)
    // Bisa pakai package seperti photo_view atau url_launcher
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Document Preview'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: url.toLowerCase().endsWith('.pdf')
                  ? const Center(child: Text('PDF Viewer - Coming Soon'))
                  : Image.network(url),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveDocument(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Dokumen'),
        content: const Text('Apakah Anda yakin ingin menyetujui dokumen KYC ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // TODO: Get actual admin ID from current user
      final adminId = 'admin123'; // Replace with actual admin ID

      await _kycService.approveDocument(
        documentId: docId,
        adminId: adminId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Dokumen berhasil disetujui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectDocument(String docId, KYCDocumentModel kycDoc) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Dokumen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Berikan alasan penolakan:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Contoh: Foto tidak jelas, dokumen tidak valid, dll',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan penolakan harus diisi'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // TODO: Get actual admin ID from current user
      final adminId = 'admin123'; // Replace with actual admin ID

      await _kycService.rejectDocument(
        documentId: docId,
        adminId: adminId,
        reason: reasonController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Dokumen berhasil ditolak'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

