import 'package:flutter/material.dart';
import '../../../util/app_colors.dart';
import '../../../util/app_spacing.dart';

class StopRecordingButton extends StatelessWidget {
  const StopRecordingButton({super.key, required this.onTap, this.size = 84});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.small),
            ),
          ),
        ),
      ),
    );
  }
}
