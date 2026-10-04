import '../repositories/album_repository.dart';

class RenameAlbumUseCase {
  final AlbumRepository _repository;

  RenameAlbumUseCase(this._repository);

  Future<void> execute(String albumId, String newName) {
    return _repository.renameAlbum(albumId, newName);
  }
}