import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../../../data/datasource/local/album_local_datasource.dart';
import '../../../data/datasource/local/clip_local_datasource.dart';
import '../../../data/repositories/album_repository_impl.dart';
import '../../../data/repositories/clip_repository_impl.dart';
import '../../../data/repositories/daily_clip_limit_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/entities/camera_lens.dart';
import '../../../domain/repositories/clip_repository.dart';
import '../../../domain/usecases/get_all_albums_usecase.dart';
import '../../../util/app_colors.dart';
import '../../../util/app_flavor.dart';
import '../../../util/app_radius.dart';
import '../../../util/app_spacing.dart';
import '../../../util/app_text_styles.dart';
import '../../widgets/stop_recording_button.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key, this.initialAlbumId, this.initialLens});

  final String? initialAlbumId;
  final CameraLens? initialLens;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isRecording = false;
  bool _isStoppingRecording = false;
  int _countdown = 3;
  Timer? _countdownTimer;
  static const int _defaultMaxSeconds = 30;
  int _maxSeconds = _defaultMaxSeconds;
  late AnimationController _recordingController;
  ClipRepository? _clipRepository;
  final DailyClipLimitRepository _dailyClipLimitRepository =
      DailyClipLimitRepository();
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
    _recordingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _maxSeconds),
    );
    _recordingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stopRecording();
      }
    });
    _loadSettings();
    _loadAlbums();
    _initCamera();
  }

  Future<void> _loadAlbums() async {
    final albums = await _getAllAlbumsUseCase.execute();
    if (mounted) {
      setState(() {
        _albums = albums;
        _selectedAlbumId = widget.initialAlbumId;
      });
    }
  }

  String get _selectedAlbumName {
    final album = _albums.where((a) => a.id == _selectedAlbumId).firstOrNull;
    return album?.name ?? 'No album';
  }

  Future<void> _showAlbumPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.background,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                'Save to album',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: AppColors.surface),
            ListTile(
              leading: const Icon(Icons.layers_clear, color: AppColors.outline),
              title: const Text(
                'No album',
                style: TextStyle(color: AppColors.onBackground),
              ),
              trailing: _selectedAlbumId == null
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.pop(context, null),
            ),
            if (_albums.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.large),
                child: Text(
                  'There are no albums yet. Create one from the Albums screen.',
                  style: TextStyle(color: AppColors.outline),
                ),
              )
            else
              for (final album in _albums)
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.outline,
                  ),
                  title: Text(
                    album.name,
                    style: const TextStyle(color: AppColors.onBackground),
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
      _settingsRepository.getMaxClipDuration(),
    ]);
    if (mounted) {
      setState(() {
        _overlayOpacity = results[0] as double;
        _brightness = results[1] as double;
        _maxSeconds = results[2] as int;
      });
      _recordingController.duration = Duration(seconds: _maxSeconds);
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
    final target = widget.initialLens == CameraLens.back
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == target,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
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
    if (AppFlavorConfig.isFree) {
      final clipsRecorded = await _dailyClipLimitRepository
          .getClipsRecordedInLast24Hours();
      if (!mounted) return;
      if (clipsRecorded >= DailyClipLimitRepository.maxClips) {
        _countdownTimer?.cancel();
        Navigator.pop(context);
        return;
      }
    }
    await _controller!.startVideoRecording();
    _recordingController.reset();
    setState(() => _isRecording = true);
    _recordingController.forward();
  }

  Future<void> _stopRecording() async {
    if (_isStoppingRecording ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }
    if (!_isRecording) return;

    _isStoppingRecording = true;
    _recordingController.stop();
    _recordingController.reset();
    final file = await _controller!.stopVideoRecording();

    if (AppFlavorConfig.isFree) {
      await _dailyClipLimitRepository.recordClip();
    }

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
    _recordingController.dispose();
    _controller?.dispose();
    _resetBrightness();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _initializeControllerFuture == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.onBackground),
            )
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      Center(
                        child: Transform.scale(
                          scaleX: -1,
                          child: CameraPreview(_controller!),
                        ),
                      ),
                      if (_overlayOpacity > 0)
                        Container(
                          color: AppColors.onBackground
                              .withValues(alpha: _overlayOpacity),
                        ),
                      if (_countdown > 0)
                        Center(
                          child: Text(
                            '$_countdown',
                            style: AppTextStyles.counter.copyWith(
                              color: AppColors.primary,
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
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.small),
                              Text(
                                'REC',
                                style: AppTextStyles.title.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_isRecording)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 50,
                          left: 0,
                          right: 0,
                          child: AnimatedBuilder(
                            animation: _recordingController,
                            builder: (context, child) {
                              final remaining = (_maxSeconds *
                                      (1 - _recordingController.value))
                                  .ceil();
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.large),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.small),
                                      child: SizedBox(
                                        height: AppSpacing.small,
                                        width: double.infinity,
                                        child: LinearProgressIndicator(
                                          value: _recordingController.value,
                                          backgroundColor: AppColors.surface,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(AppColors.primary),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.small),
                                    Text(
                                      '${remaining}s',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.onBackground,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      if (_isRecording)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: MediaQuery.of(context).padding.bottom +
                              AppSpacing.xLarge,
                          child: Center(
                            child: StopRecordingButton(
                              onTap: _stopRecording,
                            ),
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
                                horizontal: AppSpacing.medium,
                                vertical: AppSpacing.small,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.background.withValues(alpha: 0.6),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.large),
                                border: Border.all(
                                  color: AppColors.surface,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.photo_library_outlined,
                                    color: AppColors.onBackground,
                                    size: 16,
                                  ),
                                  const SizedBox(width: AppSpacing.small),
                                  Text(
                                    '$_selectedAlbumName  ▾',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.onBackground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.onBackground),
                  );
                }
              },
            ),
    );
  }
}
