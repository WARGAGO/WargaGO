// ============================================================================
// MARKETPLACE CATEGORY FILTER WIDGET
// ============================================================================
// Filter kategori produk dengan data dari backend
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/marketplace_provider.dart';

class MarketplaceCategoryFilter extends StatelessWidget {
  const MarketplaceCategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;

        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = provider.selectedCategory == category;

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
                      provider.setCategory(category);
                    },
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF1F2937),
                    ),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF2F80ED),
                    showCheckmark: false,
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF2F80ED) : const Color(0xFFE5E7EB),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
