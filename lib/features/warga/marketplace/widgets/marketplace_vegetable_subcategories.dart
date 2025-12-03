// ============================================================================
// MARKETPLACE VEGETABLE SUBCATEGORIES WIDGET
// ============================================================================
// Sub-kategori khusus untuk sayuran: Daun, Akar, Buah, Polong
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/marketplace_provider.dart';

class MarketplaceVegetableSubcategories extends StatelessWidget {
  const MarketplaceVegetableSubcategories({super.key});

  // Data sub-kategori sayuran
  final List<_SubcategoryData> _subcategories = const [
    _SubcategoryData(
      name: 'Daun',
      icon: Icons.eco,
      color: Color(0xFF2F80ED),
      examples: 'Kangkung, Bayam, Sawi',
    ),
    _SubcategoryData(
      name: 'Akar',
      icon: Icons.grass,
      color: Color(0xFF5B8DEF),
      examples: 'Wortel, Kentang, Lobak',
    ),
    _SubcategoryData(
      name: 'Buah',
      icon: Icons.local_florist,
      color: Color(0xFF1E5BB8),
      examples: 'Tomat, Terong, Cabai',
    ),
    _SubcategoryData(
      name: 'Polong',
      icon: Icons.grain,
      color: Color(0xFF4A90E2),
      examples: 'Buncis, Kacang Panjang',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        // Hanya tampilkan jika kategori 'Sayuran' atau 'Sayur' dipilih
        final selectedCategory = provider.selectedCategory.toLowerCase();
        final isSayurSelected = selectedCategory.contains('sayur') ||
                                selectedCategory.contains('sayuran');

        if (!isSayurSelected || selectedCategory == 'semua') {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Jenis Sayuran',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _subcategories.length,
                itemBuilder: (context, index) {
                  final subcategory = _subcategories[index];
                  return _buildSubcategoryCard(context, subcategory, provider);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubcategoryCard(
    BuildContext context,
    _SubcategoryData subcategory,
    MarketplaceProvider provider,
  ) {
    // Build full category name: "Sayur Daun", "Sayur Akar", etc.
    final fullCategoryName = 'Sayur ${subcategory.name}';
    final isSelected = provider.selectedCategory == fullCategoryName;

    return GestureDetector(
      onTap: () {
        // Use setCategory with full name like "Sayur Daun"
        provider.setCategory(fullCategoryName);
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    subcategory.color,
                    subcategory.color.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? subcategory.color
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? subcategory.color.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : subcategory.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  subcategory.icon,
                  color: isSelected ? Colors.white : subcategory.color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              // Name
              Text(
                subcategory.name,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              // Examples
              Text(
                subcategory.examples,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.9)
                      : const Color(0xFF6B7280),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubcategoryData {
  final String name;
  final IconData icon;
  final Color color;
  final String examples;

  const _SubcategoryData({
    required this.name,
    required this.icon,
    required this.color,
    required this.examples,
  });
}

