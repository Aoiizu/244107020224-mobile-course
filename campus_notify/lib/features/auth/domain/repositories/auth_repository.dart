import '../../../../core/result.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> login(String email, String password);
  Future<bool> hasSession();
  Future<void> logout();
}
