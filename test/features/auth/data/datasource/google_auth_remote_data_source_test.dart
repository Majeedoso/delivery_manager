import 'dart:async';

import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/features/auth/data/datasource/google_auth_remote_data_source.dart';
import 'package:fake_async/fake_async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fake_backend.dart';
import '../../../../helpers/fakes.dart';
import '../../../../helpers/locator.dart';

/// Signing in with Google: the Google account picker, then Firebase, then the
/// backend. An account the backend doesn't know is not signed up: managers
/// are created on the server (M1).
void main() {
  late FakeBackend backend;
  late MockGoogleSignIn google;
  late MockFirebaseAuth firebase;
  late MockDeviceInfoService device;
  late GoogleAuthRemoteDataSource source;

  setUpAll(() {
    registerFallbackValue(GoogleAuthProvider.credential(idToken: 'x'));
  });

  setUp(() {
    backend = FakeBackend();
    google = MockGoogleSignIn();
    firebase = MockFirebaseAuth();
    device = MockDeviceInfoService();

    final account = MockGoogleSignInAccount();
    final tokens = MockGoogleSignInAuthentication();
    final credential = MockUserCredential();
    final user = MockFirebaseUser();

    when(() => google.signOut()).thenAnswer((_) async => null);
    when(() => google.disconnect()).thenAnswer((_) async => null);
    when(() => google.signIn()).thenAnswer((_) async => account);
    when(() => account.id).thenReturn('google-42');
    when(() => account.authentication).thenAnswer((_) async => tokens);
    when(() => tokens.accessToken).thenReturn('access');
    when(() => tokens.idToken).thenReturn('google-id-token');
    when(
      () => firebase.signInWithCredential(any()),
    ).thenAnswer((_) async => credential);
    when(() => credential.user).thenReturn(user);
    when(() => user.getIdToken()).thenAnswer((_) async => 'firebase-id-token');
    when(() => user.email).thenReturn('karim@example.dz');
    when(() => user.displayName).thenReturn('Karim Haddad');
    when(() => user.photoURL).thenReturn('https://photos.example/y.jpg');
    when(() => user.uid).thenReturn('firebase-uid');
    when(() => device.getDeviceId()).thenAnswer((_) async => 'device-1');
    when(() => firebase.signOut()).thenAnswer((_) async {});

    source = GoogleAuthRemoteDataSource(
      firebaseAuth: firebase,
      googleSignIn: google,
      dio: testDio(backend),
      deviceInfoService: device,
      logger: silentLogger(),
    );
  });

  group('signing in', () {
    test('sends the Firebase proof and the Google profile', () async {
      backend.reply('POST', '/auth/google/login', body: authJson());

      await source.signInWithGoogle();

      expect(backend.last('POST', '/auth/google/login').json, {
        'id_token': 'firebase-id-token',
        'google_id': 'google-42',
        'email': 'karim@example.dz',
        'name': 'Karim Haddad',
        'avatar': 'https://photos.example/y.jpg',
        'app_type': 'manager',
        'device_id': 'device-1',
      });
    });

    test(
      'forgets the previous Google account first, so the picker shows',
      () async {
        backend.reply('POST', '/auth/google/login', body: authJson());

        await source.signInWithGoogle();

        verifyInOrder([
          () => google.signOut(),
          () => google.disconnect(),
          () => google.signIn(),
        ]);
      },
    );

    test('returns the backend\'s user with its token', () async {
      backend.reply('POST', '/auth/google/login', body: authJson(token: '9|g'));

      final user = await source.signInWithGoogle();

      expect(user.email, 'karim@example.dz');
      expect(user.token, '9|g');
    });

    test('closing the account picker is a cancellation', () async {
      when(() => google.signIn()).thenAnswer((_) async => null);

      await expectLater(
        source.signInWithGoogle(),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Google sign-in was cancelled',
          ),
        ),
      );
    });

    test('an unknown account is told so, never signed up', () async {
      backend.reply(
        'POST',
        '/auth/google/login',
        status: 404,
        body: failure(
          'Account not found. Please sign up first.',
          errorCode: 'ACCOUNT_NOT_FOUND',
        ),
      );

      await expectLater(
        source.signInWithGoogle(),
        throwsA(
          isA<ServerException>().having(
            (e) => e.errorCode,
            'errorCode',
            'ACCOUNT_NOT_FOUND',
          ),
        ),
      );
      // The app signed the account up as a manager, which the server
      // refuses: managers are only created on the server (M1)
      expect(backend.count('POST', '/auth/google/signup'), 0);
    });

    test(
      'an account of another app is refused with the backend\'s reason',
      () async {
        backend.reply(
          'POST',
          '/auth/google/login',
          status: 403,
          body: failure(
            'This account is registered as a customer.',
            errorCode: 'ROLE_MISMATCH',
          ),
        );

        await expectLater(
          source.signInWithGoogle(),
          throwsA(
            isA<ServerException>()
                .having(
                  (e) => e.message,
                  'message',
                  'This account is registered as a customer.',
                )
                .having((e) => e.errorCode, 'errorCode', 'ROLE_MISMATCH'),
          ),
        );
      },
    );

    test('an HTML error page becomes a readable failure', () async {
      backend.reply(
        'POST',
        '/auth/google/login',
        status: 500,
        body: htmlErrorPage,
      );

      await expectLater(
        source.signInWithGoogle(),
        throwsA(isA<ServerException>()),
      );
    });

    test('a Firebase refusal says so', () async {
      when(() => firebase.signInWithCredential(any())).thenThrow(
        FirebaseAuthException(code: 'user-disabled', message: 'Disabled'),
      );

      await expectLater(
        source.signInWithGoogle(),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Firebase authentication failed: Disabled',
          ),
        ),
      );
    });

    test('Firebase not answering is given up after 60 seconds', () {
      fakeAsync((async) {
        when(
          () => firebase.signInWithCredential(any()),
        ).thenAnswer((_) => Completer<UserCredential>().future);
        Object? error;
        source.signInWithGoogle().then<void>(
          (_) {},
          onError: (Object e) => error = e,
        );

        async.elapse(const Duration(seconds: 59));
        expect(error, isNull);
        async.elapse(const Duration(seconds: 1));

        expect(
          error,
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Firebase authentication timed out. Please try again.',
          ),
        );
      });
    });

    test('the backend not answering is given up after 90 seconds', () {
      fakeAsync((async) {
        backend.hang('POST', '/auth/google/login');
        Object? error;
        source.signInWithGoogle().then<void>(
          (_) {},
          onError: (Object e) => error = e,
        );

        async.elapse(const Duration(seconds: 89));
        expect(error, isNull);
        async.elapse(const Duration(seconds: 1));

        expect(
          error,
          isA<NetworkException>(),
          reason: 'a slow server is a network problem for the manager',
        );
      });
    });
  });

  group('signing out', () {
    test('leaves both Firebase and Google', () async {
      await source.signOutFromGoogle();

      verify(() => firebase.signOut()).called(1);
      verify(() => google.signOut()).called(1);
    });

    test('a failure is reported', () async {
      when(() => firebase.signOut()).thenThrow(Exception('offline'));

      await expectLater(
        source.signOutFromGoogle(),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
