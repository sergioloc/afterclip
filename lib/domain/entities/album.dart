class Album {
  final String id;
  final String name;
  final DateTime createdAt;
  final bool archived;

  const Album({
    required this.id,
    required this.name,
    required this.createdAt,
    this.archived = false,
  });
}