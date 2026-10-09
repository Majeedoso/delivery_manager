import 'dart:convert';

import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/secure_storage_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/token_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/platform.dart';

/// What the phone keeps between launches: the signed-in user, the token, and
/// the email for "remember me". The real classes on the plugins' in-memory
/// storage. The token lives in the encrypted storage only: the plain
/// preferences, which Android includes in its backups, kept a copy too.
void main() {
  group('AuthLocalDataSource (shared preferences)', () {
    late SharedPreferences prefs;
    late AuthLocalDataSource local;

    setUp(() async {
      prefs = await SharedPreferences.getInstance();
      local = AuthLocalDataSource(sharedPreferences: prefs);
    });

    test('a saved user comes back as it was', () async {
      final user = UserModel.fromJson(userJson());

      await local.saveUser(user);

      expect(await local.getCurrentUser(), user);
    });

    test('nothing saved reads as nothing', () async {
      expect(await local.getCurrentUser(), isNull);
    });

    test('clearing removes the user', () async {
      await local.saveUser(UserModel.fromJson(userJson()));

      await local.clearUser();

      expect(await local.getCurrentUser(), isNull);
    });

    test('the saved user carries no token', () async {
      // After a Google sign-in the user carries the session's token
      await local.saveUser(UserModel.fromJson({...userJson(), 'token': '9|g'}));

      final stored = prefs.getString('user_data')!;
      expect(stored, isNot(contains('9|g')));
      expect(jsonDecode(stored), isNot(contains('token')));
    });

    test('token copies left by an earlier version are removed', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': '1|abcdef',
        'user_data': jsonEncode({...userJson(), 'token': '9|g'}),
      });
      prefs = await SharedPreferences.getInstance();
      local = AuthLocalDataSource(sharedPreferences: prefs);

      await local.clearToken();

      expect(prefs.getString('auth_token'), isNull);
      expect(prefs.getString('user_data'), isNot(contains('9|g')));
      expect(await local.getCurrentUser(), isNotNull, reason: 'user kept');
    });

    test('clearing the token with nothing saved does nothing', () async {
      await local.clearToken();

      expect(prefs.getKeys(), isEmpty);
    });

    test('a corrupted saved user is a storage error', () async {
      SharedPreferences.setMockInitialValues({'user_data': '{not json'});
      prefs = await SharedPreferences.getInstance();
      local = AuthLocalDataSource(sharedPreferences: prefs);

      await expectLater(
        local.getCurrentUser(),
        throwsA(isA<LocalDatabaseException>()),
      );
    });

    test('the stored user keeps the role as its name', () async {
      await local.saveUser(UserModel.fromJson(userJson()));

      final stored = jsonDecode(prefs.getString('user_data')!) as Map;
      expect(stored['role'], 'manager');
    });
  });

  group('SecureStorageLocalDataSource (remember me)', () {
    final remember = SecureStorageLocalDataSource();

    test('remember me keeps the email, never the password', () async {
      await remember.saveCredentials(
        email: 'karim@example.dz',
        password: 'Secret#2026',
        rememberMe: true,
      );

      expect(await remember.loadCredentials(), {
        'email': 'karim@example.dz',
        'rememberMe': 'true',
      });
      expect(
        await const FlutterSecureStorage().readAll(),
        isNot(containsValue('Secret#2026')),
      );
      expect(await remember.hasSavedCredentials(), isTrue);
    });

    test('turning remember me off forgets the email', () async {
      await remember.saveCredentials(
        email: 'karim@example.dz',
        password: 'p',
        rememberMe: true,
      );

      await remember.saveCredentials(
        email: 'karim@example.dz',
        password: 'p',
        rememberMe: false,
      );

      expect(await remember.loadCredentials(), {
        'email': null,
        'rememberMe': null,
      });
      expect(await remember.hasSavedCredentials(), isFalse);
    });
  });

  group('TokenLocalDataSource (secure storage)', () {
    final tokens = TokenLocalDataSource();

    test('saves, reads and clears the token', () async {
      await tokens.saveToken('1|abcdef');
      expect(await tokens.getToken(), '1|abcdef');
      expect(await tokens.hasToken(), isTrue);

      await tokens.clearToken();
      expect(await tokens.getToken(), isNull);
      expect(await tokens.hasToken(), isFalse);
    });

    group('on a phone with a corrupted keystore', () {
      late BrokenSecureStorage broken;

      setUp(() => broken = BrokenSecureStorage()..install());

      test('reading gives no token instead of crashing', () async {
        expect(await tokens.getToken(), isNull);
        expect(await tokens.hasToken(), isFalse);
      });

      test('saving and clearing fail quietly', () async {
        await tokens.saveToken('1|abcdef');
        await tokens.clearToken();
      });

      test('the storage is wiped once to recover, not on every call', () async {
        await tokens.getToken();
        await tokens.getToken();
        await tokens.saveToken('1|abcdef');

        expect(broken.wipes, 1);
      });
    });
  });

  test('an unknown role in a stored user falls back to operator', () {
    // Documents the parser's fallback; the email-OTP screen used to store
    // "UserRole.manager", which lands here (M3, fixed in that screen).
    expect(
      UserModel.fromJson(userJson(role: 'UserRole.manager')).role,
      UserRole.operator,
    );
  });

  test('a cache exception without a message has a default one', () {
    expect(const CacheException().message, 'Cache error occurred');
  });
}
