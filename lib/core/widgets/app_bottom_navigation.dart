import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/dashboard/dashboard_page.dart';
import '../../features/data_warga/data_warga_main_page.dart';
import '../../features/keuangan/keuangan_page.dart';
import '../../features/kelola_lapak/kelola_lapak_page.dart';

/// Unified Bottom Navigation Bar untuk semua halaman
/// Menggunakan desain modern dengan gradient pada active state
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: const Border(
          top: BorderSide(
            color: Color(0xFFE8EAF2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.home_filled,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () {
                    if (currentIndex != 0) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const DashboardPage(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.assignment_outlined,
                  label: 'Data Warga',
                  isActive: currentIndex == 1,
                  onTap: () {
                    if (currentIndex != 1) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const DataWargaMainPage(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Keuangan',
                  isActive: currentIndex == 2,
                  onTap: () {
                    if (currentIndex != 2) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const KeuanganPage(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.store_rounded,
                  label: 'Kelola Lapak',
                  isActive: currentIndex == 3,
                  onTap: () {
                    if (currentIndex != 3) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const KelolaLapakPage(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2F80ED);
    const Color inactive = Color(0xFF7A7C89);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2F80ED),
                    Color(0xFF1E6FD9),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : inactive,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? Colors.white : inactive,
                letterSpacing: 0,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

