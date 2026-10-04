import '../entities/album.dart';
import '../repositories/album_repository.dart';

class CreateAlbumUseCase {
  final AlbumRepository _repository;

  CreateAlbumUseCase(this._repository);

  Future<Album> execute(String name) {
    return _repository.createAlbum(name);
  }
}