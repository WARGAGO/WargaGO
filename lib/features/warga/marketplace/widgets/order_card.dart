// ============================================================================
// ORDER CARD WIDGET
// ============================================================================
// Card untuk menampilkan detail pesanan
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/order_model.dart';
import '../pages/order_detail_page.dart';

class OrderCard extends StatelessWidget {
  // Primary: OrderModel
  final OrderModel? orderModel;

  // Legacy parameters for backward compatibility
  final String? orderId;
  final String? date;
  final String? storeName;
  final List<Map<String, dynamic>>? items;
  final String? total;
  final String? status;
  final String? statusText;
  final Color? statusColor;

  const OrderCard({
    super.key,
    this.orderModel,
    this.orderId,
    this.date,
    this.storeName,
    this.items,
    this.total,
    this.status,
    this.statusText,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    // Use orderModel if available, otherwise use legacy parameters
    final displayOrderId = orderModel?.orderId ?? orderId ?? '';
    final displayDate = orderModel != null
        ? DateFormat('dd MMM yyyy', 'id_ID').format(orderModel!.createdAt)
        : date ?? '';
    final displayStoreName = orderModel?.sellerName ?? storeName ?? '';
    final displayItems = orderModel?.items.map((item) => {
      'name': item.productName,
      'qty': item.quantity,
      'unit': item.unit,
    }).toList() ?? items ?? [];
    final displayTotal = orderModel != null
        ? 'Rp ${orderModel!.totalAmount.toStringAsFixed(0)}'
        : total ?? '';
    final displayStatus = orderModel?.status.name ?? status ?? '';
    final displayStatusText = orderModel?.statusText ?? statusText ?? '';
    final displayStatusColor = orderModel != null
        ? Color(orderModel!.statusColorValue)
        : (statusColor ?? Colors.grey);

    return GestureDetector(
      onTap: () {
        // Only navigate if we have a valid OrderModel
        if (orderModel != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(order: orderModel!),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(displayStoreName, displayStatusText, displayStatusColor),

            // Order Details
            _buildOrderDetails(displayOrderId, displayDate, displayItems, displayTotal),

            // Actions
            if (displayStatus == 'completed') _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String storeName, String statusText, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.storefront,
                  size: 16,
                  color: Color(0xFF2F80ED),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                storeName,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusText,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(String orderId, String date, List<Map<String, dynamic>> items, String total) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                date,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2F80ED),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item['name']} (${item['qty']} ${item['unit']})',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          )),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Text(
                total,
                style: GoogleFonts.poppins(
                  fontSize: 16,
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

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // TODO: Beli lagi
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2F80ED)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                'Beli Lagi',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2F80ED),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Beri ulasan
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F80ED),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                elevation: 0,
              ),
              child: Text(
                'Beri Ulasan',
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
    );
  }
}

