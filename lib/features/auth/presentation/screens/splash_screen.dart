import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/services/permission_service.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_state.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/helpers/auth_navigation_helper.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/features/settings/presentation/screens/settings_screen.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_bloc.dart';
import 'package:delivery_manager/features/app_version/presentation/screens/update_required_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';

/// Splash screen for app initialization
///
/// This is the first screen shown when the app starts. It handles:
/// - Internet connectivity check
/// - Notification permission request
/// - Notification service initialization
/// - Authentication status check
///
/// The screen uses SplashBloc to orchestrate initialization and
/// AuthBloc to check authentication status.
///
/// Navigation:
/// - If authenticated: Navigates to MainScreen or AccountStatusScreen based on user status
/// - If not authenticated: Navigates to LoginScreen
///
/// The screen displays:
/// - App logo/image
/// - Status messages (localized)
/// - Loading indicators during initialization
/// - Error messages and retry buttons if initialization fails
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Route name for navigation
  static const String route = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timeoutTimer;
  bool _forceShowRefresh = false;

  @override
  void initState() {
    super.initState();
    // Start initialization when screen is loaded
    context.read<SplashBloc>().add(const InitializeAppEvent());

    // Set a fallback timer to force show refresh button after 30 seconds
    // This ensures the button appears even if the internet check hangs
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _forceShowRefresh = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  /// Handle authentication state changes
  void _handleAuthState(AuthState authState) {
    final logger = sl<LoggingService>();
    logger.debug(
      'SplashScreen: _handleAuthState called - requestState: ${authState.requestState}, isAuthenticated: ${authState.isAuthenticated}, user: ${authState.user?.name}',
    );

    // Only navigate if we're actually in the checking authentication step
    // This prevents navigation from happening when auth state changes for other reasons
    final splashState = context.read<SplashBloc>().state;
    if (splashState.currentStep != SplashStep.checkingAuthentication &&
        splashState.currentStep != SplashStep.complete) {
      logger.debug(
        'SplashScreen: Ignoring auth state change - not in authentication check step',
      );
      return;
    }

    if (authState.requestState == RequestState.loaded) {
      logger.debug(
        'SplashScreen: Auth state is loaded, handling navigation...',
      );
      if (authState.isAuthenticated) {
        // User is authenticated - navigate based on status
        AuthNavigationHelper.navigateBasedOnUserStatus(context, authState.user);
      } else {
        // Not authenticated - go to login
        AuthNavigationHelper.navigateBasedOnUserStatus(context, null);
      }
    } else if (authState.requestState == RequestState.error) {
      // On error, go to login screen
      AuthNavigationHelper.navigateBasedOnUserStatus(context, null);
    }
  }

  /// Get localized status message
  String _getStatusMessage(AppLocalizations localizations, SplashState state) {
    if (!state.internetCheckCompleted) {
      return localizations.checkingInternet;
    }
    if (!state.hasInternetConnection) {
      return localizations.noInternetConnection;
    }
    if (!state.hasNotificationPermission &&
        state.requestState != RequestState.loading) {
      return localizations.notificationsRequired;
    }

    switch (state.statusMessage) {
      case 'initializing':
        return localizations.initializing;
      case 'checkingInternet':
        return localizations.checkingInternet;
      case 'checkingNotifications':
        return localizations.checkingNotifications;
      case 'settingUpNotifications':
        return localizations.settingUpNotifications;
      case 'checkingAuthentication':
        return localizations.checkingAuthentication;
      case 'requestingPermission':
        return localizations.requestingPermission;
      case 'noInternetConnection':
        return localizations.noInternetConnection;
      case 'notificationsRequired':
        return localizations.notificationsRequired;
      case 'initializationFailed':
        return localizations.initializationFailed;
      case 'permissionRequestFailed':
        return localizations.permissionRequestFailed;
      default:
        return localizations.initializing;
    }
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator() {
    return MaterialTheme.getCircularProgressIndicator(context);
  }

  /// Build no internet connection UI
  Widget _buildNoInternetUI(SplashBloc bloc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.wifi_off,
          size: 26.sp,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        SizedBox(height: 3.h),
        Text(
          AppLocalizations.of(context)!.noInternetDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 3.h),
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton(
            onPressed: () {
              // Reset the force show refresh flag and restart timer
              setState(() {
                _forceShowRefresh = false;
              });
              _timeoutTimer?.cancel();
              _timeoutTimer = Timer(const Duration(seconds: 30), () {
                if (mounted) {
                  setState(() {
                    _forceShowRefresh = true;
                  });
                }
              });
              bloc.add(const RetryInitializationEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.green[700]
                  : Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.w),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, color: Colors.white, size: 20.sp),
                SizedBox(width: 2.w),
                Text(
                  AppLocalizations.of(context)!.retry,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build no notification permission UI
  Widget _buildNoPermissionUI(SplashBloc bloc) {
    return Column(
      children: [
        Icon(
          Icons.notifications_off,
          size: 26.sp,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        SizedBox(height: 3.h),
        SizedBox(
          width: double.infinity,
          height: 7.5.h,
          child: ElevatedButton(
            onPressed: () {
              bloc.add(const RequestNotificationPermissionEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.orange[700]
                  : Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.w),
              ),
              elevation: 3,
            ),
            child: Text(
              AppLocalizations.of(context)!.enableNotifications,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// Build main content based on state
  Widget _buildMainContent(
    SplashState state,
    SplashBloc bloc,
    AppLocalizations localizations,
  ) {
    // Check if we're actively checking internet (show loading, not refresh button)
    final bool isActivelyCheckingInternet =
        state.currentStep == SplashStep.checkingInternet &&
        state.requestState == RequestState.loading &&
        !state.internetCheckCompleted;

    // If force show refresh is true, or if we're stuck checking internet for too long, show refresh button
    // But only if we're NOT actively checking (i.e., the check has timed out or is stuck)
    final bool shouldShowRefresh =
        _forceShowRefresh ||
        (!state.internetCheckCompleted &&
            state.currentStep == SplashStep.checkingInternet &&
            !isActivelyCheckingInternet);

    // Check if we're in an error/action state first - these should never show loading
    final bool isInErrorOrActionState =
        state.currentStep == SplashStep.noInternet ||
        state.currentStep == SplashStep.noNotificationPermission ||
        state.currentStep == SplashStep.versionUpdateRequired ||
        state.currentStep == SplashStep.error;

    // Show loading if:
    // 1. We're actively checking internet (transitioning from noInternet to checkingInternet)
    // 2. OR we're NOT in an error/action state AND we're still initializing AND not showing refresh
    final isInitializing =
        isActivelyCheckingInternet ||
        (!isInErrorOrActionState &&
            !shouldShowRefresh &&
            (state.requestState == RequestState.loading ||
                !state.versionCheckCompleted ||
                (!state.internetCheckCompleted &&
                    state.currentStep != SplashStep.checkingInternet) ||
                (state.currentStep != SplashStep.noInternet &&
                    state.currentStep != SplashStep.noNotificationPermission &&
                    state.currentStep != SplashStep.versionUpdateRequired &&
                    state.currentStep != SplashStep.error)));

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50.w,
            height: 50.w,
            child: Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/images/splash_screen_dark_mode.png'
                  : 'assets/images/splash_screen_light_mode.png',
              width: 50.w,
              height: 50.w,
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(height: 3.h),
          // App name
          Text(
            localizations.appName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          // Status message
          Text(
            _getStatusMessage(localizations, state),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          // Loading indicator or action button
          if (isInitializing)
            _buildLoadingIndicator()
          else if (state.currentStep == SplashStep.noInternet ||
              shouldShowRefresh)
            _buildNoInternetUI(bloc)
          else if (state.currentStep == SplashStep.noNotificationPermission)
            _buildNoPermissionUI(bloc),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        final logger = sl<LoggingService>();
        logger.debug(
          'SplashScreen: AuthBloc state changed - requestState: ${authState.requestState}, isAuthenticated: ${authState.isAuthenticated}, user: ${authState.user?.name}',
        );
        _handleAuthState(authState);
      },
      child: BlocConsumer<SplashBloc, SplashState>(
        listener: (context, state) {
          // Reset timer if internet check completed or if we're no longer checking internet
          if (state.internetCheckCompleted ||
              (state.currentStep != SplashStep.checkingInternet &&
                  state.currentStep != SplashStep.initializing)) {
            if (mounted && _forceShowRefresh) {
              setState(() {
                _forceShowRefresh = false;
              });
            }
            _timeoutTimer?.cancel();
          }

          // Handle version update required
          if (state.currentStep == SplashStep.versionUpdateRequired) {
            // Get version info from AppVersionBloc
            final versionBloc = context.read<AppVersionBloc>();
            if (versionBloc.state.appVersion != null) {
              Navigator.pushReplacementNamed(
                context,
                UpdateRequiredScreen.route,
                arguments: {
                  'appVersion': versionBloc.state.appVersion!,
                  'userCurrentVersion':
                      versionBloc.state.userCurrentVersion ?? 'Unknown',
                },
              );
            }
          }
          // Handle permanent permission denial - open settings
          if (state.errorMessage == 'permissionPermanentlyDenied' &&
              state.currentStep == SplashStep.noNotificationPermission) {
            PermissionService().showSettingsDialog(context).then((shouldOpen) {
              if (shouldOpen) {
                PermissionService().openAppSettings();
              }
            });
          }
        },
        builder: (context, state) {
          final localizations = AppLocalizations.of(context);
          if (localizations == null) {
            // Return a simple loading screen if localizations are not available
            return Scaffold(
              body: Center(
                child: MaterialTheme.getCircularProgressIndicator(context),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              //elevation: 0,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, SettingsScreen.route);
                  },
                  icon: Icon(
                    Icons.settings,
                    size: 24.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  tooltip: localizations.settings,
                ),
              ],
            ),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: Theme.of(context).brightness == Brightness.dark
                  ? MaterialTheme.getGradientBackground(context)
                  : const BoxDecoration(color: Color(0xFFFEF8F1)),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: _buildMainContent(
                    state,
                    context.read<SplashBloc>(),
                    localizations,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
