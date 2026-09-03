import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _overlayOpacityKey = 'overlay_opacity';
  static const _brightnessKey = 'brightness';
  static const double defaultOverlayOpacity = 0.90;
  static const double defaultBrightness = 1.0;

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
}