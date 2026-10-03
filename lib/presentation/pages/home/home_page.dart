import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/datasource/local/album_local_datasource.dart';
import '../../../data/datasource/local/clip_local_datasource.dart';
import '../../../data/repositories/album_repository_impl.dart';
import '../../../data/repositories/clip_repository_impl.dart';
import '../../../data/repositories/daily_clip_limit_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/entities/camera_lens.dart';
import '../../../domain/entities/energy_saving_mode.dart';
import '../../../domain/usecases/get_all_albums_usecase.dart';
import '../../../domain/usecases/get_all_clips_usecase.dart';
import '../../../domain/usecases/set_album_archived_usecase.dart';
import '../../../util/app_colors.dart';
import '../../../util/app_flavor.dart';
import '../../widgets/camera_lens_toast.dart';
import '../../widgets/confirmation_dialog.dart';
import '../albums/albums_page.dart';
import '../camera/camera_page.dart';
import '../permissions/permission_page.dart';
import '../settings/settings_page.dart';
import 'full_home_page.dart';
import 'saving_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SettingsRepository _settingsRepository = SettingsRepository();
  final DailyClipLimitRepository _dailyClipLimitRepository =
      DailyClipLimitRepository();
  Map<String, int> _albumClipCounts = {};
  List<Album?> _activeAlbums = [];
  int _albumIndex = 0;
  String? _selectedAlbumId;
  CameraLens _lens = CameraLens.front;
  bool _loading = true;
  bool _isOpeningCamera = false;
  EnergySavingMode _mode = EnergySavingMode.off;
  OverlayEntry? _lensToastEntry;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    try {
      final mode = await _settingsRepository.getEnergySavingMode();
      final clips = await GetAllClipsUseCase(
        ClipRepositoryImpl(ClipLocalDatasource()),
      ).execute();
      if (AppFlavorConfig.isFree) {
        await _dailyClipLimitRepository.seedFromSavedClips(
          clips.map((clip) => clip.createdAt),
        );
      }
      final albums = await GetAllAlbumsUseCase(
        AlbumRepositoryImpl(AlbumLocalDatasource()),
      ).execute();
      final counts = <String, int>{};
      for (final clip in clips) {
        final albumId = clip.albumId;
        if (albumId != null) {
          counts[albumId] = (counts[albumId] ?? 0) + 1;
        }
      }
      if (!mounted) return;
      setState(() {
        _mode = mode;
        _albumClipCounts = counts;
        _activeAlbums = albums.where((a) => !a.archived).toList();
        if (_activeAlbums.isEmpty) _activeAlbums.add(null);
        _albumIndex = 0;
        _selectedAlbumId =
            _activeAlbums.isEmpty ? null : _activeAlbums.first?.id;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onAlbumChanged(int index) {
    if (index == _albumIndex) return;
    setState(() {
      _albumIndex = index;
      _selectedAlbumId = _activeAlbums[index]?.id;
    });
  }

  void _toggleCamera() {
    final selectedLens = _lens == CameraLens.front
        ? CameraLens.back
        : CameraLens.front;
    setState(() {
      _lens = selectedLens;
    });
    _showLensSelectedToast(selectedLens);
  }

  void _selectLens(CameraLens lens) {
    if (lens != _lens) {
      setState(() => _lens = lens);
    }
    _showLensSelectedToast(lens);
  }

  void _showLensSelectedToast(CameraLens lens) {
    final previousEntry = _lensToastEntry;
    _lensToastEntry = null;
    previousEntry?.remove();
    previousEntry?.dispose();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => CameraLensToast(
        lens: lens,
        onDismiss: () {
          if (!mounted || !identical(_lensToastEntry, entry)) return;
          entry.remove();
          entry.dispose();
          _lensToastEntry = null;
        },
      ),
    );
    _lensToastEntry = entry;
    Overlay.of(context, rootOverlay: true).insert(entry);
  }

  @override
  void dispose() {
    final entry = _lensToastEntry;
    _lensToastEntry = null;
    entry?.remove();
    entry?.dispose();
    super.dispose();
  }

  Future<void> _archiveAlbum(String? albumId) async {
    if (albumId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text(
          'Archive album',
          style: TextStyle(color: AppColors.onBackground),
        ),
        content: const Text(
          'This album will be hidden from the home screen, but you can still access it from your gallery.',
          style: TextStyle(color: AppColors.onBackground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.outline)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await SetAlbumArchivedUseCase(
      AlbumRepositoryImpl(AlbumLocalDatasource()),
    ).execute(albumId, true);
    _loadPage();
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
    _loadPage();
  }

  Future<void> _openCamera() async {
    if (_isOpeningCamera) return;
    _isOpeningCamera = true;

    try {
      if (AppFlavorConfig.isFree) {
        final clipsRecorded = await _dailyClipLimitRepository
            .getClipsRecordedInLast24Hours();
        if (!mounted) return;
        if (clipsRecorded >= DailyClipLimitRepository.maxClips) {
          await _showDailyClipLimitDialog();
          return;
        }
      }

      if (!await _ensureRecordingPermissions()) return;
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CameraPage(initialAlbumId: _selectedAlbumId, initialLens: _lens),
        ),
      );
      await _loadPage();
    } finally {
      _isOpeningCamera = false;
    }
  }

  Future<void> _showDailyClipLimitDialog() async {
    await ConfirmationDialog.show(
      context,
      title: '24-hour limit reached',
      message:
          'The free version allows 24 clips in the last 24 hours. '
          'You can record again when a clip is over 24 hours old.',
      confirmLabel: 'OK',
      confirmColor: AppColors.primary,
      showCancelButton: false,
    );
  }

  Future<bool> _ensureRecordingPermissions() async {
    final statuses = await Future.wait([
      Permission.camera.status,
      Permission.microphone.status,
    ]);
    if (statuses.every((status) => status.isGranted)) return true;
    if (!mounted) return false;

    final result = await PermissionPage.showRecording(context);
    if (result == PermissionRequestResult.denied) {
      _showPermissionSnackBar(
        'Camera and microphone permissions are required to record. You can '
        'enable them in your device settings.',
      );
    } else if (result == PermissionRequestResult.blocked) {
      _showPermissionSnackBar(
        'Camera and microphone permissions are blocked. Enable them in your '
        'device settings to record.',
      );
    }
    return result == PermissionRequestResult.granted;
  }

  void _showPermissionSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surface,
      ),
    );
  }

  void _openAlbums() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AlbumsPage()),
    ).then((_) => _loadPage());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(backgroundColor: AppColors.background);
    }

    return switch (_mode) {
      EnergySavingMode.off => FullHomePage(
          albums: _activeAlbums,
          albumIndex: _albumIndex,
          albumClipCounts: _albumClipCounts,
          lens: _lens,
          onAlbumChanged: _onAlbumChanged,
          onToggleCamera: _toggleCamera,
          onSelectLens: _selectLens,
          onOpenSettings: _openSettings,
          onOpenCamera: _openCamera,
          onOpenAlbums: _openAlbums,
          onArchiveAlbum: _archiveAlbum,
        ),
      EnergySavingMode.on => SavingHomePage(
          albums: _activeAlbums,
          albumIndex: _albumIndex,
          albumClipCounts: _albumClipCounts,
          lens: _lens,
          onAlbumChanged: _onAlbumChanged,
          onToggleCamera: _toggleCamera,
          onSelectLens: _selectLens,
          onOpenSettings: _openSettings,
          onOpenCamera: _openCamera,
          onOpenAlbums: _openAlbums,
          onArchiveAlbum: _archiveAlbum,
        ),
    };
  }
}
