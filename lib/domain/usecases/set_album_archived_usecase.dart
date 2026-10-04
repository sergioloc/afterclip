import '../repositories/album_repository.dart';

class SetAlbumArchivedUseCase {
  final AlbumRepository _repository;

  SetAlbumArchivedUseCase(this._repository);

  Future<void> execute(String albumId, bool archived) {
    return _repository.setAlbumArchived(albumId, archived);
  }
}