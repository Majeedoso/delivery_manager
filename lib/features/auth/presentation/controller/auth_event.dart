import 'package:equatable/equatable.dart';

/// Base class for all authentication-related events
///
/// This abstract class extends Equatable to enable state comparison
/// and is used as the event type for the AuthBloc.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when user attempts to log in with email and password
///
/// Contains:
/// - [email]: User's email address
/// - [password]: User's password
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// Event triggered when user attempts to register a new account
///
/// Contains:
/// - [name]: User's full name
/// - [email]: User's email address
/// - [password]: User's chosen password
/// - [role]: User's role (typically 'manager' for this app)
/// - [phone]: User's phone number (optional)
class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;
  final String phone;

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.phone,
  });

  @override
  List<Object> get props => [name, email, password, role, phone];
}

/// Event triggered when user attempts to log out
///
/// Clears authentication token and user data from local storage
/// and logs out from the backend server.
class LogoutEvent extends AuthEvent {}

/// Event triggered to check the current authentication status
///
/// Used during app initialization (splash screen) to verify if user
/// has a valid authentication token and is still authenticated.
class CheckAuthStatusEvent extends AuthEvent {}

/// Event triggered when user attempts to sign in with Google
///
/// Initiates the Google OAuth flow:
/// 1. Shows Google account picker
/// 2. Authenticates with Firebase
/// 3. Sends credentials to backend
/// 4. Saves authentication token
class GoogleSignInEvent extends AuthEvent {}

/// Event triggered when user attempts to sign up with Google
///
/// Similar to GoogleSignInEvent but for new user registration.
/// Creates a new account using Google credentials.
class GoogleSignUpEvent extends AuthEvent {}

/// Event triggered when user attempts to sign out from Google
///
/// Disconnects from Google account and clears Google authentication.
class GoogleSignOutEvent extends AuthEvent {}

/// Event triggered when user requests to resend email verification
///
/// Sends a new email verification link to the user's email address.
class ResendVerificationEmailEvent extends AuthEvent {}

/// Event triggered when user requests to resend password reset OTP
///
/// Sends a new password reset OTP to the user's email address.
/// Contains:
/// - [email]: The email address to send the OTP to
class ResendPasswordResetOtpEvent extends AuthEvent {
  final String email;

  const ResendPasswordResetOtpEvent({required this.email});

  @override
  List<Object> get props => [email];
}

/// Event triggered when user verifies email OTP
///
/// Verifies the 6-digit OTP code sent to the user's email.
/// Contains:
/// - [email]: The email address to verify
/// - [otp]: The 6-digit OTP code
class VerifyEmailOtpEvent extends AuthEvent {
  final String email;
  final String otp;

  const VerifyEmailOtpEvent({required this.email, required this.otp});

  @override
  List<Object> get props => [email, otp];
}

/// Event triggered when user verifies password reset OTP (from login page)
///
/// Verifies the 6-digit OTP code for password reset.
/// Contains:
/// - [email]: The email address
/// - [otp]: The 6-digit OTP code
class VerifyPasswordResetOtpEvent extends AuthEvent {
  final String email;
  final String otp;

  const VerifyPasswordResetOtpEvent({required this.email, required this.otp});

  @override
  List<Object> get props => [email, otp];
}

/// Event triggered when user resets password (from login page)
///
/// Resets the user's password using OTP verification.
/// Contains:
/// - [email]: The email address
/// - [otp]: The 6-digit OTP code
/// - [password]: The new password
/// - [passwordConfirmation]: The password confirmation
class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String otp;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordEvent({
    required this.email,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object> get props => [email, otp, password, passwordConfirmation];
}

/// Event triggered when authenticated user verifies password reset OTP
///
/// Verifies the 6-digit OTP code for password reset (authenticated users).
/// Contains:
/// - [otp]: The 6-digit OTP code
class VerifyPasswordResetOtpAuthenticatedEvent extends AuthEvent {
  final String otp;

  const VerifyPasswordResetOtpAuthenticatedEvent({required this.otp});

  @override
  List<Object> get props => [otp];
}

/// Event triggered when authenticated user resets password
///
/// Resets the authenticated user's password using OTP verification.
/// Contains:
/// - [otp]: The 6-digit OTP code
/// - [newPassword]: The new password
/// - [newPasswordConfirmation]: The password confirmation
class ResetPasswordAuthenticatedEvent extends AuthEvent {
  final String otp;
  final String newPassword;
  final String newPasswordConfirmation;

  const ResetPasswordAuthenticatedEvent({
    required this.otp,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  @override
  List<Object> get props => [otp, newPassword, newPasswordConfirmation];
}

/// Event triggered when authenticated user requests password reset OTP
///
/// Sends a password reset OTP to the authenticated user's email.
/// No email parameter is required as it uses the authenticated user's email.
class SendPasswordResetOtpAuthenticatedEvent extends AuthEvent {
  const SendPasswordResetOtpAuthenticatedEvent();
}
