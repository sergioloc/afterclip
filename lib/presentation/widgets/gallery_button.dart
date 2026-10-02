import 'package:flutter/material.dart';

class GalleryButton extends StatelessWidget {
  const GalleryButton({
    super.key,
    this.clipCount = 0,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.badgeBackground,
    required this.badgeForeground,
    required this.onTap,
  });

  final int clipCount;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final Color badgeBackground;
  final Color badgeForeground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 52,
        height: 52,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Icon(Icons.photo_library_outlined, color: color, size: 24),
        ),
      ),
    );
  }
}