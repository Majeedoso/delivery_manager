import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';
import 'package:delivery_manager/features/auth/presentation/helpers/auth_navigation_helper.dart';
import 'package:delivery_manager/features/auth/presentation/screens/account_status_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/routes.dart';

/// After the start-up check or a sign-in, the user's account decides the
/// first screen: login, the account status page, or the app.
void main() {
  UserModel manager({String? status = 'active', bool verified = true}) =>
      UserModel.fromJson(
        userJson(
          status: status,
          emailVerifiedAt: verified ? '2026-09-01T10:00:00.000000Z' : null,
        ),
      );

  String routeFor(UserModel? user) =>
      AuthNavigationHelper.getRouteForUser(user);

  group('the account', () {
    test('status getters', () {
      expect(manager(status: 'active').isApproved, isTrue);
      expect(manager(status: 'active').canPerformBusinessOperations, isTrue);
      expect(manager(status: 'pending_approval').isPendingApproval, isTrue);
      expect(manager(status: 'suspended').isSuspended, isTrue);
      expect(manager(status: 'rejected').isRejected, isTrue);
      expect(manager(status: 'deleted').isDeleted, isTrue);
      expect(manager(verified: false).hasVerifiedEmail, isFalse);
    });
  });

  group('a manager', () {
    test('nobody signed in goes to login', () {
      expect(routeFor(null), LoginScreen.route);
    });

    test('an approved, verified manager goes to the app', () {
      expect(routeFor(manager()), AppRoutes.main);
    });

    test('an account waiting for approval stays on the status page', () {
      expect(
        routeFor(manager(status: 'pending_approval')),
        AccountStatusScreen.route,
      );
    });

    test('approved but with an unverified email stays on the status page', () {
      expect(routeFor(manager(verified: false)), AccountStatusScreen.route);
    });

    test('a suspended or rejected manager goes to the account status page', () {
      expect(routeFor(manager(status: 'suspended')), AccountStatusScreen.route);
      expect(routeFor(manager(status: 'rejected')), AccountStatusScreen.route);
    });

    test('a status the app does not know stays on the status page', () {
      expect(routeFor(manager(status: 'unknown')), AccountStatusScreen.route);
    });
  });

  test('every business role is treated the same', () {
    for (final role in [
      UserRole.driver,
      UserRole.restaurant,
      UserRole.operator,
      UserRole.manager,
    ]) {
      final user = UserModel.fromJson(
        userJson(role: role.name, status: 'suspended'),
      );
      expect(routeFor(user), AccountStatusScreen.route, reason: role.name);
    }
  });

  testWidgets('navigating replaces the whole history', (tester) async {
    final routes = RouteLog();
    await pumpPage(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => AuthNavigationHelper.navigateBasedOnUserStatus(
            context,
            manager(),
          ),
          child: const Text('go'),
        ),
      ),
      routes: routes,
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(routes.last.name, AppRoutes.main);
    expect(find.text('go'), findsNothing, reason: 'nothing to go back to');
  });
}
