import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/public_settings_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:logger/logger.dart';

/// Screens, blocs and some services resolve their dependencies through `sl`
/// themselves, so tests put fakes there. Only the locator tests run the real
/// `ServicesLocator().init()`.
///
/// Register in setUp: flutter_test_config.dart resets `sl` after every test.
void registerBloc<T extends Object>(T fake) =>
    sl.registerFactory<T>(() => fake);

void registerUseCase<T extends Object>(T fake) =>
    sl.registerLazySingleton<T>(() => fake);

/// Repositories, data sources, `Dio`, `SharedPreferences` and the like.
void registerService<T extends Object>(T instance) =>
    sl.registerLazySingleton<T>(() => instance);

/// A LoggingService that prints nothing and never calls Crashlytics.
LoggingService silentLogger() =>
    LoggingService(logger: Logger(level: Level.off), isDebugMode: true);

void registerSilentLogger() {
  if (!sl.isRegistered<LoggingService>()) {
    sl.registerLazySingleton<LoggingService>(silentLogger);
  }
}

/// The manager's settings as the server would give them. Screens look them
/// up in `sl` (the map's token, the wait before another emailed code), so a
/// fake is always registered; a test changes [values] to play another server.
class FakePublicSettings implements PublicSettingsService {
  /// Only what a test needs: a setting left out takes the app's fallback.
  final Map<String, dynamic> values = {
    'app_mapbox_access_token': 'pk.test-map-token',
  };

  /// How many times the server was asked.
  int refreshes = 0;

  /// What the server answers on the next [refresh] (null: nothing new).
  Map<String, dynamic>? next;

  @override
  Future<void> refresh() async {
    refreshes++;
    if (next != null) values.addAll(next!);
  }

  @override
  String text(String key) {
    final value = values[key];
    return value is String ? value : '';
  }

  @override
  int number(String key, {required int fallback}) {
    final value = values[key];
    return value is num ? value.toInt() : fallback;
  }

  @override
  double decimal(String key, {required double fallback}) {
    final value = values[key];
    return value is num ? value.toDouble() : fallback;
  }

  @override
  String get mapToken => text('app_mapbox_access_token');

  @override
  double get mapDefaultLatitude =>
      decimal('map_default_latitude', fallback: 36.247524721057616);

  @override
  double get mapDefaultLongitude =>
      decimal('map_default_longitude', fallback: 0.92113119431679);

  @override
  int get otpResendWaitSeconds =>
      number('otp_resend_wait_seconds', fallback: 120);
}

/// The fake settings every test starts with.
FakePublicSettings get publicSettings =>
    sl<PublicSettingsService>() as FakePublicSettings;

void registerPublicSettings() {
  if (!sl.isRegistered<PublicSettingsService>()) {
    final settings = FakePublicSettings();
    sl.registerLazySingleton<PublicSettingsService>(() => settings);
  }
}

/// Clears `sl` and puts the silent logger and the fake settings back (run
/// after every test).
Future<void> resetLocator() async {
  await sl.reset();
  registerSilentLogger();
  registerPublicSettings();
}
