import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

/// Helper class for formatting profile data for display
/// This keeps formatting logic separate from UI components
class ProfileFormatter {
  /// The role as the manager reads it: this app's accounts are managers
  /// (another role, which the server never lets in, keeps its own name).
  static String formatRoleName(UserRole role, AppLocalizations l10n) {
    return role == UserRole.manager ? l10n.manager : role.roleName;
  }

  /// The account status in capitals: "active" (or none) in the manager's
  /// language, any other as the server names it.
  static String formatStatus(String? status, AppLocalizations l10n) {
    if (status == null || status == 'active') return l10n.active.toUpperCase();
    return status.toUpperCase();
  }
}

