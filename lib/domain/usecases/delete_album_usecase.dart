import '../repositories/album_repository.dart';

class DeleteAlbumUseCase {
  final AlbumRepository _repository;

  DeleteAlbumUseCase(this._repository);

  Future<void> execute(String albumId) {
    return _repository.deleteAlbum(albumId);
  }
}