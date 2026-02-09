import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

/// A reusable dialog for confirming unsaved changes.
/// 
/// Returns:
/// - `true` if user wants to discard changes
/// - `false` if user wants to save changes (caller should handle saving)
/// - `null` if user cancels (clicks outside or back button)
class UnsavedChangesDialog {
  /// Shows the unsaved changes confirmation dialog.
  /// 
  /// Parameters:
  /// - [context]: BuildContext to show the dialog
  /// - [onSave]: Callback function to execute when user clicks Save
  /// 
  /// Returns:
  /// - `true` if user wants to discard changes
  /// - `false` if user wants to save (onSave will be called)
  /// - `null` if user cancels
  static Future<bool?> show(
    BuildContext context, {
    required VoidCallback onSave,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.unsavedChanges ?? 'Unsaved Changes'),
        content: Text(AppLocalizations.of(context)?.unsavedChangesMessage ?? 
            'You have unsaved changes. Do you want to save them or discard them?'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true), // Discard
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)?.discard ?? 'Discard'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Don't pop yet, caller will handle
                    onSave();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)?.save ?? 'Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

