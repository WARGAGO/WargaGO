// lib/pages/profile/widgets/produk_saya_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_produk_screen.dart';

class ProdukSayaScreen extends StatelessWidget {
  const ProdukSayaScreen({super.key});

  final List<Map<String, dynamic>> products = const [
    {"name": "Wortel", "price": "Rp 10.000", "stock": 50},
    {"name": "Bayam", "price": "Rp 5.000", "stock": 100},
    {"name": "Kolplay", "price": "Rp 8.000", "stock": 30},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Produk Saya',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Belum ada Produk",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text("Tambahkan Produk Pertama"),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (_, i) {
                final p = products[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: NetworkImage(
                        "https://via.placeholder.com/150",
                      ),
                    ),
                    title: Text(
                      p["name"],
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text("${p["price"]} • Stok: ${p["stock"]}"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F80ED),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TambahProdukScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
