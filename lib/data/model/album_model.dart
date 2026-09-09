import '../../domain/entities/album.dart';

class AlbumModel {
  final String id;
  final String name;
  final String createdAt;

  const AlbumModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory AlbumModel.fromEntity(Album album) {
    return AlbumModel(
      id: album.id,
      name: album.name,
      createdAt: album.createdAt.toIso8601String(),
    );
  }

  Album toEntity() {
    return Album(
      id: id,
      name: name,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt,
    };
  }
}