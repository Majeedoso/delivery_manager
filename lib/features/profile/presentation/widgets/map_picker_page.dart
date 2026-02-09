import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/core/widgets/unsaved_changes_dialog.dart';
import 'package:delivery_manager/core/config/app_config.dart';

class MapPickerPage extends StatefulWidget {
  static const String routeName = "MapPickerPage";
  final double? initialLat;
  final double? initialLng;

  const MapPickerPage({super.key, this.initialLat, this.initialLng});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng? selectedLocation;
  late final LatLng _initialLocation;
  late final MapController _mapController;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();

    _initialLocation = LatLng(
      (widget.initialLat == null || widget.initialLat == 0)
          ? 36.247524721057616
          : widget.initialLat!,
      (widget.initialLng == null || widget.initialLng == 0)
          ? 0.92113119431679
          : widget.initialLng!,
    );

    selectedLocation = _initialLocation;
    _mapController = MapController();
  }

  bool _hasUnsavedChanges() {
    if (selectedLocation == null) return false;

    // Check if location has changed (with small tolerance for floating point precision)
    const tolerance = 0.000001;
    final latChanged =
        (selectedLocation!.latitude - _initialLocation.latitude).abs() >
        tolerance;
    final lngChanged =
        (selectedLocation!.longitude - _initialLocation.longitude).abs() >
        tolerance;

    return latChanged || lngChanged;
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges()) {
      return true; // Allow pop if no changes
    }

    // Show confirmation dialog
    final result = await UnsavedChangesDialog.show(
      context,
      onSave: () {
        // Return the selected location
        Navigator.pop(context, selectedLocation);
      },
    );

    return result ?? false; // Discard if result is null (user clicked outside)
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ErrorSnackBar.show(
            context,
            'Location services are disabled. Please enable location services.',
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ErrorSnackBar.show(context, 'Location permissions are denied.');
          }
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ErrorSnackBar.show(
            context,
            'Location permissions are permanently denied. Please enable them in app settings.',
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        selectedLocation = currentLocation;
        _isLoadingLocation = false;
      });

      // Move map to current location
      _mapController.move(currentLocation, 15);
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(context, 'Error getting location: ${e.toString()}');
      }
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  String _getMapStyleUrl() {
    return 'https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v12/tiles/{z}/{x}/{y}?access_token=${AppConfig.mapboxAccessToken}';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Icon color: white in dark mode, black in light mode
    final iconColor = isDark ? Colors.white : Colors.black;
    // Button background matches sign up button background color
    const buttonBackgroundColor = Color(0xFFFF8A32);

    return PopScope(
      canPop: !_hasUnsavedChanges(),
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (!_hasUnsavedChanges()) {
          Navigator.of(context).pop();
          return;
        }

        // Show confirmation dialog
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(localizations.selectLocationOnMap)),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: selectedLocation!,
                initialZoom: 14,
                onTap: (tapPosition, point) {
                  setState(() => selectedLocation = point);
                },
                // Enable gesture controls for pinch zoom and rotation
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: _getMapStyleUrl(),
                  userAgentPackageName: 'com.delivery.driver',
                ),
                if (selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // My Location button
            Positioned(
              bottom: 90,
              left: 16,
              child: FloatingActionButton(
                heroTag: 'my_location',
                backgroundColor: buttonBackgroundColor,
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                child: _isLoadingLocation
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                        ),
                      )
                    : Icon(Icons.my_location, color: iconColor),
              ),
            ),

            // Select Location Button (Save)
            Positioned(
              bottom: 20,
              left: 16,
              child: FloatingActionButton(
                heroTag: 'select_location',
                backgroundColor: Colors.green,
                onPressed: selectedLocation != null
                    ? () {
                        Navigator.pop(context, selectedLocation);
                      }
                    : null,
                child: const Icon(Icons.check, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
