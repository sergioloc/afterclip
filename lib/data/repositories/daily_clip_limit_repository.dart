import 'package:shared_preferences/shared_preferences.dart';

class DailyClipLimitRepository {
  static const int maxClips = 24;
  static const Duration rollingWindow = Duration(hours: 24);
  static const String _recordedClipsKey = 'free_clips_recorded_at';
  static const String _migrationCompletedKey = 'free_clip_limit_migrated_v1';

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  Future<int> getClipsRecordedInLast24Hours({DateTime? now}) async {
    final recordedAt = await _getRecentRecordingTimes(now ?? DateTime.now());
    return recordedAt.length;
  }

  Future<void> recordClip({DateTime? recordedAt}) async {
    final timestamp = (recordedAt ?? DateTime.now()).toUtc();
    final recent = await _getRecentRecordingTimes(timestamp);
    recent.add(timestamp);
    await _preferences.setStringList(
      _recordedClipsKey,
      recent.map((date) => date.toIso8601String()).toList(),
    );
  }

  Future<void> seedFromSavedClips(Iterable<DateTime> clipDates) async {
    final migrationCompleted =
        await _preferences.getBool(_migrationCompletedKey) ?? false;
    if (migrationCompleted) return;

    final now = DateTime.now().toUtc();
    final recent = await _getRecentRecordingTimes(now);
    final cutoff = now.subtract(rollingWindow);
    final knownTimestamps =
        recent.map((date) => date.microsecondsSinceEpoch).toSet();

    for (final clipDate in clipDates) {
      final timestamp = clipDate.toUtc();
      if (timestamp.isAfter(cutoff) &&
          knownTimestamps.add(timestamp.microsecondsSinceEpoch)) {
        recent.add(timestamp);
      }
    }

    await _preferences.setStringList(
      _recordedClipsKey,
      recent.map((date) => date.toIso8601String()).toList(),
    );
    await _preferences.setBool(_migrationCompletedKey, true);
  }

  Future<List<DateTime>> _getRecentRecordingTimes(DateTime now) async {
    final values = await _preferences.getStringList(_recordedClipsKey) ?? [];
    final cutoff = now.toUtc().subtract(rollingWindow);
    final recent = <DateTime>[];

    for (final value in values) {
      final parsed = DateTime.tryParse(value);
      if (parsed == null) continue;

      final timestamp = parsed.toUtc();
      if (timestamp.isAfter(cutoff)) {
        recent.add(timestamp);
      }
    }

    final normalizedValues =
        recent.map((date) => date.toIso8601String()).toList();
    if (normalizedValues.length != values.length ||
        !_sameValues(normalizedValues, values)) {
      await _preferences.setStringList(_recordedClipsKey, normalizedValues);
    }

    return recent;
  }

  bool _sameValues(List<String> normalized, List<String> original) {
    if (normalized.length != original.length) return false;
    for (var index = 0; index < normalized.length; index++) {
      if (normalized[index] != original[index]) return false;
    }
    return true;
  }
}
