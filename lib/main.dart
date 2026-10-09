import 'dart:async';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sizer/sizer.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/services/public_settings_service.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_bloc.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_event.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_state.dart';
import 'package:delivery_manager/core/services/notification_service.dart';
import 'package:delivery_manager/core/services/crash_reporting_service.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/widgets/initialization_error_screen.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/routes/route_generator.dart';
import 'package:delivery_manager/core/utils/app_timeouts.dart';
import 'package:delivery_manager/core/utils/app_navigator.dart';
import 'package:delivery_manager/core/utils/week_material_localizations.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_bloc.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_event.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_state.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/screens/login_screen.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'firebase_options.dart';

// Simple logger for initialization (before service locator is ready)
final _initLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 3,
    lineLength: 120,
    colors: true,
    printEmojis: false,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

Future<void> main() => startApp();

/// Every step [startApp] runs before the app starts, in order.
///
/// The app always uses these defaults. Tests pass their own steps, so the
/// startup order, timeouts and error screens can be checked without Firebase.
class StartupSteps {
  const StartupSteps();

  /// Lock orientation to portrait only
  Future<void> lockOrientation() => SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  /// Initialize App Config (Environment Variables)
  Future<void> loadConfig() => AppConfig.load();

  Future<void> initFirebase() =>
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Future<void> initCrashReporting() => CrashReportingService.initialize();

  Future<void> recordError(Object error, StackTrace stackTrace, String reason) =>
      CrashReportingService.recordError(error, stackTrace, reason: reason);

  Future<void> initServices() => ServicesLocator().init();

  /// The manager's settings the app needs (map token, timers): asked for in
  /// the background, never waited for
  void loadPublicSettings() => sl<PublicSettingsService>().refresh();

  Future<void> initNotifications() => NotificationService.initialize();

