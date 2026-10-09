import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';

import 'helpers/fonts.dart';
import 'helpers/locator.dart';
import 'helpers/platform.dart';

/// Runs around every test file under test/; flutter_test finds it by name.
///
/// Every test starts from the same place:
/// - Roboto and the Material icons, so text is measured like on a phone and an
///   overflow on the 360-wide test screen is a real one.
/// - intl's date data for all locales, so DateFormat works in plain tests too
///   (widget tests also get it from flutter_localizations).
/// - A test `.env`. AppConfig reads BASE_URL and HOST_URL on demand, and
///   flutter_dotenv throws when nothing has been loaded.
/// - Fresh platform fakes before each test: location, permissions, links,
///   package info, clipboard, local notifications, secure storage, shared
///   preferences, DNS and the FCM token. No test reaches a real plugin or the
///   network.
/// - A clean service locator after each test, keeping a silent LoggingService
///   (lib looks the logger up about 60 times, often as a default argument)
///   and fake manager settings (`publicSettings`: map token, code timers).
///   Register fakes in setUp, never setUpAll: the reset would drop them.
/// - Loggers print nothing (lib logs every step), so failures stay readable.
/// - A tap that lands off the screen, or on another widget, fails its test.
///   flutter_test only warns, and a card that had grown left tests tapping
///   nothing while they still passed: scroll to the target first
///   (`scrollTo`).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadAppFonts();
  await initializeDateFormatting();
  loadTestEnv();
  registerSilentLogger();
  registerPublicSettings();
  Logger.level = Level.off;
  WidgetController.hitTestWarningShouldBeFatal = true;

  setUp(installPlatformFakes);
  tearDown(resetLocator);

  await testMain();
}
