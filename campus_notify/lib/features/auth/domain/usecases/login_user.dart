import '../../../../core/failures.dart';
import '../../../../core/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  const LoginUser(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSession>> call(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    if (!cleanEmail.contains('@')) {
      return const Err(ValidationFailure('Enter a valid email'));
    }
    if (password.length < 6) {
      return const Err(
          ValidationFailure('Password must be at least 6 characters'));
    }
    return _repo.login(cleanEmail, password);
  }
}
