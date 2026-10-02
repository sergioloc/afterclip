import 'package:flutter/material.dart';
import '../../../util/app_flavor.dart';
import '../../../util/app_radius.dart';
import '../../../util/app_spacing.dart';
import '../../../util/app_text_styles.dart';

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({
    super.key,
    required this.accent,
    required this.titleColor,
    required this.highlightColor,
  });

  final Color accent;
  final Color titleColor;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent,
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Text(
          'AFTER',
          style: AppTextStyles.brandTitle.copyWith(color: titleColor),
        ),
        Text(
          'CLIP',
          style: AppTextStyles.brandTitle.copyWith(color: highlightColor),
        ),
        if (AppFlavorConfig.isPro) ...[
          const SizedBox(width: AppSpacing.small),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.small,
              vertical: AppSpacing.xxSmall,
            ),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.small),
              border: Border.all(color: accent.withValues(alpha: 0.55)),
            ),
            child: Text(
              'PRO',
              style: AppTextStyles.label.copyWith(
                color: accent,
                fontSize: AppTextSizes.labelMedium,
              ),
            ),
          ),
        ],
      ],
    );
  }
}