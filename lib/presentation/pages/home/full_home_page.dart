import 'package:flutter/material.dart';
import '../../../domain/entities/album.dart';
import '../../../util/app_colors.dart';
import '../../widgets/album_frame.dart';
import '../../widgets/app_bar_title.dart';
import '../../widgets/gallery_button.dart';
import '../../widgets/page_indicator.dart';
import '../../widgets/round_action_button.dart';
import '../../widgets/shutter_button.dart';

class FullHomePage extends StatelessWidget {
  const FullHomePage({
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
          accent: AppColors.primary,
          titleColor: AppColors.white,
          highlightColor: AppColors.primary,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: RoundActionButton(
              icon: Icons.settings,
              color: AppColors.white70,
              backgroundColor: AppColors.white05,
              borderColor: AppColors.white24,
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
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.white24,
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
                    color: AppColors.white70,
                    backgroundColor: AppColors.white05,
                    borderColor: AppColors.white24,
                    badgeBackground: AppColors.primary,
                    badgeForeground: AppColors.white,
                    onTap: onOpenAlbums,
                  ),
                  ShutterButton(
                    onTap: onOpenCamera,
                    ringColor: AppColors.primary,
                  ),
                  RoundActionButton(
                    icon: Icons.cameraswitch,
                    color: AppColors.white70,
                    backgroundColor: AppColors.white05,
                    borderColor: AppColors.white24,
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