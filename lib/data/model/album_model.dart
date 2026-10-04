import '../../domain/entities/album.dart';

class AlbumModel {
  final String id;
  final String name;
  final String createdAt;
  final bool archived;

  const AlbumModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.archived = false,
  });

  factory AlbumModel.fromEntity(Album album) {
    return AlbumModel(
      id: album.id,
      name: album.name,
      createdAt: album.createdAt.toIso8601String(),
      archived: album.archived,
    );
  }

  Album toEntity() {
    return Album(
      id: id,
      name: name,
      createdAt: DateTime.parse(createdAt),
      archived: archived,
    );
  }

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: json['createdAt'] as String,
      archived: json['archived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt,
      'archived': archived,
    };
  }
}