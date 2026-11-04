import '../entities/announcement.dart';

class SearchAnnouncements {
  const SearchAnnouncements();

  List<Announcement> call(List<Announcement> items, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((a) => a.title.toLowerCase().contains(q)).toList();
  }
}
