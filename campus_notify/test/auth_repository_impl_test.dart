import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notification_app/core/failures.dart';
import 'package:campus_notification_app/core/result.dart';
import 'package:campus_notification_app/features/auth/data/auth_remote_source.dart';
import 'package:campus_notification_app/features/auth/data/auth_repository_impl.dart';
import 'package:campus_notification_app/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notification_app/shared/data/token_store.dart';

class FakeRemote extends AuthRemoteSource {
  FakeRemote({this.fail = false});
  final bool fail;

  @override
  Future<TokenPair> login(String email, String password) async {
    if (fail) throw Exception('Wrong email or password');
    return TokenPair('access-$email', 'refresh-$email');
  }
}

class MemoryTokenStore extends TokenStore {
  String? access;
  String? refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

void main() {
  late MemoryTokenStore store;

  setUp(() => store = MemoryTokenStore());

  test('login success saves both tokens and returns the session', () async {
    final repo = AuthRepositoryImpl(FakeRemote(), store);
    final r = await repo.login('a@b.com', '123456');

    expect(r, isA<Ok<AuthSession>>());
    expect((r as Ok<AuthSession>).value.email, 'a@b.com');
    expect(store.access, 'access-a@b.com');
    expect(store.refresh, 'refresh-a@b.com');
  });

  test('login failure returns an AuthFailure and saves nothing', () async {
    final repo = AuthRepositoryImpl(FakeRemote(fail: true), store);
    final r = await repo.login('a@b.com', 'wrong-pass');

    expect(r, isA<Err<AuthSession>>());
    final failure = (r as Err<AuthSession>).failure;
    expect(failure, isA<AuthFailure>());
    expect(failure.message, 'Wrong email or password');
    expect(store.access, isNull);
    expect(store.refresh, isNull);
  });

  test('hasSession follows the stored access token', () async {
    final repo = AuthRepositoryImpl(FakeRemote(), store);
    expect(await repo.hasSession(), isFalse);

    await repo.login('a@b.com', '123456');
    expect(await repo.hasSession(), isTrue);
  });

  test('logout clears the stored tokens', () async {
    final repo = AuthRepositoryImpl(FakeRemote(), store);
    await repo.login('a@b.com', '123456');
    await repo.logout();

    expect(await repo.hasSession(), isFalse);
    expect(store.refresh, isNull);
  });
}
