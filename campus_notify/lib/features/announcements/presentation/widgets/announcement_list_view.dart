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
        child:
            Text(q.isEmpty ? 'No announcements yet.' : 'No results for "$q".'),
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
