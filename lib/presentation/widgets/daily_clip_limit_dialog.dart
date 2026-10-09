import 'package:flutter/material.dart';
import '../../data/repositories/daily_clip_limit_repository.dart';
import '../../util/app_colors.dart';
import '../../util/app_text_styles.dart';
import 'pro_upgrade_layout.dart';

class DailyClipLimitDialog extends StatelessWidget {
  const DailyClipLimitDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: AppColors.background.withValues(alpha: 0.85),
      builder: (_) => const DailyClipLimitDialog(),
    );
  }

  TextSpan _highlight(String text) => TextSpan(
    text: text,
    style: const TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.bold,
    ),
  );

  TextSpan _appTitle(String text) => TextSpan(
    text: text,
    style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 2
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ProUpgradeLayout(
      title: '24-hour limit reached',
      body: Text.rich(
        TextSpan(
          style: AppTextStyles.paragraph.copyWith(
            color: AppColors.onBackground,
          ),
          children: [
            const TextSpan(text: 'The free version allows '),
            TextSpan(
              text: '${DailyClipLimitRepository.maxClips} clips',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' in the last 24 hours.\n\n'),
            const TextSpan(text: '- Wait for one of your clips to be over '),
            _highlight('24 hours old'),
            const TextSpan(text: ', which frees up a slot.\n\n'),
            const TextSpan(text: '- Or download '),
            _appTitle('AFTERCLIP PRO'),
            const TextSpan(text: ' for unlimited clips.'),
          ],
        ),
      ),
    );
  }
}
