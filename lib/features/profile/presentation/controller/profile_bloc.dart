import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/change_email_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/confirm_email_change_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/send_delete_account_otp_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/verify_delete_account_otp_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/load_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/save_credentials_usecase.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_event.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_state.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/services/logging_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final ChangeEmailUseCase changeEmailUseCase;
  final ConfirmEmailChangeUseCase confirmEmailChangeUseCase;
  final SendDeleteAccountOtpUseCase sendDeleteAccountOtpUseCase;
  final VerifyDeleteAccountOtpUseCase verifyDeleteAccountOtpUseCase;
  final LoadCredentialsUseCase loadCredentialsUseCase;
  final SaveCredentialsUseCase saveCredentialsUseCase;
  final LoggingService _logger;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
    required this.changeEmailUseCase,
    required this.confirmEmailChangeUseCase,
    required this.sendDeleteAccountOtpUseCase,
    required this.verifyDeleteAccountOtpUseCase,
    required this.loadCredentialsUseCase,
    required this.saveCredentialsUseCase,
    LoggingService? logger,
  }) : _logger = logger ?? sl<LoggingService>(),
       super(const ProfileState()) {
    on<GetProfileEvent>(_getProfile);
    on<UpdateProfileEvent>(_updateProfile);
    on<ChangePasswordEvent>(_changePassword);
    on<ChangeEmailEvent>(_changeEmail);
    on<ConfirmEmailChangeEvent>(_confirmEmailChange);
    on<SendDeleteAccountOtpEvent>(_sendDeleteAccountOtp);
    on<VerifyDeleteAccountOtpEvent>(_verifyDeleteAccountOtp);
  }

  Future<void> _getProfile(GetProfileEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await getProfileUseCase(const NoParameters());

    result.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        message: failure.message,
      )),
      (profile) => emit(state.copyWith(
        profile: profile,
        requestState: RequestState.loaded,
      )),
    );
  }

  Future<void> _updateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await updateProfileUseCase(UpdateProfileParameters(
      name: event.name,
      phone: event.phone,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        message: failure.message,
      )),
      (profile) => emit(state.copyWith(
        profile: profile,
        requestState: RequestState.loaded,
        message: 'Profile updated successfully',
      )),
    );
  }

  Future<void> _changePassword(ChangePasswordEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await changePasswordUseCase(ChangePasswordParameters(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      newPasswordConfirmation: event.newPasswordConfirmation,
    ));

    await result.fold(
      (failure) async {
        emit(state.copyWith(
          requestState: RequestState.error,
          message: failure.message,
        ));
      },
      (_) async {
        // Update saved credentials if they exist and rememberMe is enabled
        // Do this before emitting to avoid emit after handler completion error
        await _updateSavedCredentialsIfNeeded(event.newPassword);
        
        if (!emit.isDone) {
          emit(state.copyWith(
            requestState: RequestState.loaded,
            message: 'Password changed successfully',
          ));
        }
      },
    );
  }

  /// Updates saved credentials if they exist and rememberMe is enabled
  /// This is called after a successful password change
  /// Since the user is authenticated, we update any saved credentials with rememberMe enabled
  Future<void> _updateSavedCredentialsIfNeeded(String newPassword) async {
    try {
      // Load existing credentials
      final loadResult = await loadCredentialsUseCase(const NoParameters());
      
      await loadResult.fold(
        (_) {
          // No saved credentials or error loading, nothing to update
        },
        (credentials) async {
          // Check if rememberMe is enabled and we have saved credentials
          if (credentials['rememberMe'] == 'true' && 
              credentials['email'] != null && 
              credentials['email']!.isNotEmpty) {
            // Since the user is authenticated and changing their password,
            // we update the saved credentials regardless of email match
            // (the user is authenticated, so it's safe to assume it's their account)
            final saveResult = await saveCredentialsUseCase(SaveCredentialsParameters(
              email: credentials['email']!, // Use original email (preserve case)
              password: newPassword,
              rememberMe: true,
            ));
            
            saveResult.fold(
              (failure) {
                _logger.error('ProfileBloc: Failed to save credentials: ${failure.message}');
              },
              (success) {
                if (success) {
                  _logger.info('ProfileBloc: Updated saved password for user: ${credentials['email']}');
                } else {
                  _logger.warning('ProfileBloc: Save credentials returned false for user: ${credentials['email']}');
                }
              },
            );
          }
        },
      );
    } catch (e) {
      // Log error but don't fail the password change operation
      _logger.error('ProfileBloc: Error updating saved credentials', error: e);
    }
  }

  Future<void> _changeEmail(ChangeEmailEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await changeEmailUseCase(ChangeEmailParameters(
      newEmail: event.newEmail,
      currentPassword: event.currentPassword,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        message: failure.message,
        resendCountdown: null,
      )),
      (response) => emit(state.copyWith(
        requestState: RequestState.loaded,
        message: 'Email change request submitted. Please check your new email for verification.',
        resendCountdown: response.resendCountdown,
      )),
    );
  }

  Future<void> _confirmEmailChange(ConfirmEmailChangeEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(requestState: RequestState.loading));

    // Store the old email before the change
    final oldEmail = state.profile?.email;

    final result = await confirmEmailChangeUseCase(ConfirmEmailChangeParameters(
      newEmail: event.newEmail,
      otp: event.otp,
    ));

    await result.fold(
      (failure) async {
        emit(state.copyWith(
          requestState: RequestState.error,
          message: failure.message,
        ));
      },
      (response) async {
        // Update saved credentials if they exist and rememberMe is enabled
        // Since the user is authenticated and successfully changed their email,
        // we update the saved credentials regardless of old email match
        await _updateSavedCredentialsEmailIfNeeded(oldEmail, event.newEmail);
        
        if (!emit.isDone) {
          emit(state.copyWith(
            profile: response.profile,
            requestState: RequestState.loaded,
            message: response.message,
          ));
        }
      },
    );
  }

  /// Updates saved credentials email if they exist and rememberMe is enabled
  /// This is called after a successful email change
  /// Since the user is authenticated, we update any saved credentials with rememberMe enabled
  Future<void> _updateSavedCredentialsEmailIfNeeded(String? oldEmail, String newEmail) async {
    try {
      _logger.debug('ProfileBloc: Checking saved credentials for email change - oldEmail: $oldEmail, newEmail: $newEmail');
      
      // Load existing credentials
      final loadResult = await loadCredentialsUseCase(const NoParameters());
      
      await loadResult.fold(
        (failure) {
          _logger.debug('ProfileBloc: Failed to load credentials: ${failure.message}');
          // No saved credentials or error loading, nothing to update
        },
        (credentials) async {
          _logger.debug('ProfileBloc: Loaded credentials - rememberMe: ${credentials['rememberMe']}, email: ${credentials['email']}');
          
          // Check if rememberMe is enabled and we have saved credentials
          if (credentials['rememberMe'] == 'true' && 
              credentials['email'] != null && 
              credentials['email']!.isNotEmpty &&
              credentials['password'] != null &&
              credentials['password']!.isNotEmpty) {
            // Since the user is authenticated and successfully changed their email,
            // we update the saved credentials with the new email (keep the same password)
            final savedPassword = credentials['password']!;
            
            _logger.debug('ProfileBloc: Updating saved email to: $newEmail');
            
            final saveResult = await saveCredentialsUseCase(SaveCredentialsParameters(
              email: newEmail,
              password: savedPassword,
              rememberMe: true,
            ));
            
            saveResult.fold(
              (failure) {
                _logger.error('ProfileBloc: Failed to save credentials: ${failure.message}');
              },
              (success) {
                if (success) {
                  _logger.info('ProfileBloc: Updated saved email from ${credentials['email']} to $newEmail');
                } else {
                  _logger.warning('ProfileBloc: Save credentials returned false');
                }
              },
            );
          } else {
            _logger.debug('ProfileBloc: No saved credentials with rememberMe enabled or email/password is empty');
            _logger.debug('ProfileBloc: rememberMe=${credentials['rememberMe']}, email=${credentials['email']}, hasPassword=${credentials['password'] != null && credentials['password']!.isNotEmpty}');
          }
        },
      );
    } catch (e, stackTrace) {
      // Log error but don't fail the email change operation
      _logger.error('ProfileBloc: Error updating saved credentials email', error: e);
      _logger.debug('ProfileBloc: Stack trace: $stackTrace');
    }
  }

  Future<void> _sendDeleteAccountOtp(SendDeleteAccountOtpEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await sendDeleteAccountOtpUseCase(const NoParameters());

    result.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        message: failure.message,
        resendCountdown: null,
      )),
      (response) => emit(state.copyWith(
        requestState: RequestState.loaded,
        message: 'Account deletion OTP sent to your email',
        resendCountdown: response.resendCountdown,
      )),
    );
  }

  Future<void> _verifyDeleteAccountOtp(VerifyDeleteAccountOtpEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await verifyDeleteAccountOtpUseCase(VerifyDeleteAccountOtpParameters(
      otp: event.otp,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        message: failure.message,
      )),
      (_) => emit(state.copyWith(
        requestState: RequestState.loaded,
        message: 'Account deleted successfully',
      )),
    );
  }

}
