import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

/// The pictures the app shows are files packed with it: one the code names
/// that is not there shows an error icon (or nothing) on the phone, which no
/// page test sees while a picture loads.
void main() {
  /// Every `assets/...` path written in [text].
  Iterable<String> assetsIn(String text) => RegExp(
    r'''assets/[A-Za-z0-9_./-]+\.(?:png|jpe?g|gif|webp|ico|svg|json|ttf|otf|mp3|wav)''',
  ).allMatches(text).map((m) => m.group(0)!);

  // M2: six pictures were deleted from assets/images in March while the
  // splash, the first-run page, the coupons' page, the native splash and the
  // launcher icons still named them
  test('every picture the code names is packed with the app', () {
    final missing = <String>{};
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      for (final asset in assetsIn(file.readAsStringSync())) {
        if (!File(asset).existsSync()) {
          missing.add('$asset (${file.path.replaceAll('\\', '/')})');
        }
      }
    }

    expect(missing, isEmpty);
  });

  // Decision 2 of manager_suite_report.md: the phone showed Flutter's own
  // logo under the app's name, and on Android's splash
  test('the launcher icon is the app\'s own, not Flutter\'s', () {
    // The icons `flutter create` writes, by their SHA-1
    const flutters = {
      'mdpi': '7d18d43e4eb8fe59ea46cf51cc659be6a7f4cab5',
      'hdpi': 'ea2b064031f64e11892f4dedc3e43c373b97c645',
      'xhdpi': '45963ffb5dda7e9df4a26eda4459111d7bf1fe94',
      'xxhdpi': 'e373f4f6fa753c8a6df8465b1a70f2a749c202c8',
      'xxxhdpi': 'dd0452802ca0cd6c81b9b5982aeb56b051b73829',
    };
    flutters.forEach((density, flutters) {
      final icon = File(
        'android/app/src/main/res/mipmap-$density/ic_launcher.png',
      );
      expect(
        sha1.convert(icon.readAsBytesSync()).toString(),
        isNot(flutters),
        reason: density,
      );
    });
    expect(
      File(
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
      ).existsSync(),
      isTrue,
      reason: 'Android 8 and later draw the adaptive icon',
    );
  });

  test('so is every picture pubspec.yaml names (native splash, icons)', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final named = assetsIn(pubspec).toSet();

    expect(named, isNotEmpty);
    expect(named.where((asset) => !File(asset).existsSync()), isEmpty);
  });

  test('the folders pubspec.yaml packs exist', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final folders = RegExp(
      r'^\s+- (assets/[^\s]*/)\s*$',
      multiLine: true,
    ).allMatches(pubspec).map((m) => m.group(1)!);

    expect(folders, isNotEmpty);
    for (final folder in folders) {
      expect(Directory(folder).existsSync(), isTrue, reason: folder);
    }
  });
}
