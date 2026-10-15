import '../../../core/failures.dart';
import '../../../core/result.dart';
import '../../../shared/data/token_store.dart';
import '../domain/entities/auth_session.dart';
import '../domain/repositories/auth_repository.dart';
import 'auth_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._store);
  final AuthRemoteSource _remote;
  final TokenStore _store;

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    try {
      final t = await _remote.login(email, password);
      await _store.save(access: t.access, refresh: t.refresh);
      return Ok(AuthSession(email: email));
    } catch (e) {
      return Err(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<bool> hasSession() async => (await _store.readAccess()) != null;

  @override
  Future<void> logout() => _store.clear();
}
