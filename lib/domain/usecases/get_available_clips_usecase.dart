import '../entities/clip.dart';
import '../repositories/clip_repository.dart';

class GetAvailableClipsUseCase {
  final ClipRepository _repository;

  GetAvailableClipsUseCase(this._repository);

  Future<List<Clip>> execute() {
    return _repository.getAvailableClips();
  }
}