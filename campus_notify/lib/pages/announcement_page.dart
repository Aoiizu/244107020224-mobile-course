import 'package:flutter/material.dart';
import '../data/app_deps.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key, required this.deps, required this.id});
  final AppDeps deps;
  final String id;
  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  late final Future<dynamic> _future =
      widget.deps.api.get('/announcements/${widget.id}').then((r) => r.data);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Announcement ${widget.id}')),
        body: FutureBuilder<dynamic>(
          future: _future,
          builder: (_, snap) {
            if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final d = snap.data as Map;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${d['title']}', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text('${d['body']}'),
              ]),
            );
          },
        ),
      );
}
