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

  /// The request options with the stored token.
  Future<Options> _authorized() async {
    final tokenResult = await tokenRepository.getToken();
    final token = tokenResult.fold(
      (failure) => throw ServerException(
        message: 'Failed to get token: ${failure.message}',
      ),
      (token) => token,
    );

    if (token == null || token.isEmpty) {
      throw const ServerException(message: 'No authentication token found');
    }

    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  /// Laravel's validation errors (every field's messages), else its message.
  static String? _validationMessage(Object? body) {
    if (body is! Map) return null;
    final errors = body['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final messages = [
        for (final messages in errors.values)
          if (messages is List)
            for (final message in messages)
              if (message is String) message,
      ];
      if (messages.isNotEmpty) return messages.join(', ');
    }
    final message = body['message'];
    return message is String ? message : null;
  }

  /// What a failed request means for the driver. Only a JSON body has a
  /// message (an HTML error page raised a TypeError here); [validationCodes]
  /// answer with the field errors (the server's reason used to be replaced
  /// by "Validation failed").
  static Exception _failure(
    DioException e,
    String fallback, {
    Set<int> validationCodes = const {422},
    String validationFallback = 'Validation failed',
  }) {
    final response = e.response;
    if (response != null) {
      final body = response.data;
      final message = body is Map && body['message'] is String
          ? body['message'] as String
          : null;
      if (response.statusCode == 401) {
        return const ServerException(
          message: 'Authentication failed. Please login again.',
        );
      }
      if (validationCodes.contains(response.statusCode)) {
        return ValidationException(
          message: _validationMessage(body) ?? validationFallback,
        );
      }
      if (response.statusCode == 429) {
        return ServerException(
          message: message ?? 'Please wait before requesting another OTP',
        );
      }
      return ServerException(message: message ?? fallback);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException(
          message:
              'Request timeout. Please check your internet connection and try again.',
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          message:
              'Cannot connect to server. Please check your internet connection.',
        );
      default:
        return ServerException(message: 'Network error: ${e.message}');
    }
  }

  /// The data source's own exceptions pass through; anything else (an
  /// answer that can't be read) becomes a server error. They used to be
  /// wrapped too: "Unexpected error: Instance of 'ServerException'".
  static Exception _unexpected(Object e) {
    if (e is ServerException ||
        e is NetworkException ||
        e is ValidationException) {
      return e as Exception;
    }
    return ServerException(message: 'Unexpected error: $e');
  }

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await dio.get(
        ApiConstance.getProfilePath,
        options: await _authorized(),
      );
      
      logger.debug('Profile API Response Status: ${response.statusCode}');
      return ProfileModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      logger.error('Profile API DioException', error: e);
      throw _failure(e, 'Failed to get profile');
    } catch (e) {
      logger.error('Profile API Unexpected Error', error: e);
      throw _unexpected(e);
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;

      final response = await dio.put(
        ApiConstance.updateProfilePath,
        data: data,
        options: await _authorized(),
      );
      
      logger.debug('Update Profile API Response Status: ${response.statusCode}');
      // The answer has no role and no dates: the profile is read again
      return await getProfile();
    } on DioException catch (e) {
      throw _failure(e, 'Failed to update profile');
    } catch (e) {
      throw _unexpected(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      // The passwords are never logged
      await dio.post(
        ApiConstance.changePasswordPath,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
        options: await _authorized(),
      );
    } on DioException catch (e) {
      logger.error('Change Password API DioException', error: e);
      throw _failure(e, 'Failed to change password');
    } catch (e) {
      logger.error('Change Password API Unexpected Error', error: e);
      throw _unexpected(e);
    }
  }

  @override
  Future<ResendEmailChangeOtpResponseModel> changeEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    try {
      final response = await dio.post(
        ApiConstance.changeEmailPath,
        data: {
          'new_email': newEmail,
          'current_password': currentPassword,
        },
        options: await _authorized(),
      );
      return ResendEmailChangeOtpResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.error('Change Email API DioException', error: e);
      throw _failure(e, 'Failed to change email');
    } catch (e) {
      throw _unexpected(e);
    }
  }

  @override
  Future<ConfirmEmailChangeResponseModel> confirmEmailChange({
    required String newEmail,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        ApiConstance.confirmEmailChangePath,
        data: {
          'new_email': newEmail,
          'otp': otp,
        },
        options: await _authorized(),
      );

      return ConfirmEmailChangeResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _failure(e, 'Failed to confirm email change');
    } catch (e) {
      throw _unexpected(e);
    }
  }

  @override
  Future<SendDeleteAccountOtpResponseModel> sendDeleteAccountOtp() async {
    try {
      final response = await dio.post(
        ApiConstance.sendDeleteAccountOtpPath,
        options: await _authorized(),
      );
      
      logger.debug('Send Delete Account OTP API Response Status: ${response.statusCode}');
      return SendDeleteAccountOtpResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.error('Send Delete Account OTP API DioException', error: e);
      throw _failure(e, 'Failed to send delete account OTP');
    } catch (e) {
      logger.error('Send Delete Account OTP API Unexpected Error', error: e);
      throw _unexpected(e);
    }
  }

  @override
  Future<void> verifyDeleteAccountOtpAndDelete({
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        ApiConstance.verifyDeleteAccountOtpPath,
        data: {
          'otp': otp,
        },
        options: await _authorized(),
      );
      
      logger.debug('Verify Delete Account OTP API Response Status: ${response.statusCode}');
    } on DioException catch (e) {
      logger.error('Verify Delete Account OTP API DioException', error: e);
      throw _failure(
        e,
        'Failed to verify OTP and delete account',
        validationCodes: const {400, 422},
        validationFallback: 'Invalid or expired OTP',
      );
    } catch (e) {
      logger.error('Verify Delete Account OTP API Unexpected Error', error: e);
      throw _unexpected(e);
    }
  }
}
