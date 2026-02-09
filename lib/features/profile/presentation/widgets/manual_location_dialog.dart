import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class ManualLocationDialog extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final void Function(double, double) onSave;

  const ManualLocationDialog({
    super.key,
    required this.initialLat,
    required this.initialLng,
    required this.onSave,
  });

  @override
  State<ManualLocationDialog> createState() => _ManualLocationDialogState();
}

class _ManualLocationDialogState extends State<ManualLocationDialog> {
  late TextEditingController _latController;
  late TextEditingController _lngController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _latController = TextEditingController(
      text: widget.initialLat == 0 ? '' : widget.initialLat.toString(),
    );
    _lngController = TextEditingController(
      text: widget.initialLng == 0 ? '' : widget.initialLng.toString(),
    );
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(localizations.enterCoordinatesManually),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _latController,
              decoration: InputDecoration(
                labelText: localizations.latitude,
                prefixIcon: const Icon(Icons.map),
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return localizations.latitudeRequired;
                }
                final lat = double.tryParse(value.trim());
                if (lat == null) {
                  return localizations.invalidLatitude;
                }
                if (lat < -90 || lat > 90) {
                  return localizations.latitudeRange;
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _lngController,
              decoration: InputDecoration(
                labelText: localizations.longitude,
                prefixIcon: const Icon(Icons.map),
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return localizations.longitudeRequired;
                }
                final lng = double.tryParse(value.trim());
                if (lng == null) {
                  return localizations.invalidLongitude;
                }
                if (lng < -180 || lng > 180) {
                  return localizations.longitudeRange;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: 30.w,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.grey,
            ),
            child: Text(
              localizations.cancel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        SizedBox(
          width: 30.w,
          child: TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final lat = double.tryParse(_latController.text.trim()) ?? 0;
                final lng = double.tryParse(_lngController.text.trim()) ?? 0;
                widget.onSave(lat, lng);
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              localizations.save,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

