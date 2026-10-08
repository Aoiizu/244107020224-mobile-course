import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_notification_app/firebase_options.dart';
import 'data/app_deps.dart';
import 'notifications/fcm_service.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final deps = AppDeps();
  await deps.session.restore();
  final router = buildRouter(deps);

  runApp(CampusApp(router: router, deps: deps));
  unawaited(deps.fcm.init(router)); // permission, token, topic, tap handlers
}

class CampusApp extends StatelessWidget {
  const CampusApp({super.key, required this.router, required this.deps});
  final GoRouter router;
  final AppDeps deps;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Campus Notifications',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: deps.messengerKey,
        routerConfig: router,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      );
}
