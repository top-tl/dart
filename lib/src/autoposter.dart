import 'dart:async';
import 'client.dart';

/// A callback that returns the current stats to post.
typedef StatsCallback = Future<Map<String, int>> Function();

/// Automatically posts stats to TOP.TL at regular intervals.
class Autoposter {
  final TopTL _client;
  final String _username;
  final Duration _interval;
  final StatsCallback _statsCallback;

  Timer? _timer;
  void Function(Map<String, dynamic>)? _onPost;
  void Function(Object error)? _onError;

  /// Creates a new Autoposter.
  ///
  /// [client] is the TOP.TL client instance.
  /// [username] is the listing username to post stats for.
  /// [statsCallback] is an async function returning a map with optional keys:
  /// `memberCount` and `groupCount`.
  /// [interval] is the time between posts (default: 30 minutes).
  Autoposter({
    required TopTL client,
    required String username,
    required StatsCallback statsCallback,
    Duration interval = const Duration(minutes: 30),
  })  : _client = client,
        _username = username,
        _statsCallback = statsCallback,
        _interval = interval;

  /// Set a callback for successful stat posts.
  void onPost(void Function(Map<String, dynamic> result) callback) {
    _onPost = callback;
  }

  /// Set a callback for errors.
  void onError(void Function(Object error) callback) {
    _onError = callback;
  }

  /// Start the autoposter. Posts immediately, then at [interval].
  void start() {
    postOnce();
    _timer = Timer.periodic(_interval, (_) => postOnce());
  }

  /// Stop the autoposter.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Whether the autoposter is currently running.
  bool get isRunning => _timer?.isActive ?? false;

  /// Post stats once (useful for manual invocation).
  Future<void> postOnce() async {
    try {
      final stats = await _statsCallback();
      final result = await _client.postStats(
        _username,
        memberCount: stats['memberCount'],
        groupCount: stats['groupCount'],
      );
      _onPost?.call(result);
    } catch (e) {
      _onError?.call(e);
    }
  }
}
