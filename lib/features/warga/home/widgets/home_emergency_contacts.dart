// ============================================================================
// HOME EMERGENCY CONTACTS WIDGET
// ============================================================================
// Kontak darurat penting (Polisi, Pemadam, Ambulans, dll)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeEmergencyContacts extends StatelessWidget {
  const HomeEmergencyContacts({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      ContactItem(
        name: 'Polisi',
        number: '110',
        icon: Icons.local_police_rounded,
        color: const Color(0xFF3B82F6),
      ),
      ContactItem(
        name: 'Pemadam',
        number: '113',
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFEF4444),
      ),
      ContactItem(
        name: 'Ambulans',
        number: '118',
        icon: Icons.local_hospital_rounded,
        color: const Color(0xFF10B981),
      ),
      ContactItem(
        name: 'Ketua RT',
        number: '0812-3456-7890',
        icon: Icons.person_rounded,
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Kontak Darurat',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return _buildContactButton(contacts[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(ContactItem contact) {
    return Builder(
      builder: (context) => Material(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _copyPhoneNumber(context, contact.name, contact.number),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: contact.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    contact.icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        contact.name,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        contact.number,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _copyPhoneNumber(BuildContext context, String name, String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Nomor $name disalin: $phoneNumber',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class ContactItem {
  final String name;
  final String number;
  final IconData icon;
  final Color color;

  ContactItem({
    required this.name,
    required this.number,
    required this.icon,
    required this.color,
  });
}

