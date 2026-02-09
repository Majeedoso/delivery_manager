import 'package:dio/dio.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/features/profile/data/models/profile_model.dart';
import 'package:delivery_manager/features/profile/data/models/resend_email_change_otp_response_model.dart';
import 'package:delivery_manager/features/profile/data/models/confirm_email_change_response_model.dart';
import 'package:delivery_manager/features/profile/data/models/send_delete_account_otp_response_model.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';

abstract class BaseProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile({
    String? name,
    String? phone,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });
  Future<ResendEmailChangeOtpResponseModel> changeEmail({
    required String newEmail,
    required String currentPassword,
  });
  Future<ConfirmEmailChangeResponseModel> confirmEmailChange({
    required String newEmail,
    required String otp,
  });
  Future<SendDeleteAccountOtpResponseModel> sendDeleteAccountOtp();
  Future<void> verifyDeleteAccountOtpAndDelete({
    required String otp,
  });
}

class ProfileRemoteDataSource implements BaseProfileRemoteDataSource {
  final Dio dio;
  final BaseTokenRepository tokenRepository;
  final LoggingService? _logger;
  
  ProfileRemoteDataSource({
    required this.dio,
    required this.tokenRepository,
    LoggingService? logger,
  }) : _logger = logger;
  
  LoggingService get logger {
    try {
      return _logger ?? sl<LoggingService>();
    } catch (e) {
      return LoggingService();
    }
  }

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final tokenResult = await tokenRepository.getToken();
      final token = tokenResult.fold(
        (failure) => throw ServerException(message: 'Failed to get token: ${failure.message}'),
        (token) => token,
      );
      
      if (token == null || token.isEmpty) {
        throw ServerException(message: 'No authentication token found');
      }
      
