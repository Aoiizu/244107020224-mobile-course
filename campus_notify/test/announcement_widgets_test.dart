import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notification_app/core/failures.dart';
import 'package:campus_notification_app/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notification_app/features/announcements/presentation/providers/announcement_providers.dart';
import 'package:campus_notification_app/features/announcements/presentation/widgets/announcement_list_view.dart';
import 'package:campus_notification_app/features/announcements/presentation/widgets/announcement_results.dart';

final _items = [
  Announcement(
      id: '1',
      title: 'Library hours',
      body: '',
      publishedAt: DateTime(2026, 10, 10)),
  Announcement(
      id: '2',
      title: 'Midterm schedule',
      body: '',
      publishedAt: DateTime(2026, 10, 14)),
];

Widget _wrap(Widget child, {List<dynamic> overrides = const []}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('AnnouncementListView', () {
    testWidgets('shows each title with its formatted date', (tester) async {
      await tester.pumpWidget(_wrap(
        AnnouncementListView(items: _items, query: '', onOpen: (_) {}),
      ));

      expect(find.text('Library hours'), findsOneWidget);
      expect(find.text('Midterm schedule'), findsOneWidget);
      expect(find.text('14 Oct 2026'), findsOneWidget);
    });

    testWidgets('tapping an item reports its id', (tester) async {
      String? opened;
      await tester.pumpWidget(_wrap(
        AnnouncementListView(
            items: _items, query: '', onOpen: (id) => opened = id),
      ));

      await tester.tap(find.text('Midterm schedule'));

      expect(opened, '2');
    });

    testWidgets('empty list without a query says there is nothing yet',
        (tester) async {
      await tester.pumpWidget(_wrap(
        AnnouncementListView(items: const [], query: '', onOpen: (_) {}),
      ));

      expect(find.text('No announcements yet.'), findsOneWidget);
    });
  });

  group('AnnouncementResults', () {
    testWidgets('shows a progress indicator while loading', (tester) async {
      await tester.pumpWidget(_wrap(
        const AnnouncementResults(),
        overrides: [
          visibleAnnouncementsProvider
              .overrideWithValue(const AsyncLoading<List<Announcement>>()),
        ],
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows the failure message and a Retry button on error',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const AnnouncementResults(),
        overrides: [
          visibleAnnouncementsProvider.overrideWithValue(
            AsyncError<List<Announcement>>(
              const NetworkFailure('Could not load announcements'),
              StackTrace.empty,
            ),
          ),
        ],
      ));

      expect(find.text('Could not load announcements'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('Retry loads the announcements again', (tester) async {
      var calls = 0;
      await tester.pumpWidget(_wrap(
        const AnnouncementResults(),
        overrides: [
          announcementsProvider.overrideWith((ref) async {
            calls++;
            throw StateError('offline');
          }),
        ],
      ));
      await tester.pumpAndSettle();
      expect(calls, 1);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(calls, 2);
    });
  });
}
