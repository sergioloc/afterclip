import 'package:flutter/material.dart';
import '../../../util/app_colors.dart';

class AlbumNameDialog extends StatefulWidget {
  const AlbumNameDialog({
    super.key,
    this.initialValue,
    this.title = 'Nuevo álbum',
    this.hintText = 'Nombre del álbum',
    this.confirmLabel = 'Crear',
    this.cancelLabel = 'Cancelar',
  });

  final String? initialValue;
  final String title;
  final String hintText;
  final String confirmLabel;
  final String cancelLabel;

  static Future<String?> show(
    BuildContext context, {
    String? initialValue,
    String title = 'Nuevo álbum',
    String hintText = 'Nombre del álbum',
    String confirmLabel = 'Crear',
    String cancelLabel = 'Cancelar',
  }) {
    return showDialog<String>(
      context: context,
      barrierColor: AppColors.background.withValues(alpha: 0.85),
      builder: (_) => AlbumNameDialog(
        initialValue: initialValue,
        title: title,
        hintText: hintText,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
    );
  }

  @override
  State<AlbumNameDialog> createState() => _AlbumNameDialogState();
}

class _AlbumNameDialogState extends State<AlbumNameDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    if (widget.initialValue != null) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.initialValue!.length,
      );
    }
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  void _confirm() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _controller.text.trim().isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.onBackground,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                style: const TextStyle(color: AppColors.onSurface, fontSize: 16),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _confirm(),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(
                    color: AppColors.outline,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _DialogPillButton(
                  label: widget.cancelLabel,
                  foregroundColor: AppColors.outline,
                  splashColor: AppColors.onBackground.withValues(alpha: 0.12),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                _DialogPillButton(
                  label: widget.confirmLabel,
                  foregroundColor:
                      canConfirm ? AppColors.onPrimary : AppColors.outline,
                  backgroundColor:
                      canConfirm ? AppColors.primary : AppColors.surface,
                  splashColor: AppColors.onPrimary.withValues(alpha: 0.16),
                  onPressed: canConfirm ? _confirm : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogPillButton extends StatelessWidget {
  const _DialogPillButton({
    required this.label,
    required this.foregroundColor,
    required this.splashColor,
    required this.onPressed,
    this.backgroundColor,
  });

  final String label;
  final Color foregroundColor;
  final Color splashColor;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        splashColor: splashColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: foregroundColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}