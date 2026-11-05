import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/format.dart';
import '../../../../routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/announcement_providers.dart';
import '../widgets/announcement_list_view.dart';

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
    final list = ref.watch(visibleAnnouncementsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Notify'), actions: [
        IconButton(
          tooltip: 'Assistant',
          icon: const Icon(Icons.smart_toy),
          onPressed: () => context.push(Routes.assistant),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => ref.read(authStateProvider.notifier).logout(),
        ),
      ]),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.all(8),
            child: Text('FCM token: $_token')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            onChanged: ref.read(searchQueryProvider.notifier).set,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by title',
            ),
          ),
        ),
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
            data: (items) => AnnouncementListView(
              items: items,
              query: ref.watch(searchQueryProvider),
              onOpen: (id) => context.go(Routes.announcementOf(id)),
            ),
          ),
        ),
      ]),
    );
  }
}