      final response = await dio.get(
        ApiConstance.getProfilePath,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      logger.debug('Profile API Response Status: ${response.statusCode}');
      logger.debug('Profile API Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        logger.debug('Profile Data: $data');
        return ProfileModel.fromJson(data);
      } else {
        throw ServerException(message: response.data['message'] ?? 'Failed to get profile');
      }
    } on DioException catch (e) {
      logger.error('Profile API DioException', error: e);
      logger.debug('Profile API DioException Response: ${e.response?.data}');
      logger.debug('Profile API DioException Status Code: ${e.response?.statusCode}');
      
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          throw ServerException(message: 'Authentication failed. Please login again.');
        } else if (e.response!.statusCode == 403) {
          throw ServerException(message: 'Access denied. Only operators can view their profile.');
        }
        throw ServerException(message: e.response!.data['message'] ?? 'Failed to get profile');
      } else {
        // Handle timeout and connection errors
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout || 
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(message: 'Request timeout. Please check your internet connection and try again.');
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(message: 'Cannot connect to server. Please check your internet connection.');
        } else {
          throw ServerException(message: 'Network error: ${e.message}');
        }
      }
    } catch (e) {
      logger.error('Profile API Unexpected Error', error: e);
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final tokenResult = await tokenRepository.getToken();
      final token = tokenResult.fold(
        (failure) => throw ServerException(message: 'Failed to get token: ${failure.message}'),
        (token) => token,
      );
      
      if (token == null || token.isEmpty) {
        throw ServerException(message: 'No authentication token found');
      }
      
      // For restaurant users, we need to update user profile, not restaurant profile
      // Use user_name and user_phone to distinguish from restaurant fields
      final data = <String, dynamic>{};
      if (name != null) data['user_name'] = name;
      if (phone != null) data['user_phone'] = phone;

      final response = await dio.put(
        ApiConstance.updateProfilePath,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      logger.debug('Update Profile API Response Status: ${response.statusCode}');
      logger.debug('Update Profile API Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        logger.debug('Update Profile Data: $data');
        return ProfileModel.fromJson(data);
      } else {
        throw ServerException(message: response.data['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 422) {
          throw ValidationException(message: e.response!.data['error'] ?? 'Validation failed');
        }
        throw ServerException(message: e.response!.data['message'] ?? 'Failed to update profile');
      } else {
        // Handle timeout and connection errors
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout || 
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(message: 'Request timeout. Please check your internet connection and try again.');
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(message: 'Cannot connect to server. Please check your internet connection.');
        } else {
          throw ServerException(message: 'Network error: ${e.message}');
        }
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final tokenResult = await tokenRepository.getToken();
      final token = tokenResult.fold(
        (failure) => throw ServerException(message: 'Failed to get token: ${failure.message}'),
        (token) => token,
      );
      
      if (token == null || token.isEmpty) {
        throw ServerException(message: 'No authentication token found');
      }
      
      final requestData = {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      };
      
      logger.debug('Change Password Request Data: $requestData');
      
      final response = await dio.post(
        ApiConstance.changePasswordPath,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      logger.debug('Change Password API Response Status: ${response.statusCode}');
      logger.debug('Change Password API Response Data: ${response.data}');
      
      if (response.statusCode != 200) {
        throw ServerException(message: response.data['message'] ?? 'Failed to change password');
      }
    } on DioException catch (e) {
      logger.error('Change Password API DioException', error: e);
      logger.debug('Change Password API DioException Response: ${e.response?.data}');
      logger.debug('Change Password API DioException Status Code: ${e.response?.statusCode}');
      
      if (e.response != null) {
        if (e.response!.statusCode == 422) {
          // Handle validation errors
          final errorData = e.response!.data;
          String errorMessage = 'Validation failed';
          
          if (errorData is Map<String, dynamic>) {
            if (errorData.containsKey('errors')) {
              // Laravel validation errors format
              final errors = errorData['errors'] as Map<String, dynamic>;
              final errorMessages = <String>[];
              errors.forEach((field, messages) {
                if (messages is List) {
                  errorMessages.addAll(messages.cast<String>());
                }
              });
              errorMessage = errorMessages.join(', ');
            } else if (errorData.containsKey('message')) {
              errorMessage = errorData['message'].toString();
            }
          }
          
          throw ValidationException(message: errorMessage);
        }
        throw ServerException(message: e.response!.data['message'] ?? 'Failed to change password');
      } else {
        // Handle timeout and connection errors
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout || 
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(message: 'Request timeout. Please check your internet connection and try again.');
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(message: 'Cannot connect to server. Please check your internet connection.');
        } else {
          throw ServerException(message: 'Network error: ${e.message}');
        }
      }
    } catch (e) {
      logger.error('Change Password API Unexpected Error', error: e);
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<ResendEmailChangeOtpResponseModel> changeEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    try {
      final tokenResult = await tokenRepository.getToken();
      final token = tokenResult.fold(
        (failure) => throw ServerException(message: 'Failed to get token: ${failure.message}'),
        (token) => token,
      );
      
      if (token == null || token.isEmpty) {
        throw ServerException(message: 'No authentication token found');
      }
      
      final response = await dio.post(
        ApiConstance.changeEmailPath,
        data: {
          'new_email': newEmail,
          'current_password': currentPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      if (response.statusCode != 200) {
        throw ServerException(message: response.data['message'] ?? 'Failed to change email');
      }

      // Parse and return the response model
      return ResendEmailChangeOtpResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.error('Change Email API DioException', error: e);
      logger.debug('Change Email API DioException Response: ${e.response?.data}');
      logger.debug('Change Email API DioException Status Code: ${e.response?.statusCode}');
      
      if (e.response != null) {
        if (e.response!.statusCode == 422) {
          // Handle validation errors
          final errorData = e.response!.data;
          String errorMessage = 'Validation failed';
          
          if (errorData is Map<String, dynamic>) {
            if (errorData.containsKey('errors')) {
              // Laravel validation errors format
              final errors = errorData['errors'] as Map<String, dynamic>;
              final errorMessages = <String>[];
              errors.forEach((field, messages) {
                if (messages is List) {
                  errorMessages.addAll(messages.cast<String>());
                }
              });
              errorMessage = errorMessages.join(', ');
            } else if (errorData.containsKey('message')) {
              errorMessage = errorData['message'].toString();
            }
          }
          
          throw ValidationException(message: errorMessage);
        }
        throw ServerException(message: e.response!.data['message'] ?? 'Failed to change email');
      } else {
        // Handle timeout and connection errors
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout || 
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(message: 'Request timeout. Please check your internet connection and try again.');
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(message: 'Cannot connect to server. Please check your internet connection.');
        } else {
          throw ServerException(message: 'Network error: ${e.message}');
        }
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<ConfirmEmailChangeResponseModel> confirmEmailChange({
    required String newEmail,
    required String otp,
  }) async {
    try {
      final tokenResult = await tokenRepository.getToken();
      final token = tokenResult.fold(
        (failure) => throw ServerException(message: 'Failed to get token: ${failure.message}'),
        (token) => token,
      );
      
      if (token == null || token.isEmpty) {
        throw ServerException(message: 'No authentication token found');
      }
      
      final response = await dio.post(
        ApiConstance.confirmEmailChangePath,
        data: {
          'new_email': newEmail,
          'otp': otp,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      if (response.statusCode != 200) {
        throw ServerException(message: response.data['message'] ?? 'Failed to confirm email change');
      }

      return ConfirmEmailChangeResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 422) {
          throw ValidationException(message: e.response!.data['error'] ?? 'Validation failed');
        }
        throw ServerException(message: e.response!.data['message'] ?? 'Failed to confirm email change');
      } else {
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout || 
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(message: 'Request timeout. Please check your internet connection and try again.');
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(message: 'Cannot connect to server. Please check your internet connection.');
        } else {
          throw ServerException(message: 'Network error: ${e.message}');
        }
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<SendDeleteAccountOtpResponseModel> sendDeleteAccountOtp() async {
    try {
      final tokenResult = await tokenRepository.getToken();
      final token = tokenResult.fold(
        (failure) => throw ServerException(message: 'Failed to get token: ${failure.message}'),
        (token) => token,
      );
      
      if (token == null || token.isEmpty) {
        throw ServerException(message: 'No authentication token found');
      }
      
      final response = await dio.post(
        ApiConstance.sendDeleteAccountOtpPath,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      logger.debug('Send Delete Account OTP API Response Status: ${response.statusCode}');
      logger.debug('Send Delete Account OTP API Response Data: ${response.data}');
      
      if (response.statusCode != 200) {
        throw ServerException(message: response.data['message'] ?? 'Failed to send delete account OTP');
      }

      return SendDeleteAccountOtpResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.error('Send Delete Account OTP API DioException', error: e);
      logger.debug('Send Delete Account OTP API DioException Response: ${e.response?.data}');
      logger.debug('Send Delete Account OTP API DioException Status Code: ${e.response?.statusCode}');
      
      if (e.response != null) {
        if (e.response!.statusCode == 429) {
          // Rate limiting
          final errorData = e.response!.data;
          throw ServerException(
            message: errorData['message'] ?? 'Please wait before requesting another OTP',
          );
        }
        if (e.response!.statusCode == 401) {
          throw ServerException(message: 'Authentication failed. Please login again.');
        }
        throw ServerException(message: e.response!.data['message'] ?? 'Failed to send delete account OTP');
      } else {
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout || 
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(message: 'Request timeout. Please check your internet connection and try again.');
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(message: 'Cannot connect to server. Please check your internet connection.');
        } else {
          throw ServerException(message: 'Network error: ${e.message}');
        }
      }
    } catch (e) {
      logger.error('Send Delete Account OTP API Unexpected Error', error: e);
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> verifyDeleteAccountOtpAndDelete({
    required String otp,
  }) async {
    try {
      final tokenResult = await tokenRepository.getToken();
      final token = tokenResult.fold(
        (failure) => throw ServerException(message: 'Failed to get token: ${failure.message}'),
        (token) => token,
      );
      
      if (token == null || token.isEmpty) {
        throw ServerException(message: 'No authentication token found');
      }
      
      final response = await dio.post(
        ApiConstance.verifyDeleteAccountOtpPath,
        data: {
          'otp': otp,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      logger.debug('Verify Delete Account OTP API Response Status: ${response.statusCode}');
      logger.debug('Verify Delete Account OTP API Response Data: ${response.data}');
      
      if (response.statusCode != 200) {
        throw ServerException(message: response.data['message'] ?? 'Failed to verify OTP and delete account');
      }
    } on DioException catch (e) {
      logger.error('Verify Delete Account OTP API DioException', error: e);
      logger.debug('Verify Delete Account OTP API DioException Response: ${e.response?.data}');
      logger.debug('Verify Delete Account OTP API DioException Status Code: ${e.response?.statusCode}');
      
      if (e.response != null) {
        if (e.response!.statusCode == 400 || e.response!.statusCode == 422) {
          throw ValidationException(message: e.response!.data['message'] ?? 'Invalid or expired OTP');
        }
        if (e.response!.statusCode == 401) {
          throw ServerException(message: 'Authentication failed. Please login again.');
        }
        throw ServerException(message: e.response!.data['message'] ?? 'Failed to verify OTP and delete account');
      } else {
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout || 
            e.type == DioExceptionType.sendTimeout) {
          throw NetworkException(message: 'Request timeout. Please check your internet connection and try again.');
        } else if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(message: 'Cannot connect to server. Please check your internet connection.');
        } else {
          throw ServerException(message: 'Network error: ${e.message}');
        }
      }
    } catch (e) {
      logger.error('Verify Delete Account OTP API Unexpected Error', error: e);
      if (e is ValidationException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: 'Unexpected error: $e');
    }
  }
}
