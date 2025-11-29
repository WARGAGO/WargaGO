// ============================================================================
// WARGA HOME PAGE
// ============================================================================
// Halaman utama untuk warga dengan desain modern dan menarik
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/constants/app_routes.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_kyc_alert.dart';
import '../widgets/home_info_cards.dart';
import '../widgets/home_quick_access_grid.dart';
import '../widgets/home_feature_list.dart';
import '../widgets/home_news_carousel.dart';
import '../widgets/home_upcoming_events.dart';
import '../widgets/home_emergency_contacts.dart';
import '../widgets/home_quick_report.dart';

class WargaHomePage extends StatelessWidget {
  const WargaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userModel;
        final userName = user?.nama ?? 'Warga';
        final userStatus = user?.status ?? 'unverified';

        // Determine alert status
        // Status bisa: 'approved', 'unverified', 'pending', 'rejected'
        // - approved: KYC sudah di-approve admin, full access
        // - unverified: Belum upload KYC ATAU belum di-approve admin
        // - pending: Sudah upload KYC, menunggu approval admin
        // - rejected: Ditolak admin (tidak bisa login sampai sini)

        final bool isApproved = userStatus == 'approved';
        final bool isPending = userStatus == 'pending';

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          body: SafeArea(
            child: Column(
              children: [
                // 1. App Bar (Header)
                HomeAppBar(
                  notificationCount: 3,
                  userName: userName,
                ),

                // 2. Scrollable Content (termasuk KYC Alert di dalamnya)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    color: const Color(0xFF2F80ED),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // KYC Alert - Sekarang di dalam scroll (ikut scroll)
                          if (!isApproved)
                            HomeKycAlert(
                              isKycComplete: isApproved,
                              isKycPending: isPending,
                              onUploadTap: () {
                                context.push(AppRoutes.wargaKYC);
                              },
                            ),

                          if (!isApproved) const SizedBox(height: 16),

                          // News Carousel - Berita & Pengumuman
                          const HomeNewsCarousel(),
                          const SizedBox(height: 24),


                          // Info Cards
                          const HomeInfoCards(),
                          const SizedBox(height: 28),

                          // Quick Report - Lapor Masalah
                          const HomeQuickReport(),
                          const SizedBox(height: 24),

                          // Quick Access Section
                          _buildSectionTitle('Akses Cepat'),
                          const SizedBox(height: 16),
                          const HomeQuickAccessGrid(),
                          const SizedBox(height: 28),

                          // Upcoming Events - Kegiatan Mendatang
                          const HomeUpcomingEvents(),
                          const SizedBox(height: 24),

                          // Emergency Contacts - Kontak Darurat
                          const HomeEmergencyContacts(),
                          const SizedBox(height: 24),

                          // Feature List Section
                          _buildSectionTitle('Fitur Lainnya'),
                          const SizedBox(height: 16),
                          const HomeFeatureList(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}











