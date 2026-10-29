import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/format.dart';
import '../../../../routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/announcement_providers.dart';

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
    final list = ref.watch(announcementsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Notify'), actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => ref.read(authStateProvider.notifier).logout(),
        ),
      ]),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.all(8),
            child: Text('FCM token: $_token')),
        Expanded(
          child: list.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(messageOf(e)),
                TextButton(
                  onPressed: () => ref.invalidate(announcementsProvider),
                  child: const Text('Retry'),
                ),
              ]),
            ),
            data: (items) => items.isEmpty
                ? const Center(child: Text('No announcements yet.'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final a = items[i];
                      return ListTile(
                        title: Text(a.title),
                        subtitle: Text(formatDate(a.publishedAt)),
                        onTap: () => context.go(Routes.announcementOf(a.id)),
                      );
                    },
                  ),
          ),
        ),
      ]),
    );
  }
}
