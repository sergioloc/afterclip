import 'package:flutter/material.dart';

class RoundActionButton extends StatelessWidget {
  const RoundActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.5)
              : null,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}