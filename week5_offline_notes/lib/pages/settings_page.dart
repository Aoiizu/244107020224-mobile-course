import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/prefs.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());

/// Overridden in main() with the value read BEFORE marking "opened now".
final lastOpenedProvider = Provider<String?>((ref) => null);

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider);
    final lastOpened = ref.watch(lastOpenedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          dark.when(
            loading: () => const ListTile(title: Text('Loading...')),
            error: (e, _) => ListTile(title: Text('Error: $e')),
            data: (value) => SwitchListTile(
              title: const Text('Dark mode'),
              value: value,
              onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
            ),
          ),
          ListTile(
            title: const Text('Last opened'),
            subtitle: Text(lastOpened == null
                ? 'First launch'
                : DateTime.tryParse(lastOpened)?.toLocal().toString() ??
                    lastOpened),
          ),
        ],
      ),
    );
  }
}