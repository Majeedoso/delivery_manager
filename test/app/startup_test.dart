import 'dart:async';

import 'package:delivery_manager/core/utils/app_timeouts.dart';
import 'package:delivery_manager/core/widgets/initialization_error_screen.dart';
import 'package:delivery_manager/main.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// main() only calls startApp(), which runs the startup steps in order and
/// then starts MyApp. Every step is replaced here, so the tests check the
/// order and what each failure shows without Firebase or a device.
void main() {
  late _RecordingSteps steps;
  late List<Widget> launched;

  setUp(() {
    steps = _RecordingSteps();
    launched = [];
  });

  Future<void> start() => startApp(steps: steps, run: launched.add);

  String errorShown() =>
      (launched.single as InitializationErrorScreen).errorMessage;

  test('runs every step in order, then starts the app', () async {
    await start();

    expect(steps.calls, [
      'lockOrientation',
      'loadConfig',
      'initFirebase',
      'initCrashReporting',
      'initServices',
      'loadPublicSettings',
      'initNotifications',
      'registerBackgroundHandler',
    ]);
    expect(launched.single, isA<MyApp>());
    expect(steps.recorded, isEmpty);
  });

  group('Firebase', () {
    test('failing shows the error screen and stops there', () async {
      steps.failing['initFirebase'] = Exception('no google-services.json');

      await start();

      expect(
        errorShown(),
        'Firebase initialization failed: Exception: no google-services.json',
      );
      expect(
        steps.calls,
        isNot(contains('initServices')),
        reason: 'nothing else can run without Firebase',
      );
      expect(steps.recorded, ['Firebase initialization failed']);
    });

    test('not answering within 10 seconds shows a timeout', () {
      fakeAsync((async) {
        steps.hanging.add('initFirebase');

        start();
        async.elapse(
          AppTimeouts.firebaseInit - const Duration(milliseconds: 1),
        );
        expect(launched, isEmpty, reason: 'still waiting for Firebase');

        async.elapse(const Duration(milliseconds: 1));
        expect(
          errorShown(),
          'Firebase initialization timed out after 10 seconds',
        );
        expect(steps.calls, isNot(contains('initServices')));
      });
    });
  });

  group('the service locator', () {
    test('failing shows the error screen and stops there', () async {
      steps.failing['initServices'] = StateError('Dio registered twice');

      await start();

      expect(
        errorShown(),
        'Service initialization failed: Bad state: Dio registered twice',
      );
      expect(steps.calls, isNot(contains('initNotifications')));
      expect(steps.recorded, ['Service locator initialization failed']);
    });

    test('not ready within 15 seconds shows a timeout', () {
      fakeAsync((async) {
        steps.hanging.add('initServices');

        start();
        async.elapse(AppTimeouts.serviceLocatorInit);

        expect(
          errorShown(),
          'Service locator initialization timed out after 15 seconds',
        );
      });
    });
  });

  test('retry on the error screen runs the steps again', () async {
    steps.failing['initFirebase'] = Exception('offline');
    await start();
    final errorScreen = launched.single as InitializationErrorScreen;
    steps.failing.clear();
    steps.calls.clear();

    errorScreen.onRetry!();
    await pumpEventQueue();

    expect(steps.calls.first, 'lockOrientation');
    expect(launched.last, isA<MyApp>(), reason: 'the second attempt worked');
  });

  group('an optional step failing still starts the app', () {
    for (final step in [
      'initCrashReporting',
      'loadPublicSettings',
      'initNotifications',
      'registerBackgroundHandler',
    ]) {
      test(step, () async {
        steps.failing[step] = Exception('$step broke');

        await start();

        expect(launched.single, isA<MyApp>());
        expect(steps.calls, contains('registerBackgroundHandler'));
      });
    }

    test('notifications not ready within 10 seconds', () {
      fakeAsync((async) {
        steps.hanging.add('initNotifications');

        start();
        async.elapse(AppTimeouts.notificationServiceInit);

        expect(launched.single, isA<MyApp>());
      });
    });
  });
}

/// Startup steps that do nothing but remember they ran. A step named in
/// [failing] throws that error; one in [hanging] never finishes.
class _RecordingSteps extends StartupSteps {
  final calls = <String>[];
  final failing = <String, Object>{};
  final hanging = <String>{};

  /// The reasons passed to recordError (sent to Crashlytics in the app).
  final recorded = <String>[];

  Future<void> _step(String name) {
    calls.add(name);
    if (hanging.contains(name)) return Completer<void>().future;
    final error = failing[name];
    return error == null ? Future.value() : Future.error(error);
  }

  @override
  Future<void> lockOrientation() => _step('lockOrientation');

  @override
  Future<void> loadConfig() => _step('loadConfig');

  @override
  Future<void> initFirebase() => _step('initFirebase');

  @override
  Future<void> initCrashReporting() => _step('initCrashReporting');

  @override
  Future<void> initServices() => _step('initServices');

  @override
  void loadPublicSettings() {
    calls.add('loadPublicSettings');
    final error = failing['loadPublicSettings'];
    if (error != null) throw error;
  }

  @override
  Future<void> initNotifications() => _step('initNotifications');

  @override
  void registerBackgroundHandler() {
    calls.add('registerBackgroundHandler');
    final error = failing['registerBackgroundHandler'];
    if (error != null) throw error;
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace,
    String reason,
  ) async => recorded.add(reason);
}
