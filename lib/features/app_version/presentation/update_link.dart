import 'package:delivery_manager/core/config/app_config.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Where the new version is: the server's link for this platform, else, on
/// Android, the APK the server hosts (`public/downloads/manager.apk`). The
/// app is installed directly, not from a store, so a store page would have
/// nothing to install. On an iPhone there is nothing to fall back on.
String? updateLinkFor(AppVersion version, TargetPlatform platform) {
  final isIOS = platform == TargetPlatform.iOS;
  final link = isIOS ? version.updateUrlIos : version.updateUrlAndroid;
  if (link != null && link.isNotEmpty) return link;
  return isIOS ? null : '${AppConfig.hostUrl}/downloads/manager.apk';
}

/// Opens the new version for this device. When there is none to open (an
/// iPhone without a link from the server) or it can't be opened, the
/// manager is told so: the update button never does nothing.
Future<bool> openUpdateLink(BuildContext context, AppVersion version) async {
  final l10n = AppLocalizations.of(context)!;
  final link = updateLinkFor(version, Theme.of(context).platform);
  var opened = false;
  if (link != null) {
    try {
      opened = await launchUrl(
        Uri.parse(link),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
  }
  if (!opened && context.mounted) {
    ErrorSnackBar.show(context, l10n.updateLinkUnavailable);
  }
  return opened;
}
