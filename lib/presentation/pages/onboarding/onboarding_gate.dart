import 'package:flutter/material.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/services/screenshot_demo_data_seeder.dart';
import '../../../util/app_colors.dart';
import '../home/home_page.dart';
import 'onboarding_page.dart';

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key});

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  final SettingsRepository _settingsRepository = SettingsRepository();
  bool? _showOnboarding;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await ScreenshotDemoDataSeeder.seedIfNeeded();
    final seen = await _settingsRepository.getHasSeenOnboarding();
    if (!mounted) return;
    setState(() => _showOnboarding = !seen);
  }

  void _onCompleted() {
    _settingsRepository.setHasSeenOnboarding(true);
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    final showOnboarding = _showOnboarding;
    if (showOnboarding == null) return const _GateLoading();
    if (showOnboarding) return OnboardingPage(onCompleted: _onCompleted);
    return const HomePage();
  }
}

class _GateLoading extends StatelessWidget {
  const _GateLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.onBackground),
      ),
    );
  }
}
