// ============================================================================
// MARKETPLACE CATEGORY ICONS WIDGET
// ============================================================================
// Kategori dengan ikon - includes Sayur Daun, Sayur Akar, Sayur Buah, Sayur Polong
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/marketplace_provider.dart';
import '../pages/category_products_page.dart';

class MarketplaceCategoryIcons extends StatelessWidget {
  const MarketplaceCategoryIcons({super.key});

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();

    if (cat == 'semua') {
      return Icons.apps_outlined;
    } else if (cat.contains('sayur daun') || cat == 'daun') {
      return Icons.eco;
    } else if (cat.contains('sayur akar') || cat == 'akar') {
      return Icons.grass;
    } else if (cat.contains('sayur buah')) {
      return Icons.local_florist;
    } else if (cat.contains('sayur polong') || cat == 'polong') {
      return Icons.grain;
    } else if (cat.contains('sayur')) {
      return Icons.eco_outlined;
    } else if (cat.contains('buah')) {
      return Icons.apple_outlined;
    } else if (cat == 'daging') {
      return Icons.set_meal_outlined;
    } else if (cat == 'ikan') {
      return Icons.phishing_outlined;
    } else if (cat == 'bumbu' || cat == 'rempah') {
      return Icons.local_dining_outlined;
    } else if (cat == 'sembako') {
      return Icons.shopping_basket_outlined;
    } else {
      return Icons.category_outlined;
    }
  }

  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFF2F80ED), // Primary Blue
      const Color(0xFF5B8DEF), // Light Blue
      const Color(0xFF1E5BB8), // Dark Blue
      const Color(0xFF4A90E2), // Sky Blue
      const Color(0xFF357ABD), // Medium Blue
      const Color(0xFF6B9FED), // Soft Blue
    ];
    return colors[index % colors.length];
  }

  String _getCategoryEmoji(String category) {
    final cat = category.toLowerCase();

    if (cat == 'semua') {
      return '📱';
    } else if (cat.contains('sayur daun') || cat == 'daun') {
      return '🌿';
    } else if (cat.contains('sayur akar') || cat == 'akar') {
      return '🥕';
    } else if (cat.contains('sayur buah')) {
      return '🍅';
    } else if (cat.contains('sayur polong') || cat == 'polong') {
      return '🫘';
    } else if (cat.contains('buah')) {
      return '🍎';
    } else if (cat == 'daging') {
      return '🍖';
    } else if (cat == 'ikan') {
      return '🐟';
    } else if (cat == 'sembako') {
      return '🛒';
    } else {
      return '📦';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        // Get all categories from provider
        var allCategories = provider.categories.toList();

        // Jika ada kategori "Sayuran", replace dengan sub-kategori
        final sayuranIndex = allCategories.indexWhere(
          (cat) => cat.toLowerCase().contains('sayur') && cat.toLowerCase() != 'semua',
        );

        if (sayuranIndex != -1) {
          // Hapus "Sayuran" dan insert sub-kategori
          allCategories.removeAt(sayuranIndex);
          allCategories.insertAll(sayuranIndex, [
            'Sayur Daun',
            'Sayur Akar',
            'Sayur Buah',
            'Sayur Polong',
          ]);
        }

        if (allCategories.isEmpty || allCategories.length == 1) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.setCategory('Semua');
                    },
                    child: Text(
                      'View All',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF2F80ED),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120, // Increased height to accommodate longer text
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: allCategories.length,
                itemBuilder: (context, index) {
                  final category = allCategories[index];
                  final color = _getCategoryColor(index);
                  final icon = _getCategoryIcon(category);
                  final isSelected = provider.selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        if (category == 'Semua') {
                          // Jika klik Semua, reset filter
                          provider.setCategory('Semua');
                        } else {
                          // Jika klik kategori lain, buka halaman category products
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryProductsPage(
                                category: category,
                                categoryIcon: _getCategoryEmoji(category),
                              ),
                            ),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color
                                  : color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              icon,
                              size: 28, // Reduced from 32
                              color: isSelected ? Colors.white : color,
                            ),
                          ),
                          const SizedBox(height: 6), // Reduced from 8
                          SizedBox(
                            width: 75, // Slightly wider for long text
                            child: Text(
                              category,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 11, // Reduced from 12
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFF1F2937)
                                    : const Color(0xFF6B7280),
                                height: 1.2, // Line height
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
