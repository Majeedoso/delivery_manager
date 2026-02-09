import 'package:equatable/equatable.dart';

/// App version entity representing version information from the server
/// 
/// This entity contains:
/// - minimum_version: The minimum required version for the app
/// - current_version: The latest available version
/// - update_url_ios: App Store URL for iOS updates
/// - update_url_android: Play Store URL for Android updates
class AppVersion extends Equatable {
  final String minimumVersion;
  final String currentVersion;
  final String? updateUrlIos;
  final String? updateUrlAndroid;

  const AppVersion({
    required this.minimumVersion,
    required this.currentVersion,
    this.updateUrlIos,
    this.updateUrlAndroid,
  });

  @override
  List<Object?> get props => [
        minimumVersion,
        currentVersion,
        updateUrlIos,
        updateUrlAndroid,
      ];
}

