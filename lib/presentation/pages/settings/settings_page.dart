import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../domain/entities/energy_saving_mode.dart';
import '../../../util/app_colors.dart';
import '../../../util/app_radius.dart';
import '../../../util/app_spacing.dart';
import '../../../util/app_text_styles.dart';
import '../../widgets/page_title.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsRepository _settingsRepository = SettingsRepository();

  double _overlayOpacity = SettingsRepository.defaultOverlayOpacity;
  double _brightness = SettingsRepository.defaultBrightness;
  EnergySavingMode _energySavingMode =
      SettingsRepository.defaultEnergySavingMode;
  int _maxClipDuration = SettingsRepository.defaultMaxClipDuration;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final opacity = await _settingsRepository
          .getOverlayOpacity()
          .timeout(const Duration(seconds: 3));
      final brightness = await _settingsRepository
          .getBrightness()
          .timeout(const Duration(seconds: 3));
      final energySavingMode = await _settingsRepository
          .getEnergySavingMode()
          .timeout(const Duration(seconds: 3));
      final maxClipDuration = await _settingsRepository
          .getMaxClipDuration()
          .timeout(const Duration(seconds: 3));
      if (!mounted) return;
      setState(() {
        _overlayOpacity = opacity;
        _brightness = brightness;
        _energySavingMode = energySavingMode;
        _maxClipDuration = maxClipDuration;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _saveOverlayOpacity(double value) {
    setState(() => _overlayOpacity = value);
    _settingsRepository.setOverlayOpacity(value);
  }

  void _saveBrightness(double value) {
    setState(() => _brightness = value);
    _settingsRepository.setBrightness(value);
  }

  void _saveEnergySavingMode(EnergySavingMode mode) {
    setState(() => _energySavingMode = mode);
    _settingsRepository.setEnergySavingMode(mode);
  }

  void _saveMaxClipDuration(int seconds) {
    setState(() => _maxClipDuration = seconds);
    _settingsRepository.setMaxClipDuration(seconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const PageTitle('Settings'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.onBackground))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.xLarge),
              children: [
                _buildSectionHeader('Recording'),
                const SizedBox(height: AppSpacing.large),
                _buildSettingCard(
                  title: 'Maximum clip duration',
                  subtitle: 'Recording time limit for each clip',
                  child: Row(
                    children: [
                      for (final seconds
                          in SettingsRepository.maxClipDurationOptions) ...[
                        if (seconds !=
                            SettingsRepository.maxClipDurationOptions.first)
                          const SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _saveMaxClipDuration(seconds),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding:
                                  const EdgeInsets.symmetric(vertical: AppSpacing.medium),
                              decoration: BoxDecoration(
                                color: _maxClipDuration == seconds
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.small),
                              ),
                              child: Center(
                                child: Text(
                                  '${seconds}s',
                                  style: AppTextStyles.metric.copyWith(
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxLarge),
                _buildSectionHeader('Energy'),
                const SizedBox(height: AppSpacing.large),
                _buildSettingCard(
                  title: 'Battery saver',
                  subtitle: 'Battery usage reduction level',
                  child: Row(
                    children: [
                      for (final mode in EnergySavingMode.values) ...[
                        if (mode != EnergySavingMode.values.first)
                          const SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _saveEnergySavingMode(mode),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
                              decoration: BoxDecoration(
                                color: _energySavingMode == mode
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.small),
                              ),
                              child: Center(
                                child: Text(
                                  mode.label,
                                  style: AppTextStyles.metric.copyWith(
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxLarge),
                _buildSectionHeader('Flash'),
                const SizedBox(height: AppSpacing.large),
                _buildSettingCard(
                  title: 'Overlay opacity',
                  subtitle: 'Intensity of the camera flash effect',
                  trailing: Text(
                    '${(_overlayOpacity * 100).round()}%',
                    style: AppTextStyles.heading.copyWith(
                      color: AppColors.onBackground,
                    ),
                  ),
                  child: Slider(
                    value: _overlayOpacity.clamp(0.0, 1.0),
                    min: 0,
                    max: 1,
                    onChanged: _saveOverlayOpacity,
                    activeColor: AppColors.onPrimary,
                    inactiveColor: AppColors.surface,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                _buildSettingCard(
                  title: 'Screen brightness while recording',
                  subtitle: 'Screen brightness level during recording',
                  trailing: Text(
                    '${(_brightness * 100).round()}%',
                    style: AppTextStyles.heading.copyWith(
                      color: AppColors.onBackground,
                    ),
                  ),
                  child: Slider(
                    value: _brightness.clamp(0.1, 1.0),
                    min: 0.1,
                    max: 1,
                    onChanged: _saveBrightness,
                    activeColor: AppColors.onPrimary,
                    inactiveColor: AppColors.surface,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.label.copyWith(
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxSmall),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.medium),
                trailing,
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          child,
        ],
      ),
    );
  }
}
