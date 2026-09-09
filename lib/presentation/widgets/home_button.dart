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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final int? badge;

  static const double _height = 64;
  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: _height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          color: filled
              ? AppColors.primary
              : AppColors.white.withValues(alpha: 0.05),
          border: filled
              ? null
              : Border.all(
                  color: AppColors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
          boxShadow: filled
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
                  color: filled
                      ? AppColors.white
                      : AppColors.white.withValues(alpha: 0.5),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: filled
                        ? AppColors.white
                        : AppColors.white.withValues(alpha: 0.5),
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
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: AppColors.white,
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