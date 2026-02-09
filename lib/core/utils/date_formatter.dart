import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Helper class for formatting dates for display
/// This keeps formatting logic separate from UI components
/// All formatting methods require BuildContext for localization
class DateFormatter {
  /// Format date for date picker display
  /// Format: "DD/MM/YYYY"
  /// Returns localized "Select date" if date is null
  /// 
  /// Example: "15/01/2024" or "Select date" (localized)
  static String formatDate(BuildContext context, DateTime? date) {
    if (date == null) {
      return AppLocalizations.of(context)!.selectDate;
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format date with time for display
  /// Format: "DD/MM/YYYY HH:MM"
  /// 
  /// Example: "15/01/2024 14:30"
  static String formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

