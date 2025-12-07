// ============================================================================
// ORDER DETAIL PAGE
// ============================================================================
// Halaman detail pesanan lengkap dengan tracking status
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/providers/order_provider.dart';

class OrderDetailPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailPage({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Pesanan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildOrderInfoCard(),
            const SizedBox(height: 16),
            _buildProductsCard(),
            const SizedBox(height: 16),
            _buildShippingInfoCard(),
            const SizedBox(height: 16),
            _buildPaymentSummaryCard(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(order.statusColorValue).withValues(alpha: 0.1),
            Color(order.statusColorValue).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(order.statusColorValue).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(),
            size: 48,
            color: Color(order.statusColorValue),
          ),
          const SizedBox(height: 12),
          Text(
            order.statusText,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(order.statusColorValue),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusMessage(),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusTimeline(),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (order.status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.processing:
        return Icons.inventory_2;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusMessage() {
    switch (order.status) {
      case OrderStatus.pending:
        return 'Pesanan Anda sedang menunggu konfirmasi dari penjual';
      case OrderStatus.processing:
        return 'Pesanan Anda sedang diproses oleh penjual';
      case OrderStatus.shipped:
        return 'Pesanan Anda sedang dalam perjalanan';
      case OrderStatus.completed:
        return 'Pesanan telah selesai. Terima kasih!';
      case OrderStatus.cancelled:
        return 'Pesanan telah dibatalkan';
    }
  }

  Widget _buildStatusTimeline() {
    final statuses = [
      {'status': OrderStatus.pending, 'label': 'Pending'},
      {'status': OrderStatus.processing, 'label': 'Diproses'},
      {'status': OrderStatus.shipped, 'label': 'Dikirim'},
      {'status': OrderStatus.completed, 'label': 'Selesai'},
    ];

    final currentIndex = statuses.indexWhere(
      (s) => s['status'] == order.status,
    );

    return Row(
      children: List.generate(statuses.length, (index) {
        final isActive = index <= currentIndex;
        final status = statuses[index];

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isActive
                            ? Color(order.statusColorValue)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Color(order.statusColorValue)
                          : const Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    child: isActive
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  if (index < statuses.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isActive
                            ? Color(order.statusColorValue)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                status['label'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? Color(order.statusColorValue)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderInfoCard() {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pesanan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('No. Pesanan', order.orderId),
          _buildInfoRow('Tanggal', dateFormat.format(order.createdAt)),
          _buildInfoRow('Penjual', order.sellerName),
          _buildInfoRow('Telepon Penjual', order.sellerPhone),
          if (order.notes != null && order.notes!.isNotEmpty)
            _buildInfoRow('Catatan', order.notes!),
        ],
      ),
    );
  }

  Widget _buildProductsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produk Pesanan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => _buildProductItem(item)),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.productImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} ${item.unit} x Rp ${item.price.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${item.subtotal.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2F80ED),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF2F80ED),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informasi Pengiriman',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Nama Penerima', order.buyerName),
          _buildInfoRow('Telepon', order.buyerPhone),
          _buildInfoRow('Alamat', order.buyerAddress, isAddress: true),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Subtotal', order.subtotal),
          _buildPriceRow('Biaya Pengiriman', order.shippingCost),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                'Rp ${order.totalAmount.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2F80ED),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAddress = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: isAddress ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          Text(
            'Rp ${amount.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    if (!order.canCancel && !order.canComplete) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (order.canCancel)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showCancelDialog(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Batalkan Pesanan',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
            if (order.canCancel && order.canComplete) const SizedBox(width: 12),
            if (order.canComplete)
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmReceived(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Pesanan Diterima',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Batalkan Pesanan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yakin ingin membatalkan pesanan ini?',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Alasan pembatalan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mohon masukkan alasan pembatalan'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);

              final orderProvider = context.read<OrderProvider>();
              final success = await orderProvider.cancelOrder(
                orderId: order.id,
                cancelReason: reason,
              );

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Pesanan berhasil dibatalkan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(orderProvider.error ?? 'Gagal membatalkan pesanan'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Batalkan Pesanan'),
          ),
        ],
      ),
    );
  }

  void _confirmReceived(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Konfirmasi Penerimaan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda sudah menerima pesanan ini?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Belum'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Sudah Terima'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final orderProvider = context.read<OrderProvider>();
      final success = await orderProvider.updateOrderStatus(
        orderId: order.id,
        newStatus: OrderStatus.completed,
      );

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Pesanan telah selesai'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(orderProvider.error ?? 'Gagal mengupdate status'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

