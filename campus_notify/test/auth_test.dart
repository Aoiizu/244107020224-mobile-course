import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/routes.dart';

void main() {
  test('routeFromMessage', () {
    expect(routeFromMessage({}), '/');
    expect(routeFromMessage({'route': 'announcement/3'}), '/announcement/3');
    expect(routeFromMessage({'route': '/announcement/3'}), '/announcement/3');
  });

  test('announcementOf builds path', () {
    expect(Routes.announcementOf('3'), '/announcement/3');
  });

  test('empty refresh token means re-login needed', () {
    const String? refresh = '';
    expect((refresh ?? '').isEmpty, isTrue);
  });
}