import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/services/notification_service.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

import '../../helpers/fakes.dart';
import '../../helpers/locator.dart';
import '../../helpers/platform.dart';

/// The server sends a manager no notification, so all this app does with
/// Firebase is keep the phone's FCM token known to the server: sent after a
/// sign-in, on every return to the app and when Firebase changes it. The
/// service throttles itself: one send at a time, at most one every 30
/// seconds, three tries when the network fails.
void main() {
  late MockTokenRepository tokens;
  late MockAuthRemoteDataSource api;
  late int tokenReads;

  // Real FCM tokens are long; the service logs their first 20 characters.
  const fcmToken = 'fcm-device-1:APA91bHPRgkF3JUikC4ENAHEeMrd41Zxv3hVZjC9KtT8';

  setUp(() {
    tokens = MockTokenRepository();
    api = MockAuthRemoteDataSource();
    tokenReads = 0;
    when(() => tokens.getToken()).thenAnswer((_) async => const Right('abc'));
    when(() => api.updateFcmToken(any())).thenAnswer((_) async {});
    registerService<BaseTokenRepository>(tokens);
    registerService<BaseAuthRemoteDataSource>(api);
    NotificationService.fetchFcmToken = () async {
      tokenReads++;
      return fcmToken;
    };
  });

  group('sending the token', () {
    test('a signed-in manager\'s token is sent', () async {
      await NotificationService.sendTokenToServer();

      verify(() => api.updateFcmToken(fcmToken)).called(1);
    });

    test('nothing is sent before login', () async {
      when(() => tokens.getToken()).thenAnswer((_) async => const Right(null));

      await NotificationService.sendTokenToServer();

      verifyNever(() => api.updateFcmToken(any()));
    });

    test('nothing is sent when the phone has no FCM token', () async {
      NotificationService.fetchFcmToken = () async => null;

      await NotificationService.sendTokenToServer();

      verifyNever(() => api.updateFcmToken(any()));
    });

    test('nothing is sent when the saved login cannot be read', () async {
      when(
        () => tokens.getToken(),
      ).thenAnswer((_) async => const Left(CacheFailure('keystore')));

      await NotificationService.sendTokenToServer();

      verifyNever(() => api.updateFcmToken(any()));
    });

    test('nothing is sent when Firebase cannot give a token', () async {
      NotificationService.fetchFcmToken = () async =>
          throw StateError('no Google Play services');

      await NotificationService.sendTokenToServer();

      verifyNever(() => api.updateFcmToken(any()));
    });

    test('the FCM token is read once, then reused', () {
      fakeAsync((async) {
        NotificationService.sendTokenToServer();
        async.elapse(const Duration(seconds: 30));
        NotificationService.sendTokenToServer();
        async.flushMicrotasks();

        verify(() => api.updateFcmToken(fcmToken)).called(2);
        expect(tokenReads, 1);
        expect(NotificationService.fcmToken, fcmToken);
      });
    });
  });

  group('the 30-second cooldown', () {
    test('a second send within 30 seconds is skipped', () {
      fakeAsync((async) {
        NotificationService.sendTokenToServer();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 29));
        NotificationService.sendTokenToServer();
        async.flushMicrotasks();
        verify(() => api.updateFcmToken(fcmToken)).called(1);

        async.elapse(const Duration(seconds: 1));
        NotificationService.sendTokenToServer();
        async.flushMicrotasks();
        verify(() => api.updateFcmToken(fcmToken)).called(1);
      });
    });

    test('only one send runs at a time', () {
      fakeAsync((async) {
        final answer = Completer<void>();
        when(() => api.updateFcmToken(any())).thenAnswer((_) => answer.future);

        NotificationService.sendTokenToServer();
        async.flushMicrotasks();
        NotificationService.sendTokenToServer(); // e.g. login and resume at once
        async.flushMicrotasks();
        answer.complete();
        async.flushMicrotasks();

        verify(() => api.updateFcmToken(fcmToken)).called(1);
      });
    });

    test('a refreshed token is read anew and sent after the cooldown', () {
      fakeAsync((async) {
        NotificationService.sendTokenToServer();
        async.elapse(const Duration(seconds: 30));

        NotificationService.fetchFcmToken = () async => '$fcmToken-new';
        NotificationService.refreshAndSyncToken();
        async.flushMicrotasks();

        verify(() => api.updateFcmToken('$fcmToken-new')).called(1);
      });
    });

    test('a refresh Firebase refuses sends nothing, and does not throw', () {
      fakeAsync((async) {
        NotificationService.fetchFcmToken = () async =>
            throw StateError('no Google Play services');

        NotificationService.refreshAndSyncToken();
        async.flushMicrotasks();

        verifyNever(() => api.updateFcmToken(any()));
      });
    });
  });

  group('a failing network', () {
    test('a failed send is tried again after 2 and then 4 seconds', () {
      fakeAsync((async) {
        var attempts = 0;
        when(() => api.updateFcmToken(any())).thenAnswer((_) async {
          attempts++;
          if (attempts < 3) throw const NetworkException(message: 'offline');
        });

        NotificationService.sendTokenToServer();
        async.flushMicrotasks();
        expect(attempts, 1);

        async.elapse(const Duration(seconds: 2));
        expect(attempts, 2);
        async.elapse(const Duration(seconds: 3));
        expect(attempts, 2, reason: 'the second pause is 4 seconds');
        async.elapse(const Duration(seconds: 1));
        expect(attempts, 3);
      });
    });

    test('three failures give up, and the next send may try at once', () {
      fakeAsync((async) {
        var attempts = 0;
        when(() => api.updateFcmToken(any())).thenAnswer((_) async {
          attempts++;
          throw const NetworkException(message: 'offline');
        });

        NotificationService.sendTokenToServer();
        async.elapse(const Duration(minutes: 1));
        expect(attempts, 3);

        NotificationService.sendTokenToServer();
        async.flushMicrotasks();
        expect(
          attempts,
          4,
          reason: 'a failed send must not start the 30-second cooldown',
        );
        async.elapse(const Duration(minutes: 1));
      });
    });
  });

  group('the start of the service', () {
    // The app's start runs it when the manager allowed notifications in the
    // phone's settings: the app never asks (decision 1 of
    // manager_suite_report.md)
    late int attached;

    setUp(() {
      attached = 0;
      NotificationService.attachToFirebase = () async => attached++;
    });

    test('with notifications already allowed, the app\'s start reads the '
        'token and listens for its changes', () async {
      await NotificationService.initialize();

      expect(NotificationService.isStarted, isTrue);
      expect(NotificationService.fcmToken, fcmToken);
      expect((tokenReads, attached), (1, 1));
    });

    test('nothing is sent at the start: nobody has signed in yet', () async {
      await NotificationService.initialize();

      verifyNever(() => api.updateFcmToken(any()));
    });

    test('never allowed (the app never asks): nothing starts', () async {
      permissions.statuses[Permission.notification] = PermissionStatus.denied;

      await NotificationService.initialize();

      expect(NotificationService.isStarted, isFalse);
      expect((tokenReads, attached), (0, 0));
      expect(await NotificationService.areNotificationsEnabled(), isFalse);
    });
  });

  // M7: the app created "New Orders", "Order Alerts" and "Urgent Orders" on
  // the phone, with sounds it does not pack, for alerts the server never
  // sends a manager. The rule: an app creates the channels the server names
  // for it, and no other. The server names none here (its side is pinned by
  // tests/Feature/Manager/ManagerIsNotNotifiedTest.php).
  group('the alert categories on the phone', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    test('the app creates none and shows no notification itself: the plugin '
        'that does both is not among its packages', () {
      expect(pubspec, isNot(contains('flutter_local_notifications')));

      final using = [
        for (final file in Directory(
          'lib',
        ).listSync(recursive: true).whereType<File>())
          if (file.path.endsWith('.dart') &&
              RegExp(
                r'AndroidNotificationChannel|createNotificationChannel|'
                r'FlutterLocalNotificationsPlugin',
              ).hasMatch(file.readAsStringSync()))
            file.path.replaceAll('\\', '/'),
      ];
      expect(using, isEmpty);
    });

    test('so it packs no sound', () {
      expect(packedSounds(), isEmpty);
      expect(
        File('android/app/src/main/res/raw/keep.xml').existsSync(),
        isFalse,
      );
    });
  });
}
