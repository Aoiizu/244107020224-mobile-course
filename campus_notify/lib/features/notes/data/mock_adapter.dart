import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

class MockAdapter implements HttpClientAdapter {
  MockAdapter({this.accessLifetime = const Duration(seconds: 60)});
  final Duration accessLifetime;
  bool refreshRevoked = false; 
  int refreshCalls = 0;

  String _newAccess() =>
      'access-${DateTime.now().add(accessLifetime).millisecondsSinceEpoch}';
  String _newRefresh() => 'refresh-${DateTime.now().microsecondsSinceEpoch}';

  bool _accessValid(String? header) {
    if (header == null || !header.startsWith('Bearer access-')) return false;
    final exp = int.tryParse(header.substring('Bearer access-'.length));
    return exp != null && exp > DateTime.now().millisecondsSinceEpoch;
  }

  ResponseBody _json(int status, Map<String, dynamic> body) =>
      ResponseBody.fromString(jsonEncode(body), status, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? body,
      Future<void>? cancel) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final data = o.data is Map ? o.data as Map : const {};

    if (o.path == '/auth/login') {
      final ok = '${data['email']}'.endsWith('@campus.edu') &&
          data['password'] == 'password';
      return ok
          ? _json(200, {'accessToken': _newAccess(), 'refreshToken': _newRefresh()})
          : _json(401, {'error': 'invalid_credentials'});
    }
    if (o.path == '/auth/refresh') {
      refreshCalls++;
      final rt = '${data['refreshToken']}';
      if (refreshRevoked || !rt.startsWith('refresh-')) {
        return _json(401, {'error': 'refresh_expired'});
      }
      return _json(200, {'accessToken': _newAccess(), 'refreshToken': _newRefresh()});
    }

    if (!_accessValid(o.headers['Authorization'] as String?)) {
      return _json(401, {'error': 'access_expired'});
    }
    if (o.path == '/devices') return _json(201, {'status': 'registered'});
    if (o.path.startsWith('/announcements/')) {
      final id = o.path.split('/').last;
      return _json(200, {
        'id': id,
        'title': 'Announcement #$id',
        'body': 'Mock body for announcement $id (served after auth check).',
      });
    }
    return _json(404, {'error': 'not_found'});
  }

  @override
  void close({bool force = false}) {}
}
