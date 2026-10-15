import '../../../../core/result.dart';
import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

class GetAnnouncements {
  const GetAnnouncements(this._repo);
  final AnnouncementRepository _repo;

  // Business rule: newest first.
  Future<Result<List<Announcement>>> call() async {
    final r = await _repo.fetchAll();
    return switch (r) {
      Ok(:final value) =>
        Ok([...value]..sort((a, b) => b.publishedAt.compareTo(a.publishedAt))),
      Err() => r,
    };
  }
}
