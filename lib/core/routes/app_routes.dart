/// Route names constants for the application
///
/// This file contains all route names used throughout the app
/// to ensure consistency and prevent typos.
class AppRoutes {
  // Prevent instantiation
  AppRoutes._();

  // Auth routes
  static const String firstRunLanguage = '/first-run-language';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signupChoice = '/signup-choice';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPasswordUnauthenticated =
      '/reset-password-unauthenticated';
  static const String accountStatus = '/account-status';
  static const String verifyEmailOtp = '/verify-email-otp';

  // Home routes
  static const String main = '/main';

  // Profile routes
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String changeEmail = '/change-email';
  static const String verifyEmailChangeOtp = '/verify-email-change-otp';
  static const String resetPasswordAuthenticated =
      '/reset-password-authenticated';
  static const String verifyDeleteAccountOtp = '/verify-delete-account-otp';

  // Settings routes
  static const String settings = '/settings';
  static const String about = '/about';
  static const String languageSelection = '/language-selection';
  static const String updateRequired = '/update-required';

  // Map picker route
  static const String mapPicker = '/map-picker';

  // Bank routes
  static const String bank = '/bank';
  static const String bankReceivables = '/bank-receivables';
  static const String bankNewTransaction = '/bank-new-transaction';
  static const String bankArchive = '/bank-archive';
  static const String driverDebtDetails = '/driver-debt-details';
}
