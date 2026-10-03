import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../data/datasource/local/album_local_datasource.dart';
import '../../../../data/datasource/local/clip_local_datasource.dart';
import '../../../../data/repositories/album_repository_impl.dart';
import '../../../../data/repositories/clip_repository_impl.dart';
import '../../../../data/services/gallery_service.dart';
import '../../../../domain/entities/clip.dart';
import '../../../../domain/usecases/get_all_clips_usecase.dart';
import '../../../../domain/usecases/set_album_archived_usecase.dart';
import '../../../../util/app_colors.dart';
import '../../../../util/app_radius.dart';
import '../../../../util/app_spacing.dart';
import '../../widgets/page_title.dart';

enum _ClipAction { download, delete }

class ClipsPage extends StatefulWidget {
  const ClipsPage({super.key, this.albumId, this.title, this.archived = false});

  final String? albumId;
  final String? title;
  final bool archived;

  @override
  State<ClipsPage> createState() => _ClipsPageState();
}

class _ClipsPageState extends State<ClipsPage> {
  late final GetAllClipsUseCase _getAllClipsUseCase;
  List<Clip> _clips = [];
  bool _loading = true;
  Timer? _availabilityTimer;

  @override
  void initState() {
    super.initState();
    final repository = ClipRepositoryImpl(ClipLocalDatasource());
    _getAllClipsUseCase = GetAllClipsUseCase(repository);
    _loadClips();
  }

  Future<void> _loadClips() async {
    var clips = await _getAllClipsUseCase.execute();
    if (widget.albumId != null) {
      clips = clips.where((c) => c.albumId == widget.albumId).toList();
    }
    if (mounted) {
      setState(() {
        _clips = clips;
        _loading = false;
      });
      _scheduleAvailabilityRefresh();
    }
  }

  void _scheduleAvailabilityRefresh() {
    _availabilityTimer?.cancel();
    final nextUnlock = _clips
        .where((clip) => !clip.isAvailable)
        .map((clip) => clip.createdAt.add(const Duration(hours: 24)))
        .fold<DateTime?>(
          null,
          (earliest, unlock) => earliest == null || unlock.isBefore(earliest) ? unlock : earliest,
        );

    if (nextUnlock == null) return;

    final delay = nextUnlock.difference(DateTime.now()) + const Duration(seconds: 1);
    _availabilityTimer = Timer(
      delay.isNegative ? const Duration(seconds: 1) : delay,
      () {
        if (!mounted) return;
        setState(() {});
        _scheduleAvailabilityRefresh();
      },
    );
  }

  void _playClip(Clip clip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClipPlayerPage(clip: clip),
      ),
    );
  }

  Future<void> _unarchiveAlbum() async {
    if (widget.albumId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text(
          'Unarchive album',
          style: TextStyle(color: AppColors.onBackground),
        ),
        content: const Text(
          'This album will appear on the home screen again.',
          style: TextStyle(color: AppColors.onBackground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.outline)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unarchive', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await SetAlbumArchivedUseCase(
      AlbumRepositoryImpl(AlbumLocalDatasource()),
    ).execute(widget.albumId!, false);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _deleteClip(Clip clip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text(
          'Delete clip',
          style: TextStyle(color: AppColors.onBackground),
        ),
        content: Text(
          'Are you sure you want to delete this clip?',
          style: const TextStyle(color: AppColors.onBackground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.outline)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final repository = ClipRepositoryImpl(ClipLocalDatasource());
    await repository.deleteClip(clip.id);

    setState(() => _loading = true);
    await _loadClips();
  }

  final _galleryService = GalleryService();

  Future<void> _downloadClip(Clip clip) async {
    try {
      await _galleryService.saveVideo(clip.filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video saved to your gallery.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('GalleryService saveVideo error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving the video.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showClipOptions(Clip clip) async {
    final isBlocked = !clip.isAvailable;
    final action = await showModalBottomSheet<_ClipAction>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.medium),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.large,
                vertical: AppSpacing.large,
              ),
              child: Text(
                _formatDate(clip.createdAt),
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: AppColors.surface, height: 1),
            const SizedBox(height: AppSpacing.small),
            ListTile(
              enabled: !isBlocked,
              leading: Icon(
                Icons.download_outlined,
                color: isBlocked ? AppColors.surface : AppColors.onBackground,
              ),
              title: Text(
                'Download',
                style: TextStyle(
                  color: isBlocked ? AppColors.surface : AppColors.onBackground,
                ),
              ),
              subtitle: isBlocked
                  ? Text(
                      'Available in ${_formatCountdown(clip.timeUntilAvailable)}',
                      style: const TextStyle(color: AppColors.outline),
                    )
                  : null,
              onTap: isBlocked
                  ? null
                  : () => Navigator.pop(sheetContext, _ClipAction.download),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () => Navigator.pop(sheetContext, _ClipAction.delete),
            ),
            const SizedBox(height: AppSpacing.small),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;
    switch (action) {
      case _ClipAction.download:
        await _downloadClip(clip);
        break;
      case _ClipAction.delete:
        await _deleteClip(clip);
        break;
    }
  }

  @override
  void dispose() {
    _availabilityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(
          children: [
            if (widget.title != null)
              PageTitle(widget.title!),
            const Spacer(),
            if (widget.archived)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.medium),
                child: IconButton(
                  icon: const Icon(Icons.unarchive, color: AppColors.onBackground),
                  onPressed: _unarchiveAlbum,
                ),
              ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.onBackground))
          : _clips.isEmpty
          ? const Center(
              child: Text(
                'There are no clips in this album.',
                style: TextStyle(color: AppColors.onBackground),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _clips.length,
              itemBuilder: (context, index) {
                final clip = _clips[index];
                final isBlocked = !clip.isAvailable;
                return ListTile(
                  enabled: !isBlocked,
                  leading: Icon(
                    isBlocked ? Icons.lock_outline : Icons.movie,
                    color:
                        isBlocked ? AppColors.onSurface : AppColors.primary,
                  ),
                  title: Text(
                    _formatDate(clip.createdAt),
                    style: TextStyle(
                      color:
                          isBlocked ? AppColors.onSurface : AppColors.onBackground,
                    ),
                  ),
                  subtitle: clip.isAvailable
                      ? null
                      : Text(
                          'Available in ${_formatCountdown(clip.timeUntilAvailable)}',
                          style: const TextStyle(color: AppColors.outline),
                        ),
                  trailing: isBlocked
                      ? null
                      : IconButton(
                          tooltip: 'Options',
                          icon: Icon(
                            Icons.more_vert,
                            color: isBlocked
                                ? AppColors.onSurface
                                : AppColors.onBackground,
                          ),
                          onPressed: isBlocked ? null : () => _showClipOptions(clip),
                        ),
                  onTap: isBlocked ? null : () => _playClip(clip),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final month = months[date.month - 1];
    final day = date.day;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$month $day, ${date.year} - $hour:$minute';
  }

  String _formatCountdown(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final parts = <String>[];
    if (hours > 0) parts.add('$hours hr');
    parts.add('$minutes min');
    return parts.join(' ');
  }
}

class ClipPlayerPage extends StatefulWidget {
  final Clip clip;

  const ClipPlayerPage({super.key, required this.clip});

  @override
  State<ClipPlayerPage> createState() => _ClipPlayerPageState();
}

class _ClipPlayerPageState extends State<ClipPlayerPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(
      File(widget.clip.filePath),
    );
    _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: _controller.value.isInitialized
            ? InkWell(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            : const CircularProgressIndicator(color: AppColors.onBackground),
      ),
    );
  }
}
