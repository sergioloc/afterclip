import 'package:flutter/material.dart';
import 'pill_button.dart';
import '../../../util/app_colors.dart';
import '../../../util/app_radius.dart';
import '../../../util/app_spacing.dart';
import '../../../util/app_text_styles.dart';

class AlbumNameDialog extends StatefulWidget {
  const AlbumNameDialog({
    super.key,
    this.initialValue,
    this.title = 'New album',
    this.hintText = 'Album name',
    this.confirmLabel = 'Create',
    this.cancelLabel = 'Cancel',
  });

  final String? initialValue;
  final String title;
  final String hintText;
  final String confirmLabel;
  final String cancelLabel;

  static Future<String?> show(
    BuildContext context, {
    String? initialValue,
    String title = 'New album',
    String hintText = 'Album name',
    String confirmLabel = 'Create',
    String cancelLabel = 'Cancel',
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Text(
                    widget.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.dialogTitle.copyWith(
                      color: AppColors.onBackground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xLarge),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                style: AppTextStyles.input.copyWith(color: AppColors.onSurface),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _confirm(),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTextStyles.input.copyWith(
                    color: AppColors.outline,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.large, vertical: AppSpacing.large),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PillButton(
                  label: widget.cancelLabel,
                  foregroundColor: AppColors.outline,
                  splashColor: AppColors.onBackground.withValues(alpha: 0.12),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: AppSpacing.medium),
                PillButton(
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

