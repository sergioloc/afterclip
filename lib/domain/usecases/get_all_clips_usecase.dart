import '../entities/clip.dart';
import '../repositories/clip_repository.dart';

class GetAllClipsUseCase {
  final ClipRepository _repository;

  GetAllClipsUseCase(this._repository);

  Future<List<Clip>> execute() {
    return _repository.getAllClips();
  }
}