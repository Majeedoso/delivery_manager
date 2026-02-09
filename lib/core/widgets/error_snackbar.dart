import 'package:flutter/material.dart';
import 'package:delivery_manager/core/utils/error_message_mapper.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

/// Reusable error snackbar widget
/// 
/// Provides consistent error display across the app with:
/// - User-friendly error messages
/// - Consistent styling
/// - Optional retry action
/// - Localized messages based on user's language
class ErrorSnackBar {
  /// Show an error snackbar
  /// 
  /// [context] - BuildContext for showing snackbar
  /// [error] - The error object to display
  /// [duration] - How long to show the snackbar (default: 4 seconds)
  /// [action] - Optional action button (e.g., "Retry")
  /// [onAction] - Callback when action is pressed
  static void show(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
    String? action,
    VoidCallback? onAction,
  }) {
    // Check if error should be shown
    if (!ErrorMessageMapper.shouldShowError(error)) {
      return;
    }

    // Get localized strings
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      // Fallback if localization is not available
      // Use the English translation for 'anErrorOccurred' key as fallback
      final fallbackMessage = error?.toString() ?? 'An error occurred';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fallbackMessage),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    // Get user-friendly message
    final message = ErrorMessageMapper.getUserFriendlyMessage(error, localizations);

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: (action != null && onAction != null)
            ? SnackBarAction(
                label: action,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// Show a success snackbar
  /// 
  /// [context] - BuildContext for showing snackbar
  /// [message] - Success message to display
  /// [duration] - How long to show the snackbar (default: 3 seconds)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show an info snackbar
  /// 
  /// [context] - BuildContext for showing snackbar
  /// [message] - Info message to display
  /// [duration] - How long to show the snackbar (default: 3 seconds)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

