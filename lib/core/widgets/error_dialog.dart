import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

/// A reusable error dialog widget for displaying important error messages
///
/// Use this for errors that:
/// - Require user acknowledgment
/// - Need explanation (e.g., role mismatch, account issues)
/// - Have actionable information
///
/// For temporary/minor errors, use [ErrorSnackBar] instead.
class ErrorDialog {
  /// Show an error dialog
  ///
  /// [context] - BuildContext for showing dialog
  /// [title] - Dialog title
  /// [message] - Error message to display
  /// [icon] - Optional icon (defaults to error icon)
  /// [iconColor] - Icon color (defaults to red)
  /// [buttonText] - Button text (defaults to "OK")
  /// [onPressed] - Optional callback when button is pressed
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.error_outline,
    Color? iconColor,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    final localizations = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.w),
          ),
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          contentPadding: EdgeInsets.zero,
          content: Container(
            constraints: BoxConstraints(maxWidth: 80.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon section with colored background
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  decoration: BoxDecoration(
                    color: (iconColor ?? Colors.red).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.w),
                      topRight: Radius.circular(4.w),
                    ),
                  ),
                  child: Icon(icon, size: 16.w, color: iconColor ?? Colors.red),
                ),
                // Content section
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 3.h),
                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 6.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            onPressed?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: iconColor ?? Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.w),
                            ),
                          ),
                          child: Text(
                            buttonText ?? localizations?.ok ?? 'OK',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show a role mismatch error dialog
  ///
  /// Specialized dialog for when user tries to login with wrong app
  static Future<void> showRoleMismatch(
    BuildContext context, {
    required String message,
  }) {
    final localizations = AppLocalizations.of(context);

    return show(
      context,
      title: localizations?.wrongApp ?? 'Wrong App',
      message: message,
      icon: Icons.app_blocking,
      iconColor: Colors.orange,
      buttonText: localizations?.understood ?? 'Understood',
    );
  }

  /// Show an account not found error dialog
  ///
  /// Specialized dialog for when account doesn't exist
  static Future<void> showAccountNotFound(
    BuildContext context, {
    String? message,
  }) {
    final localizations = AppLocalizations.of(context);

    return show(
      context,
      title: localizations?.accountNotFound ?? 'Account Not Found',
      message:
          message ??
          localizations?.accountNotFoundMessage ??
          'No account found with this email. Please sign up first.',
      icon: Icons.person_off,
      iconColor: Colors.orange,
      buttonText: localizations?.ok ?? 'OK',
    );
  }

  /// Show invalid credentials error dialog
  ///
  /// Specialized dialog for wrong email/password
  static Future<void> showInvalidCredentials(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return show(
      context,
      title: localizations?.loginFailed ?? 'Login Failed',
      message:
          localizations?.invalidCredentialsMessage ??
          'The email or password you entered is incorrect. Please check your credentials and try again.',
      icon: Icons.lock_outline,
      iconColor: Colors.red,
      buttonText: localizations?.tryAgain ?? 'Try Again',
    );
  }
}
