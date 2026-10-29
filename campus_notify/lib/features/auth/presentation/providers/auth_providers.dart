import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result.dart';
import '../../../../shared/data/api_client.dart';
import '../../../../shared/data/token_store.dart';
import '../../data/auth_remote_source.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_user.dart';

final tokenStoreProvider = Provider((_) => TokenStore());
final authRemoteProvider = Provider((_) => AuthRemoteSource());

final authRepositoryProvider = Provider<AuthRepository>((ref) =>
    AuthRepositoryImpl(
        ref.watch(authRemoteProvider), ref.watch(tokenStoreProvider)));

final loginUserProvider =
    Provider((ref) => LoginUser(ref.watch(authRepositoryProvider)));

final dioProvider = Provider<Dio>((ref) => buildApiClient(
      ref.watch(tokenStoreProvider),
      ref.watch(authRemoteProvider).refresh,
    ));

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.read(authRepositoryProvider).hasSession();

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final r = await ref.read(loginUserProvider).call(email, password);
    state = switch (r) {
      Ok() => const AsyncData(true),
      Err(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(false);
  }
}
