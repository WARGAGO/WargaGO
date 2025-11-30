import 'package:flutter/material.dart';

class InkWellIconButton extends StatelessWidget {
  const InkWellIconButton({
    super.key,
    this.onTap,
    required this.icon,
    this.padding = 12,
    this.color,
  });
  final Widget icon;
  final double padding;
  final void Function()? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: color ?? Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: icon,
        ),
      ),
    );
  }
}
