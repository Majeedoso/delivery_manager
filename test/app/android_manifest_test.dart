import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// What the app declares to Android. Since Android 11 an app only sees the
/// apps it says it will open: without the declaration, "can anything open
/// this?" (`canLaunchUrl`) answers no, and the button behind it does nothing.
/// No test on a fake phone can see that, so the declarations are checked
/// here, against what the app's pages do.
void main() {
  final manifest = File(
    'android/app/src/main/AndroidManifest.xml',
  ).readAsStringSync();

  test('the app asks for the permissions it uses, and no other', () {
    final asked = [
      for (final match in RegExp(
        r'<uses-permission[^>]*android:name="android\.permission\.([A-Z_]+)"',
      ).allMatches(manifest))
        match.group(1),
    ];

    // The server. Not the position: no page reads it (the map picker that
    // did was never opened by any page). Not the three the
    // local-notifications plugin needed (WAKE_LOCK, RECEIVE_BOOT_COMPLETED,
    // VIBRATE): the app shows no notification itself, the plugin went with
    // its channels (M7). Not POST_NOTIFICATIONS: the app no longer asks for
    // notifications, the server sends a manager none (decision 1); the
    // Firebase plugin declares it in the APK itself
    expect(asked, ['INTERNET']);
  });

  test('links open without asking Android first, so they need no '
      'declaration', () {
    // The email, the phone number, the legal pages and the update open with
    // launchUrl directly. A page that asked canLaunchUrl first would also
    // need a <queries> entry for its scheme, as the driver app's calls did
    final asking = [
      for (final file in Directory(
        'lib',
      ).listSync(recursive: true).whereType<File>())
        if (file.path.endsWith('.dart') &&
            file.readAsStringSync().contains('canLaunchUrl('))
          file.path.replaceAll('\\', '/'),
    ];

    expect(asking, isEmpty);
  });
}
