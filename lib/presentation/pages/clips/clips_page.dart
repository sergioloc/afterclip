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
import '../../../../util/app_spacing.dart';

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
    }
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
          'Desarchivar álbum',
          style: TextStyle(color: AppColors.onBackground),
        ),
        content: const Text(
          'El álbum volverá a aparecer en la pantalla principal.',
          style: TextStyle(color: AppColors.onBackground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.outline)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desarchivar', style: TextStyle(color: AppColors.primary)),
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
          'Borrar clip',
          style: TextStyle(color: AppColors.onBackground),
        ),
        content: Text(
          '¿Seguro que quieres borrar este clip?',
          style: const TextStyle(color: AppColors.onBackground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.outline)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar', style: TextStyle(color: AppColors.error)),
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
            content: Text('Video guardado en la galería'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('GalleryService saveVideo error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el video'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
              Text(widget.title!),
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
                'No hay clips en este álbum',
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
                    Icons.movie,
                    color: isBlocked ? AppColors.surface : AppColors.onBackground,
                  ),
                  title: Text(
                    _formatDate(clip.createdAt),
                    style: TextStyle(
                      color: isBlocked ? AppColors.surface : AppColors.onBackground,
                    ),
                  ),
                  subtitle: clip.isAvailable
                      ? null
                      : Text(
                          'Disponible en ${_formatCountdown(clip.timeUntilAvailable)}',
                          style: const TextStyle(color: AppColors.outline),
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.onBackground),
                        onPressed: () => _deleteClip(clip),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.download_outlined,
                          color: isBlocked ? AppColors.surface : AppColors.onBackground,
                        ),
                        onPressed:
                            isBlocked ? null : () => _downloadClip(clip),
                      ),
                    ],
                  ),
                  onTap: isBlocked ? null : () => _playClip(clip),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year - $hour:$minute';
  }

  String _formatCountdown(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final parts = <String>[];
    if (hours > 0) parts.add('${hours}h');
    parts.add('${minutes}min');
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