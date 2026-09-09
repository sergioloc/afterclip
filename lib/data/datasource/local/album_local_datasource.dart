import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../model/album_model.dart';

class AlbumLocalDatasource {
  static const _metadataFile = 'albums.json';

  Future<File> get _metadataFilePath async {
    final appDir = await getApplicationDocumentsDirectory();
    return File('${appDir.path}/$_metadataFile');
  }

  Future<List<AlbumModel>> getAllAlbums() async {
    try {
      final file = await _metadataFilePath;
      if (!await file.exists()) return [];

      final json = jsonDecode(await file.readAsString());
      return (json as List).map((e) => AlbumModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveAlbum(AlbumModel album) async {
    final albums = await getAllAlbums();
    albums.add(album);
    await _saveMetadata(albums);
  }

  Future<void> renameAlbum(String albumId, String newName) async {
    final albums = await getAllAlbums();
    final album = albums.firstWhere((a) => a.id == albumId);
    final updated = AlbumModel(
      id: album.id,
      name: newName,
      createdAt: album.createdAt,
    );
    albums[albums.indexOf(album)] = updated;
    await _saveMetadata(albums);
  }

  Future<void> deleteAlbum(String albumId) async {
    final albums = await getAllAlbums();
    albums.removeWhere((a) => a.id == albumId);
    await _saveMetadata(albums);
  }

  Future<void> _saveMetadata(List<AlbumModel> albums) async {
    final file = await _metadataFilePath;
    final json = albums.map((a) => a.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }
}