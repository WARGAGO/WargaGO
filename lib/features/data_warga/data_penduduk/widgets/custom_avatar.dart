import 'package:flutter/material.dart';

/// Custom avatar widget for displaying icons in a circular container
class CustomAvatar extends StatelessWidget {
  final IconData icon;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;

  const CustomAvatar({
    super.key,
    required this.icon,
    this.radius = 20,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.white,
        child: Icon(
          icon,
          color: iconColor ?? const Color(0xFF2F80ED),
          size: radius * 0.9,
        ),
      ),
    );
  }
}
