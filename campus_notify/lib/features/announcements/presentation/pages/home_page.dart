import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/announcement_results.dart';
import '../widgets/announcement_search_field.dart';
import '../widgets/fcm_token_label.dart';

/// The page itself watches nothing, so it never rebuilds after the first
/// frame. Each child owns the state it needs.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: const Column(children: [
        FcmTokenLabel(),
        AnnouncementSearchField(),
        Expanded(child: AnnouncementResults()),
      ]),
    );
  }
}
