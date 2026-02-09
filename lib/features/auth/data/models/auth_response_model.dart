import 'package:delivery_manager/features/auth/domain/entities/auth_response.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';

/// Data model for AuthResponse entity
/// 
/// Extends the domain [AuthResponse] entity and provides JSON serialization
/// for authentication API responses.
/// 
/// Handles conversion between:
/// - JSON maps (from API responses)
/// - Domain entities (for use in business logic)
/// 
/// The API response structure is:
/// ```json
/// {
///   "data": {
///     "user": { ... },
///     "token": "..."
///   },
///   "message": "..."
/// }
/// ```
class AuthResponseModel extends AuthResponse {
  const AuthResponseModel({
    required super.user,
    required super.token,
    required super.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle the actual API response structure
    final data = json['data'] ?? {};
    return AuthResponseModel(
      user: UserModel.fromJson(data['user'] ?? {}),
      token: data['token']?.toString() ?? '',
      message: json['message']?.toString() ?? 'Success',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': (user as UserModel).toJson(),
      'token': token,
      'message': message,
    };
  }
}
