import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/features/settings/presentation/screens/settings_screen.dart';

/// Screen displayed when app update is required
/// 
/// This screen is shown when the current app version is below the minimum
/// required version. It displays a message and provides buttons to update
/// the app from the App Store (iOS) or Play Store (Android).
class UpdateRequiredScreen extends StatelessWidget {
  final AppVersion appVersion;
  final String userCurrentVersion;

  const UpdateRequiredScreen({
    super.key,
    required this.appVersion,
    required this.userCurrentVersion,
  });
  
  /// Route name for navigation
  static const String route = '/update-required';
  
  
  /// Open App Store or Play Store to update the app
  Future<void> _openStore(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      // Fallback URLs if not provided
      final fallbackUrl = Theme.of(context).platform == TargetPlatform.iOS
          ? 'https://apps.apple.com'
          : 'https://play.google.com/store';
      
      final uri = Uri.parse(fallbackUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final updateUrl = isIOS ? appVersion.updateUrlIos : appVersion.updateUrlAndroid;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, SettingsScreen.route);
            },
            icon: Icon(
              Icons.settings,
              size: 24.sp,
            ),
            tooltip: localizations.settings,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              //  SizedBox(height: 4.h),
                
                // App Icon or Logo
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.system_update,
                    size: 60.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                
                // Title
                Text(
                  localizations.updateRequired,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                
                // Description
                Text(
                  localizations.updateRequiredDescription,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                
                // Version Info
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        localizations.yourCurrentVersion,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        userCurrentVersion,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      ),
                      SizedBox(height: 1.5.h),
                      Divider(
                        color: Colors.black.withOpacity(0.3),
                        height: 1,
                      ),
                      SizedBox(height: 1.5.h),
                      Text(
                        localizations.minimumRequiredVersion,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        appVersion.minimumVersion,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                      ),
                      SizedBox(height: 1.5.h),
                      Divider(
                        color: Colors.black.withOpacity(0.3),
                        height: 1,
                      ),
                      SizedBox(height: 1.5.h),
                      Text(
                        localizations.latestAvailableVersion,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        appVersion.currentVersion,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                
                // Update Button
                ElevatedButton(
                  onPressed: () => _openStore(context, updateUrl),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4.0,
                  ),
                  child: Text(
                    localizations.updateNow,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                
                // Info text
                Text(
                  localizations.updateIsRequired,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

