import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Android 12+ plays the brand kit's animated splash
/// (res/drawable/lihlih_splash_orange.xml), slowed to 2 s (the kit's file lasts
/// 1 s; the owner's choice). `dart run flutter_native_splash:create` writes both
/// launch themes back to the still picture: put the two items back.
void main() {
  const duration = 2000;

  for (final folder in ['values-v31', 'values-night-v31']) {
    test('the $folder launch theme plays the animated splash', () {
      final styles = File(
        'android/app/src/main/res/$folder/styles.xml',
      ).readAsStringSync();

      expect(
        styles,
        contains(
          '<item name="android:windowSplashScreenAnimatedIcon">'
          '@drawable/lihlih_splash_orange</item>',
        ),
      );
      expect(
        styles,
        contains(
          '<item name="android:windowSplashScreenAnimationDuration">'
          '$duration</item>',
        ),
      );
    });
  }

  // MainActivity keeps the splash on screen for the theme's duration: an
  // animation longer than that is cut, a shorter one leaves a still logo
  test('the animation lasts as long as the splash waits for it', () {
    final drawable = File(
      'android/app/src/main/res/drawable/lihlih_splash_orange.xml',
    ).readAsStringSync();
    final animators = RegExp(
      r'android:duration="(\d+)"',
    ).allMatches(drawable).map((m) => int.parse(m.group(1)!));

    expect(drawable, contains('<animated-vector'));
    expect(animators, isNotEmpty);
    expect(animators, everyElement(duration));
  });
}
