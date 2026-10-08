import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _token = '...';

  @override
  void initState() {
    super.initState();
    if (Firebase.apps.isNotEmpty) {
      FirebaseMessaging.instance.getToken().then((t) {
        if (mounted && t != null) {
          setState(() => _token = '${t.substring(0, 12)}...');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Notify'), actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => ref.read(authStateProvider.notifier).logout(),
        ),
      ]),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('FCM token: $_token'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go(Routes.announcementOf('3')),
            child: const Text('Open announcement 3'),
          ),
        ]),
      ),
    );
  }
}