import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campus_notification_app/main.dart' as app;
import 'package:campus_notification_app/shared/data/token_store.dart';

// Firebase is not initialized here on purpose: the app skips push setup when
// there is no Firebase app, so no notification permission dialog appears.
Future<void> _launch(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: app.App()));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Start every test logged out, even if an earlier run saved tokens.
  setUp(() async {
    await TokenStore().clear();
  });

  testWidgets('login, search, open an announcement and go back',
      (tester) async {
    await _launch(tester);
    expect(find.byKey(const Key('login-button')), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('email-field')), '  Alif@Mail.COM ');
    await tester.enterText(find.byKey(const Key('password-field')), '123456');
    await tester.tap(find.byKey(const Key('login-button')));
    await tester.pumpAndSettle();

    expect(find.text('Campus Notify'), findsOneWidget);
    expect(find.text('Library hours'), findsOneWidget);
    expect(find.text('Midterm schedule'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('search-field')), 'library');
    await tester.pumpAndSettle();
    expect(find.text('Library hours'), findsOneWidget);
    expect(find.text('Midterm schedule'), findsNothing);

    await tester.tap(find.text('Library hours'));
    await tester.pumpAndSettle();
    expect(find.text('The library closes at 6 PM on Friday.'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search-field')), findsOneWidget);
  });

  testWidgets('an invalid login shows feedback and stays on the login page',
      (tester) async {
    await _launch(tester);

    await tester.enterText(find.byKey(const Key('email-field')), 'bad-email');
    await tester.enterText(find.byKey(const Key('password-field')), '123456');
    await tester.tap(find.byKey(const Key('login-button')));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.byKey(const Key('login-button')), findsOneWidget);
  });
}
