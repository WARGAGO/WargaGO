// ============================================================================
// HOME UPCOMING EVENTS WIDGET
// ============================================================================
// Daftar kegiatan yang akan datang
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeUpcomingEvents extends StatelessWidget {
  const HomeUpcomingEvents({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      EventItem(
        title: 'Gotong Royong RT 05',
        date: '1 Des 2025',
        time: '07:00 WIB',
        location: 'Balai RT',
        icon: Icons.cleaning_services_rounded,
        color: const Color(0xFF2F80ED),
      ),
      EventItem(
        title: 'Arisan Ibu-ibu',
        date: '5 Des 2025',
        time: '14:00 WIB',
        location: 'Rumah Bu RT',
        icon: Icons.savings_rounded,
        color: const Color(0xFF3B8FF3),
      ),
      EventItem(
        title: 'Posyandu Balita',
        date: '10 Des 2025',
        time: '08:00 WIB',
        location: 'Posyandu',
        icon: Icons.child_care_rounded,
        color: const Color(0xFF4B9EFF),
      ),
    ];

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
                Text(
                  'Kegiatan Mendatang',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2F80ED),
                    ),
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
            itemCount: events.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildEventCard(events[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventItem event) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: event.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: event.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              event.icon,
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
                  event.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
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
                    Text(
                      '${event.date} • ${event.time}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.location,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: event.color,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class EventItem {
  final String title;
  final String date;
  final String time;
  final String location;
  final IconData icon;
  final Color color;

  EventItem({
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.icon,
    required this.color,
  });
}

