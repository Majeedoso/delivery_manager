import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_constance.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../core/services/services_locator.dart';
import '../../domain/entities/user.dart' as app_user;

/// Abstract interface for Google authentication remote data source
///
/// Defines the contract for Google Sign-In/Sign-Up operations:
/// - Sign in existing users with Google
/// - Sign up new users with Google
/// - Sign out from Google authentication
///
/// The implementation coordinates between Firebase Authentication,
/// Google Sign-In SDK, and the backend API.
abstract class BaseGoogleAuthRemoteDataSource {
  /// Sign in with Google (for existing users)
  ///
  /// Returns:
  /// - [User] entity with authentication token
  ///
  /// Throws:
  /// - [ServerException] for authentication errors
  /// - [NetworkException] for network errors
  Future<app_user.User> signInWithGoogle();

  /// Sign up with Google (for new users)
  ///
  /// Returns:
  /// - [User] entity with authentication token
  ///
  /// Throws:
  /// - [ServerException] for registration errors
  /// - [NetworkException] for network errors
  Future<app_user.User> signUpWithGoogle();

  /// Sign out from Google authentication
  ///
  /// Throws:
  /// - [ServerException] if sign-out fails
  Future<void> signOutFromGoogle();
}

/// Implementation of [BaseGoogleAuthRemoteDataSource]
///
/// Handles Google authentication flow:
/// 1. Initiates Google Sign-In via GoogleSignIn SDK
/// 2. Authenticates with Firebase using Google credentials
/// 3. Sends user data to backend API for authentication/registration
/// 4. Returns user entity with token
///
/// Includes timeout handling and error conversion.
class GoogleAuthRemoteDataSource implements BaseGoogleAuthRemoteDataSource {
  /// Firebase Authentication instance
  final firebase_auth.FirebaseAuth _firebaseAuth;

  /// Google Sign-In instance
  final GoogleSignIn _googleSignIn;

  /// Dio instance for backend API calls
  final Dio _dio;

  /// Logging service for centralized logging
  final LoggingService? _logger;

