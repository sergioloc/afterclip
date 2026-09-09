import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../../../data/datasource/local/album_local_datasource.dart';
import '../../../data/datasource/local/clip_local_datasource.dart';
import '../../../data/repositories/album_repository_impl.dart';
import '../../../data/repositories/clip_repository_impl.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/repositories/clip_repository.dart';
import '../../../domain/usecases/get_all_albums_usecase.dart';
import '../../../util/app_colors.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isRecording = false;
  int _countdown = 3;
  Timer? _countdownTimer;
  ClipRepository? _clipRepository;
  final SettingsRepository _settingsRepository = SettingsRepository();
  double _overlayOpacity = SettingsRepository.defaultOverlayOpacity;
  double _brightness = SettingsRepository.defaultBrightness;
  late final GetAllAlbumsUseCase _getAllAlbumsUseCase;
  List<Album> _albums = [];
  String? _selectedAlbumId;

  @override
  void initState() {
    super.initState();
    _clipRepository = ClipRepositoryImpl(ClipLocalDatasource());
    _getAllAlbumsUseCase =
        GetAllAlbumsUseCase(AlbumRepositoryImpl(AlbumLocalDatasource()));
    _loadSettings();
    _loadAlbums();
    _initCamera();
  }

  Future<void> _loadAlbums() async {
    final albums = await _getAllAlbumsUseCase.execute();
    if (mounted) {
      setState(() => _albums = albums);
    }
  }

  String get _selectedAlbumName {
    final album = _albums.where((a) => a.id == _selectedAlbumId).firstOrNull;
    return album?.name ?? 'Sin álbum';
  }

  Future<void> _showAlbumPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.black,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                'Guardar en álbum',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: AppColors.white24),
            ListTile(
              leading: const Icon(Icons.layers_clear, color: AppColors.white54),
              title: const Text(
                'Sin álbum',
                style: TextStyle(color: AppColors.white),
              ),
              trailing: _selectedAlbumId == null
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.pop(context, null),
            ),
            if (_albums.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No hay álbumes todavía. Créalos desde la pantalla de álbumes.',
                  style: TextStyle(color: AppColors.white54),
                ),
              )
            else
              for (final album in _albums)
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.white54,
                  ),
                  title: Text(
                    album.name,
                    style: const TextStyle(color: AppColors.white),
                  ),
                  trailing: _selectedAlbumId == album.id
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(context, album.id),
                ),
          ],
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _selectedAlbumId = selected);
  }

  Future<void> _loadSettings() async {
    final results = await Future.wait([
      _settingsRepository.getOverlayOpacity(),
      _settingsRepository.getBrightness(),
    ]);
    if (mounted) {
      setState(() {
        _overlayOpacity = results[0];
        _brightness = results[1];
      });
    }
    await _setBrightness();
  }

  Future<void> _setBrightness() async {
    await ScreenBrightness.instance.setScreenBrightness(_brightness);
  }

  Future<void> _resetBrightness() async {
    await ScreenBrightness.instance.resetScreenBrightness();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller!.initialize();
    setState(() {});

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });
      if (_countdown == 0) {
        timer.cancel();
        _startRecording();
      }
    });
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    await _controller!.startVideoRecording();
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (!_isRecording) return;

    final file = await _controller!.stopVideoRecording();

    if (_clipRepository != null) {
      await _clipRepository!.saveClip(file.path, albumId: _selectedAlbumId);
    }

    await _resetBrightness();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller?.dispose();
    _resetBrightness();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: _initializeControllerFuture == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.white),
            )
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return GestureDetector(
                    onTap: _isRecording ? _stopRecording : null,
                    child: Stack(
                      children: [
                        Center(
                          child: Transform.scale(
                            scaleX: -1,
                            child: CameraPreview(_controller!),
                          ),
                        ),

                        if (_overlayOpacity > 0)
                          Container(
                            color: AppColors.white.withValues(alpha: _overlayOpacity),
                          ),

                        if (_countdown > 0)
                          Center(
                            child: Text(
                              '$_countdown',
                              style: const TextStyle(
                                fontSize: 96,
                                fontWeight: FontWeight.bold,
                                color: AppColors.red,
                              ),
                            ),
                          ),

                        if (_isRecording)
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 16,
                            right: 16,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.red,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'REC',
                                  style: TextStyle(
                                    color: AppColors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (!_isRecording)
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 16,
                            left: 16,
                            child: GestureDetector(
                              onTap: _showAlbumPicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.white24,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.photo_library_outlined,
                                      color: AppColors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$_selectedAlbumName  ▾',
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.white),
                  );
                }
              },
            ),
    );
  }
}