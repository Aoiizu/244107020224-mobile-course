import '../../domain/entities/announcement.dart';

class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.publishedAt,
  });

  final String id, title, body;
  final String publishedAt;

  factory AnnouncementModel.fromJson(Map<String, dynamic> j) =>
      AnnouncementModel(
        id: '${j['id']}',
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        publishedAt: j['published_at'] as String? ?? '',
      );

  Announcement toEntity() => Announcement(
        id: id,
        title: title,
        body: body,
        publishedAt: DateTime.tryParse(publishedAt) ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}
