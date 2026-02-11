import 'package:dio/dio.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/features/auth/data/models/auth_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/resend_verification_email_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/resend_password_reset_otp_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/verify_email_otp_response_model.dart';

/// Abstract interface for remote authentication data source
///
/// Defines the contract for authentication API operations:
/// - User registration and login
/// - User logout
/// - FCM token updates
///
/// The implementation is responsible for making HTTP requests to the backend API
/// and handling network-related exceptions.
abstract class BaseAuthRemoteDataSource {
  /// Register a new user via API
  ///
  /// Parameters:
  /// - [name]: User's full name
  /// - [email]: User's email address
  /// - [password]: User's password
  /// - [role]: User's role
  /// - [phone]: User's phone number
  ///
  /// Returns:
  /// - [AuthResponseModel] containing user data and token
  ///
  /// Throws:
  /// - [ServerException] for API errors (validation, duplicate email, etc.)
  /// - [NetworkException] for network errors (timeout, connection failure)
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
  });

  /// Login user via API
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  ///
  /// Returns:
  /// - [AuthResponseModel] containing user data and token
  ///
  /// Throws:
  /// - [ServerException] for API errors (invalid credentials, etc.)
  /// - [NetworkException] for network errors (timeout, connection failure)
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  /// Logout user via API
  ///
  /// Throws:
  /// - [ServerException] for API errors
  /// - [NetworkException] for network errors
  Future<void> logout();

  /// Update FCM token on server
  ///
  /// Parameters:
  /// - [fcmToken]: Firebase Cloud Messaging token
  ///
  /// Throws:
  /// - [ServerException] for API errors
  /// - [NetworkException] for network errors
  Future<void> updateFcmToken(String fcmToken);

  /// Resend email verification OTP
  ///
  /// Returns:
  /// - [ResendVerificationEmailResponseModel] with email, expiresIn, and resendCountdown
  ///
  /// Throws:
  /// - [ServerException] for API errors (e.g., email already verified, rate limit)
  /// - [NetworkException] for network errors
  Future<ResendVerificationEmailResponseModel> resendVerificationEmail();

  /// Resend password reset OTP (from login page)
  ///
  /// Parameters:
  /// - [email]: The email address to send the password reset OTP to
  ///
  /// Returns:
  /// - [ResendPasswordResetOtpResponseModel] with email, expiresIn, and resendCountdown
  ///
  /// Throws:
  /// - [ServerException] for API errors (e.g., email not found, rate limit)
  /// - [NetworkException] for network errors
  Future<ResendPasswordResetOtpResponseModel> resendPasswordResetOtp(
    String email,
  );

  /// Send password reset OTP (authenticated users)
  ///
  /// Sends a password reset OTP to the authenticated user's email.
  /// No email parameter is required as it uses the authenticated user's email.
  ///
  /// Returns:
  /// - [ResendPasswordResetOtpResponseModel] with email, expiresIn, and resendCountdown
  ///
  /// Throws:
  /// - [ServerException] for API errors (e.g., rate limit)
  /// - [NetworkException] for network errors
  Future<ResendPasswordResetOtpResponseModel>
  sendPasswordResetOtpAuthenticated();

  /// Verify email OTP
  ///
  /// Parameters:
  /// - [email]: The email address to verify
  /// - [otp]: The 6-digit OTP code
  ///
  /// Returns:
  /// - [VerifyEmailOtpResponseModel] with updated user and message
  ///
  /// Throws:
  /// - [ServerException] for API errors (e.g., invalid OTP, expired OTP)
  /// - [NetworkException] for network errors
  Future<VerifyEmailOtpResponseModel> verifyEmailOtp({
    required String email,
    required String otp,
  });

  /// Verify password reset OTP (from login page)
  ///
  /// Parameters:
  /// - [email]: The email address
  /// - [otp]: The 6-digit OTP code
  ///
  /// Returns:
  /// - [void] if OTP is valid
  ///
  /// Throws:
  /// - [ServerException] for API errors (e.g., invalid OTP, expired OTP)
  /// - [NetworkException] for network errors
  Future<void> verifyPasswordResetOtp({
    required String email,
    required String otp,
  });

  /// Reset password (from login page)
  ///
  /// Parameters:
  /// - [email]: The email address
  /// - [otp]: The 6-digit OTP code
  /// - [password]: The new password
  /// - [passwordConfirmation]: The password confirmation
  ///
  /// Returns:
  /// - [String] success message
  ///
  /// Throws:
  /// - [ServerException] for API errors (e.g., invalid OTP, password validation)
  /// - [NetworkException] for network errors
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });

  /// Verify password reset OTP (authenticated users)
  ///
  /// Parameters:
  /// - [otp]: The 6-digit OTP code
  ///
  /// Returns:
  /// - [void] if OTP is valid
  ///
  /// Throws:
  /// - [ServerException] for API errors (e.g., invalid OTP, expired OTP)
  /// - [NetworkException] for network errors
  Future<void> verifyPasswordResetOtpAuthenticated({required String otp});

  /// Reset password (authenticated users)
  ///
  /// Parameters:
  /// - [otp]: The 6-digit OTP code
  /// - [newPassword]: The new password
  /// - [newPasswordConfirmation]: The password confirmation
  ///
  /// Returns:
  /// - [String] success message
  ///
  /// Throws:
  /// - [ServerException] for API errors (e.g., invalid OTP, password validation)
  /// - [NetworkException] for network errors
  Future<String> resetPasswordAuthenticated({
    required String otp,
    required String newPassword,
    required String newPasswordConfirmation,
  });
}

