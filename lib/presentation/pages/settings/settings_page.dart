import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../domain/entities/energy_saving_mode.dart';
import '../../../util/app_colors.dart';
import '../../../util/app_text_styles.dart';

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
        title: const Text('Ajustes'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.onBackground))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionHeader('Grabación'),
                const SizedBox(height: 16),
                _buildSettingCard(
                  title: 'Duración máxima del clip',
                  subtitle: 'Tiempo límite de grabación por clip',
                  child: Row(
                    children: [
                      for (final seconds
                          in SettingsRepository.maxClipDurationOptions) ...[
                        if (seconds !=
                            SettingsRepository.maxClipDurationOptions.first)
                          const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _saveMaxClipDuration(seconds),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _maxClipDuration == seconds
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
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
                const SizedBox(height: 32),
                _buildSectionHeader('Energía'),
                const SizedBox(height: 16),
                _buildSettingCard(
                  title: 'Ahorro de energía',
                  subtitle: 'Nivel de reducción de consumo de batería',
                  child: Row(
                    children: [
                      for (final mode in EnergySavingMode.values) ...[
                        if (mode != EnergySavingMode.values.first)
                          const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _saveEnergySavingMode(mode),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _energySavingMode == mode
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
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
                const SizedBox(height: 32),
                _buildSectionHeader('Flash'),
                const SizedBox(height: 16),
                _buildSettingCard(
                  title: 'Opacidad del overlay',
                  subtitle: 'Intensidad del efecto flash sobre la cámara',
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
                const SizedBox(height: 16),
                _buildSettingCard(
                  title: 'Brillo durante grabación',
                  subtitle: 'Nivel de brillo de la pantalla al grabar',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 4),
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
                const SizedBox(width: 12),
                trailing,
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}