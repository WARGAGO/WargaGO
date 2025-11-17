import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jawara/core/models/warga_model.dart';
import '../detail_data_warga_page.dart';
import '../edit_data_warga_page.dart';

/// Card widget untuk menampilkan data warga dengan expand/collapse
class WargaExpandableCard extends StatefulWidget {
  final WargaModel warga;

  const WargaExpandableCard({
    super.key,
    required this.warga,
  });

  @override
  State<WargaExpandableCard> createState() => _WargaExpandableCardState();
}

class _WargaExpandableCardState extends State<WargaExpandableCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF8F9FF)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isExpanded
                ? const Color(0xFF2F80ED).withValues(alpha: 0.3)
                : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isExpanded
                  ? const Color(0xFF2F80ED).withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: isExpanded ? 20 : 12,
              offset: Offset(0, isExpanded ? 8 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              _buildHeader(),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: _buildExpandedContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isExpanded
            ? LinearGradient(
                colors: [
                  const Color(0xFF2F80ED).withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              )
            : null,
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 14),
          Expanded(child: _buildWargaInfo()),
          _buildExpandIcon(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFF0F4FF),
          child: Icon(
            Icons.person_rounded,
            color: Color(0xFF2F80ED),
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildWargaInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.warga.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: const Color(0xFF1F2937),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildGenderBadge(),
            const SizedBox(width: 6),
            _buildStatusBadge(),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.warga.jenisKelamin == 'Laki-laki'
                ? Icons.male_rounded
                : Icons.female_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            widget.warga.jenisKelamin,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isActive = widget.warga.isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF10B981).withValues(alpha: 0.1)
            : const Color(0xFFEF4444).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          width: 1,
        ),
      ),
      child: Text(
        widget.warga.statusPenduduk,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
      ),
    );
  }

  Widget _buildExpandIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isExpanded
            ? const Color(0xFF2F80ED).withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isExpanded
            ? Icons.keyboard_arrow_up_rounded
            : Icons.keyboard_arrow_down_rounded,
        color: isExpanded ? const Color(0xFF2F80ED) : Colors.grey[700],
        size: 20,
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          _buildDivider(),
          const SizedBox(height: 16),
          _buildInfoCards(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF667EEA).withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.badge_rounded,
            label: "NIK",
            value: widget.warga.nik,
            color: const Color(0xFF2F80ED),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.family_restroom_rounded,
            label: "Keluarga",
            value: widget.warga.namaKeluarga.isEmpty ? '-' : widget.warga.namaKeluarga,
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailDataWargaPage(warga: widget.warga),
                ),
              );
            },
            icon: const Icon(Icons.visibility_rounded, size: 18),
            label: Text(
              "Detail",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2F80ED),
              side: const BorderSide(color: Color(0xFF2F80ED), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditDataWargaPage(warga: widget.warga),
                ),
              );
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: Text(
              "Edit",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F80ED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}

