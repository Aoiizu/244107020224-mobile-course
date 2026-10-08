import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../routes.dart';

final _local = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No BuildContext / Riverpod here.
}

class PushService {
  static const topic = 'campus-announcement';

  static Future<void> init({
    required void Function(String route) go,
    required Future<void> Function(String token) sendToken,
  }) async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (r) {
        if (r.payload != null) go(r.payload!);
      },
    );

    final settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
    final ok = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!ok) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await sendToken(token);
    FirebaseMessaging.instance.onTokenRefresh.listen(sendToken);
    await FirebaseMessaging.instance.subscribeToTopic(topic);

    // Foreground
    FirebaseMessaging.onMessage.listen((m) {
      _local.show(
        id: m.hashCode,
        title: m.notification?.title ?? 'Announcement',
        body: m.notification?.body ?? '',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'announcement',
            'Campus Announcements',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: routeFromMessage(m.data),
      );
    });

    // Background -> tap
    FirebaseMessaging.onMessageOpenedApp
        .listen((m) => go(routeFromMessage(m.data)));

    // Terminated -> tap
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) go(routeFromMessage(initial.data));
  }

  static Future<void> unsubscribe() =>
      FirebaseMessaging.instance.unsubscribeFromTopic(topic);
}