import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result.dart';
import '../../data/announcement_remote_source.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcements.dart';
import '../../domain/usecases/search_announcements.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>(
    (_) => AnnouncementRepositoryImpl(AnnouncementRemoteSource()));

final getAnnouncementsProvider = Provider(
    (ref) => GetAnnouncements(ref.watch(announcementRepositoryProvider)));

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

// --- Week 9: search ---

class SearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final searchQueryProvider =
    NotifierProvider<SearchQuery, String>(SearchQuery.new);

final visibleAnnouncementsProvider =
    Provider<AsyncValue<List<Announcement>>>((ref) {
  final all = ref.watch(announcementsProvider);
  final query = ref.watch(searchQueryProvider);
  return all.whenData((items) => const SearchAnnouncements()(items, query));
});
