import 'package:flutter/material.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

/// Shows a confirmation dialog for removing an image.
/// Returns `true` if the user confirms removal, `false` if cancelled, or `null` if dismissed.
Future<bool?> showRemoveImageConfirmationDialog(BuildContext context) async {
  final localizations = AppLocalizations.of(context)!;
  
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(localizations.removeImage),
      content: Text(localizations.areYouSureYouWantToRemoveThisImage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(localizations.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: Text(localizations.remove),
        ),
      ],
    ),
  );

  return result;
}

