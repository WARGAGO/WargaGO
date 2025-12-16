// ============================================================================
// HOME UPCOMING EVENTS WIDGET
// ============================================================================
// Daftar kegiatan yang akan datang - REAL DATA dari Firestore
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:wargago/core/models/agenda_model.dart';
import 'package:wargago/features/warga/kegiatan/pages/detail_kegiatan_warga_page.dart';

class HomeUpcomingEvents extends StatelessWidget {
  const HomeUpcomingEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('agenda')
          // ⚠️ CRITICAL: Only 1 where clause to avoid composite index!
          // Filter type & isActive client-side instead
          .where('tanggal', isGreaterThanOrEqualTo: Timestamp.now())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        // Convert to AgendaModel and filter client-side
        final events = snapshot.data!.docs
            .map((doc) => AgendaModel.fromFirestore(doc))
            .where((agenda) =>
                agenda.type == 'kegiatan' && // Filter type client-side
                agenda.isActive == true)     // Filter isActive client-side
            .toList();

        // Check if empty after filtering
        if (events.isEmpty) {
          return _buildEmptyState();
        }

        // ⚠️ Client-side sorting by tanggal (DESCENDING - terbaru di atas)
        events.sort((a, b) => b.tanggal.compareTo(a.tanggal));

        // ⚠️ Limit to 5 events (client-side)
        final limitedEvents = events.take(5).toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.event_rounded,
                            color: Color(0xFF2F80ED),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Kegiatan Mendatang',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    if (limitedEvents.length > 3)
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to all events page
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Semua',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2F80ED),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Color(0xFF2F80ED),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: limitedEvents.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final event = limitedEvents[index];
                  return _buildEventCard(context, event, index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F80ED)),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat kegiatan...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat kegiatan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 40,
              color: Color(0xFF2F80ED),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Kegiatan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada kegiatan yang dijadwalkan saat ini',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, AgendaModel event, int index) {
    // Color variations for visual appeal
    final colors = [
      const Color(0xFF2F80ED),
      const Color(0xFF3B8FF3),
      const Color(0xFF4B9EFF),
      const Color(0xFF5BA4FF),
      const Color(0xFF6BB3FF),
    ];
    final color = colors[index % colors.length];

    // Format date and time
    final dateFormat = DateFormat('d MMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm');
    final formattedDate = dateFormat.format(event.tanggal);
    final formattedTime = '${timeFormat.format(event.tanggal)} WIB';

    return InkWell(
      onTap: () {
        // Navigate to detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailKegiatanWargaPage(agenda: event),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.event_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.judul,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$formattedDate • $formattedTime',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (event.lokasi != null && event.lokasi!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.lokasi!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

