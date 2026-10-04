import 'package:flutter/material.dart';
import '../../../util/app_colors.dart';
import '../../../util/app_radius.dart';
import '../../../util/app_spacing.dart';
import '../../../util/app_text_styles.dart';

class AlbumsSummary extends StatelessWidget {
  const AlbumsSummary({
    super.key,
    required this.activeAlbums,
    required this.totalClips,
  });

  final int activeAlbums;
  final int totalClips;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.large),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.large,
        vertical: AppSpacing.large,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                  '$activeAlbums',
                  style: AppTextStyles.metric.copyWith(
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Text(
                  activeAlbums == 1 ? 'ACTIVE ALBUM' : 'ACTIVE ALBUMS',
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
                  '$totalClips',
                  style: AppTextStyles.metric.copyWith(
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Text(
                  totalClips == 1 ? 'TOTAL CLIP' : 'TOTAL CLIPS',
                  style: AppTextStyles.paragraph.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
