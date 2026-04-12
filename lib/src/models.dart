/// Represents a TOP.TL listing.
class Listing {
  final String username;
  final String? title;
  final String? description;
  final String? category;
  final String? type;
  final int? memberCount;
  final int? votes;
  final String? avatar;
  final String? url;
  final Map<String, dynamic> raw;

  Listing({
    required this.username,
    this.title,
    this.description,
    this.category,
    this.type,
    this.memberCount,
    this.votes,
    this.avatar,
    this.url,
    required this.raw,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      username: json['username'] ?? '',
      title: json['title'],
      description: json['description'],
      category: json['category'],
      type: json['type'],
      memberCount: json['memberCount'] != null
          ? (json['memberCount'] as num).toInt()
          : null,
      votes:
          json['votes'] != null ? (json['votes'] as num).toInt() : null,
      avatar: json['avatar'],
      url: json['url'],
      raw: json,
    );
  }

  @override
  String toString() => 'Listing(username: $username, title: $title)';
}

/// Represents a votes response from the API.
class VotesResponse {
  final int votes;
  final int monthlyVotes;
  final List<dynamic> voters;
  final Map<String, dynamic> raw;

  VotesResponse({
    required this.votes,
    required this.monthlyVotes,
    required this.voters,
    required this.raw,
  });

  factory VotesResponse.fromJson(Map<String, dynamic> json) {
    return VotesResponse(
      votes: (json['votes'] as num?)?.toInt() ?? 0,
      monthlyVotes: (json['monthlyVotes'] as num?)?.toInt() ?? 0,
      voters: json['voters'] ?? [],
      raw: json,
    );
  }

  @override
  String toString() =>
      'VotesResponse(votes: $votes, monthlyVotes: $monthlyVotes)';
}

/// Represents global TOP.TL statistics.
class Stats {
  final int totalListings;
  final int totalVotes;
  final int totalUsers;
  final Map<String, dynamic> raw;

  Stats({
    required this.totalListings,
    required this.totalVotes,
    required this.totalUsers,
    required this.raw,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalListings: (json['totalListings'] as num?)?.toInt() ?? 0,
      totalVotes: (json['totalVotes'] as num?)?.toInt() ?? 0,
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      raw: json,
    );
  }

  @override
  String toString() =>
      'Stats(totalListings: $totalListings, totalVotes: $totalVotes)';
}
