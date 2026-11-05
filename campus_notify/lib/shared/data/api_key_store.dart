import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeyStore {
  ApiKeyStore([FlutterSecureStorage? s])
      : _s = s ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;
  static const _key = 'ai_api_key';

  Future<String?> read() => _s.read(key: _key);
  Future<void> save(String value) => _s.write(key: _key, value: value);
  Future<void> clear() => _s.delete(key: _key);
}
