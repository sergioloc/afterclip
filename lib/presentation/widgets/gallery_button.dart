import 'package:flutter/material.dart';
import '../../../util/app_text_styles.dart';

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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Icon(Icons.photo_library_outlined, color: color, size: 24),
            ),
            if (clipCount > 0)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: badgeBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$clipCount',
                    style: AppTextStyles.badge.copyWith(
                      color: badgeForeground,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}