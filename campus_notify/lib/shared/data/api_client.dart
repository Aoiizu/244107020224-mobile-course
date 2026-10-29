import 'package:dio/dio.dart';
import 'token_store.dart';

Dio buildApiClient(
    TokenStore store, Future<String> Function(String refreshToken) refresh) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (o, h) async {
      final t = await store.readAccess();
      if (t != null) o.headers['Authorization'] = 'Bearer $t';
      h.next(o);
    },
    onError: (e, h) async {
      final req = e.requestOptions;
      if (e.response?.statusCode == 401 && req.extra['retried'] != true) {
        final rt = await store.readRefresh();
        if (rt != null) {
          try {
            final newAccess = await refresh(rt);
            await store.save(access: newAccess, refresh: rt);
            req.extra['retried'] = true;
            req.headers['Authorization'] = 'Bearer $newAccess';
            return h.resolve(await dio.fetch(req));
          } catch (_) {
            await store.clear();
          }
        }
      }
      h.next(e);
    },
  ));
  return dio;
}
