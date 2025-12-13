// ============================================================================
// ADMIN POLL CARD WIDGET
// ============================================================================
// Card khusus untuk admin dengan management actions
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/core/models/poll_model.dart';
import 'package:intl/intl.dart';

class AdminPollCard extends StatelessWidget {
  final Poll poll;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onClose;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final VoidCallback? onViewAnalytics;

  const AdminPollCard({
    super.key,
    required this.poll,
    required this.onTap,
    this.onEdit,
    this.onClose,
    this.onDelete,
    this.onPin,
    this.onViewAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    final isOfficial = poll.pollLevel == 'official';
    final isActive = poll.isActive;
    final isClosed = poll.isClosed;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: poll.isPinned
            ? const BorderSide(color: Color(0xFFFBBF24), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Pinned Icon
                  if (poll.isPinned)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.push_pin,
                        size: 14,
                        color: Color(0xFFFBBF24),
                      ),
                    ),
                  if (poll.isPinned) const SizedBox(width: 8),

                  // Badge
                  _buildBadge(
                    label: isOfficial ? 'RESMI' : 'KOMUNITAS',
                    icon: isOfficial ? Icons.verified_rounded : Icons.groups_rounded,
                    gradient: isOfficial
                        ? const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                          ),
                  ),
                  const Spacer(),

                  // Status Badge
                  if (isClosed)
                    _buildStatusBadge(
                      label: 'DITUTUP',
                      color: Colors.grey.shade400,
                    )
                  else if (poll.isReported)
                    _buildStatusBadge(
                      label: 'DILAPORKAN',
                      color: const Color(0xFFEF4444),
                    )
                  else if (isActive)
                    _buildStatusBadge(
                      label: 'AKTIF',
                      color: const Color(0xFF10B981),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                poll.title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                  letterSpacing: -0.2,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                poll.description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Creator & Date Info
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    poll.createdByName,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(poll.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stats Row
              Row(
                children: [
                  _buildStatChip(
                    icon: Icons.how_to_vote_rounded,
                    label: '${poll.totalVotes}',
                    color: const Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    icon: Icons.list_rounded,
                    label: '${poll.totalOptions} opsi',
                    color: const Color(0xFF8B5CF6),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(
                      icon: Icons.access_time_rounded,
                      label: _formatTimeRemaining(poll.timeRemaining),
                      color: poll.isEndingSoon
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF6B7280),
                    ),
                  ],
                ],
              ),

              // Admin Actions
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              _buildAdminActions(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Build admin action buttons
  Widget _buildAdminActions(BuildContext context) {
    return Row(
      children: [
        // Analytics
        if (onViewAnalytics != null)
          _buildActionButton(
            icon: Icons.analytics_outlined,
            label: 'Analytics',
            onTap: onViewAnalytics!,
            color: const Color(0xFF3B82F6),
          ),

        // Pin/Unpin
        if (onPin != null) ...[
          const SizedBox(width: 8),
          _buildActionButton(
            icon: poll.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: poll.isPinned ? 'Unpin' : 'Pin',
            onTap: onPin!,
            color: const Color(0xFFFBBF24),
          ),
        ],

        // Close
        if (onClose != null && poll.isActive) ...[
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.close_rounded,
            label: 'Tutup',
            onTap: onClose!,
            color: const Color(0xFFEF4444),
          ),
        ],

        const Spacer(),

        // More menu
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: Colors.grey.shade600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            if (onEdit != null)
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Lihat Detail'),
                ],
              ),
            ),
            if (onDelete != null)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
                break;
              case 'view':
                onTap();
                break;
              case 'delete':
                _confirmDelete(context);
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Polling?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Polling ini akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}h lagi';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}j lagi';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m lagi';
    } else {
      return 'Segera berakhir';
    }
  }
}

