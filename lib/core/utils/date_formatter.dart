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
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

