import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notification_app/core/result.dart';
import 'package:campus_notification_app/features/announcements/data/announcement_remote_source.dart';
import 'package:campus_notification_app/features/announcements/data/repositories/announcement_repository_impl.dart';
import 'package:campus_notification_app/features/announcements/domain/entities/announcement.dart';

class CountingSource extends AnnouncementRemoteSource {
  int calls = 0;
  bool fail = false;

  @override
  Future<List<Map<String, dynamic>>> fetchAll() async {
    calls++;
    if (fail) throw Exception('offline');
    return [
      {
        'id': 1,
        'title': 'A',
        'body': '',
        'published_at': '2026-10-10T08:00:00'
      },
    ];
  }
}

void main() {
  late CountingSource source;
  late DateTime clock;
  late AnnouncementRepositoryImpl repo;

  setUp(() {
    source = CountingSource();
    clock = DateTime(2026, 11, 1, 10);
    repo = AnnouncementRepositoryImpl(
      source,
      ttl: const Duration(seconds: 30),
      now: () => clock,
    );
  });

  test('second fetchAll inside the ttl is served from cache', () async {
    await repo.fetchAll();
    await repo.fetchAll();
    expect(source.calls, 1);
  });

  test('fetchById after fetchAll does not call the source again', () async {
    await repo.fetchAll();
    final r = await repo.fetchById('1');
    expect(r, isA<Ok<Announcement>>());
    expect(source.calls, 1);
  });

  test('expired cache fetches again', () async {
    await repo.fetchAll();
    clock = clock.add(const Duration(seconds: 31));
    await repo.fetchAll();
    expect(source.calls, 2);
  });

  test('concurrent calls share one request', () async {
    await Future.wait([repo.fetchAll(), repo.fetchAll(), repo.fetchAll()]);
    expect(source.calls, 1);
  });

  test('stale data is served when the refresh fails', () async {
    await repo.fetchAll();
    clock = clock.add(const Duration(seconds: 31));
    source.fail = true;
    final r = await repo.fetchAll();
    expect(r, isA<Ok<List<Announcement>>>());
    expect((r as Ok<List<Announcement>>).value, hasLength(1));
  });

  test('failure with an empty cache returns an error', () async {
    source.fail = true;
    final r = await repo.fetchAll();
    expect(r, isA<Err<List<Announcement>>>());
  });
}
