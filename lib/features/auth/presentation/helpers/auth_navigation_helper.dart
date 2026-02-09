import 'package:flutter/material.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';
import 'package:delivery_manager/features/home/presentation/screens/main_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/account_status_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/login_screen.dart';

/// Helper class for authentication-related navigation logic
/// Centralizes the logic for determining where to navigate based on user status and role
class AuthNavigationHelper {
  /// Get the appropriate route based on user authentication status and role
  ///
  /// Returns:
  /// - LoginScreen.route if user is null
  /// - AccountStatusScreen.route for business users with pending/suspended/rejected status
  /// - MainScreen.route for approved business users or customer role
  static String getRouteForUser(User? user) {
    if (user == null) {
      return LoginScreen.route;
    }

    // Check account status for business roles
    if (user.role == UserRole.operator ||
        user.role == UserRole.restaurant ||
        user.role == UserRole.driver ||
        user.role == UserRole.manager) {
      if (user.isPendingApproval || user.isSuspended || user.isRejected) {
        // Account needs approval or is suspended/rejected - show status screen
        return AccountStatusScreen.route;
      } else if (user.isApproved) {
        // Account is approved - check email verification
        if (!user.hasVerifiedEmail) {
          // Account is approved but email is not verified - show status screen
          return AccountStatusScreen.route;
        }
        // Account is approved and email is verified - allow access
        return MainScreen.route;
      } else {
        // Unknown status - show status screen
        return AccountStatusScreen.route;
      }
    } else {
      // Customer role - no approval needed, go directly to main screen
      return MainScreen.route;
    }
  }

  /// Navigate to the appropriate screen based on user status
  ///
  /// Removes all previous routes from the navigation stack
  static void navigateBasedOnUserStatus(BuildContext context, User? user) {
    print('🔵 [NAV_HELPER] Navigating based on user status...');
    print(
      '🔵 [NAV_HELPER] User: ${user?.email}, status: ${user?.status}, role: ${user?.role}',
    );
    print(
      '🔵 [NAV_HELPER] isPendingApproval: ${user?.isPendingApproval}, isApproved: ${user?.isApproved}',
    );
    print('🔵 [NAV_HELPER] hasVerifiedEmail: ${user?.hasVerifiedEmail}');
    final route = getRouteForUser(user);
    print('🔵 [NAV_HELPER] Selected route: $route');
    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
    print('🔵 [NAV_HELPER] Navigation completed');
  }
}
