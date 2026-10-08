/// Pure functions (no Flutter/Firebase imports) so they are unit-testable.

final _safeId = RegExp(r'^[A-Za-z0-9_-]+$');
final _announcementPath = RegExp(r'^/announcement/[A-Za-z0-9_-]+$');

/// Maps an FCM `data` payload to an in-app route, or null if unusable.
/// Accepts {route: "/announcement/42"} or {announcementId: "42"}.
String? routeFromMessageData(Map<String, dynamic> data) {
  final route = data['route'];
  if (route is String && _announcementPath.hasMatch(route)) return route;
  final id = data['announcementId'];
  if (id != null && _safeId.hasMatch('$id')) return '/announcement/$id';
  return null;
}

/// Route guard. Unauthenticated users ALWAYS end up on /login; the wanted
/// destination is kept in ?from= so a notification tap survives the login.
String? authRedirect({required bool loggedIn, required String location}) {
  final uri = Uri.parse(location);
  final atLogin = uri.path == '/login';
  if (!loggedIn) {
    if (atLogin) return null;
    return location == '/'
        ? '/login'
        : '/login?from=${Uri.encodeQueryComponent(location)}';
  }
  if (atLogin) {
    final from = uri.queryParameters['from'];
    // Only same-app paths: blocks open-redirect values like //evil.com
    final safe = from != null && from.startsWith('/') && !from.startsWith('//');
    return safe ? from : '/';
  }
  return null;
}
