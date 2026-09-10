import 'package:flutter/material.dart';

class ShutterButton extends StatelessWidget {
  const ShutterButton({
    super.key,
    required this.onTap,
    required this.color,
    required this.ringColor,
    this.size = 84,
  });

  final VoidCallback onTap;
  final Color color;
  final Color ringColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Widget shutter = GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ringColor, width: 4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
      ),
    );

    return SizedBox(
      width: size + 24,
      height: size + 24,
      child: Center(child: shutter),
    );
  }
}