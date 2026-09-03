import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/repositories/settings_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsRepository _settingsRepository = SettingsRepository();

  double _overlayOpacity = SettingsRepository.defaultOverlayOpacity;
  double _brightness = SettingsRepository.defaultBrightness;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final results = await Future.wait([
        _settingsRepository.getOverlayOpacity(),
        _settingsRepository.getBrightness(),
      ]).timeout(const Duration(seconds: 3));
      if (!mounted) return;
      setState(() {
        _overlayOpacity = results[0];
        _brightness = results[1];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Ajustes'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionHeader('Flash'),
                const SizedBox(height: 16),
                _buildSettingCard(
                  title: 'Opacidad del overlay',
                  subtitle: 'Intensidad del efecto flash sobre la cámara',
                  trailing: Text(
                    '${(_overlayOpacity * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Slider(
                    value: _overlayOpacity.clamp(0.0, 1.0),
                    min: 0,
                    max: 1,
                    onChanged: _saveOverlayOpacity,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  title: 'Brillo durante grabación',
                  subtitle: 'Nivel de brillo de la pantalla al grabar',
                  trailing: Text(
                    '${(_brightness * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Slider(
                    value: _brightness.clamp(0.1, 1.0),
                    min: 0.1,
                    max: 1,
                    onChanged: _saveBrightness,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
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
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required Widget trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
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
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}