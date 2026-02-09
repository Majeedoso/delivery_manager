import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/utils/app_timeouts.dart';
import 'package:delivery_manager/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/login_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/logout_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/register_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/google_sign_up_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/google_sign_out_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/save_token_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/clear_token_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/resend_verification_email_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/resend_password_reset_otp_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/verify_password_reset_otp_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/send_password_reset_otp_authenticated_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/verify_password_reset_otp_authenticated_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/reset_password_authenticated_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/load_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/save_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/core/services/notification_service.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';
import 'package:dio/dio.dart';

/// Business Logic Component (BLoC) for managing authentication state
///
/// This BLoC handles all authentication-related operations including:
/// - User login and registration
/// - Google Sign-In/Sign-Up/Sign-Out
/// - Token management
/// - Authentication status checking
/// - Logout
///
/// It uses various use cases from the domain layer to perform these operations
/// and emits AuthState changes that the UI can react to.
///
/// The BLoC follows Clean Architecture principles:
/// - Presentation layer (this file) depends on Domain layer (use cases)
/// - Domain layer is independent and contains business logic
/// - Data layer implements domain interfaces
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Use case for user login
  final LoginUseCase loginUseCase;

  /// Use case for user registration
  final RegisterUseCase registerUseCase;

  /// Use case for user logout
  final LogoutUseCase logoutUseCase;

  /// Use case for getting current authenticated user
  final GetCurrentUserUseCase getCurrentUserUseCase;

  /// Use case for Google Sign-In
  final GoogleSignInUseCase googleSignInUseCase;

  /// Use case for Google Sign-Up
  final GoogleSignUpUseCase googleSignUpUseCase;

  /// Use case for Google Sign-Out
  final GoogleSignOutUseCase googleSignOutUseCase;

  /// Use case for saving authentication token
  final SaveTokenUseCase saveTokenUseCase;

  /// Use case for checking authentication status
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  /// Use case for clearing authentication token
  final ClearTokenUseCase clearTokenUseCase;

  /// Use case for resending email verification
  final ResendVerificationEmailUseCase resendVerificationEmailUseCase;

  /// Use case for resending password reset OTP
  final ResendPasswordResetOtpUseCase resendPasswordResetOtpUseCase;

  /// Use case for verifying password reset OTP
  final VerifyPasswordResetOtpUseCase verifyPasswordResetOtpUseCase;

  /// Use case for resetting password
  final ResetPasswordUseCase resetPasswordUseCase;

  /// Use case for sending password reset OTP (authenticated users)
  final SendPasswordResetOtpAuthenticatedUseCase
  sendPasswordResetOtpAuthenticatedUseCase;

  /// Use case for verifying password reset OTP (authenticated users)
  final VerifyPasswordResetOtpAuthenticatedUseCase
  verifyPasswordResetOtpAuthenticatedUseCase;

  /// Use case for resetting password (authenticated users)
  final ResetPasswordAuthenticatedUseCase resetPasswordAuthenticatedUseCase;

  /// Use case for loading saved credentials
  final LoadCredentialsUseCase loadCredentialsUseCase;

  /// Use case for saving credentials
  final SaveCredentialsUseCase saveCredentialsUseCase;

  /// Logging service for centralized logging
  final LoggingService _logger;

  /// Creates an instance of AuthBloc with required use cases
  ///
  /// All use cases are injected via dependency injection,
  /// following the Dependency Inversion Principle.
  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.googleSignInUseCase,
    required this.googleSignUpUseCase,
    required this.googleSignOutUseCase,
    required this.saveTokenUseCase,
    required this.checkAuthStatusUseCase,
    required this.clearTokenUseCase,
    required this.resendVerificationEmailUseCase,
    required this.resendPasswordResetOtpUseCase,
    required this.verifyPasswordResetOtpUseCase,
    required this.resetPasswordUseCase,
    required this.sendPasswordResetOtpAuthenticatedUseCase,
    required this.verifyPasswordResetOtpAuthenticatedUseCase,
    required this.resetPasswordAuthenticatedUseCase,
    required this.loadCredentialsUseCase,
    required this.saveCredentialsUseCase,
    LoggingService? logger,
  }) : _logger = logger ?? sl<LoggingService>(),
       super(const AuthState()) {
    // Register event handlers
    on<LoginEvent>(_login);
    on<RegisterEvent>(_register);
    on<LogoutEvent>(_logout);
    on<CheckAuthStatusEvent>(_checkAuthStatus);
    on<GoogleSignInEvent>(_googleSignIn);
    on<GoogleSignUpEvent>(_googleSignUp);
    on<GoogleSignOutEvent>(_googleSignOut);
    on<ResendVerificationEmailEvent>(_resendVerificationEmail);
    on<ResendPasswordResetOtpEvent>(_resendPasswordResetOtp);
    on<VerifyPasswordResetOtpEvent>(_verifyPasswordResetOtp);
    on<ResetPasswordEvent>(_resetPassword);
    on<SendPasswordResetOtpAuthenticatedEvent>(
      _sendPasswordResetOtpAuthenticated,
    );
    on<VerifyPasswordResetOtpAuthenticatedEvent>(
      _verifyPasswordResetOtpAuthenticated,
    );
    on<ResetPasswordAuthenticatedEvent>(_resetPasswordAuthenticated);
  }

  /// Handles user login event
  ///
  /// Process:
  /// 1. Emit loading state
  /// 2. Call login use case with email and password
  /// 3. On success: save token, send FCM token to server, emit success state
  /// 4. On failure: emit error state with error message
  FutureOr<void> _login(LoginEvent event, Emitter<AuthState> emit) async {
    _logger.debug('AuthBloc: Starting login process...');
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await loginUseCase(
      LoginParameters(email: event.email, password: event.password),
    );

    await result.fold(
      (failure) async {
        _logger.warning('AuthBloc: Login failed: ${failure.message}');
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: failure.message,
            isAuthenticated: false,
          ),
        );
      },
      (authResponse) async {
        _logger.info('AuthBloc: Login successful, saving token...');
        // Save token after successful login
        await saveTokenUseCase(SaveTokenParameters(token: authResponse.token));

        // Send FCM token to server after successful login
        try {
          _logger.debug('AuthBloc: Sending FCM token to server...');
          await NotificationService.sendTokenToServer();
          _logger.info('AuthBloc: FCM token sent successfully');
        } catch (e) {
          _logger.error('AuthBloc: Error sending FCM token', error: e);
          // Don't fail login if FCM token sending fails
        }

        if (!emit.isDone) {
          _logger.debug('AuthBloc: Emitting login success state');
          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              user: authResponse.user,
              message: authResponse.message,
              isAuthenticated: true,
            ),
          );
        }
      },
    );
  }

  /// Handles user registration event
  ///
  /// Process:
  /// 1. Emit loading state
  /// 2. Call register use case with user details
  /// 3. On success: save token, emit success state with user data
  /// 4. On failure: emit error state with error message
  FutureOr<void> _register(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await registerUseCase(
      RegisterParameters(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
        phone: event.phone,
      ),
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: failure.message,
            isAuthenticated: false,
          ),
        );
      },
      (authResponse) async {
        // Save token after successful registration
        await saveTokenUseCase(SaveTokenParameters(token: authResponse.token));

        if (!emit.isDone) {
          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              user: authResponse.user,
              message: authResponse.message,
              isAuthenticated: true,
            ),
          );
        }
      },
    );
  }

  /// Handles user logout event
  ///
  /// Process:
  /// 1. Emit loading state
  /// 2. Call logout use case (with 5-second timeout)
  /// 3. Clear local authentication token (even if server logout fails)
  /// 4. Emit logout success state
  ///
  /// Note: Local data is always cleared even if server logout fails,
  /// ensuring users can always log out locally.
  FutureOr<void> _logout(LogoutEvent event, Emitter<AuthState> emit) async {
    _logger.debug('AuthBloc: Starting logout process...');
    emit(state.copyWith(requestState: RequestState.loading));

    try {
      // Add timeout to the entire logout process
      final result = await logoutUseCase(
        const NoParameters(),
      ).timeout(AppTimeouts.logout);

      await result.fold(
        (failure) async {
          _logger.warning(
            'AuthBloc: Logout failed on server, clearing local data...',
          );
          // Even if logout fails on server, clear local data
          await clearTokenUseCase(const NoParameters());
          if (!emit.isDone) {
            _logger.debug(
              'AuthBloc: Emitting logout success state (server failure)',
            );
            emit(
              const AuthState(
                requestState: RequestState.loaded,
                isAuthenticated: false,
                message: 'Logged out successfully',
              ),
            );
          }
        },
        (_) async {
          _logger.info(
            'AuthBloc: Logout successful on server, clearing local data...',
          );
          // Clear token after successful logout
          await clearTokenUseCase(const NoParameters());

          if (!emit.isDone) {
            _logger.debug(
              'AuthBloc: Emitting logout success state (server success)',
            );
            emit(
              const AuthState(
                requestState: RequestState.loaded,
                isAuthenticated: false,
                message: 'Logged out successfully',
              ),
            );
          }
        },
      );
    } on TimeoutException {
      _logger.warning('AuthBloc: Logout timeout, clearing local data...');
      // If logout times out, still clear local data and complete logout
      await clearTokenUseCase(const NoParameters());

      if (!emit.isDone) {
        _logger.debug('AuthBloc: Emitting logout success state (timeout)');
        emit(
          const AuthState(
            requestState: RequestState.loaded,
            isAuthenticated: false,
            message: 'Logged out successfully',
          ),
        );
      }
    } catch (e) {
      _logger.error('AuthBloc: Logout error, clearing local data...', error: e);
      // If any other error occurs, still complete logout
      await clearTokenUseCase(const NoParameters());

      if (!emit.isDone) {
        _logger.debug('AuthBloc: Emitting logout success state (error)');
        emit(
          const AuthState(
            requestState: RequestState.loaded,
            isAuthenticated: false,
            message: 'Logged out successfully',
          ),
        );
      }
    }
  }

  /// Handles authentication status check event
  ///
  /// This is called during app initialization (splash screen) to verify
  /// if the user has a valid authentication token.
  ///
  /// Process:
  /// 1. Emit loading state
  /// 2. If user with token exists in memory, use that token to refresh from server
  /// 3. Otherwise, check if authentication token is valid via SecureStorage
  /// 4. If valid: fetch current user data and emit authenticated state
  /// 5. If invalid: emit unauthenticated state
  ///
  /// Used by SplashBloc to determine initial navigation.
  /// Also used by AccountStatusScreen to refresh user status.
  FutureOr<void> _checkAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    _logger.debug(
      'AuthBloc: _checkAuthStatus called, starting authentication check...',
    );
    // Preserve current user during loading to avoid showing default/error messages
    emit(state.copyWith(requestState: RequestState.loading, user: state.user));

    // Check if we already have a user with a token in memory
    // This bypasses SecureStorage issues (e.g., corrupted keystore)
    if (state.user != null &&
        state.user!.token != null &&
        state.user!.token!.isNotEmpty) {
      _logger.debug(
        'AuthBloc: Found in-memory user with token, refreshing from server...',
      );
      await _refreshUserFromServer(state.user!.token!, emit);
      return;
    }

    _logger.debug(
      'AuthBloc: No in-memory token, calling checkAuthStatusUseCase...',
    );
    final result = await checkAuthStatusUseCase(const NoParameters());
    _logger.debug('AuthBloc: checkAuthStatusUseCase completed');

    await result.fold(
      (failure) async {
        _logger.warning(
          'AuthBloc: checkAuthStatusUseCase failed: ${failure.message}',
        );
        // If SecureStorage fails but we have a user in memory, try server refresh
        if (state.user != null) {
          _logger.debug(
            'AuthBloc: SecureStorage failed but user exists, keeping current state...',
          );
          if (!emit.isDone) {
            emit(
              state.copyWith(
                requestState: RequestState.loaded,
                user: state.user,
                isAuthenticated: true,
              ),
            );
          }
        } else {
          if (!emit.isDone) {
            emit(
              state.copyWith(
                requestState: RequestState.error,
                message: failure.message,
                isAuthenticated: false,
              ),
            );
          }
        }
      },
      (isAuthenticated) async {
        if (isAuthenticated) {
          // If token is valid, get current user
          final userResult = await getCurrentUserUseCase(const NoParameters());
          await userResult.fold(
            (failure) async {
              if (!emit.isDone) {
                emit(
                  state.copyWith(
                    requestState: RequestState.error,
                    message: failure.message,
                    isAuthenticated: false,
                  ),
                );
              }
            },
            (user) async {
              // Sync FCM token when user is authenticated on app startup
              // This ensures token is always up to date even if it changed
              try {
                _logger.debug(
                  'AuthBloc: User authenticated, syncing FCM token...',
                );
                await NotificationService.sendTokenToServer();
                _logger.info('AuthBloc: FCM token synced successfully');
              } catch (e) {
                _logger.error('AuthBloc: Error syncing FCM token', error: e);
                // Don't fail auth check if FCM token sync fails
              }

              if (!emit.isDone) {
                emit(
                  state.copyWith(
                    requestState: RequestState.loaded,
                    user: user,
                    isAuthenticated: true,
                  ),
                );
              }
            },
          );
        } else {
          if (!emit.isDone) {
            emit(
              state.copyWith(
                requestState: RequestState.loaded,
                isAuthenticated: false,
              ),
            );
          }
        }
      },
    );
  }

  /// Refresh user data directly from server using the provided token
  /// This bypasses SecureStorage and is used when we have an in-memory token
  Future<void> _refreshUserFromServer(
    String token,
    Emitter<AuthState> emit,
  ) async {
    try {
      _logger.debug(
        'AuthBloc: Refreshing user from server with in-memory token...',
      );

      // Import dio here since we need direct access
      final dio = sl<Dio>();
      final response = await dio.get(
        ApiConstance.userPath,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final userData = response.data['data'] as Map<String, dynamic>;
        // Preserve the token in userData
        userData['token'] = token;

        final user = User.fromJson(userData);
        _logger.info(
          'AuthBloc: User refreshed from server successfully: ${user.email}',
        );
        _logger.debug(
          'AuthBloc: User status: ${user.status}, isApproved: ${user.isApproved}',
        );

        // Sync FCM token
        try {
          _logger.debug('AuthBloc: Syncing FCM token after server refresh...');
          await NotificationService.sendTokenToServer();
          _logger.info('AuthBloc: FCM token synced successfully');
        } catch (e) {
          _logger.error('AuthBloc: Error syncing FCM token', error: e);
        }

        if (!emit.isDone) {
          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              user: user,
              isAuthenticated: true,
            ),
          );
        }
      } else {
        _logger.warning(
          'AuthBloc: Server refresh failed with status ${response.statusCode}',
        );
        // If server refresh fails, keep the existing user state
        if (!emit.isDone) {
          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              user: state.user,
              isAuthenticated: state.user != null,
            ),
          );
        }
      }
    } catch (e) {
      _logger.error('AuthBloc: Error refreshing user from server', error: e);
      // On error, emit error state but preserve user
      if (!emit.isDone) {
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: 'Failed to refresh user status. Please try again.',
            user: state.user,
            isAuthenticated: state.user != null,
          ),
        );
      }
    }
  }

  /// Handles Google Sign-In event
  ///
  /// Process:
  /// 1. Emit loading state
  /// 2. Call Google Sign-In use case (handles OAuth flow)
  /// 3. On success: send FCM token to server, emit success state
  /// 4. On failure: emit error state
  ///
  /// Note: Google Sign-In flow includes:
  /// - Google account picker
  /// - Firebase authentication
  /// - Backend authentication
  FutureOr<void> _googleSignIn(
    GoogleSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🔵 [AUTH_BLOC] Starting Google Sign-In process...');
    _logger.debug('AuthBloc: Starting Google Sign-In process...');
    emit(state.copyWith(requestState: RequestState.loading));

    print('🔵 [AUTH_BLOC] Calling googleSignInUseCase...');
    _logger.debug('AuthBloc: Calling googleSignInUseCase...');
    final result = await googleSignInUseCase(const NoParameters());
    print('🔵 [AUTH_BLOC] googleSignInUseCase completed');
    _logger.debug('AuthBloc: googleSignInUseCase completed');

    await result.fold(
      (failure) async {
        print('🔴 [AUTH_BLOC] Google Sign-In FAILED: ${failure.message}');
        _logger.error('AuthBloc: Google Sign-In failed: ${failure.message}');
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: failure.message,
            isAuthenticated: false,
          ),
        );
      },
      (user) async {
        print('🟢 [AUTH_BLOC] Google Sign-In SUCCESS for user: ${user.email}');
        _logger.info(
          'AuthBloc: Google Sign-In successful for user: ${user.email}',
        );
        // Note: Google Sign-In doesn't return a token in this implementation
        // The token is handled internally by the Google Sign-In flow

        // Send FCM token to server after successful Google Sign-In
        try {
          _logger.debug(
            'AuthBloc: Sending FCM token to server after Google Sign-In...',
          );
          await NotificationService.sendTokenToServer();
          _logger.info(
            'AuthBloc: FCM token sent successfully after Google Sign-In',
          );
        } catch (e) {
          _logger.error(
            'AuthBloc: Error sending FCM token after Google Sign-In',
            error: e,
          );
          // Don't fail login if FCM token sending fails
        }

        if (!emit.isDone) {
          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              user: user,
              message: 'Signed in with Google successfully',
              isAuthenticated: true,
            ),
          );
        }
      },
    );
  }

  /// Handles Google Sign-Up event
  ///
  /// Process:
  /// 1. Emit loading state
  /// 2. Call Google Sign-Up use case (creates new account)
  /// 3. On success: emit success state with user data
  /// 4. On failure: emit error state
  FutureOr<void> _googleSignUp(
    GoogleSignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🔵 [AUTH_BLOC] Starting Google Sign-Up process...');
    _logger.debug('AuthBloc: Starting Google Sign-Up process...');
    emit(state.copyWith(requestState: RequestState.loading));

    print('🔵 [AUTH_BLOC] Calling googleSignUpUseCase...');
    _logger.debug('AuthBloc: Calling googleSignUpUseCase...');
    final result = await googleSignUpUseCase(const NoParameters());
    print('🔵 [AUTH_BLOC] googleSignUpUseCase completed');
    _logger.debug('AuthBloc: googleSignUpUseCase completed');

    await result.fold(
      (failure) async {
        print('🔴 [AUTH_BLOC] Google Sign-Up FAILED: ${failure.message}');
        _logger.error('AuthBloc: Google Sign-Up failed: ${failure.message}');
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: failure.message,
            isAuthenticated: false,
          ),
        );
      },
      (user) async {
        print('🟢 [AUTH_BLOC] Google Sign-Up SUCCESS for user: ${user.email}');
        print('🟢 [AUTH_BLOC] User status: ${user.status}');
        print('🟢 [AUTH_BLOC] User role: ${user.role}');
        print(
          '🟢 [AUTH_BLOC] User isPendingApproval: ${user.isPendingApproval}',
        );
        print('🟢 [AUTH_BLOC] User isApproved: ${user.isApproved}');
        _logger.info(
          'AuthBloc: Google Sign-Up successful for user: ${user.email}',
        );
        if (!emit.isDone) {
          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              user: user,
              message: 'Signed up with Google successfully',
              isAuthenticated: true,
            ),
          );
          print('🟢 [AUTH_BLOC] State emitted with isAuthenticated: true');
        }
      },
    );
  }

  /// Handles Google Sign-Out event
  ///
  /// Process:
  /// 1. Emit loading state
  /// 2. Call Google Sign-Out use case (disconnects from Google)
  /// 3. Emit unauthenticated state
  FutureOr<void> _googleSignOut(
    GoogleSignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await googleSignOutUseCase(const NoParameters());

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: failure.message,
          ),
        );
      },
      (_) async {
        if (!emit.isDone) {
          emit(
            const AuthState(
              requestState: RequestState.loaded,
              isAuthenticated: false,
              message: 'Signed out from Google successfully',
            ),
          );
        }
      },
    );
  }

  /// Handles resend email verification event
  ///
  /// Process:
  /// 1. Emit loading state
  /// 2. Call resend verification email use case
  /// 3. On success: emit success state with message
  /// 4. On failure: emit error state with error message
  FutureOr<void> _resendVerificationEmail(
    ResendVerificationEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await resendVerificationEmailUseCase(const NoParameters());

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: failure.message,
            resendCountdown: null,
          ),
        );
      },
      (response) async {
        if (!emit.isDone) {
          // Note: Message will be localized in the UI layer
          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              message: 'verificationEmailSent', // Localization key
              resendCountdown: response.resendCountdown,
            ),
          );
        }
      },
    );
  }

  /// Handles resend password reset OTP event
  ///
  /// Process:
  /// 1. Emit loading state
  /// 2. Call resend password reset OTP use case
  /// 3. On success: emit success state with message and resend countdown
  /// 4. On failure: emit error state with error message
  FutureOr<void> _resendPasswordResetOtp(
    ResendPasswordResetOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await resendPasswordResetOtpUseCase(
      ResendPasswordResetOtpParameters(email: event.email),
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: failure.message,
            resendCountdown: null,
          ),
        );
      },
      (response) async {
        if (!emit.isDone) {
          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              message:
                  'Password reset OTP sent successfully. Please check your email.',
              resendCountdown: response.resendCountdown,
            ),
          );
        }
      },
    );
  }

  /// Handles password reset OTP verification event (unauthenticated users)
  ///
  /// Process:
  /// 1. Emit loading state
  /// 2. Call verify password reset OTP use case with email and OTP
  /// 3. On success: emit success state with message
  /// 4. On failure: emit error state with error message
  FutureOr<void> _verifyPasswordResetOtp(
    VerifyPasswordResetOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await verifyPasswordResetOtpUseCase(
      VerifyPasswordResetOtpParameters(email: event.email, otp: event.otp),
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: failure.message,
          ),
        );
      },
      (_) async {
        if (!emit.isDone) {
          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              message:
                  'OTP verified successfully. You can now reset your password.',
            ),
          );
        }
      },
    );
  }

  /// Handles password reset event (unauthenticated users)
  ///
  /// Process:
  /// 1. Emit loading state
  /// 2. Call reset password use case with email, OTP, and new password
  /// 3. On success: emit success state with message
  /// 4. On failure: emit error state with error message
  FutureOr<void> _resetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await resetPasswordUseCase(
      ResetPasswordParameters(
        email: event.email,
        otp: event.otp,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      ),
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: failure.message,
          ),
        );
      },
      (message) async {
        // Update saved credentials if they exist and rememberMe is enabled
        await _updateSavedCredentialsIfNeededForEmail(
          event.email,
          event.password,
        );

        if (!emit.isDone) {
          emit(
            state.copyWith(requestState: RequestState.loaded, message: message),
          );
        }
      },
    );
  }

  /// Handles send password reset OTP event (authenticated users)
  ///
  /// Process:
  /// 1. Emit loading state
  /// 2. Call send password reset OTP authenticated use case
  /// 3. On success: emit success state with message and resend countdown
  /// 4. On failure: emit error state with error message
  FutureOr<void> _sendPasswordResetOtpAuthenticated(
    SendPasswordResetOtpAuthenticatedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await sendPasswordResetOtpAuthenticatedUseCase(
      const NoParameters(),
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: failure.message,
            resendCountdown: null,
          ),
        );
      },
      (response) async {
        if (!emit.isDone) {
          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              message:
                  'Password reset OTP sent successfully. Please check your email.',
              resendCountdown: response.resendCountdown,
            ),
          );
        }
      },
    );
  }

  /// Handles password reset OTP verification event (authenticated users)
  ///
  /// Process:
  /// 1. Emit loading state
  /// 2. Call verify password reset OTP authenticated use case with OTP
  /// 3. On success: emit success state with message
  /// 4. On failure: emit error state with error message
  FutureOr<void> _verifyPasswordResetOtpAuthenticated(
    VerifyPasswordResetOtpAuthenticatedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await verifyPasswordResetOtpAuthenticatedUseCase(
      VerifyPasswordResetOtpAuthenticatedParameters(otp: event.otp),
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: failure.message,
          ),
        );
      },
      (_) async {
        if (!emit.isDone) {
          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              message:
                  'OTP verified successfully. You can now reset your password.',
            ),
          );
        }
      },
    );
  }

  /// Handles password reset event (authenticated users)
  ///
  /// Process:
  /// 1. Emit loading state
  /// 2. Call reset password authenticated use case with OTP and new password
  /// 3. On success: emit success state with message
  /// 4. On failure: emit error state with error message
  FutureOr<void> _resetPasswordAuthenticated(
    ResetPasswordAuthenticatedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await resetPasswordAuthenticatedUseCase(
      ResetPasswordAuthenticatedParameters(
        otp: event.otp,
        newPassword: event.newPassword,
        newPasswordConfirmation: event.newPasswordConfirmation,
      ),
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: failure.message,
          ),
        );
      },
      (message) async {
        // Update saved credentials if they exist and rememberMe is enabled
        await _updateSavedCredentialsIfNeeded(event.newPassword);

        if (!emit.isDone) {
          emit(
            state.copyWith(requestState: RequestState.loaded, message: message),
          );
        }
      },
    );
  }

  /// Updates saved credentials if they exist and rememberMe is enabled
  /// This is called after a successful password change/reset (authenticated users)
  /// Since the user is authenticated, we update any saved credentials with rememberMe enabled
  Future<void> _updateSavedCredentialsIfNeeded(String newPassword) async {
    try {
      _logger.debug(
        'AuthBloc: Checking saved credentials for authenticated password reset',
      );

      // Load existing credentials
      final loadResult = await loadCredentialsUseCase(const NoParameters());

      await loadResult.fold(
        (failure) {
          _logger.debug(
            'AuthBloc: Failed to load credentials: ${failure.message}',
          );
          // No saved credentials or error loading, nothing to update
        },
        (credentials) async {
          _logger.debug(
            'AuthBloc: Loaded credentials - rememberMe: ${credentials['rememberMe']}, email: ${credentials['email']}',
          );

          // Check if rememberMe is enabled and we have saved credentials
          if (credentials['rememberMe'] == 'true' &&
              credentials['email'] != null &&
              credentials['email']!.isNotEmpty) {
            // Since the user is authenticated and resetting their password,
            // we update the saved credentials regardless of email match
            // (the user is authenticated, so it's safe to assume it's their account)
            final saveResult = await saveCredentialsUseCase(
              SaveCredentialsParameters(
                email:
                    credentials['email']!, // Use original email (preserve case)
                password: newPassword,
                rememberMe: true,
              ),
            );

            saveResult.fold(
              (failure) {
                _logger.error(
                  'AuthBloc: Failed to save credentials: ${failure.message}',
                );
              },
              (success) {
                if (success) {
                  _logger.info(
                    'AuthBloc: Updated saved password for user: ${credentials['email']}',
                  );
                } else {
                  _logger.warning(
                    'AuthBloc: Save credentials returned false for user: ${credentials['email']}',
                  );
                }
              },
            );
          } else {
            _logger.debug(
              'AuthBloc: No saved credentials with rememberMe enabled or email is empty',
            );
          }
        },
      );
    } catch (e) {
      // Log error but don't fail the password reset operation
      _logger.error('AuthBloc: Error updating saved credentials', error: e);
    }
  }

  /// Updates saved credentials if they exist and rememberMe is enabled
  /// This is called after a successful password reset (unauthenticated users)
  /// Uses the email from the event since user is not authenticated
  Future<void> _updateSavedCredentialsIfNeededForEmail(
    String email,
    String newPassword,
  ) async {
    try {
      _logger.debug('AuthBloc: Checking saved credentials for email: $email');

      // Normalize the email from the event (trim and lowercase for comparison)
      final normalizedEventEmail = email.trim().toLowerCase();
      _logger.debug('AuthBloc: Normalized event email: $normalizedEventEmail');

      // Load existing credentials
      final loadResult = await loadCredentialsUseCase(const NoParameters());

      await loadResult.fold(
        (failure) {
          _logger.debug(
            'AuthBloc: Failed to load credentials: ${failure.message}',
          );
          // No saved credentials or error loading, nothing to update
        },
        (credentials) async {
          _logger.debug(
            'AuthBloc: Loaded credentials - rememberMe: ${credentials['rememberMe']}, email: ${credentials['email']}',
          );

          // Check if rememberMe is enabled and we have saved credentials
          if (credentials['rememberMe'] == 'true' &&
              credentials['email'] != null &&
              credentials['email']!.isNotEmpty) {
            // For unauthenticated password reset, if the user successfully reset their password
            // using their email, and they have saved credentials with rememberMe enabled,
            // we should update them (the successful password reset proves they have access to that email)
            // We update the saved email to match the one used for password reset
            _logger.debug(
              'AuthBloc: Updating saved credentials with new password and email from reset',
            );

            // Update the saved password and email (use the email from the reset event)
            final saveResult = await saveCredentialsUseCase(
              SaveCredentialsParameters(
                email: email, // Use the email from the reset event
                password: newPassword,
                rememberMe: true,
              ),
            );

            saveResult.fold(
              (failure) {
                _logger.error(
                  'AuthBloc: Failed to save credentials: ${failure.message}',
                );
              },
              (success) {
                if (success) {
                  _logger.info(
                    'AuthBloc: Successfully updated saved password and email for user: $email',
                  );
                } else {
                  _logger.warning(
                    'AuthBloc: Save credentials returned false for user: $email',
                  );
                }
              },
            );
          } else {
            _logger.debug(
              'AuthBloc: No saved credentials with rememberMe enabled or email is empty',
            );
            _logger.debug(
              'AuthBloc: rememberMe=${credentials['rememberMe']}, email=${credentials['email']}',
            );
          }
        },
      );
    } catch (e, stackTrace) {
      // Log error but don't fail the password reset operation
      _logger.error('AuthBloc: Error updating saved credentials', error: e);
      _logger.debug('AuthBloc: Stack trace: $stackTrace');
    }
  }
}
