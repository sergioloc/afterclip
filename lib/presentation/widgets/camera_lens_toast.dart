import 'dart:async';

import 'package:flutter/material.dart';
import '../../domain/entities/camera_lens.dart';
import '../../util/app_colors.dart';
import '../../util/app_spacing.dart';

class CameraLensToast extends StatefulWidget {
  const CameraLensToast({
    super.key,
    required this.lens,
    required this.onDismiss,
  });

  final CameraLens lens;
  final VoidCallback onDismiss;

  @override
  State<CameraLensToast> createState() => _CameraLensToastState();
}

class _CameraLensToastState extends State<CameraLensToast> {
  bool _visible = false;
  Timer? _dismissTimer;
  Timer? _removeTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    _dismissTimer = Timer(const Duration(milliseconds: 2000), _hide);
  }

  void _hide() {
    if (!mounted) return;
    setState(() => _visible = false);
    _removeTimer = Timer(const Duration(milliseconds: 250), widget.onDismiss);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _removeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFront = widget.lens == CameraLens.front;
    final label = isFront ? 'Front camera selected' : 'Rear camera selected';

    return Positioned(
      top: MediaQuery.paddingOf(context).top + 100,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            offset: _visible ? Offset.zero : const Offset(0, -1.4),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              scale: _visible ? 1 : 0.88,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _visible ? 1 : 0,
                child: Material(
                  color: const Color(0xFF202124),
                  elevation: 10,
                  shadowColor: Colors.black54,
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.large,
                      vertical: AppSpacing.medium,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFront
                              ? Icons.photo_camera_front
                              : Icons.photo_camera_back_outlined,
                          color: AppColors.onBackground,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Text(
                          label,
                          style: const TextStyle(
                            color: AppColors.onBackground,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
