import 'package:flutter/material.dart';
import '../../../data/datasource/local/clip_local_datasource.dart';
import '../../../data/repositories/clip_repository_impl.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../domain/entities/energy_saving_mode.dart';
import '../../../domain/usecases/get_all_clips_usecase.dart';
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
  int _clipCount = 0;
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
      final useCase =
          GetAllClipsUseCase(ClipRepositoryImpl(ClipLocalDatasource()));
      final clips = await useCase.execute();
      if (!mounted) return;
      setState(() {
        _mode = mode;
        _clipCount = clips.length;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
    _loadPage();
  }

  void _openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraPage()),
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
      return const Scaffold(backgroundColor: AppColors.black);
    }

    final clipCount = _clipCount;

    return switch (_mode) {
      EnergySavingMode.off => FullHomePage(
          clipCount: clipCount,
          onOpenSettings: _openSettings,
          onOpenCamera: _openCamera,
          onOpenAlbums: _openAlbums,
        ),
      EnergySavingMode.on => SavingHomePage(
          clipCount: clipCount,
          onOpenSettings: _openSettings,
          onOpenCamera: _openCamera,
          onOpenAlbums: _openAlbums,
        ),
    };
  }
}