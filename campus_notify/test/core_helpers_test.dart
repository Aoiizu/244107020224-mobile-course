import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notification_app/core/failures.dart';
import 'package:campus_notification_app/core/format.dart';
import 'package:campus_notification_app/core/privacy.dart';
import 'package:campus_notification_app/routes.dart';

void main() {
  group('formatDate', () {
    test('prints day, short month and year', () {
      expect(formatDate(DateTime(2026, 10, 14)), '14 Oct 2026');
    });
  });

  group('messageOf', () {
    test('uses the message of a Failure', () {
      expect(messageOf(const NetworkFailure('offline')), 'offline');
    });

    test('removes the Exception prefix', () {
      expect(messageOf(Exception('boom')), 'boom');
    });
  });

  group('routeFromMessage', () {
    test('defaults to home when there is no route', () {
      expect(routeFromMessage({}), '/');
    });

    test('adds a leading slash', () {
      expect(routeFromMessage({'route': 'announcement/3'}), '/announcement/3');
    });

    test('keeps a valid route unchanged', () {
      expect(routeFromMessage({'route': '/announcement/3'}), '/announcement/3');
    });
  });

  group('redactSensitive', () {
    test('hides emails and long numbers but keeps short numbers', () {
      expect(
        redactSensitive('room 12 mail a@b.com id 1234567890'),
        'room 12 mail [email] id [number]',
      );
    });
  });
}
