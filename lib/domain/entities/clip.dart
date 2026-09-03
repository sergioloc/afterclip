class Clip {
  final String id;
  final String filePath;
  final DateTime createdAt;

  const Clip({
    required this.id,
    required this.filePath,
    required this.createdAt,
  });

  bool get isAvailable => DateTime.now().difference(createdAt).inHours >= 24;

  Duration get timeUntilAvailable {
    final elapsed = DateTime.now().difference(createdAt);
    final remaining = const Duration(hours: 24) - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}