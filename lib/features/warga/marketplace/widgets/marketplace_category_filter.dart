// ============================================================================
// MARKETPLACE CATEGORY FILTER WIDGET
// ============================================================================
// Filter kategori sayuran
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketplaceCategoryFilter extends StatefulWidget {
  const MarketplaceCategoryFilter({super.key});

  @override
  State<MarketplaceCategoryFilter> createState() => _MarketplaceCategoryFilterState();
}

class _MarketplaceCategoryFilterState extends State<MarketplaceCategoryFilter> {
  String selectedCategory = 'Semua';
  
  final List<String> categories = [
    'Semua',
    'Sayur Akar',
    'Sayur Buah',
    'Sayur Daun',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 80),
              child: FilterChip(
                label: Text(
                  category,
                  overflow: TextOverflow.visible,
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF1F2937),
                ),
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFF10B981),
                showCheckmark: false,
                side: BorderSide(
                  color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
          );
        },
      ),
    );
  }
}
