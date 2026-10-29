import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore([FlutterSecureStorage? s])
      : _s = s ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;

  Future<void> save({required String access, required String refresh}) async {
    await _s.write(key: 'access', value: access);
    await _s.write(key: 'refresh', value: refresh);
  }

  Future<String?> readAccess() => _s.read(key: 'access');
  Future<String?> readRefresh() => _s.read(key: 'refresh');
  Future<void> clear() => _s.deleteAll();
}
