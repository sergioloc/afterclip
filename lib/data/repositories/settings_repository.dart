import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/energy_saving_mode.dart';

class SettingsRepository {
  static const _overlayOpacityKey = 'overlay_opacity';
  static const _brightnessKey = 'brightness';
  static const _energySavingModeKey = 'energy_saving_mode';
  static const _maxClipDurationKey = 'max_clip_duration';
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const double defaultOverlayOpacity = 0.90;
  static const double defaultBrightness = 1.0;
  static const EnergySavingMode defaultEnergySavingMode = EnergySavingMode.off;
  static const int defaultMaxClipDuration = 30;
  static const List<int> maxClipDurationOptions = [30, 60, 90];
  static const bool defaultHasSeenOnboarding = false;

  late final SharedPreferencesAsync _prefs;

  SettingsRepository() {
    _prefs = SharedPreferencesAsync();
  }

  Future<double> getOverlayOpacity() async {
    return await _prefs.getDouble(_overlayOpacityKey) ?? defaultOverlayOpacity;
  }

  Future<void> setOverlayOpacity(double value) async {
    await _prefs.setDouble(_overlayOpacityKey, value);
  }

  Future<double> getBrightness() async {
    return await _prefs.getDouble(_brightnessKey) ?? defaultBrightness;
  }

  Future<void> setBrightness(double value) async {
    await _prefs.setDouble(_brightnessKey, value);
  }

  Future<EnergySavingMode> getEnergySavingMode() async {
    final index = await _prefs.getInt(_energySavingModeKey);
    if (index == null || index < 0 || index >= EnergySavingMode.values.length) {
      return defaultEnergySavingMode;
    }
    return EnergySavingMode.values[index];
  }

  Future<void> setEnergySavingMode(EnergySavingMode mode) async {
    await _prefs.setInt(_energySavingModeKey, mode.index);
  }

  Future<int> getMaxClipDuration() async {
    return await _prefs.getInt(_maxClipDurationKey) ?? defaultMaxClipDuration;
  }

  Future<void> setMaxClipDuration(int seconds) async {
    await _prefs.setInt(_maxClipDurationKey, seconds);
  }

  Future<bool> getHasSeenOnboarding() async {
    return await _prefs.getBool(_hasSeenOnboardingKey) ?? defaultHasSeenOnboarding;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs.setBool(_hasSeenOnboardingKey, value);
  }
}