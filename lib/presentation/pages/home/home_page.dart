import 'package:flutter/material.dart';
import '../../../data/datasource/local/clip_local_datasource.dart';
import '../../../data/repositories/clip_repository_impl.dart';
import '../../../domain/usecases/get_all_clips_usecase.dart';
import '../camera/camera_page.dart';
import '../clips/clips_page.dart';
import '../settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _clipCount = 0;

  @override
  void initState() {
    super.initState();
    _loadClipCount();
  }

  Future<void> _loadClipCount() async {
    final useCase = GetAllClipsUseCase(
      ClipRepositoryImpl(ClipLocalDatasource()),
    );
    final clips = await useCase.execute();
    if (mounted) {
      setState(() => _clipCount = clips.length);
    }
  }

  Future<void> _openClips() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClipsPage()),
    );
    _loadClipCount();
  }

  Future<void> _openCamera() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraPage()),
    );
    await Future.delayed(const Duration(milliseconds: 200));
    await _loadClipCount();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _openCamera,
          child: const Scaffold(
            backgroundColor: Colors.black,
          ),
        ),
        Positioned(
          bottom: 32,
          left: 24,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 32,
          right: 24,
          child: GestureDetector(
            onTap: _openClips,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Center(
                child: Text(
                  _clipCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}