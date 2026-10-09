import 'package:equatable/equatable.dart';
import 'package:delivery_manager/core/utils/enums.dart';

/// Represents the state of the splash screen initialization process
/// 
/// This state tracks the progress of app initialization including:
/// - Internet connectivity check
/// - Authentication status check
/// 
/// The state uses [SplashStep] enum to track which initialization step
/// is currently being executed.
class SplashState extends Equatable {
  /// Current state of the initialization request (loading, loaded, error)
  final RequestState requestState;
  
  /// Current step in the initialization process
  final SplashStep currentStep;
  
  /// Localized status message key (to be translated in UI)
  final String statusMessage;
  
  /// Whether device has internet connectivity
  final bool hasInternetConnection;
  
  /// Whether internet connectivity check has completed
  final bool internetCheckCompleted;
  

  
  /// Whether version check has completed
  final bool versionCheckCompleted;
  
  /// Whether app version is supported
  final bool isVersionSupported;
  
  /// Error message if initialization fails
  final String? errorMessage;

  const SplashState({
    this.requestState = RequestState.loaded,
    this.currentStep = SplashStep.initializing,
    this.statusMessage = '',
    this.hasInternetConnection = false,
    this.internetCheckCompleted = false,
    this.versionCheckCompleted = false,
    this.isVersionSupported = true,
    this.errorMessage,
  });

  /// Creates a new SplashState with updated values
  /// 
  /// Only the provided parameters will be updated; others will remain unchanged.
  /// This is used for immutable state updates.
  SplashState copyWith({
    RequestState? requestState,
    SplashStep? currentStep,
    String? statusMessage,
    bool? hasInternetConnection,
    bool? internetCheckCompleted,
    bool? versionCheckCompleted,
    bool? isVersionSupported,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SplashState(
      requestState: requestState ?? this.requestState,
      currentStep: currentStep ?? this.currentStep,
      statusMessage: statusMessage ?? this.statusMessage,
      hasInternetConnection: hasInternetConnection ?? this.hasInternetConnection,
      internetCheckCompleted: internetCheckCompleted ?? this.internetCheckCompleted,
      versionCheckCompleted: versionCheckCompleted ?? this.versionCheckCompleted,
      isVersionSupported: isVersionSupported ?? this.isVersionSupported,
      // clearError: a null errorMessage alone means "keep the current one"
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        requestState,
        currentStep,
        statusMessage,
        hasInternetConnection,
        internetCheckCompleted,
        versionCheckCompleted,
        isVersionSupported,
        errorMessage,
      ];
}

/// Enum representing different steps in the splash screen initialization process
/// 
/// The initialization follows this sequence:
/// 1. [initializing] - Starting initialization
/// 2. [checkingVersion] - Checking app version compatibility
/// 3. [checkingInternet] - Checking internet connectivity
/// 4. [checkingAuthentication] - Checking authentication status
/// 5. [complete] - Initialization complete
/// 
/// Error states:
/// - [versionUpdateRequired] - App version is below minimum required
/// - [noInternet] - No internet connection detected
/// - [error] - General error during initialization
enum SplashStep {
  /// Initial state, starting initialization
  initializing,
  
  /// Checking app version compatibility
  checkingVersion,
  
  /// Checking internet connectivity
  checkingInternet,
  
  
  
  
  /// Checking authentication status with AuthBloc
  checkingAuthentication,
  
  /// Initialization complete
  complete,
  
  /// No internet connection detected
  noInternet,
  
  
  
  /// App version update required
  versionUpdateRequired,
  
  /// General error during initialization
  error,
}

