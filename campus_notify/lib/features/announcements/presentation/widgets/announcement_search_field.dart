import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/announcement_providers.dart';

/// Only writes the query (ref.read), so it never rebuilds while typing.
class AnnouncementSearchField extends ConsumerWidget {
  const AnnouncementSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        onChanged: ref.read(searchQueryProvider.notifier).set,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search by title',
        ),
      ),
    );
  }
}
