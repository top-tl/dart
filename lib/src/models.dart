/// A TOP.TL listing. Field names mirror the JSON the API returns;
/// anything unknown is preserved in [raw] so forward-compat is free.
class Listing {
  final String id;
  final String username;
  final String title;
  final String? description;

  /// `"CHANNEL" | "GROUP" | "BOT"`.
  final String type;

  final int memberCount;
  final int voteCount;
  final List<String> languages;
  final bool verified;
  final bool featured;
  final String? photoUrl;
  final List<String> tags;

  final Map<String, dynamic> raw;

  Listing({
    required this.id,
    required this.username,
    required this.title,
    this.description,
    required this.type,
    this.memberCount = 0,
    this.voteCount = 0,
    this.languages = const [],
    this.verified = false,
    this.featured = false,
    this.photoUrl,
    this.tags = const [],
    required this.raw,
  });

  factory Listing.fromJson(Map<String, dynamic> json) => Listing(
        id: (json['id'] ?? '') as String,
        username: (json['username'] ?? '') as String,
        title: (json['title'] ?? '') as String,
        description: json['description'] as String?,
        type: (json['type'] ?? '') as String,
        memberCount: _asInt(json['memberCount']),
        voteCount: _asInt(json['voteCount']),
        languages: _asStringList(json['languages']),
        verified: json['verified'] == true,
        featured: json['featured'] == true,
        photoUrl: json['photoUrl'] as String?,
        tags: _asStringList(json['tags']),
        raw: json,
      );

  @override
  String toString() => 'Listing(username: $username, title: $title)';
}

/// One entry in the response from [TopTL.getVotes].
class Voter {
  final String? userId;
  final String? firstName;
  final String? username;
  final String? votedAt;
  final Map<String, dynamic> raw;

  Voter({this.userId, this.firstName, this.username, this.votedAt, required this.raw});

  factory Voter.fromJson(Map<String, dynamic> json) => Voter(
        userId: (json['userId'] ?? json['id'])?.toString(),
        firstName: json['firstName'] as String?,
        username: json['username'] as String?,
        votedAt: (json['votedAt'] ?? json['createdAt']) as String?,
        raw: json,
      );
}

/// Response from [TopTL.hasVoted].
class VoteCheck {
  final bool voted;
  final String? votedAt;
  final Map<String, dynamic> raw;

  VoteCheck({required this.voted, this.votedAt, required this.raw});

  factory VoteCheck.fromJson(Map<String, dynamic> json) => VoteCheck(
        voted: (json['voted'] ?? json['hasVoted']) == true,
        votedAt: json['votedAt'] as String?,
        raw: json,
      );
}

/// Per-listing result from [TopTL.postStats] / [TopTL.batchPostStats].
class StatsResult {
  final bool success;
  final String? username;
  final String? error;
  final Map<String, dynamic> raw;

  StatsResult({required this.success, this.username, this.error, required this.raw});

  factory StatsResult.fromJson(Map<String, dynamic> json) => StatsResult(
        success: json['success'] != false,
        username: json['username'] as String?,
        error: json['error'] as String?,
        raw: json,
      );
}

/// Config for [TopTL.setWebhook] (both request body and response shape).
class WebhookConfig {
  final String? url;
  final String? rewardTitle;
  final Map<String, dynamic> raw;

  WebhookConfig({this.url, this.rewardTitle, required this.raw});

  factory WebhookConfig.fromJson(Map<String, dynamic> json) => WebhookConfig(
        url: (json['url'] ?? json['webhookUrl']) as String?,
        rewardTitle: json['rewardTitle'] as String?,
        raw: json,
      );
}

/// Response from [TopTL.testWebhook].
class WebhookTestResult {
  final bool success;
  final int? statusCode;
  final String? message;
  final Map<String, dynamic> raw;

  WebhookTestResult({required this.success, this.statusCode, this.message, required this.raw});

  factory WebhookTestResult.fromJson(Map<String, dynamic> json) => WebhookTestResult(
        success: json['success'] == true,
        statusCode: _asIntOrNull(json['statusCode'] ?? json['status']),
        message: (json['message'] ?? json['error']) as String?,
        raw: json,
      );
}

/// Site-wide totals from [TopTL.getGlobalStats].
class GlobalStats {
  final int total;
  final int channels;
  final int groups;
  final int bots;
  final Map<String, dynamic> raw;

  GlobalStats({
    this.total = 0,
    this.channels = 0,
    this.groups = 0,
    this.bots = 0,
    required this.raw,
  });

  factory GlobalStats.fromJson(Map<String, dynamic> json) => GlobalStats(
        total: _asInt(json['total']),
        channels: _asInt(json['channels']),
        groups: _asInt(json['groups']),
        bots: _asInt(json['bots']),
        raw: json,
      );
}

int _asInt(Object? v) => v is num ? v.toInt() : 0;
int? _asIntOrNull(Object? v) => v is num ? v.toInt() : null;
List<String> _asStringList(Object? v) =>
    v is List ? v.map((e) => e.toString()).toList() : const [];
