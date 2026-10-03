import 'package:flutter/material.dart';
import '../../../util/app_colors.dart';
import '../../../util/app_radius.dart';
import '../../../util/app_spacing.dart';
import '../../../util/app_text_styles.dart';
import 'pill_button.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Delete',
    this.cancelLabel = 'Cancel',
    this.confirmColor = AppColors.error,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color confirmColor;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Delete',
    String cancelLabel = 'Cancel',
    Color confirmColor = AppColors.error,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: AppColors.background.withValues(alpha: 0.85),
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
      ),
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
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: confirmColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: AppTextStyles.dialogTitle.copyWith(
                      color: AppColors.onBackground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xLarge),
            Text(
              message,
              style: AppTextStyles.paragraph.copyWith(
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: AppSpacing.xLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PillButton(
                  label: cancelLabel,
                  foregroundColor: AppColors.outline,
                  splashColor: AppColors.onBackground.withValues(alpha: 0.12),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                const SizedBox(width: AppSpacing.medium),
                PillButton(
                  label: confirmLabel,
                  foregroundColor: AppColors.onPrimary,
                  backgroundColor: confirmColor,
                  splashColor: AppColors.onPrimary.withValues(alpha: 0.16),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
