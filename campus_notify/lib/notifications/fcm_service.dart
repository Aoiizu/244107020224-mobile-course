import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_notification_app/firebase_options.dart';
import '../data/session.dart';
import '../router/route_logic.dart';

/// Must be top-level. Runs in its own isolate when a message arrives in
/// background/terminated state. The system tray shows the notification part.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class FcmService {
  FcmService(this._dio, this._session, this._messengerKey);
  final Dio _dio; // authenticated Dio (auto-refresh)
  final SessionController _session;
  final GlobalKey<ScaffoldMessengerState> _messengerKey;

  static const topic = 'campus-announcement';
  final token = ValueNotifier<String?>(null);
  String? _lastSent;
  late GoRouter _router;

  Future<void> init(GoRouter router) async {
    _router = router;
    final fm = FirebaseMessaging.instance;

    final settings = await fm.requestPermission(); // Android 13+/iOS prompt
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    token.value = await fm.getToken();
    await fm.subscribeToTopic(topic);

    // Token rotates on reinstall / restore / clear-data: always re-send it.
    fm.onTokenRefresh.listen((t) {
      token.value = t;
      _lastSent = null;
      syncToken();
    });

    // Register once logged in (POST /devices needs auth), and again after
    // every re-login. Reset on logout so the next user's login re-registers.
    _session.addListener(() {
      if (_session.isAuthenticated) {
        syncToken();
      } else {
        _lastSent = null;
      }
    });
    syncToken();

    FirebaseMessaging.onMessage.listen(_onForeground); // app open
    FirebaseMessaging.onMessageOpenedApp.listen(_open); // background tap
    final initial = await fm.getInitialMessage(); //       terminated tap
    if (initial != null) _open(initial);
  }

  /// Documented backend contract: POST /devices {token, platform}
  Future<void> syncToken() async {
    final t = token.value;
    if (!_session.isAuthenticated || t == null || t == _lastSent) return;
    try {
      await _dio.post('/devices',
          data: {'token': t, 'platform': defaultTargetPlatform.name});
      _lastSent = t;
    } on DioException {
      // keep _lastSent null: retried on next login / token refresh
    }
  }

  void _onForeground(RemoteMessage m) {
    // FCM does not draw a system banner while the app is in the foreground.
    final route = routeFromMessageData(m.data);
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(
            '${m.notification?.title ?? 'Announcement'}\n${m.notification?.body ?? ''}'),
        duration: const Duration(seconds: 8),
        action: route == null
            ? null
            : SnackBarAction(label: 'OPEN', onPressed: () => _router.go(route)),
      ));
  }

  void _open(RemoteMessage m) {
    final route = routeFromMessageData(m.data);
    // If logged out, the router guard sends the user to /login?from=route.
    if (route != null) _router.go(route);
  }
}
