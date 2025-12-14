import 'package:flutter/material.dart';

class PengeluaranPage extends StatelessWidget {
  const PengeluaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Fitur Pengeluaran\nSegera Hadir',
          style: TextStyle(fontSize: 24, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
