import 'package:flutter/material.dart';
import '../../../domain/entities/camera_lens.dart';

class LensFlipButton extends StatelessWidget {
  const LensFlipButton({
    super.key,
    required this.lens,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.onToggle,
  });

  final CameraLens lens;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Center(
          child: Icon(
            lens == CameraLens.front
                ? Icons.photo_camera_front
                : Icons.photo_camera_back_outlined,
            color: color,
            size: 26,
          ),
        ),
      ),
    );
  }
}