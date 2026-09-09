import 'dart:math';
import 'package:flutter/material.dart';
import '../../../data/datasource/local/clip_local_datasource.dart';
import '../../../data/repositories/clip_repository_impl.dart';
import '../../../domain/usecases/get_all_clips_usecase.dart';
import '../../../util/app_colors.dart';
import '../../widgets/home_button.dart';
import '../camera/camera_page.dart';
import '../clips/clips_page.dart';

class LowEnergyHomePage extends StatefulWidget {
  const LowEnergyHomePage({super.key, required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  State<LowEnergyHomePage> createState() => _LowEnergyHomePageState();
}

class _LowEnergyHomePageState extends State<LowEnergyHomePage>
    with TickerProviderStateMixin {
  int _clipCount = 0;
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _loadClipCount();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // ── Background gradient ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D0D0D),
                  Color(0xFF1A0000),
                  Color(0xFF000000),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Ambient glow blobs ──
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, _) {
              final v = _glowController.value;
              return Positioned(
                top: size.height * 0.15 + sin(v * pi) * 20,
                left: size.width * 0.1 + cos(v * pi) * 15,
                child: _ambientBlob(
                  120,
                  AppColors.red.withValues(alpha: 0.06 + v * 0.03),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, _) {
              final v = _glowController.value;
              return Positioned(
                bottom: size.height * 0.2 + cos(v * pi) * 15,
                right: size.width * 0.05 + sin(v * pi) * 10,
                child: _ambientBlob(
                  80,
                  AppColors.red.withValues(alpha: 0.04 + v * 0.02),
                ),
              );
            },
          ),

          // ── Static particles ──
          ..._buildParticles(size),

          // ── Main content ──
          SafeArea(
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
                const SizedBox(height: 4),
                Text(
                  'CAMARA DESCARTABLE',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 4,
                    color: AppColors.grey,
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildRecordButton(),
                ),

                const SizedBox(height: 24),

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
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text.rich(
      TextSpan(
        text: 'After',
        style: TextStyle(
          fontFamily: 'Dantene',
          fontSize: 60,
          letterSpacing: 4,
          color: AppColors.white,
        ),
        children: [
          TextSpan(
            text: 'Clip',
            style: TextStyle(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        final v = _glowController.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.red.withValues(alpha: 0.15 + v * 0.25),
                blurRadius: 20 + v * 20,
                spreadRadius: 2 + v * 6,
              ),
            ],
          ),
          child: HomeButton(
            icon: Icons.fiber_manual_record,
            label: 'Record',
            filled: true,
            glow: false,
            onTap: _openCamera,
          ),
        );
      },
    );
  }

  Widget _buildSettingsButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        color: AppColors.white.withValues(alpha: 0.08),
      ),
      child: IconButton(
        onPressed: widget.onOpenSettings,
        icon: Icon(
          Icons.settings,
          color: AppColors.white.withValues(alpha: 0.8),
          size: 22,
        ),
      ),
    );
  }

  List<Widget> _buildParticles(Size size) {
    final rng = Random(42);
    return List.generate(8, (i) {
      final startX = rng.nextDouble() * size.width;
      final startY = rng.nextDouble() * size.height;
      final dotSize = 1.0 + rng.nextDouble() * 1.5;
      final speed = 0.3 + rng.nextDouble() * 0.7;

      return AnimatedBuilder(
        animation: _glowController,
        builder: (context, _) {
          final t = (_glowController.value * speed + i / 8) % 1.0;
          final y = startY - t * size.height * 0.3;
          final x = startX + sin(t * pi * 2 + i) * 20;
          final opacity = (sin(t * pi) * 0.3).clamp(0.0, 0.3);

          return Positioned(
            left: x,
            top: y,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.red.withValues(alpha: opacity),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _ambientBlob(double radius, Color color) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color, blurRadius: radius * 0.8),
        ],
      ),
    );
  }
}