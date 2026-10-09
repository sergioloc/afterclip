import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../util/app_colors.dart';
import '../../util/app_radius.dart';
import '../../util/app_spacing.dart';
import '../../util/app_text_styles.dart';
import 'pill_button.dart';

class ProUpgradeLayout extends StatelessWidget {
  const ProUpgradeLayout({
    super.key,
    required this.title,
    required this.body,
    this.acceptLabel = 'Get Pro',
  });

  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.slc.afterclip.pro';

  final String title;
  final Widget body;
  final String acceptLabel;

  static Future<void> openPlayStore() {
    return launchUrl(
      Uri.parse(_playStoreUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xLarge),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.onBackground, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.dialogTitle.copyWith(
                color: AppColors.onBackground,
                fontSize: AppTextSizes.titleLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.xxLarge),
            SizedBox(
              height: 140,
              child: Lottie.asset(
                'assets/animations/premium.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: AppSpacing.xxLarge),
            body,
            const SizedBox(height: AppSpacing.xLarge),
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    label: 'Later',
                    foregroundColor: AppColors.outline,
                    borderColor: AppColors.outline,
                    splashColor: AppColors.onBackground.withValues(alpha: 0.12),
                    expand: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: PillButton(
                    label: acceptLabel,
                    foregroundColor: AppColors.onPrimary,
                    backgroundColor: AppColors.primary,
                    splashColor: AppColors.onPrimary.withValues(alpha: 0.16),
                    expand: true,
                    onPressed: openPlayStore,
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
