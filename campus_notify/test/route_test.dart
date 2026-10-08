import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notification_app/router/route_logic.dart';

void main() {
  group('routeFromMessageData', () {
    test('uses data.route when valid', () {
      expect(routeFromMessageData({'route': '/announcement/42'}), '/announcement/42');
    });
    test('falls back to announcementId', () {
      expect(routeFromMessageData({'announcementId': '7'}), '/announcement/7');
    });
    test('rejects unknown or malicious routes', () {
      expect(routeFromMessageData({'route': '/admin'}), isNull);
      expect(routeFromMessageData({'route': '//evil.com'}), isNull);
      expect(routeFromMessageData({'announcementId': '../x'}), isNull);
      expect(routeFromMessageData({}), isNull);
    });
  });

  group('authRedirect (route guard)', () {
    test('unauthenticated is always sent to /login', () {
      expect(authRedirect(loggedIn: false, location: '/'), '/login');
      expect(authRedirect(loggedIn: false, location: '/login'), isNull);
    });
    test('unauthenticated deep link keeps destination in ?from=', () {
      final r = authRedirect(loggedIn: false, location: '/announcement/42')!;
      expect(Uri.parse(r).path, '/login');
      expect(Uri.parse(r).queryParameters['from'], '/announcement/42');
    });
    test('after login, /login bounces to ?from= or /', () {
      expect(authRedirect(loggedIn: true, location: '/login?from=%2Fannouncement%2F42'),
          '/announcement/42');
      expect(authRedirect(loggedIn: true, location: '/login'), '/');
    });
    test('blocks open redirect via ?from=', () {
      expect(authRedirect(loggedIn: true, location: '/login?from=%2F%2Fevil.com'), '/');
    });
    test('authenticated users reach protected pages', () {
      expect(authRedirect(loggedIn: true, location: '/announcement/1'), isNull);
    });
  });
}
