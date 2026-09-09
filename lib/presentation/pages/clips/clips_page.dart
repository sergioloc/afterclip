import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../data/datasource/local/clip_local_datasource.dart';
import '../../../../data/repositories/clip_repository_impl.dart';
import '../../../../data/services/gallery_service.dart';
import '../../../../domain/entities/clip.dart';
import '../../../../domain/usecases/get_all_clips_usecase.dart';
import '../../../../util/app_colors.dart';

class ClipsPage extends StatefulWidget {
  const ClipsPage({super.key, this.albumId, this.title});

  final String? albumId;
  final String? title;

  @override
  State<ClipsPage> createState() => _ClipsPageState();
}

class _ClipsPageState extends State<ClipsPage> {
  static const String _secretPin = '1996';

  late final GetAllClipsUseCase _getAllClipsUseCase;
  List<Clip> _clips = [];
  bool _loading = true;
  bool _unlocked = false;

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

  Future<void> _promptForPin() async {
    final controller = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.black,
        title: const Text(
          'PIN',
          style: TextStyle(color: AppColors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          style: const TextStyle(color: AppColors.white),
          decoration: const InputDecoration(
            hintText: '****',
            hintStyle: TextStyle(color: AppColors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.white54),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Aceptar', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );

    if (pin == null) return;

    if (pin == _secretPin) {
      setState(() {
        _unlocked = true;
        _loading = true;
      });
      await _loadClips();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN incorrecto'),
            backgroundColor: AppColors.red,
          ),
        );
      }
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

  Future<void> _deleteClip(Clip clip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.black,
        title: const Text(
          'Borrar clip',
          style: TextStyle(color: AppColors.white),
        ),
        content: Text(
          '¿Seguro que quieres borrar este clip?',
          style: const TextStyle(color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar', style: TextStyle(color: AppColors.red)),
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
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('GalleryService saveVideo error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el video'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: Text(widget.title ?? 'Mis clips'),
        actions: [
          IconButton(
            icon: Icon(
              _unlocked ? Icons.lock_open : Icons.lock,
              color: _unlocked ? AppColors.green : AppColors.black,
            ),
            onPressed: _unlocked
                ? () {
                    setState(() {
                      _unlocked = false;
                      _loading = true;
                    });
                    _loadClips();
                  }
                : _promptForPin,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.white))
          : _clips.isEmpty
          ? const Center(
              child: Text(
                'No hay clips en este álbum',
                style: TextStyle(color: AppColors.white),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _clips.length,
              itemBuilder: (context, index) {
                final clip = _clips[index];
                final isBlocked = !clip.isAvailable && !_unlocked;
                return ListTile(
                  enabled: !isBlocked,
                  leading: Icon(
                    Icons.movie,
                    color: isBlocked ? AppColors.white24 : AppColors.white,
                  ),
                  title: Text(
                    _formatDate(clip.createdAt),
                    style: TextStyle(
                      color: isBlocked ? AppColors.white24 : AppColors.white,
                    ),
                  ),
                  subtitle: clip.isAvailable
                      ? null
                      : Text(
                          'Disponible en ${_formatCountdown(clip.timeUntilAvailable)}',
                          style: const TextStyle(color: AppColors.grey),
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_unlocked)
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.white),
                          onPressed: () => _deleteClip(clip),
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.download_outlined,
                          color: isBlocked ? AppColors.white24 : AppColors.white,
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
      backgroundColor: AppColors.black,
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
            : const CircularProgressIndicator(color: AppColors.white),
      ),
    );
  }
}