  void registerBackgroundHandler() =>
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

/// Starts the app: runs [steps] in order, then hands [MyApp] to [run].
///
/// A failed or timed-out critical step (Firebase, services) shows
/// [InitializationErrorScreen] instead, whose retry starts over.
Future<void> startApp({
  StartupSteps steps = const StartupSteps(),
  void Function(Widget app) run = runApp,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await steps.lockOrientation();

  // Initialize App Config (Environment Variables)
  await steps.loadConfig();

  // Track initialization errors
  String? initializationError;

  try {
    // Initialize Firebase
    if (kDebugMode) {
      _initLogger.i('Main: Initializing Firebase...');
    }
    await steps.initFirebase().timeout(AppTimeouts.firebaseInit);
    if (kDebugMode) {
      _initLogger.i('Main: Firebase initialized successfully');
    }

    // Initialize crash reporting after Firebase is ready
    try {
      await steps.initCrashReporting();
      if (kDebugMode) {
        _initLogger.i('Main: Crash reporting initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        _initLogger.e('Main: Error initializing crash reporting: $e');
      }
      // Crash reporting failure is not critical, continue without it
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      _initLogger.w('Main: Firebase initialization timed out: $e');
    }
    initializationError =
        'Firebase initialization timed out after ${AppTimeouts.firebaseInit.inSeconds} seconds';
    _showErrorScreen(initializationError, steps, run);
    return;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      _initLogger.e(
        'Main: Firebase initialization failed: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
    // Try to record error to crash reporting if available
    try {
      await steps.recordError(
        e,
        stackTrace,
        'Firebase initialization failed',
      );
    } catch (_) {
      // Ignore crash reporting errors
    }
    initializationError = 'Firebase initialization failed: ${e.toString()}';
    _showErrorScreen(initializationError, steps, run);
    return;
  }

  try {
    // Initialize service locator
    if (kDebugMode) {
      _initLogger.i('Main: Initializing service locator...');
    }
    await steps.initServices().timeout(AppTimeouts.serviceLocatorInit);
    if (kDebugMode) {
      _initLogger.i('Main: Service locator initialized successfully');
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      _initLogger.w('Main: Service locator initialization timed out: $e');
    }
    initializationError =
        'Service locator initialization timed out after ${AppTimeouts.serviceLocatorInit.inSeconds} seconds';
    _showErrorScreen(initializationError, steps, run);
    return;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      _initLogger.e(
        'Main: Service locator initialization failed: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
    // Try to record error to crash reporting if available
    try {
      await steps.recordError(
        e,
        stackTrace,
        'Service locator initialization failed',
      );
    } catch (_) {
      // Ignore crash reporting errors
    }
    initializationError = 'Service initialization failed: ${e.toString()}';
    _showErrorScreen(initializationError, steps, run);
    return;
  }

  try {
    steps.loadPublicSettings();
  } catch (_) {
    // The last values known are used; the app starts all the same
  }

  try {
    // Initialize notification service (non-critical)
    if (kDebugMode) {
      _initLogger.i('Main: Starting notification service initialization...');
    }
    await steps.initNotifications().timeout(
      AppTimeouts.notificationServiceInit,
    );
    if (kDebugMode) {
      _initLogger.i('Main: Notification service initialization completed');
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      _initLogger.w('Main: Notification service initialization timed out: $e');
      _initLogger.i('Main: Continuing without notification service...');
    }
    // Notification service timeout is not critical, continue without it
  } catch (e, stackTrace) {
    if (kDebugMode) {
      _initLogger.e(
        'Main: Error initializing notification service: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _initLogger.i('Main: Continuing without notification service...');
    }
    // Notification service failure is not critical, continue without it
  }

  try {
    // Set up background message handler (non-critical)
    if (kDebugMode) {
      _initLogger.i('Main: Setting up background message handler...');
    }
    steps.registerBackgroundHandler();
    if (kDebugMode) {
      _initLogger.i('Main: Background message handler registered successfully');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      _initLogger.e(
        'Main: Error setting up background message handler: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _initLogger.i('Main: Continuing without background message handler...');
    }
    // Background handler failure is not critical, continue without it
  }

  // All critical initialization completed successfully
  run(const MyApp());
}

/// Shows error screen when initialization fails; retry starts the app again
void _showErrorScreen(
  String errorMessage,
  StartupSteps steps,
  void Function(Widget app) run,
) {
  run(
    InitializationErrorScreen(
      errorMessage: errorMessage,
      onRetry: () {
        // Restart the app by running the startup steps again
        startApp(steps: steps, run: run);
      },
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription<void>? _suspensionSub;
  bool _handlingSuspension = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _suspensionSub = accountSuspendedEvents.stream.listen(
      (_) => _onAccountSuspended(),
    );
  }

  @override
  void dispose() {
    _suspensionSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called when the backend returns 403 ACCOUNT_NOT_APPROVED mid-session.
  /// Sends the suspended manager back to the login screen.
  void _onAccountSuspended() {
    if (_handlingSuspension) return;
    _handlingSuspension = true;
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      LoginScreen.route,
      (route) => false,
    );
    // Reset flag after a short delay to allow re-trigger if navigation failed
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _handlingSuspension = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app resumes from background, refresh FCM token to ensure it's synced
    if (state == AppLifecycleState.resumed) {
      try {
        final logger = sl<LoggingService>();
        logger.info('MyApp: App resumed, refreshing FCM token...');
        // Sync token when app comes to foreground (don't await to avoid blocking UI)
        NotificationService.sendTokenToServer().catchError((error) {
          logger.error(
            'MyApp: Error syncing FCM token on resume',
            error: error,
          );
        });
      } catch (e) {
        // Service locator might not be ready, use fallback logger
        if (kDebugMode) {
          _initLogger.w('MyApp: Error syncing FCM token on resume: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<LocalizationBloc>()..add(GetCurrentLanguageEvent()),
      child: BlocBuilder<LocalizationBloc, LocalizationState>(
        builder: (context, state) {
          // Wait for first run check to complete before showing the app
          if (!state.firstRunCheckCompleted) {
            // Show a simple loading screen while checking first run status
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFFFF8A32),
                  ),
                ),
              ),
            );
          }

          return BlocProvider(
            create: (context) =>
                sl<ThemeBloc>()..add(const GetCurrentThemeEvent()),
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, themeState) {
                return BlocProvider(
                  create: (context) => sl<AuthBloc>(),
                  child: BlocProvider(
                    create: (context) => sl<CountdownBloc>(),
                    child: Directionality(
                      textDirection: _getTextDirection(
                        state.currentLanguage.code,
                      ),
                      child: Sizer(
                        builder: (context, orientation, deviceType) {
                          // Determine initial route based on first run status
                          final initialRoute = state.isFirstRun
                              ? AppRoutes.firstRunLanguage
                              : AppRoutes.splash;

                          return MaterialApp(
                            locale: Locale(state.currentLanguage.code),
                            navigatorKey: navigatorKey,
                            debugShowCheckedModeBanner: false,
                            // The title of the recent-apps screen: the app's name in its language
                            onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
                            // Localization configuration
                            localizationsDelegates: const [
                              AppLocalizations.delegate,
                              // Before Flutter's own: a calendar's week
                              // begins on Sunday in every language
                              WeekMaterialLocalizations.delegate,
                              GlobalMaterialLocalizations.delegate,
                              GlobalWidgetsLocalizations.delegate,
                              GlobalCupertinoLocalizations.delegate,
                            ],
                            supportedLocales: const [
                              Locale('en'), // English
                              Locale('ar'), // Arabic
                              Locale('fr'), // French
                            ],
                            // Theme with MaterialTheme
                            theme: MaterialTheme.lightTheme(),
                            darkTheme: MaterialTheme.darkTheme(),
                            themeMode: themeState.currentTheme,
                            // Routes - initial route depends on first run status
                            initialRoute: initialRoute,
                            routes: RouteGenerator.generateRoutes(),
                            onUnknownRoute: RouteGenerator.unknownRoute,
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Helper method to determine text direction based on language
  static TextDirection _getTextDirection(String languageCode) {
    switch (languageCode) {
      case 'ar': // Arabic
        return TextDirection.rtl;
      case 'en': // English
      case 'fr': // French
      default:
        return TextDirection.ltr;
    }
  }
}
