class AnnouncementRemoteSource {
  // Mock data. Swap for dio.get('/announcements') when a real API exists.
  Future<List<Map<String, dynamic>>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {'id': 1, 'title': 'Library hours', 'body': 'The library closes at 6 PM on Friday.', 'published_at': '2026-10-10T08:00:00'},
      {'id': 2, 'title': 'Midterm schedule', 'body': 'Midterms start on 20 October.', 'published_at': '2026-10-12T09:30:00'},
      {'id': 3, 'title': 'Room change', 'body': 'Mobile class moved to Room A2 at 1:00 PM.', 'published_at': '2026-10-14T07:15:00'},
    ];
  }
}
