# toptl

[![pub package](https://img.shields.io/pub/v/toptl.svg?color=3775a9)](https://pub.dev/packages/toptl)
[![pub points](https://img.shields.io/pub/points/toptl?color=3776ab)](https://pub.dev/packages/toptl/score)
[![Downloads](https://img.shields.io/pub/dm/toptl.svg?color=blue)](https://pub.dev/packages/toptl)
[![License](https://img.shields.io/github/license/top-tl/dart.svg?color=green)](https://github.com/top-tl/dart/blob/main/LICENSE)
[![TOP.TL](https://img.shields.io/badge/top.tl-developers-2ec4b6)](https://top.tl/developers)

Official Dart SDK for **[TOP.TL](https://top.tl)** — post bot stats, check votes, and manage vote webhooks from your Telegram bot.

## Install

```yaml
dependencies:
  toptl: ^0.1.0
```

Dart `>=3.0.0`.

## Quick start

```dart
import 'package:toptl/toptl.dart';

Future<void> main() async {
  final client = TopTL('toptl_xxx');

  // Look up a listing
  final listing = await client.getListing('durov');
  print('${listing.title} — ${listing.voteCount} votes');

  // Post stats for a bot you own
  await client.postStats(
    'mybot',
    memberCount: 5000,
    groupCount: 1200,
    channelCount: 300,
  );

  // Reward voters
  final check = await client.hasVoted('mybot', 123456789);
  if (check.voted) {
    // grant premium …
  }

  client.close();
}
```

## Autoposter

For long-running bots:

```dart
final poster = Autoposter(
  client: client,
  username: 'mybot',
  statsCallback: () async => {
    'memberCount': await getUserCount(),
    'groupCount': await getGroupCount(),
  },
  interval: const Duration(minutes: 30),
  onlyOnChange: true,
)..start();

// poster.stop(); on shutdown
```

## Webhooks

```dart
await client.setWebhook(
  'mybot',
  'https://mybot.example.com/toptl-vote',
  rewardTitle: '30-day premium',
);

final result = await client.testWebhook('mybot');
print(result.success);
```

## Batch stats

Up to 25 listings per request:

```dart
await client.batchPostStats([
  {'username': 'bot1', 'memberCount': 1200},
  {'username': 'bot2', 'memberCount': 5400},
]);
```

## Error handling

Everything throws a subclass of `TopTLException`:

```dart
try {
  await client.postStats('mybot', memberCount: 5000);
} on AuthenticationException {
  // bad token / missing scope
} on NotFoundException {
  // listing doesn't exist
} on RateLimitException {
  // back off and retry
} on ValidationException catch (e) {
  print(e.message); // server payload
}
```

## License

MIT.
