import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/format.dart';
import '../../../../routes.dart';
import '../providers/announcement_providers.dart';
import 'announcement_list_view.dart';

/// The only widget that watches the search results, so typing rebuilds
/// this subtree and nothing else on the page.
class AnnouncementResults extends ConsumerWidget {
  const AnnouncementResults({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(visibleAnnouncementsProvider);
    final query = ref.watch(searchQueryProvider);
    return list.when(
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
        query: query,
        onOpen: (id) => context.go(Routes.announcementOf(id)),
      ),
    );
  }
}
