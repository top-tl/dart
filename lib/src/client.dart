import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

/// Client for the TOP.TL Telegram Directory API.
class TopTL {
  final String _token;
  final String _baseUrl;
  final http.Client _httpClient;

  /// Creates a new TOP.TL client.
  ///
  /// [token] is your API token.
  /// [baseUrl] overrides the default API URL (optional).
  /// [httpClient] allows injecting a custom HTTP client for testing.
  TopTL(
    this._token, {
    String baseUrl = 'https://top.tl/api/v1',
    http.Client? httpClient,
  })  : _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        _httpClient = httpClient ?? http.Client();

  /// Get listing info for a [username].
  Future<Listing> getListing(String username) async {
    final data = await _request('GET', '/listing/$username');
    return Listing.fromJson(data);
  }

  /// Get votes for a listing.
  Future<VotesResponse> getVotes(String username) async {
    final data = await _request('GET', '/listing/$username/votes');
    return VotesResponse.fromJson(data);
  }

  /// Check if [userId] has voted for a listing.
  Future<bool> hasVoted(String username, dynamic userId) async {
    final data = await _request('GET', '/listing/$username/has-voted/$userId');
    return data['voted'] == true;
  }

  /// Post stats for a listing.
  Future<Map<String, dynamic>> postStats(
    String username, {
    int? memberCount,
    int? groupCount,
  }) async {
    final body = <String, dynamic>{};
    if (memberCount != null) body['memberCount'] = memberCount;
    if (groupCount != null) body['groupCount'] = groupCount;
    return await _request('POST', '/listing/$username/stats', body: body);
  }

  /// Get global TOP.TL stats.
  Future<Stats> getStats() async {
    final data = await _request('GET', '/stats');
    return Stats.fromJson(data);
  }

  /// Close the underlying HTTP client.
  void close() {
    _httpClient.close();
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'toptl-dart/1.0.0',
    };

    http.Response response;

    if (method == 'POST') {
      response = await _httpClient.post(
        uri,
        headers: headers,
        body: jsonEncode(body ?? {}),
      );
    } else {
      response = await _httpClient.get(uri, headers: headers);
    }

    if (response.statusCode >= 400) {
      throw Exception(
        'API error (HTTP ${response.statusCode}): ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
