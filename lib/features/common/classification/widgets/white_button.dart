import 'package:flutter/material.dart';

class WhiteButton extends StatelessWidget {
  const WhiteButton({
    super.key,
    this.onTap,
    required this.child,
    this.minWidth = 0,
    this.minHeight = 0,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.padding = const EdgeInsets.all(12),
    this.color = Colors.white,
  });
  final Widget child;
  final void Function()? onTap;
  final double minWidth;
  final double minHeight;
  final double maxWidth;
  final double maxHeight;
  final EdgeInsets padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth,
        minHeight: minHeight,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            padding: padding,
            decoration: BoxDecoration(
              color: onTap == null ? Colors.grey.shade300 : color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
