import 'package:equatable/equatable.dart';

/// Base class for all splash screen initialization events
/// 
/// This abstract class extends Equatable to enable state comparison
/// and is used as the event type for the SplashBloc.
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered to start the app initialization process
/// 
/// This is the first event dispatched when the splash screen loads.
/// It resets the splash state and begins the initialization sequence:
/// 1. Check internet connection
/// 2. Check notification permissions
/// 3. Initialize notification service
/// 4. Check authentication status
class InitializeAppEvent extends SplashEvent {
  const InitializeAppEvent();
}

/// Event triggered to check internet connectivity
/// 
/// This is the first step in the initialization process.
/// Uses ConnectivityService to verify actual internet access,
/// not just network interface availability.
class CheckInternetConnectionEvent extends SplashEvent {
  const CheckInternetConnectionEvent();
}

/// Event triggered to request notification permission from the user
/// 
/// Used when notification permission is not granted.
/// Opens the system permission dialog for notifications.
class RequestNotificationPermissionEvent extends SplashEvent {
  const RequestNotificationPermissionEvent();
}

/// Event triggered when user wants to retry the initialization process
/// 
/// Used when initialization fails (e.g., no internet connection).
/// Restarts the entire initialization sequence from the beginning.
class RetryInitializationEvent extends SplashEvent {
  const RetryInitializationEvent();
}

