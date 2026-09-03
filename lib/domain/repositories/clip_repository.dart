import '../entities/clip.dart';

abstract class ClipRepository {
  Future<Clip> saveClip(String tempFilePath);
  Future<List<Clip>> getAvailableClips();
  Future<List<Clip>> getAllClips();
  Future<void> deleteClip(String clipId);
}