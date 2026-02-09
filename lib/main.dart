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
import 'package:device_preview/device_preview.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
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
import 'package:delivery_manager/features/localization/presentation/controller/localization_bloc.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_event.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_state.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
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

// Global navigator key for notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize App Config (Environment Variables)
  await AppConfig.load();

  // Track initialization errors
  String? initializationError;

  try {
    // Initialize Firebase
    if (kDebugMode) {
      _initLogger.i('Main: Initializing Firebase...');
    }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(AppTimeouts.firebaseInit);
    if (kDebugMode) {
      _initLogger.i('Main: Firebase initialized successfully');
    }

    // Initialize crash reporting after Firebase is ready
    try {
      await CrashReportingService.initialize();
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
    _showErrorScreen(initializationError);
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
      await CrashReportingService.recordError(
        e,
        stackTrace,
        reason: 'Firebase initialization failed',
      );
    } catch (_) {
      // Ignore crash reporting errors
    }
    initializationError = 'Firebase initialization failed: ${e.toString()}';
    _showErrorScreen(initializationError);
    return;
  }

  try {
    // Initialize service locator
    if (kDebugMode) {
      _initLogger.i('Main: Initializing service locator...');
    }
    await ServicesLocator().init().timeout(AppTimeouts.serviceLocatorInit);
    if (kDebugMode) {
      _initLogger.i('Main: Service locator initialized successfully');
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      _initLogger.w('Main: Service locator initialization timed out: $e');
    }
    initializationError =
        'Service locator initialization timed out after ${AppTimeouts.serviceLocatorInit.inSeconds} seconds';
    _showErrorScreen(initializationError);
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
      await CrashReportingService.recordError(
        e,
        stackTrace,
        reason: 'Service locator initialization failed',
      );
    } catch (_) {
      // Ignore crash reporting errors
    }
    initializationError = 'Service initialization failed: ${e.toString()}';
    _showErrorScreen(initializationError);
    return;
  }

  try {
    // Initialize theme service
    if (kDebugMode) {
      _initLogger.i('Main: Initializing theme service...');
    }
    // ThemeService.init() is no longer needed - ThemeBloc handles initialization
    if (kDebugMode) {
      _initLogger.i('Main: Theme service initialized successfully');
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      _initLogger.w('Main: Theme service initialization timed out: $e');
      _initLogger.i('Main: Continuing with default theme...');
    }
    // Theme service failure is not critical, continue with default theme
  } catch (e, stackTrace) {
    if (kDebugMode) {
      _initLogger.e(
        'Main: Theme service initialization failed: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _initLogger.i('Main: Continuing with default theme...');
    }
    // Theme service failure is not critical, continue with default theme
  }

  try {
    // Initialize notification service (non-critical)
    if (kDebugMode) {
      _initLogger.i('Main: Starting notification service initialization...');
    }
    await NotificationService.initialize().timeout(
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
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
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
  // Enable device preview only in debug mode
  runApp(
    DevicePreview(
      enabled: false, // kDebugMode,
      builder: (context) => const MyApp(),
    ),
  );
}

/// Shows error screen when initialization fails
void _showErrorScreen(String errorMessage) {
  runApp(
    InitializationErrorScreen(
      errorMessage: errorMessage,
      onRetry: () {
        // Restart the app by calling main again
        main();
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
                  child: CircularProgressIndicator(color: Colors.orange),
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
                            // Use DevicePreview locale if enabled, otherwise use app locale
                            locale:
                                DevicePreview.locale(context) ??
                                Locale(state.currentLanguage.code),
                            builder: DevicePreview.appBuilder,
                            navigatorKey: navigatorKey,
                            debugShowCheckedModeBanner: false,
                            // Localization configuration
                            localizationsDelegates: const [
                              AppLocalizations.delegate,
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
