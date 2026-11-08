import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The .env is packed into the APK as it is, comments included: it holds the
/// server's address and nothing else. It carried a map token the app no
/// longer read (the token comes from the server's settings) and old
/// addresses in comments.
void main() {
  final lines = File('.env').readAsLinesSync().map((line) => line.trim());

  test('holds the server\'s address only', () {
    final keys = [
      for (final line in lines)
        if (line.isNotEmpty && !line.startsWith('#'))
          line.split('=').first.trim(),
    ];

    expect(keys, ['BASE_URL', 'HOST_URL']);
  });

  test('its comments name no address', () {
    expect([
      for (final line in lines)
        if (line.startsWith('#') && line.contains('://')) line,
    ], isEmpty);
  });

  test('.env.production is the server, in https, and nothing else', () {
    final lines = File('.env.production').readAsLinesSync();
    final host = lines.last.replaceFirst('HOST_URL=', '');

    expect(host, startsWith('https://'));
    expect(lines, ['BASE_URL=$host/api', 'HOST_URL=$host']);
  });

  // Not packed, a release build stops at launch, and no other test runs in
  // release.
  test('.env.production is packed into the APK', () {
    final assets = File('pubspec.yaml').readAsLinesSync().map((l) => l.trim());

    expect(assets, contains('- .env.production'));
  });
}
