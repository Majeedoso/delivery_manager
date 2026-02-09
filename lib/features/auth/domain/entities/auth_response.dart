import 'package:equatable/equatable.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';

/// Authentication response entity
/// 
/// This entity represents the response from authentication operations
/// (login, registration, Google Sign-In, etc.).
/// 
/// Contains:
/// - [user]: The authenticated user object
/// - [token]: Authentication token for API requests
/// - [message]: Success or informational message
class AuthResponse extends Equatable {
  final User user;
  final String token;
  final String message;

  const AuthResponse({
    required this.user,
    required this.token,
    required this.message,
  });

  @override
  List<Object> get props => [user, token, message];
}
