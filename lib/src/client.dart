import 'dart:convert';
import 'package:http/http.dart' as http;

import 'exceptions.dart';
import 'models.dart';

const _defaultBaseUrl = 'https://top.tl/api';
const _userAgent = 'toptl-dart/0.1.0';

/// Async client for the TOP.TL public API.
class TopTL {
  final String _token;
  final String _baseUrl;
  final http.Client _httpClient;

  TopTL(
    this._token, {
    String baseUrl = _defaultBaseUrl,
    http.Client? httpClient,
  })  : _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        _httpClient = httpClient ?? http.Client() {
    if (_token.isEmpty) {
      throw ArgumentError('token is required');
    }
  }

  // ---- Listings ------------------------------------------------------

  Future<Listing> getListing(String username) async {
    final data = await _request('GET', '/v1/listing/$username');
    return Listing.fromJson(data);
  }

  Future<List<Voter>> getVotes(String username, {int? limit}) async {
    var path = '/v1/listing/$username/votes';
    if (limit != null) path = '$path?limit=$limit';
    final raw = await _requestRaw('GET', path);
    final decoded = jsonDecode(raw);
    final items = decoded is List
        ? decoded
        : (decoded is Map<String, dynamic>
            ? (decoded['items'] as List? ?? const [])
            : const []);
    return items
        .whereType<Map<String, dynamic>>()
        .map(Voter.fromJson)
        .toList(growable: false);
  }

  Future<VoteCheck> hasVoted(String username, Object userId) async {
    final data = await _request('GET', '/v1/listing/$username/has-voted/$userId');
    return VoteCheck.fromJson(data);
  }

  // ---- Stats ---------------------------------------------------------

  /// Update counters on a listing you own. Only the named args you pass
  /// are sent — nulls are dropped so the server leaves those counters
  /// untouched.
  Future<StatsResult> postStats(
    String username, {
    int? memberCount,
    int? groupCount,
    int? channelCount,
    List<String>? botServes,
  }) async {
    final body = <String, dynamic>{};
    if (memberCount != null) body['memberCount'] = memberCount;
    if (groupCount != null) body['groupCount'] = groupCount;
    if (channelCount != null) body['channelCount'] = channelCount;
    if (botServes != null) body['botServes'] = botServes;
    if (body.isEmpty) {
      throw ArgumentError(
        'postStats requires at least one of memberCount, groupCount, channelCount, botServes',
      );
    }
    final data = await _request('POST', '/v1/listing/$username/stats', body: body);
    return StatsResult.fromJson(data);
  }

  /// Post stats for up to 25 listings in one call. Each item must
  /// include a `username`.
  Future<List<StatsResult>> batchPostStats(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return const [];
    final raw = await _requestRaw('POST', '/v1/stats/batch', body: items);
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(StatsResult.fromJson)
        .toList(growable: false);
  }

  Future<GlobalStats> getGlobalStats() async {
    final data = await _request('GET', '/v1/stats');
    return GlobalStats.fromJson(data);
  }

  // ---- Webhooks ------------------------------------------------------

  Future<WebhookConfig> setWebhook(
    String username,
    String url, {
    String? rewardTitle,
  }) async {
    final body = <String, dynamic>{'url': url};
    if (rewardTitle != null) body['rewardTitle'] = rewardTitle;
    final data = await _request('PUT', '/v1/listing/$username/webhook', body: body);
    return WebhookConfig.fromJson(data);
  }

  Future<WebhookTestResult> testWebhook(String username) async {
    final data = await _request('POST', '/v1/listing/$username/webhook/test');
    return WebhookTestResult.fromJson(data);
  }

  // ---- Internal ------------------------------------------------------

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Object? body,
  }) async {
    final raw = await _requestRaw(method, path, body: body);
    if (raw.isEmpty) return const {};
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : const {};
  }

  Future<String> _requestRaw(String method, String path, {Object? body}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': _userAgent,
    };
    final encoded = body == null ? null : jsonEncode(body);

    http.Response response;
    switch (method) {
      case 'GET':
        response = await _httpClient.get(uri, headers: headers);
        break;
      case 'POST':
        response = await _httpClient.post(uri, headers: headers, body: encoded ?? '');
        break;
      case 'PUT':
        response = await _httpClient.put(uri, headers: headers, body: encoded ?? '');
        break;
      case 'DELETE':
        response = await _httpClient.delete(uri, headers: headers, body: encoded);
        break;
      default:
        throw ArgumentError('unsupported method: $method');
    }

    if (response.statusCode >= 400) {
      String message;
      Object? parsed;
      try {
        parsed = jsonDecode(response.body);
        message = parsed is Map && parsed['message'] is String
            ? parsed['message'] as String
            : 'HTTP ${response.statusCode}';
      } catch (_) {
        parsed = response.body;
        message = 'HTTP ${response.statusCode}';
      }
      throw TopTLException.forStatus(response.statusCode, message, parsed);
    }

    return response.body;
  }

  /// Close the underlying HTTP client.
  void close() => _httpClient.close();
}
