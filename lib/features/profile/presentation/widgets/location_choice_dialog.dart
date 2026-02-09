import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

enum LocationChoice { manual, map }

class LocationChoiceDialog extends StatelessWidget {
  const LocationChoiceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(localizations.selectLocationMethod),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(
          width: 30.w,
          child: TextButton(
            onPressed: () => Navigator.pop(context, LocationChoice.manual),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              localizations.manualEntry,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        SizedBox(
          width: 30.w,
          child: TextButton(
            onPressed: () => Navigator.pop(context, LocationChoice.map),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              localizations.fromMap,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

