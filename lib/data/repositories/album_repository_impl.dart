import 'package:uuid/uuid.dart';
import '../../domain/entities/album.dart';
import '../../domain/repositories/album_repository.dart';
import '../datasource/local/album_local_datasource.dart';
import '../model/album_model.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumLocalDatasource _localDatasource;
  final _uuid = const Uuid();

  AlbumRepositoryImpl(this._localDatasource);

  @override
  Future<List<Album>> getAllAlbums() async {
    final albums = await _localDatasource.getAllAlbums();
    return albums.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Album> createAlbum(String name) async {
    final album = Album(
      id: _uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
    );
    await _localDatasource.saveAlbum(AlbumModel.fromEntity(album));
    return album;
  }

  @override
  Future<void> renameAlbum(String albumId, String newName) {
    return _localDatasource.renameAlbum(albumId, newName);
  }

  @override
  Future<void> deleteAlbum(String albumId) {
    return _localDatasource.deleteAlbum(albumId);
  }
}