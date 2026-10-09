import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump.dart';

/// ErrorSnackBar is how 22 screens report a failure: one red bar with a
/// readable message, optionally with an action such as "Retry".
void main() {
  /// Pumps a page whose button reports [error].
  Future<void> report(
    WidgetTester tester,
    Object? error, {
    String? action,
    VoidCallback? onAction,
    Locale locale = const Locale('en'),
  }) async {
    await pumpPage(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => ErrorSnackBar.show(
                context,
                error,
                action: action,
                onAction: onAction,
              ),
              child: const Text('fail'),
            ),
          ),
        ),
      ),
      locale: locale,
    );
    await tester.tap(find.text('fail'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // the bar slides in
  }

  testWidgets('shows the readable message in a red bar', (tester) async {
    await report(tester, const ServerFailure('Restaurant is closed'));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Restaurant is closed'), findsOneWidget);
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
      Colors.red.shade700,
    );
  });

  testWidgets('a refusal to cancel an order is shown', (tester) async {
    await report(
      tester,
      const ServerFailure('Order cannot be cancelled at this stage'),
    );

    expect(
      find.text('Order cannot be cancelled at this stage'),
      findsOneWidget,
      reason: 'the manager tapped cancel and must learn why nothing happened',
    );
  });

  testWidgets('closing Google sign-in shows nothing', (tester) async {
    await report(
      tester,
      const ServerException(message: 'Google sign-in was cancelled'),
    );

    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('an action button runs its callback', (tester) async {
    var retried = 0;
    await report(
      tester,
      const NetworkFailure('Connection timeout'),
      action: 'Retry',
      onAction: () => retried++,
    );

    await tester.tap(find.text('Retry'));

    expect(retried, 1);
  });

  testWidgets('the message follows the manager\'s language', (tester) async {
    await report(
      tester,
      const NetworkFailure('Connection timeout'),
      locale: const Locale('ar'),
    );

    expect(
      find.text(
        'انتهت مهلة الطلب. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('success and info messages are switched off by design', (
    tester,
  ) async {
    await pumpPage(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () {
              ErrorSnackBar.showSuccess(context, 'Saved');
              ErrorSnackBar.showInfo(context, 'FYI');
            },
            child: const Text('go'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pump();

    expect(find.byType(SnackBar), findsNothing);
  });
}
