import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/notifications/data/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});
  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Firebase.apps.isEmpty) return;
      final router = ref.read(routerProvider);
      try {
        await PushService.init(
          go: router.go,
          sendToken: (token) async {
            try {
              await ref.read(dioProvider).post('/devices',
                  data: {'fcm_token': token, 'platform': 'android'});
            } catch (_) {}
          },
        );
      } catch (e) {
        debugPrint('Push init failed: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Campus Notify',
        routerConfig: ref.watch(routerProvider),
      );
}
