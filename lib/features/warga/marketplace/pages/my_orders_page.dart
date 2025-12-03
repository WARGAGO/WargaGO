// ============================================================================
// MY ORDERS PAGE
// ============================================================================
// Halaman untuk menampilkan daftar pesanan pengguna dari backend
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/order_provider.dart';
import '../../../../core/models/order_model.dart';
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

    // Load orders saat page dibuka
    Future.microtask(() {
      context.read<OrderProvider>().loadMyOrders();
    });
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
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          // Loading state
          if (orderProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (orderProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    orderProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => orderProvider.loadMyOrders(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(orderProvider.allOrders),
              _buildOrderList(orderProvider.processingOrders),
              _buildOrderList(orderProvider.shippedOrders),
              _buildOrderList(orderProvider.completedOrders),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders) {
    // Jika tidak ada orders, tampilkan empty state
    if (orders.isEmpty) {
      return const OrdersEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<OrderProvider>().loadMyOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          // Convert items untuk OrderCard widget
          final items = order.items.map((item) => {
            'name': item.productName,
            'qty': item.quantity,
            'unit': item.unit,
          }).toList();

          // Format date
          final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
          final formattedDate = dateFormat.format(order.createdAt);

          return OrderCard(
            orderId: order.orderId,
            date: formattedDate,
            storeName: order.sellerName,
            items: items,
            total: 'Rp ${order.totalAmount.toStringAsFixed(0)}',
            status: order.status.name,
            statusText: order.statusText,
            statusColor: Color(order.statusColorValue),
          );
        },
      ),
    );
  }
}
