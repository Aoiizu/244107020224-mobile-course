import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'data/prefs.dart';
import 'pages/note_detail_page.dart';
import 'pages/note_page.dart';
import 'pages/posts_page.dart';
import 'pages/settings_page.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const NotesPage()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
    GoRoute(path: '/posts', builder: (_, __) => const PostsPage()),
    GoRoute(
      path: '/note/:id',
      builder: (_, state) =>
          NoteDetailPage(id: int.parse(state.pathParameters['id']!)),
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use SQLite for web (runs in the browser)
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  final prefs = PrefsRepository();
  final previousOpen = await prefs.getLastOpened(); // read BEFORE overwriting
  await prefs.markOpenedNow();

  runApp(ProviderScope(
    overrides: [lastOpenedProvider.overrideWithValue(previousOpen)],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider).value ?? false;

    return MaterialApp.router(
      title: 'Offline Notes',
      routerConfig: _router,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
    );
  }
}