// ============================================================================
// ADMIN PROFILE PAGE
// ============================================================================
// Halaman profile admin yang lengkap dengan:
// - Info profil (nama, tanggal lahir, tempat lahir, dll)
// - FAQ Section untuk panduan admin
// - Settings & Preferences
// - Logout & Account Management
// ============================================================================

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'widgets/faq_section.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_menu_section.dart';
import 'pages/edit_profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/about_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Map<String, dynamic>? _adminData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
    _loadAdminData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          setState(() {
            _adminData = doc.data();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading admin data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2F80ED),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header dengan avatar dan info utama
                  ProfileHeader(
                    adminData: _adminData,
                    onEditPressed: () => _navigateToEditProfile(),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Info Card - Data Personal
                        ProfileInfoCard(adminData: _adminData),

                        const SizedBox(height: 20),

                        // Menu Section
                        ProfileMenuSection(
                          onSettingsTap: () => _navigateToSettings(),
                          onFAQTap: () => _showFAQBottomSheet(),
                          onAboutTap: () => _navigateToAbout(),
                          onLogoutTap: () => _showLogoutDialog(),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(adminData: _adminData),
      ),
    ).then((_) => _loadAdminData());
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutPage(),
      ),
    );
  }

  void _showFAQBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FAQSection(),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Logout',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun admin?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _performLogout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    // Close confirmation dialog first
    Navigator.of(context).pop();

    // Use SchedulerBinding to ensure all Navigator operations are complete
    // before starting logout process
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Show loading overlay (not a dialog, to avoid Navigator issues)
      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (context) => Container(
          color: Colors.black54,
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2F80ED),
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);

      try {
        // Perform logout
        await FirebaseAuth.instance.signOut();

        // Remove loading overlay
        overlayEntry.remove();

        // Navigate to login using GoRouter
        if (mounted) {
          // Use scheduleMicrotask to ensure we're outside the current frame
          scheduleMicrotask(() {
            if (mounted) {
              context.go('/login');
            }
          });
        }
      } catch (e) {
        print('Error logging out: $e');

        // Remove loading overlay
        overlayEntry.remove();

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saat logout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }
}

