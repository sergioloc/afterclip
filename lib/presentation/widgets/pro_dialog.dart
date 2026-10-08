import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../util/app_colors.dart';
import '../../util/app_radius.dart';
import '../../util/app_spacing.dart';
import '../../util/app_text_styles.dart';
import 'pill_button.dart';

class ProDialog extends StatelessWidget {
  const ProDialog({super.key});

  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.slc.afterclip.pro';

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: AppColors.background.withValues(alpha: 0.85),
      builder: (_) => const ProDialog(),
    );
  }

  Future<void> _openPlayStore() {
    return launchUrl(
      Uri.parse(_playStoreUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  TextSpan _appTitle(String text) => TextSpan(
    text: text,
    style: const TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.bold,
      letterSpacing: 2
    ),
  );

  TextSpan _highlight(String text) => TextSpan(
        text: text,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      );

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
              'Upgrade to premium',
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
            Text.rich(
              TextSpan(
                style: AppTextStyles.paragraph.copyWith(
                  color: AppColors.onBackground,
                ),
                children: [
                  const TextSpan(text: 'Download '),
                  _appTitle('AFTERCLIP PRO'),
                  const TextSpan(text: ' to access premium features:'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            Text.rich(
              TextSpan(
                style: AppTextStyles.paragraph.copyWith(
                  color: AppColors.onBackground,
                ),
                children: [
                  const TextSpan(text: '- '),
                  _highlight('Unlimited'),
                  const TextSpan(text: ' clips every day.\n\n- Record clips up to '),
                  _highlight('90 seconds'),
                  const TextSpan(text: '.\n\n- '),
                  _highlight('Battery saver'),
                  const TextSpan(text: ' mode.'),
                ],
              ),
            ),
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
                    label: 'Accept',
                    foregroundColor: AppColors.onPrimary,
                    backgroundColor: AppColors.primary,
                    splashColor: AppColors.onPrimary.withValues(alpha: 0.16),
                    expand: true,
                    onPressed: _openPlayStore,
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
