import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notification_app/data/app_deps.dart';
import 'package:campus_notification_app/data/mock_adapter.dart';
import 'package:campus_notification_app/data/session.dart';
import 'package:campus_notification_app/data/token_store.dart';

Future<(AppDeps, MockAdapter)> setUpDeps() async {
  final mock = MockAdapter();
  final deps = AppDeps(store: MemoryTokenStore(), mock: mock);
  await deps.session.login('student@campus.edu', 'password');
  return (deps, mock);
}

Future<void> expireAccess(AppDeps d) async => d.store.save(
    TokenPair(access: 'access-0', refresh: (await d.store.readRefresh())!));

void main() {
  test('login stores tokens and authenticates', () async {
    final (d, _) = await setUpDeps();
    expect(d.session.isAuthenticated, isTrue);
    expect(await d.store.readRefresh(), startsWith('refresh-'));
  });

  test('401 triggers exactly one refresh, then the request is retried', () async {
    final (d, mock) = await setUpDeps();
    await expireAccess(d);
    final r = await d.api.get('/announcements/1');
    expect(r.statusCode, 200);
    expect(mock.refreshCalls, 1);
    expect(await d.store.readAccess(), isNot('access-0'));
    expect(d.session.isAuthenticated, isTrue);
  });

  test('parallel 401s share a single refresh call', () async {
    final (d, mock) = await setUpDeps();
    await expireAccess(d);
    await Future.wait([d.api.get('/announcements/1'), d.api.get('/announcements/2')]);
    expect(mock.refreshCalls, 1);
  });

  test('dead refresh token logs the user out and clears storage', () async {
    final (d, mock) = await setUpDeps();
    await expireAccess(d);
    mock.refreshRevoked = true;
    await expectLater(d.api.get('/announcements/1'), throwsA(isA<DioException>()));
    expect(d.session.status, SessionStatus.unauthenticated);
    expect(await d.store.readRefresh(), isNull);
    expect(mock.refreshCalls, 1); // no retry loop
  });
}
