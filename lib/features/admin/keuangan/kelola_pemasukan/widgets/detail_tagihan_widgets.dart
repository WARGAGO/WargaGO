// ============================================================================
// DETAIL TAGIHAN - REUSABLE WIDGETS
// ============================================================================
// Widget reusable untuk detail tagihan page
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/keuangan_constants.dart';

/// Status badge widget untuk menampilkan status tagihan
class TagihanStatusBadge extends StatelessWidget {
  const TagihanStatusBadge({
    super.key,
    required this.status,
    required this.color,
  });

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KeuanganSpacing.xl,
        vertical: KeuanganSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: KeuanganSpacing.sm),
          Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section title dengan icon
class TagihanSectionTitle extends StatelessWidget {
  const TagihanSectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(KeuanganSpacing.sm),
          decoration: BoxDecoration(
            color: KeuanganColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(KeuanganRadius.sm),
          ),
          child: Icon(
            icon,
            size: KeuanganIconSize.md,
            color: KeuanganColors.primary,
          ),
        ),
        const SizedBox(width: KeuanganSpacing.md),
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: KeuanganColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Info card container dengan shadow
class TagihanInfoCard extends StatelessWidget {
  const TagihanInfoCard({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KeuanganSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KeuanganRadius.lg),
        border: Border.all(
          color: const Color(0xFFE8EAF2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

/// Detail row dengan icon, label, dan value
class TagihanDetailRow extends StatelessWidget {
  const TagihanDetailRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isBold = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(KeuanganSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(KeuanganRadius.sm),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: KeuanganSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: KeuanganColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isBold ? 16 : 14,
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                  color: KeuanganColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Success dialog untuk approval
class TagihanSuccessDialog extends StatelessWidget {
  const TagihanSuccessDialog({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KeuanganRadius.xl),
      ),
      contentPadding: const EdgeInsets.all(KeuanganSpacing.xxl),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(KeuanganSpacing.lg),
            decoration: BoxDecoration(
              color: KeuanganColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: KeuanganColors.success,
              size: 64,
            ),
          ),
          const SizedBox(height: KeuanganSpacing.xl),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: KeuanganColors.textPrimary,
            ),
          ),
          const SizedBox(height: KeuanganSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: KeuanganColors.textSecondary,
            ),
          ),
          const SizedBox(height: KeuanganSpacing.xxl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: KeuanganColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: KeuanganSpacing.lg,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KeuanganRadius.md),
                ),
                elevation: 0,
              ),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rejection dialog untuk penolakan
class TagihanRejectionDialog extends StatelessWidget {
  const TagihanRejectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KeuanganRadius.xl),
      ),
      contentPadding: const EdgeInsets.all(KeuanganSpacing.xxl),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(KeuanganSpacing.lg),
            decoration: BoxDecoration(
              color: KeuanganColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel_outlined,
              color: KeuanganColors.error,
              size: 64,
            ),
          ),
          const SizedBox(height: KeuanganSpacing.xl),
          Text(
            'Pembayaran Ditolak',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: KeuanganColors.textPrimary,
            ),
          ),
          const SizedBox(height: KeuanganSpacing.sm),
          Text(
            'Alasan penolakan telah dikirim',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: KeuanganColors.textSecondary,
            ),
          ),
          const SizedBox(height: KeuanganSpacing.xxl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: KeuanganColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: KeuanganSpacing.lg,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KeuanganRadius.md),
                ),
                elevation: 0,
              ),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rejection form untuk input alasan penolakan
class TagihanRejectionForm extends StatelessWidget {
  const TagihanRejectionForm({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TagihanInfoCard(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(KeuanganSpacing.sm),
              decoration: BoxDecoration(
                color: KeuanganColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(KeuanganRadius.sm),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                color: KeuanganColors.error,
                size: KeuanganIconSize.md,
              ),
            ),
            const SizedBox(width: KeuanganSpacing.md),
            Text(
              'Alasan Penolakan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: KeuanganColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: KeuanganSpacing.lg),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Masukkan alasan penolakan pembayaran...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: KeuanganColors.textTertiary,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KeuanganRadius.md),
              borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KeuanganRadius.md),
              borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KeuanganRadius.md),
              borderSide: const BorderSide(
                color: KeuanganColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(KeuanganSpacing.lg),
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: KeuanganColors.textPrimary,
          ),
        ),
        const SizedBox(height: KeuanganSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: KeuanganColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: KeuanganSpacing.lg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KeuanganRadius.md),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cancel_outlined, size: KeuanganIconSize.md),
                const SizedBox(width: KeuanganSpacing.sm),
                Text(
                  'Tolak Pembayaran',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

