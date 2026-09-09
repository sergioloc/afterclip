import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../domain/entities/energy_saving_mode.dart';
import '../../../util/app_colors.dart';

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
      if (!mounted) return;
      setState(() {
        _overlayOpacity = opacity;
        _brightness = brightness;
        _energySavingMode = energySavingMode;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text('Ajustes'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.white))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
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
                                    : AppColors.white10,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  mode.label,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
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
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Slider(
                    value: _overlayOpacity.clamp(0.0, 1.0),
                    min: 0,
                    max: 1,
                    onChanged: _saveOverlayOpacity,
                    activeColor: AppColors.white,
                    inactiveColor: AppColors.white24,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  title: 'Brillo durante grabación',
                  subtitle: 'Nivel de brillo de la pantalla al grabar',
                  trailing: Text(
                    '${(_brightness * 100).round()}%',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Slider(
                    value: _brightness.clamp(0.1, 1.0),
                    min: 0.1,
                    max: 1,
                    onChanged: _saveBrightness,
                    activeColor: AppColors.white,
                    inactiveColor: AppColors.white24,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
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
        color: AppColors.white10,
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
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.white54,
                        fontSize: 13,
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