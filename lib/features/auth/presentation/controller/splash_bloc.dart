import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/utils/app_timeouts.dart';
import 'package:delivery_manager/core/services/connectivity_service.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_state.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_bloc.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_event.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';

/// Business Logic Component (BLoC) for managing splash screen initialization
///
/// This BLoC orchestrates the app initialization sequence:
/// 1. Check internet connectivity (required)
/// 2. Check the app's version
/// 3. Check authentication status (via AuthBloc)
///
/// It asks for no notification permission: the server sends a manager
/// nothing (decision 1 of manager_suite_report.md)
///
/// The BLoC ensures all prerequisites are met before allowing the app
/// to proceed to the main screens. If any required step fails, it displays
/// appropriate error messages and allows retry.
///
/// Key features:
/// - Sequential initialization with clear error states
/// - Retry mechanism for failed steps
/// - Integration with AuthBloc for authentication checks
/// - Optimized timeouts to prevent hanging
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  /// Reference to AuthBloc for checking authentication status
  ///
  /// This is provided from the widget tree context in main.dart
  /// It's nullable because it may not be available immediately
  final AuthBloc? authBloc;

  /// Reference to AppVersionBloc for checking app version
  ///
  /// This is provided from the widget tree context in main.dart
  /// It's nullable because it may not be available immediately
  final AppVersionBloc? appVersionBloc;

  /// Logging service for centralized logging
  final LoggingService _logger;

  /// Checks for a working internet connection (injected so tests don't use DNS)
  final Future<bool> Function() _hasInternetConnection;

  /// Creates an instance of SplashBloc
  ///
  /// [authBloc] is injected from the widget tree context
  /// and used to check authentication status during initialization
  /// [appVersionBloc] is injected to check app version compatibility
  /// [connectivityCheck] defaults to [ConnectivityService.hasInternetConnection]
  /// [logger] is optional - if not provided, will use service locator
  SplashBloc({
    this.authBloc,
    this.appVersionBloc,
    Future<bool> Function()? connectivityCheck,
    LoggingService? logger,
  }) : _logger = logger ?? sl<LoggingService>(),
       _hasInternetConnection =
           connectivityCheck ?? ConnectivityService.hasInternetConnection,
       super(SplashState()) {
    // Register event handlers
    on<InitializeAppEvent>(_initializeApp);
    on<CheckInternetConnectionEvent>(_checkInternetConnection);
    on<RetryInitializationEvent>(_retryInitialization);
  }

  /// Handles app initialization event
  ///
  /// Process:
  /// 1. Reset all state to initial values
  /// 2. Wait briefly for localization to initialize
  /// 3. Start internet connection check
  FutureOr<void> _initializeApp(
    InitializeAppEvent event,
    Emitter<SplashState> emit,
  ) async {
    _logger.debug('SplashBloc: Starting app initialization...');

    // Reset state
    emit(state.copyWith(
      requestState: RequestState.loading,
      currentStep: SplashStep.initializing,
      statusMessage: '',
      hasInternetConnection: false,
      internetCheckCompleted: false,
      versionCheckCompleted: false,
      isVersionSupported: true,
      clearError: true,
    ));

    // Give localization time to initialize
    await Future.delayed(const Duration(milliseconds: 100));

    // Step 0: Check internet connection first (version check needs internet)
    add(const CheckInternetConnectionEvent());
  }

  /// Checks app version compatibility
  ///
  /// Process:
  /// 1. Update state to checkingVersion
  /// 2. Call AppVersionBloc to check version
  /// 3. If version not supported: emit error state with versionUpdateRequired step
  /// 4. If version supported: proceed to notification permission check
  ///
  /// Note: If version check fails (network error), we allow app to continue
  ///
  /// Fixed race condition: Checks current state first before waiting for stream changes
  Future<void> _checkAppVersion(Emitter<SplashState> emit) async {
    _logger.debug('SplashBloc: Checking app version...');
    emit(state.copyWith(
      currentStep: SplashStep.checkingVersion,
      statusMessage: 'checkingVersion',
      versionCheckCompleted: false,
    ));

    if (appVersionBloc != null) {
      try {
        _logger.debug('SplashBloc: AppVersionBloc is available, triggering version check...');

        // Fix race condition: Check current state first
        var currentState = appVersionBloc!.state;
        _logger.debug('SplashBloc: Initial AppVersionBloc state - requestState: ${currentState.requestState}');

        // If already in loaded state with data, use it immediately
        if (currentState.requestState == RequestState.loaded &&
            (currentState.appVersion != null || currentState.message.isNotEmpty)) {
          _logger.debug('SplashBloc: Version check already completed, using current state');
          emit(state.copyWith(
            versionCheckCompleted: true,
            isVersionSupported: currentState.isVersionSupported,
          ));

          if (!currentState.isVersionSupported) {
            emit(state.copyWith(
              requestState: RequestState.error,
              currentStep: SplashStep.versionUpdateRequired,
              statusMessage: 'versionUpdateRequired',
            ));
            return;
          }

          // Version is supported: the account
          await _checkAuthentication(emit);
          return;
        }

        // Trigger version check if not already loaded
        appVersionBloc!.add(const CheckAppVersionEvent());
        _logger.debug('SplashBloc: CheckAppVersionEvent added to AppVersionBloc');
        
        // Wait for version check to complete (with timeout)
        _logger.debug('SplashBloc: Waiting for AppVersionBloc to emit loaded state...');
        
        final versionState = await appVersionBloc!.stream.firstWhere(
          (state) {
            _logger.debug('SplashBloc: Received AppVersionBloc state - requestState: ${state.requestState}, isVersionSupported: ${state.isVersionSupported}, hasAppVersion: ${state.appVersion != null}');
            // Wait for loaded state AND make sure we got version data (not just initial state)
            return state.requestState == RequestState.loaded && 
                   (state.appVersion != null || state.message.isNotEmpty);
          },
        ).timeout(
          AppTimeouts.versionCheck,
          onTimeout: () {
            _logger.debug('SplashBloc: Version check timed out after ${AppTimeouts.versionCheck.inSeconds} seconds, current state: ${appVersionBloc!.state.requestState}');
            // If timeout, check if we have any state
            final timeoutState = appVersionBloc!.state;
            if (timeoutState.requestState == RequestState.loaded && timeoutState.appVersion != null) {
              return timeoutState;
            }
            // If no valid state, return current and allow app to continue
            return timeoutState;
          },
        );

        _logger.info('SplashBloc: Version check completed. Final state - Supported: ${versionState.isVersionSupported}, Message: ${versionState.message}');

        emit(state.copyWith(
          versionCheckCompleted: true,
          isVersionSupported: versionState.isVersionSupported,
        ));

        if (!versionState.isVersionSupported) {
          emit(state.copyWith(
            requestState: RequestState.error,
            currentStep: SplashStep.versionUpdateRequired,
            statusMessage: 'versionUpdateRequired',
          ));
          return;
        }

        // Version is supported: the account
        await _checkAuthentication(emit);
      } catch (e) {
        _logger.debug('SplashBloc: Error checking version', e);
        // On error, allow app to continue (don't block on version check failures)
        emit(state.copyWith(
          versionCheckCompleted: true,
          isVersionSupported: true, // Allow app to continue
        ));
        await _checkAuthentication(emit);
      }
    } else {
      _logger.debug('SplashBloc: AppVersionBloc is null, skipping version check');
      // If AppVersionBloc not available, continue without version check
      emit(state.copyWith(
        versionCheckCompleted: true,
        isVersionSupported: true,
      ));
      await _checkAuthentication(emit);
    }
  }

  /// Handles internet connection check event
  ///
  /// Process:
  /// 1. Update state to checkingInternet
  /// 2. Call ConnectivityService with 15-second timeout
  /// 3. If no internet: emit error state with noInternet step
  /// 4. If internet available: proceed to notification permission check
  ///
  /// Uses ConnectivityService which has its own retry logic (2 attempts, 6s each)
  FutureOr<void> _checkInternetConnection(
    CheckInternetConnectionEvent event,
    Emitter<SplashState> emit,
  ) async {
    _logger.debug('SplashBloc: Checking internet connection...');
    emit(state.copyWith(
      requestState: RequestState.loading, // Ensure loading state is set
      currentStep: SplashStep.checkingInternet,
      statusMessage: 'checkingInternet', // Will be localized in UI
      internetCheckCompleted: false,
    ));

    bool internetCheckResult = false;
    try {
      // Connectivity service has its own timeout and retry logic
      // Give it enough time for retries (10s per attempt x 2 attempts + overhead)
      internetCheckResult = await _hasInternetConnection()
          .timeout(
            AppTimeouts.internetCheck,
            onTimeout: () {
              _logger.debug('SplashBloc: Internet check timed out after ${AppTimeouts.internetCheck.inSeconds} seconds');
              return false;
            },
          );
      _logger.info('SplashBloc: Internet connection check completed. Result: $internetCheckResult');
    } catch (e) {
      _logger.debug('SplashBloc: Error checking internet connection', e);
      internetCheckResult = false;
    } finally {
      // Always mark as completed, even if there was an error or timeout
      // This ensures the refresh button appears even if the check hangs
      emit(state.copyWith(
        hasInternetConnection: internetCheckResult,
        internetCheckCompleted: true,
      ));

      if (!internetCheckResult) {
        emit(state.copyWith(
          requestState: RequestState.error,
          currentStep: SplashStep.noInternet,
          statusMessage: 'noInternetConnection',
        ));
        return;
      }
    }

    // Step 1: Check app version (after internet check since API needs internet).
    // It continues into the auth check by itself
    // (or stops on a required update), so nothing follows here.
    await _checkAppVersion(emit);
  }

  /// Checks authentication status using AuthBloc
  ///
  /// Process:
  /// 1. Update state to checkingAuthentication
  /// 2. Dispatch CheckAuthStatusEvent to AuthBloc
  /// 3. Wait for AuthBloc to emit state change
  /// 4. Navigation is handled by SplashScreen listening to AuthBloc
  ///
  /// Note: This method doesn't wait for AuthBloc response directly.
  /// Instead, the SplashScreen widget listens to AuthBloc state changes
  /// and navigates accordingly.
  Future<void> _checkAuthentication(Emitter<SplashState> emit) async {
    _logger.debug('SplashBloc: Checking authentication status...');
    emit(state.copyWith(
      currentStep: SplashStep.checkingAuthentication,
      statusMessage: 'checkingAuthentication',
    ));

    // Trigger auth check using the provided AuthBloc instance
    // The AuthBloc should be provided from the widget tree context
    if (authBloc != null) {
      _logger.debug('SplashBloc: Adding CheckAuthStatusEvent to AuthBloc');
      authBloc!.add(CheckAuthStatusEvent());
      _logger.debug('SplashBloc: CheckAuthStatusEvent added, waiting for AuthBloc response...');
    } else {
      _logger.error('SplashBloc: ERROR - AuthBloc is null!');
      emit(state.copyWith(
        requestState: RequestState.error,
        currentStep: SplashStep.error,
        statusMessage: 'initializationFailed',
        errorMessage: 'AuthBloc not available',
      ));
    }

    // Keep the state as checkingAuthentication until AuthBloc responds
    // Don't mark as complete here - let the navigation happen via AuthBloc listener
  }

  /// Handles retry initialization event
  ///
  /// Simply restarts the initialization process by dispatching InitializeAppEvent
  /// This allows users to retry after fixing issues (e.g., connecting to internet)
  FutureOr<void> _retryInitialization(
    RetryInitializationEvent event,
    Emitter<SplashState> emit,
  ) async {
    _logger.info('SplashBloc: Retrying initialization...');
    add(const InitializeAppEvent());
  }
}

