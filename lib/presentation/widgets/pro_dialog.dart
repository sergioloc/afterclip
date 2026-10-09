import 'package:flutter/material.dart';
import '../../util/app_colors.dart';
import '../../util/app_spacing.dart';
import '../../util/app_text_styles.dart';
import 'pro_upgrade_layout.dart';

class ProDialog extends StatelessWidget {
  const ProDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: AppColors.background.withValues(alpha: 0.85),
      builder: (_) => const ProDialog(),
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
    return ProUpgradeLayout(
      title: 'Upgrade to premium',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
        ],
      ),
    );
  }
}
