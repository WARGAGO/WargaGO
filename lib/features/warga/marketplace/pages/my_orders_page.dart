// ============================================================================
// MY ORDERS PAGE
// ============================================================================
// Halaman untuk menampilkan daftar pesanan pengguna
// ============================================================================

import 'package:flutter/material.dart';
import '../widgets/my_orders_header.dart';
import '../widgets/order_card.dart';
import '../widgets/orders_empty_state.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: MyOrdersHeader(tabController: _tabController),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList('all'),
          _buildOrderList('processing'),
          _buildOrderList('shipped'),
          _buildOrderList('completed'),
        ],
      ),
    );
  }

  Widget _buildOrderList(String status) {
    // Demo data
    final List<Map<String, dynamic>> orders = [
      {
        'orderId': 'ORD-2025-001',
        'date': '25 Nov 2025',
        'storeName': 'Toko Sayur Rafcol',
        'items': [
          {'name': 'Sayur Wortel', 'qty': 1, 'unit': 'kg'},
          {'name': 'Sayur Bayam', 'qty': 2, 'unit': 'ikat'},
        ],
        'total': 'Rp. 25.000',
        'status': 'processing',
        'statusText': 'Sedang Diproses',
        'statusColor': Color(0xFFF59E0B),
      },
      {
        'orderId': 'ORD-2025-002',
        'date': '24 Nov 2025',
        'storeName': 'Toko Sayur Segar',
        'items': [
          {'name': 'Kentang', 'qty': 3, 'unit': 'kg'},
        ],
        'total': 'Rp. 30.000',
        'status': 'shipped',
        'statusText': 'Dalam Pengiriman',
        'statusColor': Color(0xFF2F80ED),
      },
      {
        'orderId': 'ORD-2025-003',
        'date': '23 Nov 2025',
        'storeName': 'Toko Sayur Rafcol',
        'items': [
          {'name': 'Tomat', 'qty': 2, 'unit': 'kg'},
        ],
        'total': 'Rp. 20.000',
        'status': 'completed',
        'statusText': 'Selesai',
        'statusColor': Color(0xFF2F80ED),
      },
    ];

    // Filter orders based on status
    List<Map<String, dynamic>> filteredOrders = orders;
    if (status != 'all') {
      filteredOrders = orders.where((order) => order['status'] == status).toList();
    }

    if (filteredOrders.isEmpty) {
      return const OrdersEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return OrderCard(
          orderId: order['orderId'],
          date: order['date'],
          storeName: order['storeName'],
          items: List<Map<String, dynamic>>.from(order['items']),
          total: order['total'],
          status: order['status'],
          statusText: order['statusText'],
          statusColor: order['statusColor'],
        );
      },
    );
  }
}
