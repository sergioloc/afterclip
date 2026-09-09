import 'package:flutter/material.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../domain/entities/energy_saving_mode.dart';
import '../../../util/app_colors.dart';
import '../settings/settings_page.dart';
import 'high_energy_home_page.dart';
import 'low_energy_home_page.dart';
import 'medium_energy_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SettingsRepository _settingsRepository = SettingsRepository();
  EnergySavingMode? _mode;

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final mode = await _settingsRepository.getEnergySavingMode();
    if (mounted) {
      setState(() => _mode = mode);
    }
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
    _loadMode();
  }

  @override
  Widget build(BuildContext context) {
    final mode = _mode;
    if (mode == null) {
      return const Scaffold(backgroundColor: AppColors.black);
    }

    switch (mode) {
      case EnergySavingMode.low:
        return LowEnergyHomePage(onOpenSettings: _openSettings);
      case EnergySavingMode.medium:
        return MediumEnergyHomePage(onOpenSettings: _openSettings);
      case EnergySavingMode.high:
        return HighEnergyHomePage(onOpenSettings: _openSettings);
    }
  }
}