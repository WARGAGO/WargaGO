import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wargago/core/constants/app_routes.dart';
import 'package:wargago/core/providers/auth_provider.dart';

/// Dashboard Page Full Version untuk Bendahara
/// Versi paling lengkap dengan semua fitur: header, ringkasan keuangan, menu grid interaktif, dan info akun
class BendaharaDashboardPage extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const BendaharaDashboardPage({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final user = authProvider.userModel;

    // Data ringkasan keuangan sementara (nanti akan diganti dengan data real dari Firestore/Provider)
    const double totalIuranMasuk = 12300000;
    const double totalTunggakan = 4500000;
    const double saldoKas = 28450000;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard Bendahara',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2F80ED),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final bool? shouldLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    content: Text(
                      'Apakah Anda yakin ingin logout?',
                      style: GoogleFonts.poppins(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Batal', style: GoogleFonts.poppins()),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Logout',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (shouldLogout == true) {
                await authProvider.signOut();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2F80ED), Color(0xFF2F80ED), Colors.white],
            stops: [0.0, 0.4, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Selamat Datang
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.nama ?? 'Bendahara RW',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Bendahara',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Konten Utama dengan Background Putih Rounded
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section: Ringkasan Keuangan Bulan Ini
                        Text(
                          'Ringkasan Keuangan Bulan Ini',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Row: Iuran Masuk & Tunggakan
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Iuran Masuk',
                                amount: 'Rp 12.300.000',
                                icon: Icons.arrow_downward,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Tunggakan',
                                amount: 'Rp 4.500.000',
                                icon: Icons.warning_amber_rounded,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Saldo Kas (Full Width)
                        _buildSummaryCard(
                          title: 'Saldo Kas RW',
                          amount: 'Rp 28.450.000',
                          icon: Icons.account_balance,
                          color: const Color(0xFF2F80ED),
                          isLarge: true,
                        ),

                        const SizedBox(height: 40),

                        // Section: Menu Utama
                        Text(
                          'Menu Utama',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Grid Menu 2x2
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.2,
                          children: [
                            _buildMenuCard(
                              icon: Icons.receipt_long,
                              title: 'Iuran Warga',
                              onTap: () => onNavigateToTab(1),
                            ),
                            _buildMenuCard(
                              icon: Icons.history,
                              title: 'Riwayat Transaksi',
                              onTap: () => onNavigateToTab(2),
                            ),
                            _buildMenuCard(
                              icon: Icons.bar_chart,
                              title: 'Laporan Keuangan',
                              onTap: () => onNavigateToTab(3),
                            ),
                            _buildMenuCard(
                              icon: Icons.person,
                              title: 'Profil Saya',
                              onTap: () => onNavigateToTab(4),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Section: Informasi Akun
                        Text(
                          'Informasi Akun',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildInfoTile(
                          icon: Icons.person,
                          title: 'Nama',
                          value: user?.nama ?? '-',
                        ),
                        _buildInfoTile(
                          icon: Icons.email,
                          title: 'Email',
                          value: user?.email ?? '-',
                        ),
                        _buildInfoTile(
                          icon: Icons.badge,
                          title: 'Role',
                          value: user?.role ?? '-',
                        ),
                        _buildInfoTile(
                          icon: Icons.fingerprint,
                          title: 'User ID',
                          value: user?.id ?? '-',
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget: Card Ringkasan Keuangan
  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    bool isLarge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isLarge ? 32 : 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isLarge ? 16 : 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: isLarge ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Widget: Card Menu Utama
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: const Color(0xFF2F80ED).withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2F80ED).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2F80ED).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: const Color(0xFF2F80ED)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget: Tile Informasi Akun
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2F80ED).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2F80ED), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
