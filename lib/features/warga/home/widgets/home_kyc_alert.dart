// ============================================================================
// HOME KYC ALERT WIDGET
// ============================================================================
// Alert banner untuk mengingatkan user melengkapi KYC
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeKycAlert extends StatelessWidget {
  final bool isKycComplete;
  final bool isKycPending;
  final VoidCallback onUploadTap;

  const HomeKycAlert({
    super.key,
    required this.isKycComplete,
    required this.isKycPending,
    required this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) {
    // Jika KYC sudah complete, tidak perlu tampilkan alert
    if (isKycComplete) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isKycPending
              ? [
                  const Color(0xFFFBBF24), // Yellow-400
                  const Color(0xFFF59E0B), // Yellow-500
                ]
              : [
                  const Color(0xFFF59E0B), // Orange-500
                  const Color(0xFFEF4444), // Red-500
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isKycPending
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFFEF4444))
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isKycPending
                  ? Icons.schedule_rounded
                  : Icons.warning_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKycPending
                      ? 'Menunggu Persetujuan Admin'
                      : 'Lengkapi Data KYC',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isKycPending
                      ? 'KYC Anda sedang diverifikasi oleh admin'
                      : 'Upload KTP & KK untuk akses fitur lengkap',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // Button (hanya tampil jika belum upload)
          if (!isKycPending) ...[
            const SizedBox(width: 12),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: onUploadTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Upload',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

