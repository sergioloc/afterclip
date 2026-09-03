import '../entities/clip.dart';
import '../repositories/clip_repository.dart';

class SaveClipUseCase {
  final ClipRepository _repository;

  SaveClipUseCase(this._repository);

  Future<Clip> execute(String tempFilePath) {
    return _repository.saveClip(tempFilePath);
  }
}