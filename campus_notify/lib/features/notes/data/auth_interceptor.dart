import 'package:dio/dio.dart';
import 'session.dart';
import 'token_store.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio, this._store, this._session);
  final Dio _dio;
  final TokenStore _store;
  final SessionController _session;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final t = await _store.readAccess();
    if (t != null) options.headers['Authorization'] = 'Bearer $t';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    if (err.response?.statusCode != 401 || req.extra['retried'] == true) {
      return handler.next(err);
    }
    final ok = await _session.refreshOnce();
    if (!ok) return handler.next(err); // session already logged out
    req.extra['retried'] = true;
    try {
      handler.resolve(await _dio.fetch(req)); // onRequest re-attaches new token
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
