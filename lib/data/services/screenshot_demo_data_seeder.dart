import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/app_flavor.dart';
import '../model/album_model.dart';
import '../model/clip_model.dart';
import '../repositories/daily_clip_limit_repository.dart';

class ScreenshotDemoDataSeeder {
  /// Enable with `flutter run --flavor free --dart-define=AFTERCLIP_SCREENSHOT_DEMO=true`.
  static const bool enabled = kDebugMode && bool.fromEnvironment('AFTERCLIP_SCREENSHOT_DEMO');
  static const _seededKey = 'screenshot_demo_data_seeded_v1';

  static Future<void> seedIfNeeded() async {
    if (!enabled) return;

    try {
      final preferences = SharedPreferencesAsync();
      if (await preferences.getBool(_seededKey) ?? false) return;

      final appDirectory = await getApplicationDocumentsDirectory();
      final albumsFile = File('${appDirectory.path}/albums.json');
      final clipsFile = File('${appDirectory.path}/clips.json');

      // Never mix demo data with albums or clips already on the device.
      if (await albumsFile.exists() || await clipsFile.exists()) {
        await preferences.setBool(_seededKey, true);
        return;
      }

      final now = DateTime.now();
      final albums = [
        AlbumModel(
          id: 'screenshot-bachelor-party',
          name: 'Bachelor Party',
          createdAt: now.subtract(const Duration(days: 8)).toIso8601String(),
        ),
        AlbumModel(
          id: 'screenshot-21st-birthday',
          name: '21st Birthday',
          createdAt: now.subtract(const Duration(days: 5)).toIso8601String(),
        ),
        AlbumModel(
          id: 'screenshot-ski-trip',
          name: 'Ski Trip',
          createdAt: now.subtract(const Duration(days: 3)).toIso8601String(),
        ),
        AlbumModel(
          id: 'screenshot-weekend-in-paris',
          name: 'Weekend in Paris',
          createdAt: now.subtract(const Duration(days: 2)).toIso8601String(),
        ),
        AlbumModel(
          id: 'screenshot-team-building',
          name: 'Team Building',
          createdAt: now.subtract(const Duration(days: 1)).toIso8601String(),
        ),
      ];

      final clipsDirectory = Directory('${appDirectory.path}/clips');
      await clipsDirectory.create(recursive: true);
      final clips = <ClipModel>[];

      // The first two clips per album count toward the rolling 24-hour limit.
      void addClip(String id, String albumId, Duration age) {
        clips.add(
          ClipModel(
            id: 'screenshot-$id',
            filePath: '${clipsDirectory.path}/screenshot-$id.mp4',
            createdAt: now.subtract(age).toIso8601String(),
            albumId: albumId,
          ),
        );
      }

      void addClipGroup(String prefix, String albumId, int count) {
        for (var index = 0; index < count; index++) {
          final age = index < 2
              ? Duration(minutes: 45 + (clips.length * 73) % (20 * 60))
              : Duration(days: 2, hours: index * 2, minutes: index * 11);
          final clipNumber = (index + 1).toString().padLeft(2, '0');
          addClip('$prefix-$clipNumber', albumId, age);
        }
      }

      addClipGroup('bachelor', 'screenshot-bachelor-party', 3);
      addClipGroup('birthday', 'screenshot-21st-birthday', 4);
      addClipGroup('ski', 'screenshot-ski-trip', 5);
      addClipGroup('paris', 'screenshot-weekend-in-paris', 6);
      addClipGroup('team', 'screenshot-team-building', 7);

      final sampleVideo = await rootBundle.load(
        'assets/demo/screenshot_clip.mp4',
      );
      final sampleVideoBytes = sampleVideo.buffer.asUint8List(
        sampleVideo.offsetInBytes,
        sampleVideo.lengthInBytes,
      );
      for (final clip in clips) {
        await File(clip.filePath).writeAsBytes(sampleVideoBytes);
      }

      await albumsFile.writeAsString(
        jsonEncode(albums.map((album) => album.toJson()).toList()),
      );
      await clipsFile.writeAsString(
        jsonEncode(clips.map((clip) => clip.toJson()).toList()),
      );

      if (AppFlavorConfig.isFree) {
        final dailyLimitRepository = DailyClipLimitRepository();
        for (final clip in clips) {
          await dailyLimitRepository.recordClip(
            recordedAt: DateTime.parse(clip.createdAt),
          );
        }
      }

      await preferences.setBool(_seededKey, true);
    } catch (error, stackTrace) {
      debugPrint('Screenshot demo data seeding failed: $error\n$stackTrace');
    }
  }
}
