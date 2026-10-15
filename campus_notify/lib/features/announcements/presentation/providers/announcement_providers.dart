import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result.dart';
import '../../data/announcement_remote_source.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcements.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>(
    (_) => AnnouncementRepositoryImpl(AnnouncementRemoteSource()));

final getAnnouncementsProvider =
    Provider((ref) => GetAnnouncements(ref.watch(announcementRepositoryProvider)));

final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final r = await ref.watch(getAnnouncementsProvider).call();
  return switch (r) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});

// Repository straight to provider: one-line lookup, no use case needed.
final announcementProvider =
    FutureProvider.family<Announcement, String>((ref, id) async {
  final r = await ref.watch(announcementRepositoryProvider).fetchById(id);
  return switch (r) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});
