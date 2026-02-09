import 'package:equatable/equatable.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';

/// Represents the state of the app version check
/// 
/// This state is managed by AppVersionBloc and contains:
/// - [requestState]: Current state of the version check (loading, loaded, error)
/// - [appVersion]: App version information from server (null if not loaded)
/// - [isVersionSupported]: Whether the current app version meets minimum requirements
/// - [message]: Success or error message from the last operation
/// 
/// The state is immutable and uses the copyWith method for updates.
class AppVersionState extends Equatable {
  /// Current state of the version check request
  final RequestState requestState;
  
  /// App version information from server, null if not loaded
  final AppVersion? appVersion;
  
  /// Current version of the app installed on the user's device
  final String? userCurrentVersion;
  
  /// Whether the current app version meets minimum requirements
  final bool isVersionSupported;
  
  /// Success or error message from the last version check operation
  final String message;

  const AppVersionState({
    this.requestState = RequestState.loading,
    this.appVersion,
    this.userCurrentVersion,
    this.isVersionSupported = true, // Default to true, will be updated after check
    this.message = '',
  });

  /// Creates a new AppVersionState with updated values
  /// 
  /// Only the provided parameters will be updated; others will remain unchanged.
  /// This is used for immutable state updates.
  AppVersionState copyWith({
    RequestState? requestState,
    AppVersion? appVersion,
    String? userCurrentVersion,
    bool? isVersionSupported,
    String? message,
  }) {
    return AppVersionState(
      requestState: requestState ?? this.requestState,
      appVersion: appVersion ?? this.appVersion,
      userCurrentVersion: userCurrentVersion ?? this.userCurrentVersion,
      isVersionSupported: isVersionSupported ?? this.isVersionSupported,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        requestState,
        appVersion,
        userCurrentVersion,
        isVersionSupported,
        message,
      ];
}

