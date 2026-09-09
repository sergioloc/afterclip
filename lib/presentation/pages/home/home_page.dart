import 'package:flutter/material.dart';
import '../../../data/datasource/local/clip_local_datasource.dart';
import '../../../data/repositories/clip_repository_impl.dart';
import '../../../domain/usecases/get_all_clips_usecase.dart';
import '../../../util/app_colors.dart';
import '../../widgets/home_button.dart';
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
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Toolbar row with settings ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      color: AppColors.white.withValues(alpha: 0.05),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.settings,
                        color: AppColors.white.withValues(alpha: 0.7),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── App title (below toolbar, centered) ──
            const SizedBox(height: 24),
            const Text(
              'AFTERCLIP',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                color: AppColors.white,
              ),
            ),

            const Spacer(),

            // ── Record button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: HomeButton(
                icon: Icons.fiber_manual_record,
                label: 'Record',
                filled: true,
                onTap: _openCamera,
              ),
            ),

            const SizedBox(height: 24),

            // ── Album button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: HomeButton(
                icon: Icons.photo_library_outlined,
                label: 'Album',
                badge: _clipCount,
                onTap: _openClips,
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}