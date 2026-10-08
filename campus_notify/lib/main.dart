import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_pages.dart';
import 'pages/login_pages.dart';
import 'providers/auth_providers.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      if (auth.isLoading && !auth.hasValue) return null;
      final loggedIn = auth.value ?? false;
      final atLogin = state.matchedLocation == Routes.login;
      if (!loggedIn && !atLogin) return Routes.login;
      if (loggedIn && atLogin) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.login, builder: (_, __) => const LoginPage()),
      GoRoute(path: Routes.home, builder: (_, __) => const HomePage()),
      GoRoute(
        path: Routes.announcement,
        builder: (_, s) => AnnouncementPage(id: s.pathParameters['id'] ?? ''),
      ),
    ],
  );
});

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
      if (Firebase.apps.isEmpty) {
        debugPrint('Firebase not configured, skipping push setup');
        return;
      }
      final router = ref.read(routerProvider);
      try {
        await PushService.init(
          go: router.go,
          sendToken: (token) async {
            try {
              await ref.read(dioProvider).post(
                '/devices',
                data: {'fcm_token': token, 'platform': 'android'},
              );
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