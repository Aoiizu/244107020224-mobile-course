import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_clients.dart';
import '../data/auth_repository.dart';
import '../data/token_store.dart';

final tokenStoreProvider = Provider((_) => TokenStore());
final authRepositoryProvider = Provider((_) => AuthRepository());
final dioProvider = Provider<Dio>((ref) =>
    buildApiClient(ref.watch(tokenStoreProvider), ref.watch(authRepositoryProvider)));

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async =>
      (await ref.read(tokenStoreProvider).readAccess()) != null;

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final s = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: s.access, refresh: s.refresh);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(false);
  }
}