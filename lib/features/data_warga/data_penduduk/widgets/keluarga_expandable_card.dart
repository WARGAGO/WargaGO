import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../detail_keluarga_page.dart';

/// Card widget untuk menampilkan data keluarga
class KeluargaExpandableCard extends StatefulWidget {
  final String namaKepalaKeluarga;
  final String alamat;
  final String status;

  const KeluargaExpandableCard({
    super.key,
    required this.namaKepalaKeluarga,
    required this.alamat,
    required this.status,
  });

  @override
  State<KeluargaExpandableCard> createState() => _KeluargaExpandableCardState();
}

class _KeluargaExpandableCardState extends State<KeluargaExpandableCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFFDDEAFF),
          child: Icon(Icons.person, color: Color(0xFF2F80ED)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.namaKepalaKeluarga,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        Icon(
          isExpanded
              ? Icons.keyboard_arrow_up
              : Icons.keyboard_arrow_down,
          color: Colors.grey[700],
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildInfoColumn(
                "Kepala Keluarga:",
                widget.namaKepalaKeluarga,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInfoColumn("Alamat:", widget.alamat),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DetailKeluargaPage(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2F80ED)),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(80, 36),
            ),
            child: const Text(
              "Details",
              style: TextStyle(
                color: Color(0xFF2F80ED),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          "Status:",
          style: GoogleFonts.poppins(fontSize: 11),
        ),
        Text(
          widget.status,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF10B981),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

