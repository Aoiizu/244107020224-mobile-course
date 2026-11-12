import '../../../../core/failures.dart';
import '../../../../core/result.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../announcement_remote_source.dart';
import '../models/announcement_model.dart';

/// Repository with a small in-memory cache:
/// - fresh data (younger than [ttl]) is served without a remote call
/// - concurrent callers share one in-flight request
/// - if the remote fails, stale data is served instead of an error
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl(
    this._remote, {
    Duration ttl = const Duration(seconds: 30),
    DateTime Function()? now,
  })  : _ttl = ttl,
        _now = now ?? DateTime.now;

  final AnnouncementRemoteSource _remote;
  final Duration _ttl;
  final DateTime Function() _now;

  List<Announcement>? _cache;
  DateTime? _cachedAt;
  Future<List<Announcement>>? _inFlight;

  bool get _isFresh =>
      _cache != null &&
      _cachedAt != null &&
      _now().difference(_cachedAt!) < _ttl;

  Future<List<Announcement>> _load() async {
    if (_isFresh) return _cache!;
    return _inFlight ??= _fetch().whenComplete(() => _inFlight = null);
  }

  Future<List<Announcement>> _fetch() async {
    final rows = await _remote.fetchAll();
    final items =
        rows.map((j) => AnnouncementModel.fromJson(j).toEntity()).toList();
    _cache = items;
    _cachedAt = _now();
    return items;
  }

  @override
  Future<Result<List<Announcement>>> fetchAll() async {
    try {
      return Ok(await _load());
    } catch (_) {
      final stale = _cache;
      if (stale != null) return Ok(stale);
      return const Err(NetworkFailure('Could not load announcements'));
    }
  }

  @override
  Future<Result<Announcement>> fetchById(String id) async {
    final r = await fetchAll();
    return switch (r) {
      Ok(:final value) => value.any((a) => a.id == id)
          ? Ok(value.firstWhere((a) => a.id == id))
          : const Err(NetworkFailure('Announcement not found')),
      Err(:final failure) => Err(failure),
    };
  }
}
