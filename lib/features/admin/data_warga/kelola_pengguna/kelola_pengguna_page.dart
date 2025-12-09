import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/core/models/user_model.dart';

import 'detail_pengguna_page.dart';
import 'tambah_pengguna_page.dart';
import 'repositories/user_repository.dart';

/// Kelola Pengguna Page - Manajemen akun login aplikasi
///
/// Fungsi:
/// - Kelola akun login (email, password, role)
/// - Filter berdasarkan role (Admin/User)
/// - Filter berdasarkan status (Pending/Approved)
/// - Tambah admin baru
class KelolaPenggunaPage extends StatefulWidget {
  const KelolaPenggunaPage({super.key});

  @override
  State<KelolaPenggunaPage> createState() => _KelolaPenggunaPageState();
}

class _KelolaPenggunaPageState extends State<KelolaPenggunaPage> {
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = ['Semua', 'Admin', 'Warga', 'Pending', 'Approved']; // ⭐ Added 'Approved'
  final UserRepository _userRepository = UserRepository();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2F80ED),
                    Color(0xFF1E6FD9),
                    Color(0xFF0F5FCC),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.people_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kelola Pengguna",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Kelola semua akun pengguna",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // FILTER
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(4),
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
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
                                )
                              : null,
                          color: isSelected ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : const Color(0xFF6B7280),
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // SEARCH BAR
            _buildSearchBar(),

            // LIST
            Expanded(
              child: _buildPenggunaList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahPenggunaPage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF2F80ED),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah Admin',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Search Bar Widget
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari nama atau email...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: GoogleFonts.poppins(fontSize: 14),
      ),
    );
  }

  /// Build user list with StreamBuilder connected to Firestore
  Widget _buildPenggunaList() {
    // Determine which stream to use based on filter
    Stream<List<UserModel>> userStream;

    if (_selectedFilter == 'Semua') {
      userStream = _userRepository.getAllUsers();
    } else if (_selectedFilter == 'Admin') {
      userStream = _userRepository.getUsersByRole('admin');
    } else if (_selectedFilter == 'Warga') {
      userStream = _userRepository.getUsersByRole('warga');
    } else if (_selectedFilter == 'Pending') {
      userStream = _userRepository.getPendingUsers();
    } else {
      userStream = _userRepository.getAllUsers();
    }

    return StreamBuilder<List<UserModel>>(
      stream: userStream,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F80ED)),
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Terjadi kesalahan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // No data
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Custom message based on filter
          String emptyMessage;
          if (_selectedFilter == 'Pending') {
            emptyMessage = 'Tidak ada pengguna yang menunggu approval';
          } else if (_selectedFilter == 'Approved') {
            emptyMessage = 'Belum ada pengguna yang di-approve';
          } else if (_selectedFilter == 'Admin') {
            emptyMessage = 'Tidak ada admin terdaftar';
          } else if (_selectedFilter == 'Warga') {
            emptyMessage = 'Tidak ada warga terdaftar';
          } else {
            emptyMessage = 'Belum ada pengguna terdaftar';
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada pengguna',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  emptyMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
                // ⭐ NEW: Hint for approved users
                if (_selectedFilter == 'Pending') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '💡 User yang sudah approved ada di tab "Approved"',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF059669),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        // Filter by search query
        List<UserModel> users = snapshot.data!;

        // Debug: Print total users before filtering
        print('🔍 Kelola Pengguna Debug:');
        print('   Filter: $_selectedFilter');
        print('   Total users from stream: ${users.length}');
        for (var user in users) {
          print('   - ${user.nama} (${user.email}) - Role: ${user.role} - Status: ${user.status}');
        }

        // Apply additional client-side filtering based on selected filter
        if (_selectedFilter == 'Admin') {
          users = users.where((user) => user.role.toLowerCase() == 'admin').toList();
        } else if (_selectedFilter == 'Warga') {
          users = users.where((user) => user.role.toLowerCase() == 'warga').toList();
        } else if (_selectedFilter == 'Pending') {
          users = users.where((user) {
            final status = user.status.toLowerCase();
            return status == 'pending' || status == 'unverified'; // Pending and unverified
          }).toList();
        } else if (_selectedFilter == 'Approved') { // ⭐ NEW: Filter for approved users
          users = users.where((user) {
            final status = user.status.toLowerCase();
            return status == 'approved';
          }).toList();
        }

        print('   After filter: ${users.length} users');

        // Apply search query filter
        if (_searchQuery.isNotEmpty) {
          users = users.where((user) {
            final nameLower = user.nama.toLowerCase();
            final emailLower = user.email.toLowerCase();
            final queryLower = _searchQuery.toLowerCase();
            return nameLower.contains(queryLower) ||
                emailLower.contains(queryLower);
          }).toList();
        }

        // Display filtered list
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ditemukan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Coba kata kunci lain',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildPenggunaCard(user);
          },
        );
      },
    );
  }

  Widget _buildPenggunaCard(UserModel user) {
    final isAdmin = user.role.toLowerCase() == 'admin';
    final isPending = user.status.toLowerCase() == 'pending' ||
        user.status.toLowerCase() == 'unverified';
    final isApproved = user.status.toLowerCase() == 'approved';

    // Get first letter for avatar
    final avatarLetter = user.nama.isNotEmpty
        ? user.nama[0].toUpperCase()
        : 'U';

    // Determine status badge
    String statusText;
    Color statusColor;

    if (user.status.toLowerCase() == 'unverified') {
      statusText = 'Belum Verifikasi';
      statusColor = const Color(0xFFEF4444);
    } else if (user.status.toLowerCase() == 'pending') {
      statusText = 'Menunggu';
      statusColor = const Color(0xFFFBBF24);
    } else if (user.status.toLowerCase() == 'approved') {
      statusText = 'Approved';
      statusColor = const Color(0xFF10B981);
    } else if (user.status.toLowerCase() == 'rejected') {
      statusText = 'Ditolak';
      statusColor = const Color(0xFFEF4444);
    } else {
      statusText = user.status;
      statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPenggunaPage(user: user),
              ),
            ).then((_) {
              // Refresh when coming back
              setState(() {});
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isAdmin
                          ? [const Color(0xFF2F80ED), const Color(0xFF1E6FD9)]
                          : [const Color(0xFF10B981), const Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      avatarLetter,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.nama,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Role badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isAdmin
                                  ? const Color(0xFF2F80ED).withValues(alpha: 0.1)
                                  : const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isAdmin ? 'Admin' : 'User',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isAdmin
                                    ? const Color(0xFF2F80ED)
                                    : const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              user.email,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Status badge
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

