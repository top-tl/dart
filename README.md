# TOP.TL Dart SDK

[![pub package](https://img.shields.io/pub/v/toptl.svg)](https://pub.dev/packages/toptl)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Official Dart SDK for the [TOP.TL](https://top.tl) Telegram Directory API.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  toptl: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:toptl/toptl.dart';

void main() async {
  final client = TopTL('your-api-token');

  // Get listing info
  final listing = await client.getListing('mybot');
  print(listing.title);
  print(listing.memberCount);

  // Get votes
  final votes = await client.getVotes('mybot');
  print(votes.votes);
  print(votes.monthlyVotes);

  // Check if a user has voted
  final voted = await client.hasVoted('mybot', 123456789);
  print(voted ? 'Voted' : 'Not voted');

  // Post stats
  await client.postStats('mybot', memberCount: 5000, groupCount: 120);

  // Get global stats
  final stats = await client.getStats();
  print(stats.totalListings);

  // Clean up
  client.close();
}
```

## Autoposter

Automatically post stats at regular intervals:

```dart
import 'package:toptl/toptl.dart';

void main() {
  final client = TopTL('your-api-token');

  final autoposter = Autoposter(
    client: client,
    username: 'mybot',
    interval: Duration(minutes: 30),
    statsCallback: () async {
      return {
        'memberCount': await getMyMemberCount(),
        'groupCount': await getMyGroupCount(),
      };
    },
  );

  autoposter.onPost((result) => print('Stats posted successfully'));
  autoposter.onError((error) => print('Error: $error'));

  // Start posting
  autoposter.start();

  // Later, stop it
  // autoposter.stop();
}
```

For one-off posting:

```dart
await autoposter.postOnce();
```

## API Reference

### `TopTL` Client

| Method | Description |
|--------|-------------|
| `getListing(username)` | Get listing info |
| `getVotes(username)` | Get votes for a listing |
| `hasVoted(username, userId)` | Check if a user voted |
| `postStats(username, {memberCount, groupCount})` | Post stats |
| `getStats()` | Get global TOP.TL stats |
| `close()` | Close the HTTP client |

## License

MIT - see [LICENSE](LICENSE) for details.
