import '../entities/album.dart';
import '../repositories/album_repository.dart';

class GetAllAlbumsUseCase {
  final AlbumRepository _repository;

  GetAllAlbumsUseCase(this._repository);

  Future<List<Album>> execute() {
    return _repository.getAllAlbums();
  }
}