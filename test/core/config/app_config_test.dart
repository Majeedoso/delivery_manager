import 'package:delivery_manager/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/platform.dart';

/// AppConfig reads the API address from `.env`. HOST_URL (the server without
/// `/api`) prefixes every relative image path, so a wrong derivation shows
/// broken images everywhere.
void main() {
  void useEnv(String env) {
    loadTestEnv(env: env);
    addTearDown(loadTestEnv);
  }

  test('BASE_URL is read from .env', () {
    useEnv('BASE_URL=https://delivery.example.dz/api');

    expect(AppConfig.baseUrl, 'https://delivery.example.dz/api');
  });

  test('without BASE_URL the emulator address is used', () {
    useEnv('# nothing configured');

    expect(AppConfig.baseUrl, 'http://10.0.2.2:8001/api');
  });

  group('HOST_URL', () {
    test('is used as given, without a trailing slash', () {
      useEnv('HOST_URL=https://delivery.example.dz/');

      expect(AppConfig.hostUrl, 'https://delivery.example.dz');
    });

    test('is derived from BASE_URL when not set', () {
      useEnv('BASE_URL=https://delivery.example.dz/api');
      expect(AppConfig.hostUrl, 'https://delivery.example.dz');

      useEnv('BASE_URL=https://delivery.example.dz/api/');
      expect(AppConfig.hostUrl, 'https://delivery.example.dz');

      useEnv('BASE_URL=https://delivery.example.dz/');
      expect(AppConfig.hostUrl, 'https://delivery.example.dz');
    });

    test('an empty HOST_URL counts as not set', () {
      useEnv('BASE_URL=http://10.0.2.2:8000/api\nHOST_URL=');

      expect(AppConfig.hostUrl, 'http://10.0.2.2:8000');
    });
  });

  group('a build for the end-to-end tests', () {
    setUp(() => addTearDown(() => AppConfig.e2eApi = ''));

    test('talks to the server it was given, whatever .env says', () {
      useEnv(
        'BASE_URL=https://delivery.example.dz/api\n'
        'HOST_URL=https://delivery.example.dz',
      );
      AppConfig.e2eApi = 'http://10.0.2.2:8011/api';

      expect(AppConfig.baseUrl, 'http://10.0.2.2:8011/api');
      expect(AppConfig.hostUrl, 'http://10.0.2.2:8011');
    });

    test('an ordinary build is given none', () {
      expect(AppConfig.e2eApi, isEmpty);
    });
  });
}
