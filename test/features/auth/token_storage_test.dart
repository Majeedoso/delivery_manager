import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/google_auth_remote_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/token_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/token_remote_data_source.dart';
import 'package:delivery_manager/features/auth/data/models/auth_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';
import 'package:delivery_manager/features/auth/data/repository/auth_repository.dart';
import 'package:delivery_manager/features/auth/data/repository/token_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The sign-in token lives in the phone's encrypted storage only. The app also
/// kept it in its plain preferences, which Android includes in backups: its
/// own entry after an e-mail sign-in, and inside the saved user after a Google
/// sign-in (point 5 of the customer report; the same code in the five apps).
void main() {
  const userJson = {
    'id': 3,
    'name': 'Nadia Mansouri',
    'email': 'nadia@example.dz',
    'phone': '0550000009',
    'role': 'manager',
    'status': 'active',
  };

  late SharedPreferences prefs;
  late AuthLocalDataSource local;
  late TokenRepository tokens;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    local = AuthLocalDataSource(sharedPreferences: prefs);
    tokens = TokenRepository(
      localDataSource: TokenLocalDataSource(),
      remoteDataSource: _NoTokenApi(),
    );
  });

  test('the saved user carries no token', () async {
    // After a Google sign-in the user carries the session's token
    await local.saveUser(UserModel.fromJson({...userJson, 'token': '9|g'}));

    final stored = prefs.getString('user_data')!;
    expect(stored, isNot(contains('9|g')));
    expect(jsonDecode(stored), isNot(contains('token')));
    expect((await local.getCurrentUser())?.email, 'nadia@example.dz');
  });

  test('token copies left by an earlier version are removed', () async {
    SharedPreferences.setMockInitialValues({
      'auth_token': '1|abcdef',
      'user_data': jsonEncode({...userJson, 'token': '9|g'}),
    });
    prefs = await SharedPreferences.getInstance();
    local = AuthLocalDataSource(sharedPreferences: prefs);

    await local.clearToken();

    expect(prefs.getString('auth_token'), isNull);
    expect(prefs.getString('user_data'), isNot(contains('9|g')));
    expect(await local.getCurrentUser(), isNotNull, reason: 'user kept');
  });

  test('a sign-in keeps the token in the encrypted storage only', () async {
    final repository = AuthRepository(
      baseAuthRemoteDataSource: _SignInApi(userJson),
      baseAuthLocalDataSource: local,
      baseGoogleAuthRemoteDataSource: _NoGoogle(),
      baseTokenRepository: tokens,
    );

    final answer = await repository.login(
      email: 'nadia@example.dz',
      password: 'Secret#2026',
    );

    expect(answer.isRight(), isTrue);
    expect(await tokens.getToken(), const Right<Failure, String?>('1|abcdef'));
    expect(prefs.getString('auth_token'), isNull);
    expect(prefs.getString('user_data'), isNot(contains('1|abcdef')));
  });
}

/// The server accepts the sign-in.
class _SignInApi extends Fake implements BaseAuthRemoteDataSource {
  _SignInApi(this.user);

  final Map<String, Object> user;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async => AuthResponseModel.fromJson({
    'message': 'Login successful',
    'data': {'token': '1|abcdef', 'user': user},
  });
}

class _NoGoogle extends Fake implements BaseGoogleAuthRemoteDataSource {}

class _NoTokenApi extends Fake implements BaseTokenRemoteDataSource {}
