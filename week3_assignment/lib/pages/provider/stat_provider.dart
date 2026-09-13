import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class Stat {
  final String label;
  final int value;

  const Stat({required this.label, required this.value});
}

class StatsNotifier extends AsyncNotifier<List<Stat>> {
  @override
  Future<List<Stat>> build() async {
    return _fetchStats();
  }

  Future<List<Stat>> _fetchStats() async {
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    if (random.nextDouble() < 0.3) {
      throw Exception('Failed to load statistics. Please try again.');
    }

    return const [
      Stat(label: 'Active Users', value: 1240),
      Stat(label: 'Sessions Today', value: 389),
      Stat(label: 'Avg. Duration (min)', value: 14),
    ];
  }

  Future<void> retry() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchStats);
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, List<Stat>>(
  StatsNotifier.new,
);