import 'package:flutter/services.dart';

enum AppFlavor {
  free,
  pro,
}

abstract final class AppFlavorConfig {
  static const MethodChannel _channel = MethodChannel('afterclip/flavor');

  static AppFlavor _current = AppFlavor.free;

  static AppFlavor get current => _current;

  static bool get isPro => _current == AppFlavor.pro;

  static bool get isFree => _current == AppFlavor.free;

  static String get appName => isPro ? 'AfterClip Pro' : 'AfterClip';

  static Future<void> load() async {
    try {
      final value = await _channel.invokeMethod<String>('getFlavor');
      _current = value == 'pro' ? AppFlavor.pro : AppFlavor.free;
    } catch (_) {
      _current = AppFlavor.free;
    }
  }
}