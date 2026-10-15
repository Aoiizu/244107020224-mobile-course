import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenPair {
  const TokenPair({required this.access, required this.refresh});
  final String access;
  final String refresh;
}

abstract class TokenStore {
  Future<String?> readAccess();
  Future<String?> readRefresh();
  Future<void> save(TokenPair pair);
  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
      : _s = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;

  @override
  Future<String?> readAccess() => _s.read(key: 'access_token');
  @override
  Future<String?> readRefresh() => _s.read(key: 'refresh_token');
  @override
  Future<void> save(TokenPair p) async {
    await _s.write(key: 'access_token', value: p.access);
    await _s.write(key: 'refresh_token', value: p.refresh);
  }

  @override
  Future<void> clear() async {
    await _s.delete(key: 'access_token');
    await _s.delete(key: 'refresh_token');
  }
}

class MemoryTokenStore implements TokenStore {
  String? _a, _r;
  @override
  Future<String?> readAccess() async => _a;
  @override
  Future<String?> readRefresh() async => _r;
  @override
  Future<void> save(TokenPair p) async {
    _a = p.access;
    _r = p.refresh;
  }

  @override
  Future<void> clear() async {
    _a = null;
    _r = null;
  }
}