  GoogleAuthRemoteDataSource({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required Dio dio,
    LoggingService? logger,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn,
       _dio = dio,
       _logger = logger;

  LoggingService get logger {
    try {
      return _logger ?? sl<LoggingService>();
    } catch (e) {
      return LoggingService();
    }
  }

  @override
  Future<app_user.User> signInWithGoogle() async {
    try {
      print('🟡 [GOOGLE_AUTH] Starting Google Sign-In...');
      logger.debug('🔍 Starting Google Sign-In...');

      // Sign out and disconnect to force account picker to show
      // signOut() clears the app-level session
      // disconnect() revokes access tokens and clears cached account selection
      // This ensures a fresh sign-in flow every time, preventing auto-selection from other apps
      try {
        print('🟡 [GOOGLE_AUTH] Signing out from previous Google session...');
        await _googleSignIn.signOut();
        print('🟡 [GOOGLE_AUTH] Signed out from previous Google session');
        logger.debug('🔍 Signed out from previous Google session');
      } catch (e) {
        print(
          '🟡 [GOOGLE_AUTH] No previous session to sign out (or sign out failed): $e',
        );
        logger.debug(
          '🔍 No previous session to sign out (or sign out failed)',
          e,
        );
      }

      try {
        print('🟡 [GOOGLE_AUTH] Disconnecting from previous Google account...');
        await _googleSignIn.disconnect();
        print('🟡 [GOOGLE_AUTH] Disconnected from previous Google account');
        logger.debug('🔍 Disconnected from previous Google account');
      } catch (e) {
        // If disconnect fails (e.g., no user signed in), continue anyway
        print(
          '🟡 [GOOGLE_AUTH] No previous account to disconnect (or disconnect failed): $e',
        );
        logger.debug(
          '🔍 No previous account to disconnect (or disconnect failed)',
          e,
        );
      }

      // Trigger the authentication flow
      print('🟡 [GOOGLE_AUTH] Calling _googleSignIn.signIn()...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      print('🟡 [GOOGLE_AUTH] Google user result: $googleUser');
      logger.debug('🔍 Google user result: $googleUser');

      if (googleUser == null) {
        print('🔴 [GOOGLE_AUTH] Google sign-in was cancelled');
        throw const ServerException(message: 'Google sign-in was cancelled');
      }

      // Obtain the auth details from the request
      print('🟡 [GOOGLE_AUTH] Getting Google auth tokens...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('🟡 [GOOGLE_AUTH] Google auth tokens received');
      logger.debug('🔍 Google auth tokens received');

      // Create a new credential
      // Note: In google_sign_in 7.x, accessToken and idToken are nullable strings
      print('🟡 [GOOGLE_AUTH] Creating Firebase credential...');
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🟡 [GOOGLE_AUTH] Signing in to Firebase (timeout: 30s)...');
      logger.debug('🔍 Signing in to Firebase...');

      // Sign in to Firebase with the Google credential (with timeout)
      final firebase_auth.UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print(
                '🔴 [GOOGLE_AUTH] Firebase authentication TIMED OUT after 30 seconds',
              );
              throw ServerException(
                message: 'Firebase authentication timed out. Please try again.',
              );
            },
          );
      final firebase_auth.User firebaseUser = userCredential.user!;

      print('🟢 [GOOGLE_AUTH] Firebase authentication SUCCESS');
      print('🟢 [GOOGLE_AUTH] Firebase user email: ${firebaseUser.email}');
      print('🟢 [GOOGLE_AUTH] Firebase UID: ${firebaseUser.uid}');
      print('🟢 [GOOGLE_AUTH] Google user ID: ${googleUser.id}');
      logger.debug('🔍 Firebase user: ${firebaseUser.email}');
      logger.debug('🔍 Firebase UID: ${firebaseUser.uid}');
      logger.debug('🔍 Google user ID from GoogleSignIn: ${googleUser.id}');

      // Send user data to Laravel backend
      final requestData = {
        'google_id': googleUser.id, // Use Google ID instead of Firebase UID
        'email': firebaseUser.email,
        'name': firebaseUser.displayName,
        'avatar': firebaseUser.photoURL,
        'app_type': 'driver', // Validate that user role matches driver app
      };

      print('🟡 [GOOGLE_AUTH] Preparing backend request...');
      print('🟡 [GOOGLE_AUTH] Request data: $requestData');
      print('🟡 [GOOGLE_AUTH] Backend URL: ${ApiConstance.googleSignInPath}');
      logger.debug('🔍 Sending to backend: $requestData');
      logger.debug('🔍 Backend URL: ${ApiConstance.googleSignInPath}');
      logger.debug('🔍 Attempting backend connection...');

      // Use longer timeouts for backend API call during sign-in
      // Backend might be slow, so we increase timeouts to allow more time
      DateTime startTime = DateTime.now();
      print(
        '🟡 [GOOGLE_AUTH] Sending POST request to backend (timeout: 90s)...',
      );
      final response = await _dio
          .post(
            ApiConstance.googleSignInPath,
            data: requestData,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              sendTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 45),
            ),
          )
          .timeout(
            const Duration(seconds: 90), // Total timeout including connection
            onTimeout: () {
              final elapsed = DateTime.now().difference(startTime).inSeconds;
              print(
                '🔴 [GOOGLE_AUTH] Backend request TIMED OUT after $elapsed seconds',
              );
              print(
                '🔴 [GOOGLE_AUTH] Backend URL was: ${ApiConstance.googleSignInPath}',
              );
              logger.warning(
                '🔍 Backend request timed out after $elapsed seconds',
              );
              logger.debug(
                '🔍 Backend URL was: ${ApiConstance.googleSignInPath}',
              );
              throw NetworkException(
                message:
                    'Backend request timed out. Please check your internet connection and try again.',
              );
            },
          );

      final elapsed = DateTime.now().difference(startTime).inSeconds;
      print('🟢 [GOOGLE_AUTH] Backend request completed in $elapsed seconds');
      print('🟢 [GOOGLE_AUTH] Response status: ${response.statusCode}');
      logger.info('🔍 Backend request completed in $elapsed seconds');

      print('🟢 [GOOGLE_AUTH] Backend response received');
      logger.debug('🔍 Backend response received');
      logger.debug('🔍 Backend response status: ${response.statusCode}');
      logger.debug('🔍 Backend response data: ${response.data}');

      if (response.statusCode == 200) {
        print(
          '🟢 [GOOGLE_AUTH] Backend response status is 200, extracting user data...',
        );
        // Extract user data and token from response
        final userData = response.data['data']['user'] as Map<String, dynamic>;
        final token = response.data['data']['token'] as String?;

        print('🟢 [GOOGLE_AUTH] Extracted token: $token');
        logger.debug('🔍 Extracted token: $token');

        // Add token to user data
        userData['token'] = token;

        final user = app_user.User.fromJson(userData);
        print('🟢 [GOOGLE_AUTH] User created successfully: ${user.email}');
        print('🟢 [GOOGLE_AUTH] User status: ${user.status}');
        print('🟢 [GOOGLE_AUTH] User role: ${user.role}');
        print(
          '🟢 [GOOGLE_AUTH] User isPendingApproval: ${user.isPendingApproval}',
        );
        print('🟢 [GOOGLE_AUTH] User isApproved: ${user.isApproved}');
        print('🟢 [GOOGLE_AUTH] Full user data: $userData');
        logger.info('🔍 Created user with token: ${user.token}');

        return user;
      } else {
        print(
          '🔴 [GOOGLE_AUTH] Backend response status is NOT 200: ${response.statusCode}',
        );
        throw const ServerException(
          message: 'Failed to authenticate with backend',
        );
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(
        message: 'Firebase authentication failed: ${e.message}',
      );
    } on DioException catch (e) {
      logger.error('🔍 DioException caught: ${e.type}', error: e);
      logger.debug('🔍 DioException message: ${e.message}');
      logger.debug('🔍 DioException response: ${e.response?.data}');
      logger.debug('🔍 DioException status code: ${e.response?.statusCode}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        // Safely extract error message from response data
        String? errorMessage;
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString();
        } else if (responseData is String) {
          // Try to parse as JSON if it's a string
          try {
            final parsed = jsonDecode(responseData);
            if (parsed is Map<String, dynamic>) {
              errorMessage = parsed['message']?.toString();
            }
          } catch (_) {
            // Not valid JSON, use as-is if it looks like a message
            if (responseData.isNotEmpty && !responseData.startsWith('<')) {
              errorMessage = responseData;
            }
          }
        }
        errorMessage ??= e.message;

        // Handle specific HTTP status codes with user-friendly messages
        if (statusCode == 403) {
          // Access denied - role mismatch
          throw ServerException(
            message:
                errorMessage ??
                'Access denied. This account is not authorized for the driver app. Please use the correct app for your account type.',
          );
        } else if (statusCode == 404) {
          // User not found
          throw ServerException(
            message: errorMessage ?? 'Account not found. Please sign up first.',
          );
        } else {
          // Other backend errors - show the message directly without "Backend error:" prefix
          throw ServerException(
            message: errorMessage ?? 'Authentication failed. Please try again.',
          );
        }
      } else {
        // Handle timeout and connection errors
        if (e.type == DioExceptionType.connectionTimeout) {
          logger.warning(
            '🔍 Connection timeout: Cannot establish connection to server',
          );
          logger.debug('🔍 Server URL: ${ApiConstance.googleSignInPath}');
          logger.debug('🔍 Make sure:');
          logger.debug('🔍   1. Device and server are on the same network');
          logger.debug(
            '🔍   2. Server IP address is correct (currently: ${ApiConstance.baseUrl})',
          );
          logger.debug('🔍   3. Backend server is running on port 8001');
          logger.debug('🔍   4. Firewall is not blocking the connection');
          throw NetworkException(
            message:
                'Cannot connect to server at ${ApiConstance.baseUrl}. Please check:\n1. Device and server are on the same network\n2. Server is running\n3. IP address is correct',
          );
        } else if (e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          logger.warning('🔍 Timeout error: ${e.type}');
          throw NetworkException(
            message:
                'Request timeout. Please check your internet connection and try again.',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          logger.warning(
            '🔍 Connection error: Cannot reach server at ${ApiConstance.googleSignInPath}',
          );
          logger.debug('🔍 Server URL: ${ApiConstance.baseUrl}');
          throw NetworkException(
            message:
                'Cannot connect to server at ${ApiConstance.baseUrl}. Please check your internet connection and that the backend server is running.',
          );
        } else {
          logger.error(
            '🔍 Other DioException: ${e.type} - ${e.message}',
            error: e,
          );
          throw ServerException(message: 'Network error: ${e.message}');
        }
      }
    } catch (e) {
      // Extract proper error message
      String errorMessage = 'Unexpected error occurred';
      if (e is ServerException) {
        errorMessage = e.message;
      } else if (e is NetworkException) {
        errorMessage = e.message;
      } else if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<app_user.User> signUpWithGoogle() async {
    try {
      print('🟡 [GOOGLE_AUTH] Starting Google Sign-Up...');
      logger.debug('🔍 Starting Google Sign-Up...');

      // Sign out and disconnect to force account picker to show
      // signOut() clears the app-level session
      // disconnect() revokes access tokens and clears cached account selection
      // This ensures a fresh sign-in flow every time, preventing auto-selection from other apps
      try {
        print('🟡 [GOOGLE_AUTH] Signing out from previous Google session...');
        await _googleSignIn.signOut();
        print('🟡 [GOOGLE_AUTH] Signed out from previous Google session');
        logger.debug('🔍 Signed out from previous Google session');
      } catch (e) {
        print(
          '🟡 [GOOGLE_AUTH] No previous session to sign out (or sign out failed): $e',
        );
        logger.debug(
          '🔍 No previous session to sign out (or sign out failed)',
          e,
        );
      }

      try {
        print('🟡 [GOOGLE_AUTH] Disconnecting from previous Google account...');
        await _googleSignIn.disconnect();
        print('🟡 [GOOGLE_AUTH] Disconnected from previous Google account');
        logger.debug('🔍 Disconnected from previous Google account');
      } catch (e) {
        // If disconnect fails (e.g., no user signed in), continue anyway
        print(
          '🟡 [GOOGLE_AUTH] No previous account to disconnect (or disconnect failed): $e',
        );
        logger.debug(
          '🔍 No previous account to disconnect (or disconnect failed)',
          e,
        );
      }

      // Trigger the authentication flow
      print('🟡 [GOOGLE_AUTH] Calling _googleSignIn.signIn()...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      print('🟡 [GOOGLE_AUTH] Google user result: $googleUser');
      logger.debug('🔍 Google user result: $googleUser');

      if (googleUser == null) {
        print('🔴 [GOOGLE_AUTH] Google sign-in was cancelled');
        throw const ServerException(message: 'Google sign-in was cancelled');
      }

      // Obtain the auth details from the request
      print('🟡 [GOOGLE_AUTH] Getting Google auth tokens...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('🟡 [GOOGLE_AUTH] Google auth tokens received');
      logger.debug('🔍 Google auth tokens received');

      // Create a new credential
      // Note: In google_sign_in 7.x, accessToken and idToken are nullable strings
      print('🟡 [GOOGLE_AUTH] Creating Firebase credential...');
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🟡 [GOOGLE_AUTH] Signing in to Firebase (timeout: 30s)...');
      logger.debug('🔍 Signing in to Firebase...');

      // Sign in to Firebase with the Google credential (with timeout)
      final firebase_auth.UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print(
                '🔴 [GOOGLE_AUTH] Firebase authentication TIMED OUT after 30 seconds',
              );
              throw ServerException(
                message: 'Firebase authentication timed out. Please try again.',
              );
            },
          );
      final firebase_auth.User firebaseUser = userCredential.user!;

      print('🟢 [GOOGLE_AUTH] Firebase authentication SUCCESS');
      print('🟢 [GOOGLE_AUTH] Firebase user email: ${firebaseUser.email}');
      print('🟢 [GOOGLE_AUTH] Firebase UID: ${firebaseUser.uid}');
      print('🟢 [GOOGLE_AUTH] Google user ID: ${googleUser.id}');
      logger.debug('🔍 Firebase user: ${firebaseUser.email}');
      logger.debug('🔍 Firebase UID: ${firebaseUser.uid}');
      logger.debug('🔍 Google user ID from GoogleSignIn: ${googleUser.id}');

      // Send user data to Laravel backend for signup
      final requestData = {
        'google_id': googleUser.id, // Use Google ID instead of Firebase UID
        'email': firebaseUser.email,
        'name': firebaseUser.displayName,
        'avatar': firebaseUser.photoURL,
        'role': 'driver', // Driver app should register as driver
        'app_type':
            'driver', // Validate that user role matches driver app (for login if user exists)
      };

      print('🟡 [GOOGLE_AUTH] Preparing backend request for SIGN-UP...');
      print('🟡 [GOOGLE_AUTH] Request data: $requestData');
      print('🟡 [GOOGLE_AUTH] Backend URL: ${ApiConstance.googleSignUpPath}');
      logger.debug('🔍 Sending to backend: $requestData');
      logger.debug('🔍 Backend URL: ${ApiConstance.googleSignUpPath}');
      logger.debug('🔍 Attempting backend connection...');

      // Use longer timeouts for backend API call during sign-up
      DateTime startTime = DateTime.now();
      print(
        '🟡 [GOOGLE_AUTH] Sending POST request to backend (timeout: 90s)...',
      );
      final response = await _dio
          .post(
            ApiConstance.googleSignUpPath,
            data: requestData,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              sendTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 45),
            ),
          )
          .timeout(
            const Duration(seconds: 90), // Total timeout including connection
            onTimeout: () {
              final elapsed = DateTime.now().difference(startTime).inSeconds;
              print(
                '🔴 [GOOGLE_AUTH] Backend request TIMED OUT after $elapsed seconds',
              );
              print(
                '🔴 [GOOGLE_AUTH] Backend URL was: ${ApiConstance.googleSignUpPath}',
              );
              logger.warning(
                '🔍 Backend request timed out after $elapsed seconds',
              );
              logger.debug(
                '🔍 Backend URL was: ${ApiConstance.googleSignUpPath}',
              );
              throw NetworkException(
                message:
                    'Backend request timed out. Please check your internet connection and try again.',
              );
            },
          );

      final elapsed = DateTime.now().difference(startTime).inSeconds;
      print('🟢 [GOOGLE_AUTH] Backend request completed in $elapsed seconds');
      print('🟢 [GOOGLE_AUTH] Response status: ${response.statusCode}');
      logger.info('🔍 Backend request completed in $elapsed seconds');

      print('🟢 [GOOGLE_AUTH] Backend response received');
      logger.debug('🔍 Backend response received');
      logger.debug('🔍 Backend response status: ${response.statusCode}');
      logger.debug('🔍 Backend response data: ${response.data}');

      if (response.statusCode == 200) {
        print(
          '🟢 [GOOGLE_AUTH] Backend response status is 200, extracting user data...',
        );
        // Extract user data and token from response
        final userData = response.data['data']['user'] as Map<String, dynamic>;
        final token = response.data['data']['token'] as String?;

        print('🟢 [GOOGLE_AUTH] Extracted token: $token');
        logger.debug('🔍 Extracted token: $token');

        // Add token to user data
        userData['token'] = token;

        final user = app_user.User.fromJson(userData);
        print('🟢 [GOOGLE_AUTH] User created successfully: ${user.email}');
        print('🟢 [GOOGLE_AUTH] User status: ${user.status}');
        print('🟢 [GOOGLE_AUTH] User role: ${user.role}');
        print(
          '🟢 [GOOGLE_AUTH] User isPendingApproval: ${user.isPendingApproval}',
        );
        print('🟢 [GOOGLE_AUTH] User isApproved: ${user.isApproved}');
        print('🟢 [GOOGLE_AUTH] Full user data: $userData');
        logger.info('🔍 Created user with token: ${user.token}');

        return user;
      } else {
        print(
          '🔴 [GOOGLE_AUTH] Backend response status is NOT 200: ${response.statusCode}',
        );
        throw const ServerException(message: 'Failed to register with backend');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('🔴 [GOOGLE_AUTH] FirebaseAuthException: ${e.message}');
      throw ServerException(
        message: 'Firebase authentication failed: ${e.message}',
      );
    } on DioException catch (e) {
      print('🔴 [GOOGLE_AUTH] DioException caught: ${e.type}');
      print('🔴 [GOOGLE_AUTH] DioException message: ${e.message}');
      print('🔴 [GOOGLE_AUTH] DioException response: ${e.response?.data}');
      print(
        '🔴 [GOOGLE_AUTH] DioException status code: ${e.response?.statusCode}',
      );
      logger.error(
        '🔍 DioException during Google Sign-Up: ${e.type}',
        error: e,
      );
      logger.debug('🔍 DioException message: ${e.message}');
      logger.debug('🔍 DioException response: ${e.response?.data}');
      logger.debug('🔍 DioException status code: ${e.response?.statusCode}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        // Safely extract error message from response data
        String? errorMessage;
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString();
        } else if (responseData is String) {
          // Try to parse as JSON if it's a string
          try {
            final parsed = jsonDecode(responseData);
            if (parsed is Map<String, dynamic>) {
              errorMessage = parsed['message']?.toString();
            }
          } catch (_) {
            // Not valid JSON, use as-is if it looks like a message
            if (responseData.isNotEmpty && !responseData.startsWith('<')) {
              errorMessage = responseData;
            }
          }
        }
        errorMessage ??= e.message;

        print('🔴 [GOOGLE_AUTH] Backend error (${statusCode}): $errorMessage');

        // Handle specific HTTP status codes with user-friendly messages
        if (statusCode == 403) {
          // Access denied - role mismatch or account exists with different role
          throw ServerException(
            message:
                errorMessage ??
                'Access denied. This account is not authorized for the driver app. Please use the correct app for your account type.',
          );
        } else if (statusCode == 422) {
          // User already exists or validation error
          throw ServerException(
            message:
                errorMessage ??
                'An account with this email already exists. Please sign in instead.',
          );
        } else {
          // Other backend errors - show the message directly without "Backend error:" prefix
          throw ServerException(
            message: errorMessage ?? 'Registration failed. Please try again.',
          );
        }
      } else {
        // Handle timeout and connection errors
        if (e.type == DioExceptionType.connectionTimeout) {
          print(
            '🔴 [GOOGLE_AUTH] Connection timeout: Cannot establish connection to server',
          );
          print(
            '🔴 [GOOGLE_AUTH] Server URL: ${ApiConstance.googleSignUpPath}',
          );
          logger.warning(
            '🔍 Connection timeout: Cannot establish connection to server',
          );
          logger.debug('🔍 Server URL: ${ApiConstance.googleSignUpPath}');
          logger.debug('🔍 Make sure:');
          logger.debug('🔍   1. Device and server are on the same network');
          logger.debug(
            '🔍   2. Server IP address is correct (currently: ${ApiConstance.baseUrl})',
          );
          logger.debug('🔍   3. Backend server is running on port 8001');
          logger.debug('🔍   4. Firewall is not blocking the connection');
          throw NetworkException(
            message:
                'Cannot connect to server at ${ApiConstance.baseUrl}. Please check:\n1. Device and server are on the same network\n2. Server is running\n3. IP address is correct',
          );
        } else if (e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          print('🔴 [GOOGLE_AUTH] Timeout error: ${e.type}');
          logger.warning('🔍 Timeout error: ${e.type}');
          throw NetworkException(
            message:
                'Request timeout. Please check your internet connection and try again.',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          print(
            '🔴 [GOOGLE_AUTH] Connection error: Cannot reach server at ${ApiConstance.googleSignUpPath}',
          );
          print('🔴 [GOOGLE_AUTH] Server URL: ${ApiConstance.baseUrl}');
          logger.warning(
            '🔍 Connection error: Cannot reach server at ${ApiConstance.googleSignUpPath}',
          );
          logger.debug('🔍 Server URL: ${ApiConstance.baseUrl}');
          throw NetworkException(
            message:
                'Cannot connect to server at ${ApiConstance.baseUrl}. Please check your internet connection and that the backend server is running.',
          );
        } else {
          print(
            '🔴 [GOOGLE_AUTH] Other DioException: ${e.type} - ${e.message}',
          );
          logger.error(
            '🔍 Other DioException: ${e.type} - ${e.message}',
            error: e,
          );
          throw ServerException(message: 'Network error: ${e.message}');
        }
      }
    } catch (e) {
      print('🔴 [GOOGLE_AUTH] Unexpected error caught: $e');
      // Extract proper error message
      String errorMessage = 'Unexpected error occurred';
      if (e is ServerException) {
        errorMessage = e.message;
      } else if (e is NetworkException) {
        errorMessage = e.message;
      } else if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }
      print(
        '🔴 [GOOGLE_AUTH] Throwing ServerException with message: $errorMessage',
      );
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<void> signOutFromGoogle() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw ServerException(message: 'Failed to sign out: $e');
    }
  }
}
