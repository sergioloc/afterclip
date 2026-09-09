import 'package:flutter/material.dart';
import '../../../data/datasource/local/clip_local_datasource.dart';
import '../../../data/repositories/clip_repository_impl.dart';
import '../../../domain/usecases/get_all_clips_usecase.dart';
import '../../../util/app_colors.dart';
import '../../widgets/home_button.dart';
import '../camera/camera_page.dart';
import '../clips/clips_page.dart';

class HighEnergyHomePage extends StatefulWidget {
  const HighEnergyHomePage({super.key, required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  State<HighEnergyHomePage> createState() => _HighEnergyHomePageState();
}

class _HighEnergyHomePageState extends State<HighEnergyHomePage> {
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildSettingsButton(),
                ],
              ),
            ),

            const SizedBox(height: 48),
            _buildTitle(),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: HomeButton(
                icon: Icons.fiber_manual_record,
                label: 'Record',
                filled: true,
                fillColor: AppColors.black,
                showBorder: true,
                glow: false,
                foregroundColor: AppColors.grey,
                borderColor: AppColors.grey,
                onTap: _openCamera,
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: HomeButton(
                icon: Icons.photo_library_outlined,
                label: 'Album',
                badge: _clipCount,
                fillColor: AppColors.black,
                showBorder: true,
                glow: false,
                foregroundColor: AppColors.grey,
                borderColor: AppColors.grey,
                badgeColor: AppColors.grey,
                badgeTextColor: AppColors.black,
                onTap: _openClips,
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    const fontSize = 60.0;
    const letterSpacing = 4.0;
    return Text(
      'AfterClip',
      style: TextStyle(
        fontFamily: 'Dantene',
        fontSize: fontSize,
        letterSpacing: letterSpacing,
        color: AppColors.grey,
      ),
    );
  }

  Widget _buildSettingsButton() {
    return IconButton(
      onPressed: widget.onOpenSettings,
      icon: const Icon(
        Icons.settings,
        color: AppColors.grey,
        size: 22,
      ),
    );
  }
}