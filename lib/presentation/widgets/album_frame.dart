import 'package:flutter/material.dart';
import '../../../util/app_colors.dart';
import '../../../util/app_spacing.dart';
import '../../../util/app_text_styles.dart';

class AlbumFrame extends StatelessWidget {
  const AlbumFrame({
    super.key,
    this.text,
    this.clipCount = 0,
    this.textColor = AppColors.onBackground,
    this.horizontalMargin = AppSpacing.xLarge,
    this.topMargin = AppSpacing.xLarge,
    required this.bottomInset,
    this.borderColor = AppColors.onBackground,
    this.radius = 20,
    this.borderWidth = 1,
    this.onArchive,
    this.archiveButtonColor = AppColors.onSurface,
    this.archiveButtonBackground = AppColors.surface,
  });

  final String? text;
  final int clipCount;
  final Color textColor;

  /// Acción de archivar el álbum. Solo se muestra si es distinto de null.
  final VoidCallback? onArchive;
  final Color archiveButtonColor;
  final Color archiveButtonBackground;

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
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
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
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
                              child: Text(
                                text!.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.display.copyWith(
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.large),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.medium,
                                vertical: AppSpacing.xxSmall,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: textColor),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$clipCount CLIPS',
                                style: AppTextStyles.label.copyWith(
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              if (onArchive != null)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: GestureDetector(
                    onTap: onArchive,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: archiveButtonBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.archive,
                        color: archiveButtonColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}