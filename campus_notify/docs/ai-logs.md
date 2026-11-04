## Announcement title search with empty state

### Design
- Filtering rule is a pure domain use case (no Flutter/Dio imports).
- A `Notifier<String>` holds the query; a derived provider combines it with `announcementsProvider`.
- The widget only reads state and renders a list or an empty state.

### 1. Domain: `lib/features/announcements/domain/usecases/search_announcements.dart`
```dart
import '../entities/announcement.dart';

class SearchAnnouncements {
  const SearchAnnouncements();

  List<Announcement> call(List<Announcement> items, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((a) => a.title.toLowerCase().contains(q)).toList();
  }
}
```

### 2. Providers: add to `announcement_providers.dart`
```dart
import '../../domain/usecases/search_announcements.dart';

class SearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final searchQueryProvider =
    NotifierProvider<SearchQuery, String>(SearchQuery.new);

final visibleAnnouncementsProvider =
    Provider<AsyncValue<List<Announcement>>>((ref) {
  final all = ref.watch(announcementsProvider);
  final query = ref.watch(searchQueryProvider);
  return all.whenData((items) => const SearchAnnouncements()(items, query));
});
```

### 3. Widget: `presentation/widgets/announcement_list_view.dart`
```dart
import 'package:flutter/material.dart';
import '../../../../core/format.dart';
import '../../domain/entities/announcement.dart';

class AnnouncementListView extends StatelessWidget {
  const AnnouncementListView({
    super.key,
    required this.items,
    required this.query,
    required this.onOpen,
  });

  final List<Announcement> items;
  final String query;
  final void Function(String id) onOpen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      final q = query.trim();
      return Center(
        child: Text(q.isEmpty ? 'No announcements yet.' : 'No results for "$q".'),
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(items[i].title),
        subtitle: Text(formatDate(items[i].publishedAt)),
        onTap: () => onOpen(items[i].id),
      ),
    );
  }
}
```

### 4. Page: in `home_page.dart`
Watch `visibleAnnouncementsProvider` instead of `announcementsProvider`, and add above the list:
```dart
TextField(
  onChanged: ref.read(searchQueryProvider.notifier).set,
  decoration: const InputDecoration(
    prefixIcon: Icon(Icons.search),
    hintText: 'Search by title',
  ),
),
```
Use in the `data:` branch:
```dart
data: (items) => AnnouncementListView(
  items: items,
  query: ref.watch(searchQueryProvider),
  onOpen: (id) => context.go(Routes.announcementOf(id)),
),
```

### Tests: `test/search_filter_test.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notification_app/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notification_app/features/announcements/domain/usecases/search_announcements.dart';
import 'package:campus_notification_app/features/announcements/presentation/widgets/announcement_list_view.dart';

void main() {
  final items = [
    Announcement(id: '1', title: 'Library hours', body: '', publishedAt: DateTime(2026, 10, 10)),
    Announcement(id: '2', title: 'Midterm schedule', body: '', publishedAt: DateTime(2026, 10, 12)),
    Announcement(id: '3', title: 'Library closed', body: '', publishedAt: DateTime(2026, 10, 14)),
  ];

  test('filter ignores case', () {
    expect(const SearchAnnouncements()(items, 'LIBRARY'), hasLength(2));
  });

  test('no-match query returns empty', () {
    expect(const SearchAnnouncements()(items, 'zzz-missing'), isEmpty);
  });

  testWidgets('empty state is shown when nothing matches', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AnnouncementListView(items: const [], query: 'zzz', onOpen: (_) {}),
      ),
    ));
    expect(find.text('No results for "zzz".'), findsOneWidget);
  });
}
```

### How to test
```bash
flutter analyze
flutter test test/search_filter_test.dart
flutter run
```
Manual: type `library`, `LIBRARY`, `zzz`, then clear the box. Expect 2 results, 2 results, the empty message, then all items.