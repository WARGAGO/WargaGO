// ============================================================================
// FAQ SECTION WIDGET
// ============================================================================
// Bottom sheet yang menampilkan FAQ untuk admin
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQSection extends StatefulWidget {
  const FAQSection({super.key});

  @override
  State<FAQSection> createState() => _FAQSectionState();
}

class _FAQSectionState extends State<FAQSection> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'Bagaimana cara mengelola data penduduk?',
      'answer':
          'Buka menu Data Penduduk dari dashboard. Anda bisa menambah, mengedit, atau menghapus data warga. Pastikan data yang diinput sudah benar sebelum menyimpan.',
    },
    {
      'question': 'Bagaimana cara verifikasi seller di Kelola Lapak?',
      'answer':
          'Buka menu Kelola Lapak, pilih tab Pending untuk melihat daftar seller yang menunggu verifikasi. Klik pada seller untuk melihat detail, lalu pilih Setujui atau Tolak.',
    },
    {
      'question': 'Bagaimana cara mengelola keuangan RT/RW?',
      'answer':
          'Gunakan menu Keuangan untuk mencatat pemasukan dan pengeluaran. Anda bisa melihat laporan keuangan lengkap, mengelola jenis iuran, dan membuat tagihan untuk warga.',
    },
    {
      'question': 'Bagaimana cara membuat agenda kegiatan?',
      'answer':
          'Buka menu Agenda, klik tombol (+) untuk menambah kegiatan baru. Isi detail kegiatan seperti judul, tanggal, lokasi, dan deskripsi. Kegiatan akan otomatis terkirim sebagai notifikasi ke warga.',
    },
    {
      'question': 'Bagaimana cara mengelola verifikasi KYC warga?',
      'answer':
          'Warga yang mendaftar akan upload dokumen KYC (KTP, Selfie). Admin bisa melihat dan memverifikasi di menu Verifikasi. Setujui jika dokumen valid, atau tolak dengan memberikan alasan.',
    },
    {
      'question': 'Apa yang harus dilakukan jika lupa password?',
      'answer':
          'Gunakan fitur "Lupa Password" di halaman login. Masukkan email yang terdaftar, lalu cek email untuk link reset password. Buat password baru yang kuat dan mudah diingat.',
    },
    {
      'question': 'Bagaimana cara melihat statistik dashboard?',
      'answer':
          'Dashboard menampilkan overview keuangan, kegiatan, dan aktivitas terkini. Klik pada setiap card untuk melihat detail lengkap. Data diupdate secara real-time.',
    },
    {
      'question': 'Bagaimana cara menghubungi support?',
      'answer':
          'Jika ada kendala teknis atau pertanyaan, hubungi tim developer melalui email support@jawara.com atau WhatsApp 08123456789. Tim kami siap membantu 24/7.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FD),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA500), Color(0xFFFF8C00)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFA500).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.help_rounded,
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
                        'Frequently Asked Questions',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        'Panduan & pertanyaan umum',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // FAQ List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                final isExpanded = _expandedIndex == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _expandedIndex = isExpanded ? null : index;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2F80ED)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Q${index + 1}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF2F80ED),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    faq['question']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: const Color(0xFF2F80ED),
                                ),
                              ],
                            ),
                            if (isExpanded) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FD),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  faq['answer']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF4B5563),
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

