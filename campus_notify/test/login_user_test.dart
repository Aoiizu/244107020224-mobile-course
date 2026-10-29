import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notification_app/core/failures.dart';
import 'package:campus_notification_app/core/result.dart';
import 'package:campus_notification_app/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notification_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notification_app/features/auth/domain/usecases/login_user.dart';

class CapturingAuthRepo implements AuthRepository {
  String? lastEmail;

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    lastEmail = email;
    return Ok(AuthSession(email: email));
  }

  @override
  Future<bool> hasSession() async => false;

  @override
  Future<void> logout() async {}
}

void main() {
  test('trims and lowercases the email before calling the repository', () async {
    final repo = CapturingAuthRepo();
    final r = await LoginUser(repo).call('  Alif@Mail.COM ', '123456');
    expect(r, isA<Ok<AuthSession>>());
    expect(repo.lastEmail, 'alif@mail.com');
  });

  test('blank email is rejected and the repository is not called', () async {
    final repo = CapturingAuthRepo();
    final r = await LoginUser(repo).call('   ', '123456');
    expect(r, isA<Err<AuthSession>>());
    expect((r as Err<AuthSession>).failure, isA<ValidationFailure>());
    expect(repo.lastEmail, isNull);
  });
}
