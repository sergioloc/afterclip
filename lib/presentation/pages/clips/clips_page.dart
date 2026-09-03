import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../data/datasource/local/clip_local_datasource.dart';
import '../../../../data/repositories/clip_repository_impl.dart';
import '../../../../domain/entities/clip.dart';
import '../../../../domain/usecases/get_available_clips_usecase.dart';

class ClipsPage extends StatefulWidget {
  const ClipsPage({super.key});

  @override
  State<ClipsPage> createState() => _ClipsPageState();
}

class _ClipsPageState extends State<ClipsPage> {
  late final GetAvailableClipsUseCase _getAvailableClipsUseCase;
  List<Clip> _clips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getAvailableClipsUseCase =
        GetAvailableClipsUseCase(ClipRepositoryImpl(ClipLocalDatasource()));
    _loadClips();
  }

  Future<void> _loadClips() async {
    final clips = await _getAvailableClipsUseCase.execute();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Mis clips'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _clips.isEmpty
          ? const Center(
              child: Text(
                'Aún no tienes clips disponibles.\nVuelve en 24 horas.',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _clips.length,
              itemBuilder: (context, index) {
                final clip = _clips[index];
                return ListTile(
                  leading: const Icon(Icons.movie, color: Colors.white),
                  title: Text(
                    _formatDate(clip.createdAt),
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(Icons.play_circle_outline,
                      color: Colors.white),
                  onTap: () => _playClip(clip),
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
      backgroundColor: Colors.black,
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
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}