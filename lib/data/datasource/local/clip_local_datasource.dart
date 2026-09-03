import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../model/clip_model.dart';

class ClipLocalDatasource {
  static const _clipsDir = 'clips';
  static const _metadataFile = 'clips.json';

  Future<Directory> get _clipsDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final clipsDir = Directory('${appDir.path}/$_clipsDir');
    if (!await clipsDir.exists()) {
      await clipsDir.create(recursive: true);
    }
    return clipsDir;
  }

  Future<File> get _metadataFilePath async {
    final appDir = await getApplicationDocumentsDirectory();
    return File('${appDir.path}/$_metadataFile');
  }

  Future<void> saveClip(ClipModel clip, String tempFilePath) async {
    final clipsDir = await _clipsDirectory;
    final extension = tempFilePath.split('.').last;
    final newFilePath = '${clipsDir.path}/${clip.id}.$extension';

    await File(tempFilePath).copy(newFilePath);

    final clips = await getAllClips();
    clips.add(clip);
    await _saveMetadata(clips);
  }

  Future<List<ClipModel>> getAllClips() async {
    try {
      final file = await _metadataFilePath;
      if (!await file.exists()) return [];

      final json = jsonDecode(await file.readAsString());
      return (json as List).map((e) => ClipModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteClip(String clipId) async {
    final clips = await getAllClips();
    final clip = clips.firstWhere((c) => c.id == clipId);

    final file = File(clip.filePath);
    if (await file.exists()) {
      await file.delete();
    }

    clips.removeWhere((c) => c.id == clipId);
    await _saveMetadata(clips);
  }

  Future<void> _saveMetadata(List<ClipModel> clips) async {
    final file = await _metadataFilePath;
    final json = clips.map((c) => c.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }
}