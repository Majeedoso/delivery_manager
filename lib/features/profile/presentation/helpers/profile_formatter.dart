import 'package:delivery_manager/core/utils/enums.dart';

/// Helper class for formatting profile data for display
/// This keeps formatting logic separate from UI components
class ProfileFormatter {
  /// Format role name from UserRole enum
  /// Returns the role name as a string (e.g., "operator", "customer")
  /// 
  /// Example: UserRole.operator -> "operator"
  static String formatRoleName(UserRole role) {
    return role.roleName;
  }

  /// Format status string for display
  /// Returns uppercase status or default "ACTIVE" if null
  /// 
  /// Example: "active" -> "ACTIVE", null -> "ACTIVE"
  static String formatStatus(String? status) {
    return status?.toUpperCase() ?? 'ACTIVE';
  }
}

