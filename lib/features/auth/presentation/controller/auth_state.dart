import 'package:equatable/equatable.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';

/// Represents the state of the authentication system
/// 
/// This state is managed by AuthBloc and contains:
/// - [requestState]: Current state of the authentication request (loading, loaded, error)
/// - [user]: Authenticated user object (null if not authenticated)
/// - [message]: Success or error message from the last operation
/// - [isAuthenticated]: Boolean flag indicating if user is authenticated
/// 
/// The state is immutable and uses the copyWith method for updates.
class AuthState extends Equatable {
  /// Current state of the authentication request
  final RequestState requestState;
  
  /// Authenticated user object, null if not authenticated
  final User? user;
  
  /// Success or error message from the last authentication operation
  final String message;
  
  /// Boolean flag indicating if user is currently authenticated
  final bool isAuthenticated;
  
  /// Resend countdown in seconds for email verification OTP (null if not applicable)
  final int? resendCountdown;

  const AuthState({
    this.requestState = RequestState.loaded,
    this.user,
    this.message = '',
    this.isAuthenticated = false,
    this.resendCountdown,
  });

  /// Creates a new AuthState with updated values
  /// 
  /// Only the provided parameters will be updated; others will remain unchanged.
  /// This is used for immutable state updates.
  AuthState copyWith({
    RequestState? requestState,
    User? user,
    String? message,
    bool? isAuthenticated,
    int? resendCountdown,
  }) {
    return AuthState(
      requestState: requestState ?? this.requestState,
      user: user ?? this.user,
      message: message ?? this.message,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      resendCountdown: resendCountdown ?? this.resendCountdown,
    );
  }

  @override
  List<Object?> get props => [requestState, user, message, isAuthenticated, resendCountdown];
}
