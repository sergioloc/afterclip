import 'package:flutter/material.dart';
import '../../../domain/entities/camera_lens.dart';
import '../../../util/app_colors.dart';
import '../../../util/app_spacing.dart';
import '../../../util/app_text_styles.dart';

class LensSelector extends StatelessWidget {
  const LensSelector({
    super.key,
    required this.lens,
    required this.color,
    required this.onSelect,
  });

  final CameraLens lens;
  final Color color;
  final ValueChanged<CameraLens> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxSmall),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: 'FRONT',
            active: lens == CameraLens.front,
            color: color,
            onTap: () => onSelect(CameraLens.front),
          ),
          const SizedBox(width: AppSpacing.xxSmall),
          _Segment(
            label: 'BACK',
            active: lens == CameraLens.back,
            color: color,
            onTap: () => onSelect(CameraLens.back),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large, vertical: AppSpacing.small),
        decoration: BoxDecoration(
          color: active ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: AppTextStyles.badge.copyWith(
            color: active ? AppColors.background : color,
          ),
        ),
      ),
    );
  }
}