import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../notifications/fcm_service.dart';
import 'auth_api.dart';
import 'auth_interceptor.dart';
import 'mock_adapter.dart';
import 'session.dart';
import 'token_store.dart';

class AppDeps {
  AppDeps({TokenStore? store, bool useMock = true, MockAdapter? mock})
      : store = store ?? SecureTokenStore(),
        mock = mock ?? (useMock ? MockAdapter() : null) {
    plain = Dio(BaseOptions(baseUrl: baseUrl));
    api = Dio(BaseOptions(baseUrl: baseUrl));
    final m = this.mock;
    if (m != null) {
      plain.httpClientAdapter = m;
      api.httpClientAdapter = m;
    }
    session = SessionController(this.store, DioAuthApi(plain));
    api.interceptors.add(AuthInterceptor(api, this.store, session));
  }

  static const baseUrl = 'https://api.campus.example';
  final TokenStore store;
  final MockAdapter? mock;
  late final Dio plain;
  late final Dio api; 
  late final SessionController session;
  final messengerKey = GlobalKey<ScaffoldMessengerState>();
  late final FcmService fcm = FcmService(api, session, messengerKey);
}
