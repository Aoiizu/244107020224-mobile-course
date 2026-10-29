import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notification_app/core/failures.dart';
import 'package:campus_notification_app/core/result.dart';
import 'package:campus_notification_app/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notification_app/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:campus_notification_app/features/announcements/domain/usecases/get_announcements.dart';
import 'package:campus_notification_app/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notification_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notification_app/features/auth/domain/usecases/login_user.dart';

class FakeAnnouncementRepo implements AnnouncementRepository {
  FakeAnnouncementRepo({this.items = const [], this.fail = false});
  final List<Announcement> items;
  final bool fail;

  @override
  Future<Result<List<Announcement>>> fetchAll() async =>
      fail ? const Err(NetworkFailure('offline')) : Ok(items);

  @override
  Future<Result<Announcement>> fetchById(String id) =>
      throw UnimplementedError();
}

class FakeAuthRepo implements AuthRepository {
  int loginCalls = 0;

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    loginCalls++;
    return Ok(AuthSession(email: email));
  }

  @override
  Future<bool> hasSession() async => false;

  @override
  Future<void> logout() async {}
}

void main() {
  test('GetAnnouncements sorts newest first', () async {
    final repo = FakeAnnouncementRepo(items: [
      Announcement(
          id: '1', title: 'old', body: '', publishedAt: DateTime(2026, 1, 1)),
      Announcement(
          id: '2', title: 'new', body: '', publishedAt: DateTime(2026, 6, 1)),
    ]);
    final r = await GetAnnouncements(repo).call();
    expect((r as Ok<List<Announcement>>).value.first.title, 'new');
  });

  test('GetAnnouncements forwards failure', () async {
    final r = await GetAnnouncements(FakeAnnouncementRepo(fail: true)).call();
    expect(r, isA<Err<List<Announcement>>>());
  });

  test('LoginUser rejects bad input without calling the repo', () async {
    final repo = FakeAuthRepo();
    final r = await LoginUser(repo).call('no-at-sign', '123456');
    expect(r, isA<Err<AuthSession>>());
    expect(repo.loginCalls, 0);
  });

  test('LoginUser passes valid input to the repo', () async {
    final repo = FakeAuthRepo();
    final r = await LoginUser(repo).call('a@b.com', '123456');
    expect(r, isA<Ok<AuthSession>>());
    expect(repo.loginCalls, 1);
  });
}
