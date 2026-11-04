import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notification_app/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notification_app/features/announcements/domain/usecases/search_announcements.dart';
import 'package:campus_notification_app/features/announcements/presentation/widgets/announcement_list_view.dart';

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
    Announcement(
        id: '3',
        title: 'Library closed',
        body: '',
        publishedAt: DateTime(2026, 10, 14)),
  ];

  // Tests 1-3 came from the AI answer.
  test('filter ignores case', () {
    expect(const SearchAnnouncements()(items, 'LIBRARY'), hasLength(2));
  });

  test('no-match query returns empty', () {
    expect(const SearchAnnouncements()(items, 'zzz-missing'), isEmpty);
  });

  testWidgets('empty state is shown when nothing matches', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body:
            AnnouncementListView(items: const [], query: 'zzz', onOpen: (_) {}),
      ),
    ));
    expect(find.text('No results for "zzz".'), findsOneWidget);
  });

  // Tests 4-5 were added by me to cover gaps in the AI answer.
  test('query is trimmed', () {
    expect(const SearchAnnouncements()(items, '  midterm '), hasLength(1));
  });

  test('empty or blank query returns everything', () {
    expect(const SearchAnnouncements()(items, ''), hasLength(3));
    expect(const SearchAnnouncements()(items, '   '), hasLength(3));
  });
}
