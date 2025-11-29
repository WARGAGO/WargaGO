// ============================================================================
// ADMIN KYC APPROVAL PAGE (BONUS EXAMPLE)
// ============================================================================
// Halaman untuk admin melihat dan approve/reject dokumen KYC
// TODO: Tambahkan ke admin dashboard menu
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jawara/core/models/KYC/kyc_document_model.dart';
import 'package:jawara/core/services/kyc_service.dart';
import 'package:jawara/features/admin/core_widgets/kyc_document_preview.dart';

class AdminKYCApprovalPage extends StatefulWidget {
  const AdminKYCApprovalPage({super.key});

  @override
  State<AdminKYCApprovalPage> createState() => _AdminKYCApprovalPageState();
}

class _AdminKYCApprovalPageState extends State<AdminKYCApprovalPage> {
  final KYCService _kycService = KYCService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _kycService.initializationDone,
      builder: (context, snapshot) =>
          (snapshot.connectionState == ConnectionState.waiting)
          ? const CircularProgressIndicator()
          : Scaffold(
              appBar: AppBar(
                title: Text(
                  'Verifikasi KYC',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                backgroundColor: const Color(0xFF2E7D32),
              ),
              body: StreamBuilder<List<KYCDocumentModel>>(
                stream: _kycService.streamPendingDocuments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final documents = snapshot.data ?? [];

                  if (documents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 100,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada dokumen pending',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Group documents by user
                  final Map<String, List<KYCDocumentModel>> groupedDocs = {};
                  for (var doc in documents) {
                    if (!groupedDocs.containsKey(doc.userId)) {
                      groupedDocs[doc.userId] = [];
                    }
                    groupedDocs[doc.userId]!.add(doc);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: groupedDocs.length,
                    itemBuilder: (context, index) {
                      final userId = groupedDocs.keys.elementAt(index);
                      final userDocs = groupedDocs[userId]!;

                      return _buildUserKYCCard(userId, userDocs);
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildUserKYCCard(String userId, List<KYCDocumentModel> documents) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF2E7D32),
                  child: Text(
                    userId.substring(0, 2).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User ID: ${userId.substring(0, 8)}...',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${documents.length} dokumen pending',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Documents
            ...documents.map((doc) => _buildDocumentItem(doc)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(KYCDocumentModel document) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Type
          Row(
            children: [
              Icon(Icons.description, size: 20, color: const Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              Text(
                document.documentTypeName,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(document.uploadedAt),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Document Image Preview
          KYCDocumentPreview(
            document: document,
            height: 200,
            onTap: () async {
              // Get fresh URL untuk preview
              final url = await _kycService.getDocumentUrl(document.id!);
              if (url != null && mounted) {
                _showImagePreview(context, url);
              }
            },
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rejectDocument(document),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Tolak'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveDocument(document),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Setujui'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Preview Dokumen'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Expanded(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.error, size: 64)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveDocument(KYCDocumentModel document) async {
    try {
      // TODO: Get admin ID from auth
      const adminId = 'current_admin_id';

      await _kycService.approveDocument(
        documentId: document.id!,
        adminId: adminId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dokumen ${document.documentTypeName} disetujui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectDocument(KYCDocumentModel document) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Tolak Dokumen',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Berikan alasan penolakan:',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Foto tidak jelas, data tidak sesuai',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      try {
        // TODO: Get admin ID from auth
        const adminId = 'current_admin_id';

        await _kycService.rejectDocument(
          documentId: document.id!,
          adminId: adminId,
          reason: reasonController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dokumen ${document.documentTypeName} ditolak'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }

    reasonController.dispose();
  }
}
