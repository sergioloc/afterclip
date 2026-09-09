import 'package:flutter/material.dart';
import '../../../util/app_colors.dart';
import '../../widgets/gallery_button.dart';
import '../../widgets/app_bar_title.dart';
import '../../widgets/picture_frame.dart';
import '../../widgets/round_action_button.dart';
import '../../widgets/shutter_button.dart';

class SavingHomePage extends StatelessWidget {
  const SavingHomePage({
    super.key,
    required this.clipCount,
    required this.onOpenSettings,
    required this.onOpenCamera,
    required this.onOpenClips,
  });

  final int clipCount;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenCamera;
  final VoidCallback onOpenClips;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        titleSpacing: 20,
        title: const AppBarTitle(
          accent: AppColors.grey,
          titleColor: AppColors.grey,
          highlightColor: AppColors.grey,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: RoundActionButton(
              icon: Icons.settings,
              color: AppColors.grey,
              backgroundColor: AppColors.black,
              onTap: onOpenSettings,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: const PictureFrame(bottomInset: 168),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: ShutterButton(
                onTap: onOpenCamera,
                ringColor: AppColors.grey,
              ),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 32,
            child: GalleryButton(
              clipCount: clipCount,
              color: AppColors.grey,
              backgroundColor: AppColors.black,
              borderColor: AppColors.grey,
              badgeBackground: AppColors.grey,
              badgeForeground: AppColors.black,
              onTap: onOpenClips,
            ),
          ),
          Positioned(
            right: 24,
            bottom: 32,
            child: RoundActionButton(
              icon: Icons.cameraswitch,
              color: AppColors.grey,
              backgroundColor: AppColors.black,
              borderColor: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}