import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/utils/app_timeouts.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_state.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_state.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/locator.dart';
import '../../../../helpers/platform.dart';

/// The splash screen's checklist before the app opens: internet, the minimum
/// app version, then "who is signed in" (no location, and no notifications:
/// the server sends a manager nothing). Each step can stop the start with a
/// clear reason, and the sign-in check runs exactly once.
void main() {
  late MockAuthBloc auth;
  late MockAppVersionBloc appVersion;
  late bool online;
  late int authChecks;

  const supported = AppVersionState(
    requestState: RequestState.loaded,
    appVersion: AppVersion(minimumVersion: '1.0.0', currentVersion: '1.0.0'),
    userCurrentVersion: '1.0.0',
  );

  setUpAll(registerFallbacks);

  setUp(() {
    auth = MockAuthBloc();
    appVersion = MockAppVersionBloc();
    online = true;
    authChecks = 0;
    when(() => auth.add(any())).thenAnswer((invocation) {
      if (invocation.positionalArguments.first is CheckAuthStatusEvent) {
        authChecks++;
      }
    });
    whenListen(
      auth,
      const Stream<AuthState>.empty(),
      initialState: const AuthState(),
    );
    whenListen(
      appVersion,
      const Stream<AppVersionState>.empty(),
      initialState: supported,
    );
  });

  SplashBloc build() => SplashBloc(
    authBloc: auth,
    appVersionBloc: appVersion,
    connectivityCheck: () async => online,
    logger: silentLogger(),
  );

  /// Starts the checklist under fake time and returns the last state.
  SplashState start(
    FakeAsync async, {
    SplashBloc? bloc,
    Duration run = const Duration(seconds: 1),
  }) {
    final splash = bloc ?? build();
    splash.add(const InitializeAppEvent());
    async.elapse(run);
    return splash.state;
  }

  test('with everything ready, the sign-in check runs exactly once', () {
    fakeAsync((async) {
      final state = start(async);

      expect(state.currentStep, SplashStep.checkingAuthentication);
      expect(state.hasInternetConnection, isTrue);
      expect(state.versionCheckCompleted, isTrue);
      expect(authChecks, 1);
    });
  });

  test('the steps come in order', () {
    fakeAsync((async) {
      final bloc = build();
      final steps = <SplashStep>[];
      bloc.stream.listen((s) {
        if (steps.isEmpty || steps.last != s.currentStep) {
          steps.add(s.currentStep);
        }
      });

      start(async, bloc: bloc);

      expect(steps, [
        SplashStep.initializing,
        SplashStep.checkingInternet,
        SplashStep.checkingVersion,
        SplashStep.checkingAuthentication,
      ]);
    });
  });

  group('internet', () {
    test('offline stops at "no internet", before anything else', () {
      fakeAsync((async) {
        online = false;

        final state = start(async);

        expect(state.currentStep, SplashStep.noInternet);
        expect(state.requestState, RequestState.error);
        expect(state.statusMessage, 'noInternetConnection');
        expect(authChecks, 0);
      });
    });

    test('a check that never answers counts as offline after 25 seconds', () {
      fakeAsync((async) {
        final bloc = SplashBloc(
          authBloc: auth,
          appVersionBloc: appVersion,
          connectivityCheck: () => Completer<bool>().future,
          logger: silentLogger(),
        );

        var state = start(async, bloc: bloc, run: AppTimeouts.internetCheck);
        expect(state.currentStep, SplashStep.checkingInternet);

        async.elapse(const Duration(milliseconds: 200));
        state = bloc.state;
        expect(state.currentStep, SplashStep.noInternet);
      });
    });

    test('retry starts over and gets through once online', () {
      fakeAsync((async) {
        online = false;
        final bloc = build();
        start(async, bloc: bloc);

        online = true;
        bloc.add(const RetryInitializationEvent());
        async.elapse(const Duration(seconds: 1));

        expect(bloc.state.currentStep, SplashStep.checkingAuthentication);
        expect(authChecks, 1);
      });
    });
  });

  group('the app version', () {
    test('an unsupported version stops at "update required"', () {
      fakeAsync((async) {
        whenListen(
          appVersion,
          const Stream<AppVersionState>.empty(),
          initialState: supported.copyWith(isVersionSupported: false),
        );

        final state = start(async);

        expect(state.currentStep, SplashStep.versionUpdateRequired);
        expect(state.isVersionSupported, isFalse);
        expect(permissions.requested, isEmpty, reason: 'no permission asked');
        expect(authChecks, 0);
      });
    });

    test('a check still running is waited for', () {
      fakeAsync((async) {
        final versions = StreamController<AppVersionState>();
        whenListen(
          appVersion,
          versions.stream,
          initialState: const AppVersionState(),
        );
        final bloc = build();

        start(async, bloc: bloc);
        expect(bloc.state.currentStep, SplashStep.checkingVersion);
        verify(() => appVersion.add(any())).called(1);

        versions.add(supported);
        async.elapse(const Duration(seconds: 1));
        expect(bloc.state.currentStep, SplashStep.checkingAuthentication);
        versions.close();
      });
    });

    test('a check that never finishes lets the app start after 10 seconds', () {
      fakeAsync((async) {
        whenListen(
          appVersion,
          const Stream<AppVersionState>.empty(),
          initialState: const AppVersionState(),
        );
        final bloc = build();

        start(async, bloc: bloc);
        async.elapse(AppTimeouts.versionCheck);

        expect(bloc.state.currentStep, SplashStep.checkingAuthentication);
        expect(authChecks, 1);
      });
    });
  });

  // Decision 1 of manager_suite_report.md: the splash asked for notifications
  // and let no manager in without them, though the server sends a manager
  // nothing
  group('notifications', () {
    test('are never asked for', () {
      fakeAsync((async) {
        permissions.statuses[Permission.notification] = PermissionStatus.denied;

        final state = start(async);

        expect(permissions.requested, isEmpty);
        expect(state.currentStep, SplashStep.checkingAuthentication);
        expect(authChecks, 1);
      });
    });

    test('refused for good, the app opens all the same', () {
      fakeAsync((async) {
        permissions.statuses[Permission.notification] =
            PermissionStatus.permanentlyDenied;

        final state = start(async);

        expect(state.currentStep, SplashStep.checkingAuthentication);
        expect(state.errorMessage, isNull);
      });
    });
  });

  test('without an AuthBloc the start fails with a clear error', () {
    fakeAsync((async) {
      final bloc = SplashBloc(
        appVersionBloc: appVersion,
        connectivityCheck: () async => true,
        logger: silentLogger(),
      );

      final state = start(async, bloc: bloc);

      expect(state.currentStep, SplashStep.error);
      expect(state.errorMessage, 'AuthBloc not available');
    });
  });
}
