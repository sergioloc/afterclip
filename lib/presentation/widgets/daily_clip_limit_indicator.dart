import 'package:flutter/material.dart';
import '../../../util/app_colors.dart';
import '../../../util/app_radius.dart';
import '../../../util/app_spacing.dart';
import '../../../util/app_text_styles.dart';

class DailyClipLimitIndicator extends StatelessWidget {
  const DailyClipLimitIndicator({
    super.key,
    required this.clipsRecorded,
    this.limit = 24,
  });

  final int clipsRecorded;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final isLimitReached = clipsRecorded >= limit;
    final remaining = (limit - clipsRecorded).clamp(0, limit);
    final countColor =
        isLimitReached ? AppColors.primary : AppColors.onBackground;

    return Semantics(
      label:
          '$clipsRecorded of $limit clips recorded in the last 24 hours. '
          '$remaining remaining.',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.large,
          vertical: AppSpacing.large,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LAST 24 HOURS',
              style: AppTextStyles.label.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.medium),
                      Text(
                        '$clipsRecorded',
                        style: AppTextStyles.metric.copyWith(
                          color: countColor,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.medium),
                      Text(
                        'RECORDED',
                        style: AppTextStyles.paragraph.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$remaining',
                        style: AppTextStyles.metric.copyWith(
                          color: countColor,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.medium),
                      Text(
                        'LEFT',
                        style: AppTextStyles.paragraph.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
