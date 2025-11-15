import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PengeluaranCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PengeluaranCard({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            (item['color'] as Color).withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded
              ? (item['color'] as Color).withOpacity(0.3)
              : const Color(0xFFE8EAF2),
          width: isExpanded ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? (item['color'] as Color).withOpacity(0.15)
                : Colors.black.withOpacity(0.04),
            blurRadius: isExpanded ? 20 : 10,
            offset: Offset(0, isExpanded ? 8 : 2),
            spreadRadius: isExpanded ? -2 : 0,
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  _buildIcon(),
                  const SizedBox(width: 16),
                  Expanded(child: _buildContent()),
                  _buildArrowIcon(),
                ],
              ),
            ),
          ),
          if (isExpanded) _buildExpandedContent(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (item['color'] as Color).withOpacity(0.2),
            (item['color'] as Color).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (item['color'] as Color).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (item['color'] as Color).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        _getIconByCategory(item['category']),
        color: item['color'] as Color,
        size: 28,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['name'],
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (item['color'] as Color).withOpacity(0.15),
                    (item['color'] as Color).withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (item['color'] as Color).withOpacity(0.2),
                ),
              ),
              child: Text(
                item['category'],
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: item['color'] as Color,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.access_time_rounded,
              size: 14,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                item['date'],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          item['nominal'],
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: item['color'] as Color,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildArrowIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isExpanded
            ? (item['color'] as Color).withOpacity(0.1)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isExpanded
              ? (item['color'] as Color).withOpacity(0.2)
              : Colors.transparent,
        ),
      ),
      child: Icon(
        isExpanded
            ? Icons.keyboard_arrow_up_rounded
            : Icons.keyboard_arrow_down_rounded,
        color: isExpanded
            ? item['color'] as Color
            : const Color(0xFF6B7280),
        size: 22,
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      children: [
        Container(
          height: 1.5,
          margin: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                (item['color'] as Color).withOpacity(0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                (item['color'] as Color).withOpacity(0.03),
                (item['color'] as Color).withOpacity(0.01),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailInfo(),
                const SizedBox(height: 16),
                _buildDescription(),
                const SizedBox(height: 20),
                _buildDeleteButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8EAF2),
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Nominal',
            item['nominal'],
            Icons.payments_rounded,
            item['color'] as Color,
          ),
          const SizedBox(height: 14),
          _buildDetailRow(
            'Penerima',
            item['recipient'],
            Icons.person_rounded,
            const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 14),
          _buildDetailRow(
            'Status',
            item['status'],
            Icons.check_circle_rounded,
            const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8EAF2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  size: 16,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Deskripsi',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item['description'],
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.6,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_rounded, size: 18),
          label: Text(
            'Hapus Transaksi',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 48),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconByCategory(String category) {
    switch (category) {
      case 'Operasional':
        return Icons.build_circle_rounded;
      case 'Infrastruktur':
        return Icons.construction_rounded;
      case 'Utilitas':
        return Icons.flash_on_rounded;
      case 'Kegiatan':
        return Icons.celebration_rounded;
      default:
        return Icons.payments_rounded;
    }
  }
}

