import 'package:flutter/material.dart';
import '../../../util/app_colors.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
    this.badge,
    this.glow = true,
    this.fillColor,
    this.showBorder = false,
    this.badgeColor = AppColors.primary,
    this.badgeTextColor = AppColors.white,
    this.foregroundColor,
    this.borderColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final int? badge;
  final bool glow;
  final Color? fillColor;
  final bool showBorder;
  final Color badgeColor;
  final Color badgeTextColor;
  final Color? foregroundColor;
  final Color? borderColor;

  static const double _height = 64;
  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        fillColor ?? (filled ? AppColors.primary : AppColors.white.withValues(alpha: 0.05));
    final Color foregroundColor = this.foregroundColor ??
        (filled || fillColor != null ? AppColors.white : AppColors.white.withValues(alpha: 0.5));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: _height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          color: backgroundColor,
          border: filled && !showBorder
              ? null
              : Border.all(
                  color: borderColor ?? AppColors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
          boxShadow: filled && glow
              ? [
                  BoxShadow(
                    color: AppColors.red.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: foregroundColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: foregroundColor,
                  ),
                ),
              ],
            ),
            if (badge != null && badge! > 0)
              Positioned(
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$badge',
                    style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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