/// Implementation of [BaseAuthRemoteDataSource]
///
/// Makes HTTP requests to the backend authentication API using Dio.
/// Handles error conversion from DioException to custom exceptions.
class AuthRemoteDataSource extends BaseAuthRemoteDataSource {
  /// Dio instance for making HTTP requests
  final Dio dio;

  AuthRemoteDataSource({required this.dio}) {
    // Add interceptor for Bearer token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from local storage if available
          // For now, we'll handle this in the repository
          handler.next(options);
        },
      ),
    );
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
  }) async {
    try {
      final requestData = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
        'phone': phone,
        'app_type': 'manager', // Validate that role matches manager app
      };

      final response = await dio.post(
        ApiConstance.registerPath,
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          message:
              response.data?['message']?.toString() ?? 'Registration failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMessage = 'Registration failed';

        if (errorData is Map<String, dynamic>) {
          errorMessage =
              errorData['message']?.toString() ??
              errorData['error']?.toString() ??
              'Registration failed';
        }

        throw ServerException(message: errorMessage);
      } else {
        // Handle timeout and connection errors
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(
            message:
                'Request timeout. Please check your internet connection and try again.',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(
            message:
                'Cannot connect to server. Please check your internet connection.',
          );
        } else {
          throw NetworkException(
            message: 'Network error occurred: ${e.message}',
          );
        }
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstance.loginPath,
        data: {
          'email': email,
          'password': password,
          'app_type': 'manager', // Validate that user role matches manager app
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data?['message']?.toString() ?? 'Login failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMessage = 'Login failed';

        if (errorData is Map<String, dynamic>) {
          errorMessage =
              errorData['message']?.toString() ??
              errorData['error']?.toString() ??
              'Login failed';
        }

        throw ServerException(message: errorMessage);
      } else {
        // Handle timeout and connection errors
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(
            message:
                'Request timeout. Please check your internet connection and try again.',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(
            message:
                'Cannot connect to server. Please check your internet connection.',
          );
        } else {
          throw NetworkException(
            message: 'Network error occurred: ${e.message}',
          );
        }
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await dio.post(
        ApiConstance.logoutPath,
        options: Options(
          headers: {'Authorization': 'Bearer ${await _getToken()}'},
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Logout failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Logout failed',
        );
      } else {
        // Handle timeout and connection errors
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(
            message:
                'Request timeout. Please check your internet connection and try again.',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(
            message:
                'Cannot connect to server. Please check your internet connection.',
          );
        } else {
          throw NetworkException(
            message: 'Network error occurred: ${e.message}',
          );
        }
      }
    }
  }

  @override
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      final response = await dio.post(
        ApiConstance.updateFcmTokenEndpoint,
        data: {'fcm_token': fcmToken},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update FCM token',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Failed to update FCM token',
        );
      } else {
        // Handle timeout and connection errors
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(
            message:
                'Request timeout. Please check your internet connection and try again.',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(
            message:
                'Cannot connect to server. Please check your internet connection.',
          );
        } else {
          throw NetworkException(
            message: 'Network error occurred: ${e.message}',
          );
        }
      }
    }
  }

  @override
  Future<ResendVerificationEmailResponseModel> resendVerificationEmail() async {
    try {
      final response = await dio.post(
        ApiConstance.resendVerificationEmailPath,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to resend verification email',
        );
      }

      // Parse and return the response model
      return ResendVerificationEmailResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMessage = 'Failed to resend verification email';

        if (errorData is Map<String, dynamic>) {
          errorMessage =
              errorData['message']?.toString() ??
              errorData['error']?.toString() ??
              'Failed to resend verification email';
        }

        throw ServerException(message: errorMessage);
      } else {
        // Handle timeout and connection errors
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(
            message:
                'Request timeout. Please check your internet connection and try again.',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(
            message:
                'Cannot connect to server. Please check your internet connection.',
          );
        } else {
          throw NetworkException(
            message: 'Network error occurred: ${e.message}',
          );
        }
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<ResendPasswordResetOtpResponseModel> resendPasswordResetOtp(
    String email,
  ) async {
    try {
      final response = await dio.post(
        ApiConstance.forgotPasswordPath,
        data: {'email': email},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to send password reset OTP',
        );
      }

      // Parse and return the response model
      return ResendPasswordResetOtpResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMessage = 'Failed to send password reset OTP';

        if (errorData is Map<String, dynamic>) {
          errorMessage =
              errorData['message']?.toString() ??
              errorData['error']?.toString() ??
              'Failed to send password reset OTP';
        }

        throw ServerException(message: errorMessage);
      } else {
        // Handle timeout and connection errors
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(
            message:
                'Request timeout. Please check your internet connection and try again.',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(
            message:
                'Cannot connect to server. Please check your internet connection.',
          );
        } else {
          throw NetworkException(
            message: 'Network error occurred: ${e.message}',
          );
        }
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<ResendPasswordResetOtpResponseModel>
  sendPasswordResetOtpAuthenticated() async {
    try {
      final response = await dio.post(
        ApiConstance.sendPasswordResetOtpPath,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to send password reset OTP',
        );
      }

      return ResendPasswordResetOtpResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMessage = 'Failed to send password reset OTP';

        if (errorData is Map<String, dynamic>) {
          errorMessage =
              errorData['message']?.toString() ??
              errorData['error']?.toString() ??
              'Failed to send password reset OTP';
        }

        throw ServerException(message: errorMessage);
      } else {
        // Handle timeout and connection errors
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(
            message:
                'Request timeout. Please check your internet connection and try again.',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(
            message:
                'Cannot connect to server. Please check your internet connection.',
          );
        } else {
          throw NetworkException(
            message: 'Network error occurred: ${e.message}',
          );
        }
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<VerifyEmailOtpResponseModel> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        ApiConstance.verifyEmailOtpPath,
        data: {'email': email, 'otp': otp},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to verify email OTP',
        );
      }

      // Note: Token will be preserved in repository layer
      return VerifyEmailOtpResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMessage = 'Failed to verify email OTP';

        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? errorMessage;
        }

        throw ServerException(message: errorMessage);
      } else {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(
            message:
                'Request timeout. Please check your internet connection and try again.',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(
            message:
                'Cannot connect to server. Please check your internet connection.',
          );
        } else {
          throw NetworkException(
            message: 'Network error occurred: ${e.message}',
          );
        }
      }
    }
  }

  @override
  Future<void> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        ApiConstance.verifyOtpPath,
        data: {'email': email, 'otp': otp},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to verify password reset OTP',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMessage = 'Failed to verify password reset OTP';

        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? errorMessage;
        }

        throw ServerException(message: errorMessage);
      } else {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(
            message:
                'Request timeout. Please check your internet connection and try again.',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(
            message:
                'Cannot connect to server. Please check your internet connection.',
          );
        } else {
          throw NetworkException(
            message: 'Network error occurred: ${e.message}',
          );
        }
      }
    }
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await dio.post(
        ApiConstance.resetPasswordPath,
        data: {
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to reset password',
        );
      }

      return response.data['message'] ?? 'Password reset successfully';
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMessage = 'Failed to reset password';

        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? errorMessage;
        }

        throw ServerException(message: errorMessage);
      } else {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(
            message:
                'Request timeout. Please check your internet connection and try again.',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(
            message:
                'Cannot connect to server. Please check your internet connection.',
          );
        } else {
          throw NetworkException(
            message: 'Network error occurred: ${e.message}',
          );
        }
      }
    }
  }

  @override
  Future<void> verifyPasswordResetOtpAuthenticated({
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        ApiConstance.verifyPasswordResetOtpOnlyPath,
        data: {'otp': otp},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to verify password reset OTP',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMessage = 'Failed to verify password reset OTP';

        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? errorMessage;
        }

        throw ServerException(message: errorMessage);
      } else {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(
            message:
                'Request timeout. Please check your internet connection and try again.',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(
            message:
                'Cannot connect to server. Please check your internet connection.',
          );
        } else {
          throw NetworkException(
            message: 'Network error occurred: ${e.message}',
          );
        }
      }
    }
  }

  @override
  Future<String> resetPasswordAuthenticated({
    required String otp,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await dio.post(
        ApiConstance.verifyPasswordResetOtpPath,
        data: {
          'otp': otp,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to reset password',
        );
      }

      return response.data['message'] ?? 'Password reset successfully';
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMessage = 'Failed to reset password';

        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? errorMessage;
        }

        throw ServerException(message: errorMessage);
      } else {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(
            message:
                'Request timeout. Please check your internet connection and try again.',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(
            message:
                'Cannot connect to server. Please check your internet connection.',
          );
        } else {
          throw NetworkException(
            message: 'Network error occurred: ${e.message}',
          );
        }
      }
    }
  }

  Future<String?> _getToken() async {
    // This should be injected or retrieved from local storage
    // For now, return null - the repository will handle token management
    return null;
  }
}
