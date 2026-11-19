import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notification_app/core/result.dart';
import 'package:campus_notification_app/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notification_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notification_app/features/auth/presentation/pages/login_page.dart';
import 'package:campus_notification_app/features/auth/presentation/providers/auth_providers.dart';

class RecordingAuthRepo implements AuthRepository {
  int loginCalls = 0;
  String? lastEmail;

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    loginCalls++;
    lastEmail = email;
    return Ok(AuthSession(email: email));
  }

  @override
  Future<bool> hasSession() async => false;

  @override
  Future<void> logout() async {}
}

Future<void> _pumpLogin(WidgetTester tester, RecordingAuthRepo repo) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
    child: const MaterialApp(home: LoginPage()),
  ));
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester, String email, String password) async {
  await tester.enterText(find.byKey(const Key('email-field')), email);
  await tester.enterText(find.byKey(const Key('password-field')), password);
  await tester.tap(find.byKey(const Key('login-button')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the email, password and login controls', (tester) async {
    await _pumpLogin(tester, RecordingAuthRepo());

    expect(find.byKey(const Key('email-field')), findsOneWidget);
    expect(find.byKey(const Key('password-field')), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
  });

  testWidgets('an invalid email shows feedback and does not call the repo',
      (tester) async {
    final repo = RecordingAuthRepo();
    await _pumpLogin(tester, repo);

    await _submit(tester, 'not-an-email', '123456');

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(repo.loginCalls, 0);
  });

  testWidgets('a short password shows feedback', (tester) async {
    final repo = RecordingAuthRepo();
    await _pumpLogin(tester, repo);

    await _submit(tester, 'a@b.com', '123');

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    expect(repo.loginCalls, 0);
  });

  testWidgets('valid input is normalized and sent to the repository once',
      (tester) async {
    final repo = RecordingAuthRepo();
    await _pumpLogin(tester, repo);

    await _submit(tester, '  Alif@Mail.COM ', '123456');

    expect(repo.loginCalls, 1);
    expect(repo.lastEmail, 'alif@mail.com');
    expect(find.text('Enter a valid email'), findsNothing);
  });
}
