import 'package:uuid/uuid.dart';
import '../../domain/entities/clip.dart';
import '../../domain/repositories/clip_repository.dart';
import '../datasource/local/clip_local_datasource.dart';
import '../model/clip_model.dart';

class ClipRepositoryImpl implements ClipRepository {
  final ClipLocalDatasource _localDatasource;
  final _uuid = const Uuid();

  ClipRepositoryImpl(this._localDatasource);

  @override
  Future<Clip> saveClip(String tempFilePath) async {
    final clip = Clip(
      id: _uuid.v4(),
      filePath: tempFilePath,
      createdAt: DateTime.now(),
    );

    final model = ClipModel.fromEntity(clip);
    await _localDatasource.saveClip(model, tempFilePath);

    return clip;
  }

  @override
  Future<List<Clip>> getAvailableClips() async {
    final clips = await _localDatasource.getAllClips();
    return clips
        .map((m) => m.toEntity())
        .where((c) => c.isAvailable)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Clip>> getAllClips() async {
    final clips = await _localDatasource.getAllClips();
    return clips.map((m) => m.toEntity()).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> deleteClip(String clipId) {
    return _localDatasource.deleteClip(clipId);
  }
}