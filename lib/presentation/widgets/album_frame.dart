import 'package:flutter/material.dart';
import '../../../util/app_colors.dart';

class AlbumFrame extends StatelessWidget {
  const AlbumFrame({
    super.key,
    this.text,
    this.clipCount = 0,
    this.textColor = AppColors.white,
    this.horizontalMargin = 24,
    this.topMargin = 24,
    required this.bottomInset,
    this.borderColor = AppColors.white,
    this.radius = 20,
    this.borderWidth = 2,
  });

  final String? text;
  final int clipCount;
  final Color textColor;

  /// Margen horizontal del marco respecto al ancho de la página.
  final double horizontalMargin;

  /// Margen superior del marco respecto a la toolbar.
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
            child: text == null
                ? null
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            text!.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              letterSpacing: 8,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: textColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                color: textColor,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$clipCount',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}