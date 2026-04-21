import 'dart:async';

import 'client.dart';
import 'models.dart';

/// Callback that returns the current counters to post. The map may
/// contain any of `memberCount`, `groupCount`, `channelCount`, and
/// `botServes` (a `List<String>`).
typedef StatsCallback = Future<Map<String, Object?>> Function();

/// Background timer that calls [TopTL.postStats] on an interval.
///
///   final poster = Autoposter(
///     client: client,
///     username: 'mybot',
///     statsCallback: () async => {'memberCount': await getUserCount()},
///     interval: const Duration(minutes: 30),
///     onlyOnChange: true,
///   )..start();
class Autoposter {
  final TopTL _client;
  final String _username;
  final Duration _interval;
  final StatsCallback _callback;
  final bool _onlyOnChange;

  Timer? _timer;
  Map<String, Object?>? _last;
  void Function(StatsResult result)? onPost;
  void Function(Object error)? onError;

  Autoposter({
    required TopTL client,
    required String username,
    required StatsCallback statsCallback,
    Duration interval = const Duration(minutes: 30),
    bool onlyOnChange = true,
  })  : _client = client,
        _username = username,
        _callback = statsCallback,
        _interval = interval,
        _onlyOnChange = onlyOnChange;

  /// Start the autoposter. First flush happens on the first tick (not
  /// immediately) so the app has a chance to collect data.
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => postOnce());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isRunning => _timer?.isActive ?? false;

  Future<void> postOnce() async {
    Map<String, Object?> stats;
    try {
      stats = await _callback();
    } catch (e) {
      onError?.call(e);
      return;
    }

    if (_onlyOnChange && _mapEquals(stats, _last)) return;

    try {
      final result = await _client.postStats(
        _username,
        memberCount: stats['memberCount'] as int?,
        groupCount: stats['groupCount'] as int?,
        channelCount: stats['channelCount'] as int?,
        botServes: (stats['botServes'] as List?)?.cast<String>(),
      );
      _last = Map.of(stats);
      onPost?.call(result);
    } catch (e) {
      onError?.call(e);
    }
  }

  bool _mapEquals(Map<String, Object?> a, Map<String, Object?>? b) {
    if (b == null) return false;
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k)) return false;
      if (a[k]?.toString() != b[k]?.toString()) return false;
    }
    return true;
  }
}
