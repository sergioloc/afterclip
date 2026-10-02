import 'package:flutter/material.dart';
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
        const SizedBox(width: 10),
        Text(
          'AFTER',
          style: AppTextStyles.brandTitle.copyWith(color: titleColor),
        ),
        Text(
          'CLIP',
          style: AppTextStyles.brandTitle.copyWith(color: highlightColor),
        ),
      ],
    );
  }
}