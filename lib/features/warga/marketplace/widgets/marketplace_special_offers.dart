// ============================================================================
// MARKETPLACE SPECIAL OFFERS WIDGET
// ============================================================================
// Carousel untuk special offers, diskon, dan toko baru
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketplaceSpecialOffers extends StatefulWidget {
  const MarketplaceSpecialOffers({super.key});

  @override
  State<MarketplaceSpecialOffers> createState() => _MarketplaceSpecialOffersState();
}

class _MarketplaceSpecialOffersState extends State<MarketplaceSpecialOffers> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OfferData> _offers = [
    _OfferData(
      title: 'Up to 50% Discount',
      subtitle: 'Sayuran Segar',
      gradient: const [Color(0xFFFF9800), Color(0xFFFF6F00)],
      icon: Icons.local_offer,
    ),
    _OfferData(
      title: 'Toko Baru!',
      subtitle: 'Warung Bu Siti',
      gradient: const [Color(0xFF2F80ED), Color(0xFF1E5BB8)],
      icon: Icons.store_outlined,
    ),
    _OfferData(
      title: 'Gratis Ongkir',
      subtitle: 'Min. Belanja Rp 50.000',
      gradient: const [Color(0xFF2F80ED), Color(0xFF1E5BB8)],
      icon: Icons.local_shipping_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Auto scroll
    Future.delayed(const Duration(seconds: 3), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;

    final nextPage = (_currentPage + 1) % _offers.length;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(seconds: 3), _autoScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Special Offers',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See All Offer',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF2F80ED),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 145, // Reduced from 160
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _offers.length,
            itemBuilder: (context, index) {
              final offer = _offers[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16), // Reduced from 20
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: offer.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: offer.gradient.first.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            offer.title,
                            style: GoogleFonts.poppins(
                              fontSize: 18, // Reduced from 20
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6), // Reduced from 8
                          Text(
                            offer.subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 14, // Reduced from 16
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 70, // Reduced from 80
                      height: 70, // Reduced from 80
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        offer.icon,
                        size: 35, // Reduced from 40
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _offers.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF2F80ED)
                    : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfferData {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;

  _OfferData({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });
}

