import 'package:dio/dio.dart';
import 'token_store.dart';

abstract class AuthApi {
  Future<TokenPair> login(String email, String password);
  Future<TokenPair> refresh(String refreshToken);
}

class DioAuthApi implements AuthApi {
  DioAuthApi(this._dio);
  final Dio _dio;

  TokenPair _parse(Response r) => TokenPair(
        access: r.data['accessToken'] as String,
        refresh: r.data['refreshToken'] as String,
      );

  @override
  Future<TokenPair> login(String email, String password) async => _parse(
      await _dio.post('/auth/login', data: {'email': email, 'password': password}));

  @override
  Future<TokenPair> refresh(String refreshToken) async => _parse(
      await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken}));
}
