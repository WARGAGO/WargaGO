import 'package:flutter/material.dart';

class TagihanFilterBar extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;
  final VoidCallback onFilterPressed;

  const TagihanFilterBar({
    Key? key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onFilterPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'Semua',
                    selectedStatus == 'Semua',
                    Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Belum Dibayar',
                    selectedStatus == 'Belum Dibayar',
                    Colors.red,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Lunas',
                    selectedStatus == 'Lunas',
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Terlambat',
                    selectedStatus == 'Terlambat',
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: onFilterPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Color color) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onStatusChanged(label);
      },
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.grey[300]!,
      ),
    );
  }
}

