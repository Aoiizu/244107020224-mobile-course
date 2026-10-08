import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/app_deps.dart';
import '../data/token_store.dart';
import '../notifications/fcm_service.dart';

String truncateToken(String t) =>
    t.length <= 16 ? t : '${t.substring(0, 8)}...${t.substring(t.length - 6)}';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.deps});
  final AppDeps deps;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Campus Notifications'), actions: [
          IconButton(
              icon: const Icon(Icons.logout), onPressed: deps.session.logout),
        ]),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('FCM device token (truncated)'),
          ValueListenableBuilder<String?>(
            valueListenable: deps.fcm.token,
            builder: (_, t, __) =>
                SelectableText(t == null ? '(not available yet)' : truncateToken(t)),
          ),
          Text('Topic: ${FcmService.topic}'),
          const Divider(height: 32),
          for (final id in [1, 2, 3])
            ListTile(
              title: Text('Announcement #$id'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/announcement/$id'),
            ),
          const Divider(height: 32),
          const Text('Demo controls'),
          OutlinedButton(
            onPressed: () async {
              final r = await deps.store.readRefresh();
              if (r != null) {
                await deps.store.save(TokenPair(access: 'access-0', refresh: r));
              }
            },
            child: const Text('Expire access token (next call auto-refreshes)'),
          ),
          OutlinedButton(
            onPressed: () => deps.mock?.refreshRevoked = true,
            child: const Text('Revoke refresh token (next 401 logs out)'),
          ),
        ]),
      );
}
