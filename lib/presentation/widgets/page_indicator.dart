import 'package:flutter/material.dart';
import '../../../util/app_spacing.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == currentIndex ? 22 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxSmall),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == currentIndex ? activeColor : inactiveColor,
            ),
          ),
      ],
    );
  }
}