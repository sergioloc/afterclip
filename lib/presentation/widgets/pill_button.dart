import 'package:flutter/material.dart';
import '../../util/app_radius.dart';
import '../../util/app_spacing.dart';
import '../../util/app_text_styles.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.foregroundColor,
    required this.splashColor,
    required this.onPressed,
    this.backgroundColor,
    this.expand = false,
  });

  final String label;
  final Color foregroundColor;
  final Color splashColor;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label.toUpperCase(),
      style: AppTextStyles.label.copyWith(
        color: foregroundColor,
      ),
    );

    return Material(
      color: backgroundColor ?? Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        splashColor: splashColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xLarge,
            vertical: AppSpacing.medium,
          ),
          child: expand
              ? SizedBox(width: double.infinity, child: Center(child: text))
              : text,
        ),
      ),
    );
  }
}
