class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.publishedAt,
  });
  final String id, title, body;
  final DateTime publishedAt;
}
