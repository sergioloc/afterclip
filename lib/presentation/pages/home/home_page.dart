import 'package:flutter/material.dart';
import '../../../data/datasource/local/album_local_datasource.dart';
import '../../../data/datasource/local/clip_local_datasource.dart';
import '../../../data/repositories/album_repository_impl.dart';
import '../../../data/repositories/clip_repository_impl.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/entities/camera_lens.dart';
import '../../../domain/entities/energy_saving_mode.dart';
import '../../../domain/usecases/get_all_albums_usecase.dart';
import '../../../domain/usecases/get_all_clips_usecase.dart';
import '../../../domain/usecases/set_album_archived_usecase.dart';
import '../../../util/app_colors.dart';
import '../albums/albums_page.dart';
import '../camera/camera_page.dart';
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
  List<Album> _albums = [];
  Map<String, int> _albumClipCounts = {};
  int _albumIndex = 0;
  String? _selectedAlbumId;
  CameraLens _lens = CameraLens.front;
  bool _loading = true;
  EnergySavingMode _mode = EnergySavingMode.off;

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
        _albums = albums;
        _albumClipCounts = counts;
        _albumIndex = 0;
        _selectedAlbumId = albums.isEmpty ? null : albums.first.id;
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
      _selectedAlbumId =
          _albums.isEmpty ? null : _albums[index].id;
    });
  }

  void _toggleCamera() {
    setState(() {
      _lens = _lens == CameraLens.front
          ? CameraLens.back
          : CameraLens.front;
    });
  }

  void _selectLens(CameraLens lens) {
    if (lens == _lens) return;
    setState(() => _lens = lens);
  }

  Future<void> _archiveAlbum(String albumId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.black,
        title: const Text(
          'Archivar álbum',
          style: TextStyle(color: AppColors.white),
        ),
        content: const Text(
          'Se ocultará el album en esta pantalla, pero podrás acceder a él desde la galería.',
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archivar', style: TextStyle(color: AppColors.primary)),
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CameraPage(initialAlbumId: _selectedAlbumId, initialLens: _lens),
      ),
    );
    _loadPage();
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
      return const Scaffold(backgroundColor: AppColors.black);
    }

    final activeAlbums = _albums.where((a) => !a.archived).toList();

    return switch (_mode) {
      EnergySavingMode.off => FullHomePage(
          albums: activeAlbums,
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
          albums: activeAlbums,
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