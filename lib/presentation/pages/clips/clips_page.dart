import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../data/datasource/local/clip_local_datasource.dart';
import '../../../../data/repositories/clip_repository_impl.dart';
import '../../../../domain/entities/clip.dart';
import '../../../../domain/usecases/get_all_clips_usecase.dart';
import '../../../../domain/usecases/get_available_clips_usecase.dart';

class ClipsPage extends StatefulWidget {
  const ClipsPage({super.key});

  @override
  State<ClipsPage> createState() => _ClipsPageState();
}

class _ClipsPageState extends State<ClipsPage> {
  static const String _secretPin = '1234';

  late final GetAvailableClipsUseCase _getAvailableClipsUseCase;
  late final GetAllClipsUseCase _getAllClipsUseCase;
  List<Clip> _clips = [];
  bool _loading = true;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    final repository = ClipRepositoryImpl(ClipLocalDatasource());
    _getAvailableClipsUseCase = GetAvailableClipsUseCase(repository);
    _getAllClipsUseCase = GetAllClipsUseCase(repository);
    _loadClips();
  }

  Future<void> _loadClips() async {
    final clips = _unlocked
        ? await _getAllClipsUseCase.execute()
        : await _getAvailableClipsUseCase.execute();
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
        backgroundColor: Colors.black,
        title: const Text(
          'PIN',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '****',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
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
            backgroundColor: Colors.red,
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
        backgroundColor: Colors.black,
        title: const Text(
          'Borrar clip',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Seguro que quieres borrar este clip?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar', style: TextStyle(color: Colors.red)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Mis clips'),
        actions: [
          IconButton(
            icon: Icon(
              _unlocked ? Icons.lock_open : Icons.lock,
              color: _unlocked ? Colors.green : Colors.black,
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
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _clips.isEmpty
          ? Center(
              child: Text(
                _unlocked
                    ? 'No hay clips grabados'
                    : 'Aún no tienes clips disponibles.\nVuelve en 24 horas.',
                style: const TextStyle(color: Colors.white),
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
                  subtitle: clip.isAvailable
                      ? null
                      : Text(
                          'Disponible en ${_formatCountdown(clip.timeUntilAvailable)}',
                          style: const TextStyle(color: Colors.orange),
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_unlocked)
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _deleteClip(clip),
                        ),
                      IconButton(
                        icon: const Icon(Icons.play_circle_outline,
                            color: Colors.white),
                        onPressed: () {
                          if (clip.isAvailable || _unlocked) {
                            _playClip(clip);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Clip aún no disponible (24h)'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    if (clip.isAvailable || _unlocked) {
                      _playClip(clip);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Clip aún no disponible (24h)'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
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
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
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