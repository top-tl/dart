/// Official Dart SDK for the TOP.TL Telegram directory API.
///
///     import 'package:toptl/toptl.dart';
///
///     final client = TopTL('toptl_xxx');
///     final listing = await client.getListing('durov');
///     await client.postStats('mybot', memberCount: 5000);
library toptl;

export 'src/client.dart';
export 'src/autoposter.dart';
export 'src/exceptions.dart';
export 'src/models.dart';
