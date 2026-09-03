import '../../domain/entities/clip.dart';

class ClipModel {
  final String id;
  final String filePath;
  final String createdAt;

  const ClipModel({
    required this.id,
    required this.filePath,
    required this.createdAt,
  });

  factory ClipModel.fromEntity(Clip clip) {
    return ClipModel(
      id: clip.id,
      filePath: clip.filePath,
      createdAt: clip.createdAt.toIso8601String(),
    );
  }

  Clip toEntity() {
    return Clip(
      id: id,
      filePath: filePath,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory ClipModel.fromJson(Map<String, dynamic> json) {
    return ClipModel(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'createdAt': createdAt,
    };
  }
}