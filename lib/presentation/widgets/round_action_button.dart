import 'package:afterclip/util/app_colors.dart';
import 'package:flutter/material.dart';

class RoundActionButton extends StatelessWidget {

  const RoundActionButton({
    super.key,
    required this.icon,
    this.border = true,
    this.onTap,
  });

  final IconData icon;
  final bool border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.background,
          border: border
              ? Border.all(color: AppColors.outline, width: 1)
              : null,
        ),
        child: Icon(icon, color: AppColors.outline, size: 24),
      ),
    );
  }
}