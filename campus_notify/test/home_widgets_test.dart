import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notification_app/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notification_app/features/announcements/presentation/providers/announcement_providers.dart';
import 'package:campus_notification_app/features/announcements/presentation/widgets/announcement_results.dart';
import 'package:campus_notification_app/features/announcements/presentation/widgets/announcement_search_field.dart';

void main() {
  final items = [
    Announcement(
        id: '1',
        title: 'Library hours',
        body: '',
        publishedAt: DateTime(2026, 10, 10)),
    Announcement(
        id: '2',
        title: 'Midterm schedule',
        body: '',
        publishedAt: DateTime(2026, 10, 12)),
  ];

  testWidgets('typing in the search field filters the list (same behavior)',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [announcementsProvider.overrideWith((ref) async => items)],
      child: const MaterialApp(
        home: Scaffold(
          body: Column(children: [
            AnnouncementSearchField(),
            Expanded(child: AnnouncementResults()),
          ]),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Library hours'), findsOneWidget);
    expect(find.text('Midterm schedule'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'midterm');
    await tester.pump();
    expect(find.text('Library hours'), findsNothing);
    expect(find.text('Midterm schedule'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('No results for "zzz".'), findsOneWidget);
  });
}
