import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'auth_api.dart';
import 'token_store.dart';

enum SessionStatus { unknown, authenticated, unauthenticated }

class SessionController extends ChangeNotifier {
  SessionController(this._store, this._api);
  final TokenStore _store;
  final AuthApi _api;

  SessionStatus status = SessionStatus.unknown;
  Future<bool>? _inflight;

  bool get isAuthenticated => status == SessionStatus.authenticated;

  Future<void> restore() async {
    status = (await _store.readRefresh()) != null
        ? SessionStatus.authenticated
        : SessionStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final pair = await _api.login(email, password);
    await _store.save(pair);
    status = SessionStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    status = SessionStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> refreshOnce() => _inflight ??= _doRefresh().whenComplete(() {
        _inflight = null;
      });

  Future<bool> _doRefresh() async {
    final rt = await _store.readRefresh();
    if (rt == null) {
      await logout();
      return false;
    }
    try {
      await _store.save(await _api.refresh(rt));
      return true;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 400 || code == 401 || code == 403) await logout();
      return false; 
    }
  }
}
