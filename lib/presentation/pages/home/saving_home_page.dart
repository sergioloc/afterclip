import 'package:flutter/material.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/entities/camera_lens.dart';
import '../../../util/app_colors.dart';
import '../../widgets/album_frame.dart';
import '../../widgets/app_bar_title.dart';
import '../../widgets/lens_selector.dart';
import '../../widgets/page_indicator.dart';
import '../../widgets/round_action_button.dart';
import '../../widgets/shutter_button.dart';

class SavingHomePage extends StatelessWidget {
  static const bool useButtonAsLensIndicator = true;

  const SavingHomePage({
    super.key,
    required this.albums,
    required this.albumIndex,
    required this.albumClipCounts,
    required this.lens,
    required this.onAlbumChanged,
    required this.onToggleCamera,
    required this.onSelectLens,
    required this.onOpenSettings,
    required this.onOpenCamera,
    required this.onOpenAlbums,
    required this.onArchiveAlbum,
  });

  final List<Album?> albums;
  final int albumIndex;
  final Map<String, int> albumClipCounts;
  final CameraLens lens;
  final ValueChanged<int> onAlbumChanged;
  final VoidCallback onToggleCamera;
  final ValueChanged<CameraLens> onSelectLens;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenCamera;
  final VoidCallback onOpenAlbums;
  final ValueChanged<String?> onArchiveAlbum;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 20,
        title: const AppBarTitle(
          accent: AppColors.outline,
          titleColor: AppColors.outline,
          highlightColor: AppColors.outline,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: RoundActionButton(
              icon: Icons.settings,
              border: false,
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
                    text: albums.isEmpty ? null : albums[index]?.name,
                    clipCount: albums.isEmpty
                        ? 0
                        : (albums[index] == null
                            ? 0
                            : (albumClipCounts[albums[index]!.id] ?? 0)),
                    textColor: AppColors.outline,
                    borderColor: AppColors.outline,
                    topMargin: useButtonAsLensIndicator ? 24 : 64,
                    bottomInset: 168,
                    onArchive: albums.isEmpty || albums[index] == null
                        ? null
                        : () => onArchiveAlbum(albums[index]!.id),
                    archiveButtonColor: AppColors.outline,
                    archiveButtonBackground: AppColors.background,
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
                  activeColor: AppColors.outline,
                  inactiveColor: AppColors.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
          if (!useButtonAsLensIndicator)
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: LensSelector(
                  lens: lens,
                  color: AppColors.outline,
                  onSelect: onSelectLens,
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
                  RoundActionButton(
                    icon: Icons.photo_library_outlined,
                    onTap: onOpenAlbums,
                    border: false,
                  ),
                  ShutterButton(
                    onTap: onOpenCamera,
                    color: AppColors.background,
                    ringColor: AppColors.outline,
                  ),
                  if (useButtonAsLensIndicator)
                    RoundActionButton(
                      icon: lens == CameraLens.front
                          ? Icons.photo_camera_front
                          : Icons.photo_camera_back_outlined,
                      onTap: onToggleCamera,
                      border: false,
                    )
                  else
                    RoundActionButton(
                      icon: Icons.cameraswitch,
                      onTap: onToggleCamera,
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