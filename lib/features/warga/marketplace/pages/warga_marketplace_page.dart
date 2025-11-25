// ============================================================================
// WARGA MARKETPLACE PAGE
// ============================================================================
// Halaman utama untuk warga akses marketplace
// ============================================================================

import 'package:flutter/material.dart';
import '../widgets/marketplace_header.dart';
import '../widgets/marketplace_program_card.dart';
import '../widgets/marketplace_daftar_button.dart';

class WargaMarketplacePage extends StatelessWidget {
  const WargaMarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const MarketplaceHeader(),
          Positioned(
            top: 170,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    MarketplaceProgramCard(),
                    MarketplaceDaftarButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
