// ============================================================================
// KEUANGAN REUSABLE WIDGETS
// ============================================================================
// Widget reusable untuk fitur Keuangan
//
// Clean Code Principles:
// ✅ Reusable - bisa dipakai di berbagai page keuangan
// ✅ Single Responsibility - setiap widget punya 1 tugas
// ✅ Clean naming - nama deskriptif
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'keuangan_constants.dart';

/// Card untuk menampilkan summary keuangan (Pemasukan/Pengeluaran)
class KeuanganSummaryCard extends StatelessWidget {
  const KeuanganSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.onTap,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KeuanganRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(KeuanganSpacing.lg),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(KeuanganRadius.lg),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(KeuanganSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KeuanganRadius.sm),
                  ),
                  child: Icon(icon, color: color, size: KeuanganIconSize.lg),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: KeuanganIconSize.sm,
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: KeuanganSpacing.md),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: KeuanganColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: KeuanganSpacing.xs),
            Text(
              amount,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card untuk transaksi (pemasukan/pengeluaran)
class KeuanganTransactionCard extends StatelessWidget {
  const KeuanganTransactionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    required this.isIncome,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String date;
  final String amount;
  final bool isIncome;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? KeuanganColors.income : KeuanganColors.expense;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KeuanganRadius.md),
      child: Container(
        padding: const EdgeInsets.all(KeuanganSpacing.lg),
        decoration: BoxDecoration(
          color: KeuanganColors.cardBackground,
          borderRadius: BorderRadius.circular(KeuanganRadius.md),
          border: Border.all(
            color: KeuanganColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(KeuanganRadius.md),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: color,
                size: KeuanganIconSize.lg,
              ),
            ),
            const SizedBox(width: KeuanganSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: KeuanganColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: KeuanganColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: KeuanganColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: KeuanganSpacing.sm),
            Text(
              amount,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Search bar untuk keuangan
class KeuanganSearchBar extends StatelessWidget {
  const KeuanganSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = 'Cari transaksi...',
  });

  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KeuanganColors.cardBackground,
        borderRadius: BorderRadius.circular(KeuanganRadius.md),
        border: Border.all(
          color: KeuanganColors.border,
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: KeuanganColors.textTertiary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: KeuanganColors.textTertiary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: KeuanganSpacing.lg,
            vertical: KeuanganSpacing.md,
          ),
        ),
      ),
    );
  }
}

/// Section header dengan title dan action button
class KeuanganSectionHeader extends StatelessWidget {
  const KeuanganSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.icon,
  });

  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: KeuanganIconSize.lg,
                color: KeuanganColors.primary,
              ),
              const SizedBox(width: KeuanganSpacing.sm),
            ],
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: KeuanganColors.textPrimary,
              ),
            ),
          ],
        ),
        if (actionText != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            child: Row(
              children: [
                Text(
                  actionText!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: KeuanganColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: KeuanganColors.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Primary button untuk keuangan
class KeuanganPrimaryButton extends StatelessWidget {
  const KeuanganPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.color = KeuanganColors.primary,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KeuanganRadius.md),
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: KeuanganIconSize.md),
                    const SizedBox(width: KeuanganSpacing.sm),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Empty state widget
class KeuanganEmptyState extends StatelessWidget {
  const KeuanganEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: KeuanganColors.textTertiary,
          ),
          const SizedBox(height: KeuanganSpacing.lg),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: KeuanganColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Format currency helper
class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatFromString(String amount) {
    final cleanAmount = amount.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanAmount.isEmpty) return 'Rp 0';
    return format(double.parse(cleanAmount));
  }
}

