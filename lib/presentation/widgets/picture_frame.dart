import 'package:flutter/material.dart';
import '../../../util/app_colors.dart';

class PictureFrame extends StatelessWidget {
  const PictureFrame({
    super.key,
    this.horizontalMargin = 24,
    this.topMargin = 24,
    required this.bottomInset,
    this.borderColor = AppColors.white,
    this.radius = 20,
    this.borderWidth = 1,
  });

  final double horizontalMargin;
  final double topMargin;

  /// Espacio reservado en la parte inferior (hasta el botón de grabar + margen).
  final double bottomInset;
  final Color borderColor;
  final double radius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - horizontalMargin * 2;
        final height = constraints.maxHeight - topMargin - bottomInset;
        if (width <= 0 || height <= 0) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalMargin,
            topMargin,
            horizontalMargin,
            bottomInset,
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
          ),
        );
      },
    );
  }
}