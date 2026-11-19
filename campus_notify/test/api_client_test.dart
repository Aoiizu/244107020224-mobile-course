import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notification_app/shared/data/api_client.dart';
import 'package:campus_notification_app/shared/data/token_store.dart';

class MemoryTokenStore extends TokenStore {
  String? access = 'old-access';
  String? refresh = 'refresh-1';
  bool cleared = false;

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> clear() async {
    cleared = true;
    access = null;
    refresh = null;
  }
}

/// Answers each request with the next status code in [statuses] and records
/// the Authorization header. A request beyond the list throws, so a retry
/// loop fails the test quickly instead of hanging it.
class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this.statuses);
  final List<int> statuses;
  final List<String?> authHeaders = [];
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    authHeaders.add(options.headers['Authorization'] as String?);
    if (calls > statuses.length) {
      throw StateError('unexpected request #$calls');
    }
    return ResponseBody.fromString(
      '{}',
      statuses[calls - 1],
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late MemoryTokenStore store;

  setUp(() => store = MemoryTokenStore());

  test('a 401 triggers one refresh and the request is retried', () async {
    final adapter = ScriptedAdapter([401, 200]);
    final dio = buildApiClient(store, (_) async => 'new-access')
      ..httpClientAdapter = adapter;

    final res = await dio.get('/announcements');

    expect(res.statusCode, 200);
    expect(adapter.calls, 2);
    expect(adapter.authHeaders.first, 'Bearer old-access');
    expect(adapter.authHeaders.last, 'Bearer new-access');
    expect(store.access, 'new-access');
  });

  test('if the refresh fails the session is cleared and the 401 is raised',
      () async {
    final adapter = ScriptedAdapter([401]);
    final dio = buildApiClient(store, (_) async => throw Exception('expired'))
      ..httpClientAdapter = adapter;

    await expectLater(
      dio.get('/announcements'),
      throwsA(isA<DioException>()
          .having((e) => e.response?.statusCode, 'status', 401)),
    );
    expect(store.cleared, isTrue);
    expect(adapter.calls, 1);
  });

  test('a second 401 after the retry is not refreshed again', () async {
    final adapter = ScriptedAdapter([401, 401]);
    final dio = buildApiClient(store, (_) async => 'new-access')
      ..httpClientAdapter = adapter;

    await expectLater(
      dio.get('/announcements'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, 2);
  });
}
