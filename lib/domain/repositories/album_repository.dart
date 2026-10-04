import '../entities/album.dart';

abstract class AlbumRepository {
  Future<List<Album>> getAllAlbums();
  Future<Album> createAlbum(String name);
  Future<void> renameAlbum(String albumId, String newName);
  Future<void> deleteAlbum(String albumId);
  Future<void> setAlbumArchived(String albumId, bool archived);
}