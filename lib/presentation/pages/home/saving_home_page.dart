import 'package:flutter/material.dart';
import '../../../domain/entities/album.dart';
import '../../../util/app_colors.dart';
import '../../widgets/album_frame.dart';
import '../../widgets/app_bar_title.dart';
import '../../widgets/gallery_button.dart';
import '../../widgets/page_indicator.dart';
import '../../widgets/round_action_button.dart';
import '../../widgets/shutter_button.dart';

class SavingHomePage extends StatelessWidget {
  const SavingHomePage({
    super.key,
    required this.clipCount,
    required this.albums,
    required this.albumIndex,
    required this.albumClipCounts,
    required this.onAlbumChanged,
    required this.onOpenSettings,
    required this.onOpenCamera,
    required this.onOpenAlbums,
  });

  final int clipCount;
  final List<Album> albums;
  final int albumIndex;
  final Map<String, int> albumClipCounts;
  final ValueChanged<int> onAlbumChanged;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenCamera;
  final VoidCallback onOpenAlbums;

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
            child: PageView.builder(
              itemCount: albums.isEmpty ? 1 : albums.length,
              onPageChanged: onAlbumChanged,
              itemBuilder: (context, index) {
                return AlbumFrame(
                  text: albums.isEmpty ? null : albums[index].name,
                  clipCount: albums.isEmpty
                      ? 0
                      : (albumClipCounts[albums[index].id] ?? 0),
                  textColor: AppColors.grey,
                  borderColor: AppColors.grey,
                  bottomInset: 168,
                );
              },
            ),
          ),
          if (albums.length > 1)
            Positioned(
              bottom: 150,
              left: 0,
              right: 0,
              child: Center(
                child: PageIndicator(
                  count: albums.length,
                  currentIndex: albumIndex,
                  activeColor: AppColors.grey,
                  inactiveColor: AppColors.grey.withValues(alpha: 0.3),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GalleryButton(
                    clipCount: clipCount,
                    color: AppColors.grey,
                    backgroundColor: AppColors.black,
                    borderColor: AppColors.grey,
                    badgeBackground: AppColors.grey,
                    badgeForeground: AppColors.black,
                    onTap: onOpenAlbums,
                  ),
                  ShutterButton(
                    onTap: onOpenCamera,
                    ringColor: AppColors.grey,
                  ),
                  RoundActionButton(
                    icon: Icons.cameraswitch,
                    color: AppColors.grey,
                    backgroundColor: AppColors.black,
                    borderColor: AppColors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}