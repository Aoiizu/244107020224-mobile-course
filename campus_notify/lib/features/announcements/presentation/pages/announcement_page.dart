import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/format.dart';
import '../../../../routes.dart';
import '../providers/announcement_providers.dart';

class AnnouncementPage extends ConsumerWidget {
  const AnnouncementPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(announcementProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcement #$id'),
        leading: BackButton(onPressed: () => context.go(Routes.home)),
      ),
      body: a.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(messageOf(e))),
        data: (x) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(x.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(formatDate(x.publishedAt)),
            const SizedBox(height: 16),
            Text(x.body),
          ]),
        ),
      ),
    );
  }
}
