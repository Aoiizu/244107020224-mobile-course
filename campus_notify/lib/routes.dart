class Routes {
  static const login = '/login';
  static const home = '/';
  static const announcement = '/announcement/:id';
  static String announcementOf(String id) => '/announcement/$id';
}

String routeFromMessage(Map<String, dynamic> data) {
  final r = (data['route'] as String?) ?? '/';
  return r.startsWith('/') ? r : '/$r';
}