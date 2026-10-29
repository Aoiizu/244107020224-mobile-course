import '../../../../core/failures.dart';
import '../../../../core/result.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../announcement_remote_source.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl(this._remote);
  final AnnouncementRemoteSource _remote;

  @override
  Future<Result<List<Announcement>>> fetchAll() async {
    try {
      final rows = await _remote.fetchAll();
      return Ok(
          rows.map((j) => AnnouncementModel.fromJson(j).toEntity()).toList());
    } catch (_) {
      return const Err(NetworkFailure('Could not load announcements'));
    }
  }

  @override
  Future<Result<Announcement>> fetchById(String id) async {
    final r = await fetchAll();
    return switch (r) {
      Ok(:final value) => value.any((a) => a.id == id)
          ? Ok(value.firstWhere((a) => a.id == id))
          : const Err(NetworkFailure('Announcement not found')),
      Err(:final failure) => Err(failure),
    };
  }
}
