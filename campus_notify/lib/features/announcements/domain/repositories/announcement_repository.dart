import '../../../../core/result.dart';
import '../entities/announcement.dart';

abstract class AnnouncementRepository {
  Future<Result<List<Announcement>>> fetchAll();
  Future<Result<Announcement>> fetchById(String id);
}
