import 'package:delivery_manager/core/services/public_settings_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/api_json.dart';
import '../../helpers/fake_backend.dart';

/// What the manager sets on the server and the app needs (the map's token,
/// the wait before another emailed code, where the map opens): read from
/// `GET /settings/public`, remembered on the phone, never written in the app
/// or its .env.
void main() {
  late FakeBackend backend;
  late SharedPreferences preferences;

  /// GET /settings/public (SettingsController@getPublic).
  Map<String, dynamic> settingsJson(Map<String, Object?> values) => {
    'success': true,
    'message': 'Public settings retrieved successfully',
    'data': [
      for (final entry in values.entries)
        {
          'key': entry.key,
          'value': entry.value,
          'description': 'A setting',
          'type': entry.value is String ? 'string' : 'integer',
        },
    ],
    'count': values.length,
  };

  setUp(() async {
    backend = FakeBackend();
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  PublicSettingsService service() =>
      PublicSettingsService(dio: testDio(backend), preferences: preferences);

  void serverGives(Map<String, Object?> values) => backend.reply(
    'GET',
    PublicSettingsService.path,
    body: settingsJson(values),
  );

  test('reads the manager\'s settings from the server', () async {
    serverGives({
      'app_mapbox_access_token': 'pk.from-the-server',
      'otp_resend_wait_seconds': 45,
      'map_default_latitude': 36.7538,
      'map_default_longitude': 3.0588,
    });
    final settings = service();

    await settings.refresh();

    expect(settings.mapToken, 'pk.from-the-server');
    expect(settings.otpResendWaitSeconds, 45);
    expect(
      (settings.mapDefaultLatitude, settings.mapDefaultLongitude),
      (36.7538, 3.0588),
    );
    expect(backend.requests.single.path, '/settings/public');
  });

  test('before the server answered: no token, the usual numbers', () {
    final settings = service();

    expect(settings.mapToken, isEmpty);
    expect(settings.otpResendWaitSeconds, 120);
    expect(settings.mapDefaultLatitude, closeTo(36.2475, 0.0001));
    expect(settings.mapDefaultLongitude, closeTo(0.9211, 0.0001));
  });

  test('remembers the last values for the next start', () async {
    serverGives({
      'app_mapbox_access_token': 'pk.remembered',
      'otp_resend_wait_seconds': 60,
    });
    await service().refresh();

    final nextStart = service();

    expect(nextStart.mapToken, 'pk.remembered');
    expect(nextStart.otpResendWaitSeconds, 60);
  });

  test('offline keeps the last known values', () async {
    serverGives({'app_mapbox_access_token': 'pk.remembered'});
    await service().refresh();
    backend.fail(
      'GET',
      PublicSettingsService.path,
      DioExceptionType.connectionError,
    );
    final settings = service();

    await settings.refresh();

    expect(settings.mapToken, 'pk.remembered');
  });

  test('a server error or an odd answer changes nothing', () async {
    serverGives({'app_mapbox_access_token': 'pk.remembered'});
    final settings = service();
    await settings.refresh();

    backend.reply('GET', PublicSettingsService.path, status: 500, body: {});
    await settings.refresh();
    backend.reply(
      'GET',
      PublicSettingsService.path,
      body: '<html>maintenance</html>',
    );
    await settings.refresh();
    backend.reply(
      'GET',
      PublicSettingsService.path,
      body: ok({'not': 'a list'}),
    );
    await settings.refresh();

    expect(settings.mapToken, 'pk.remembered');
  });

  test('a new token replaces the old one', () async {
    serverGives({'app_mapbox_access_token': 'pk.old'});
    final settings = service();
    await settings.refresh();

    serverGives({'app_mapbox_access_token': 'pk.new'});
    await settings.refresh();

    expect(settings.mapToken, 'pk.new');
    expect(service().mapToken, 'pk.new', reason: 'remembered too');
  });

  test('a value of another kind takes the fallback', () async {
    serverGives({
      'app_mapbox_access_token': 42,
      'otp_resend_wait_seconds': 'soon',
      'map_default_latitude': null,
    });
    final settings = service();

    await settings.refresh();

    expect(settings.mapToken, isEmpty);
    expect(settings.otpResendWaitSeconds, 120);
    expect(settings.mapDefaultLatitude, closeTo(36.2475, 0.0001));
  });

  test('two screens asking at once make one request', () async {
    serverGives({'app_mapbox_access_token': 'pk.once'});
    final settings = service();

    await Future.wait([settings.refresh(), settings.refresh()]);

    expect(backend.requests, hasLength(1));
  });

  test('what was stored on the phone and can\'t be read is ignored', () async {
    SharedPreferences.setMockInitialValues({'public_settings': 'not json'});
    preferences = await SharedPreferences.getInstance();

    expect(service().otpResendWaitSeconds, 120);
  });
}
