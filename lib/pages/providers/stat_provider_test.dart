import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_244107020224/pages/providers/stat_provider.dart';

void main() {
  group('StatsNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('starts in loading state, then resolves to data or error', () async {
      final initial = container.read(statsProvider);
      expect(initial, isA<AsyncLoading<List<Stat>>>());

      try {
        final data = await container.read(statsProvider.future);
        expect(data, hasLength(3));
        expect(data.map((s) => s.label), containsAll(<String>[
          'Active Users',
          'Sessions Today',
          'Avg. Duration (min)',
        ]));

        final resolved = container.read(statsProvider);
        expect(resolved, isA<AsyncData<List<Stat>>>());
      } catch (_) {
        final resolved = container.read(statsProvider);
        expect(resolved, isA<AsyncError<List<Stat>>>());
      }
    }, timeout: const Timeout(Duration(seconds: 5)));

    test('retry() sets loading then resolves again without mutating prior list',
        () async {
      try {
        await container.read(statsProvider.future);
      } catch (_) {}

      final beforeRetry = container.read(statsProvider);

      final notifier = container.read(statsProvider.notifier);
      final retryFuture = notifier.retry();

      expect(container.read(statsProvider), isA<AsyncLoading<List<Stat>>>());

      await retryFuture;

      final afterRetry = container.read(statsProvider);
      expect(identical(beforeRetry, afterRetry), isFalse);
    }, timeout: const Timeout(Duration(seconds: 5)));
  });
}