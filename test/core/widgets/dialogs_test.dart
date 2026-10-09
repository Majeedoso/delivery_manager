import 'package:delivery_manager/core/widgets/error_dialog.dart';
import 'package:delivery_manager/core/widgets/initialization_error_screen.dart';
import 'package:delivery_manager/core/widgets/unsaved_changes_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump.dart';

/// The shared dialogs: login failures, unsaved edits, and the screen shown
/// when the app cannot start.
void main() {
  group('ErrorDialog', () {
    testWidgets('shows the title, the message and one button', (tester) async {
      var pressed = 0;
      final closed = await pumpOpener<void>(
        tester,
        (context) => ErrorDialog.show(
          context,
          title: 'Payment not sent',
          message: 'The restaurant has not confirmed the last one',
          buttonText: 'Back',
          onPressed: () => pressed++,
        ),
      );

      expect(find.text('Payment not sent'), findsOneWidget);
      expect(
        find.text('The restaurant has not confirmed the last one'),
        findsOneWidget,
      );

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      await closed;

      expect(find.byType(AlertDialog), findsNothing);
      expect(pressed, 1, reason: 'the callback runs after the dialog closes');
    });

    testWidgets('stays open when tapping outside it', (tester) async {
      await pumpOpener<void>(
        tester,
        (context) => ErrorDialog.show(context, title: 'T', message: 'M'),
      );

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('OK'), findsOneWidget, reason: 'the default button');
    });

    testWidgets('the ready-made variants explain the problem', (tester) async {
      await pumpOpener<void>(
        tester,
        (context) => ErrorDialog.showRoleMismatch(
          context,
          message: 'This account belongs to a customer',
        ),
      );
      expect(find.text('Wrong App'), findsOneWidget);
      expect(find.text('Understood'), findsOneWidget);
      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();

      await pumpOpener<void>(
        tester,
        (context) => ErrorDialog.showAccountNotFound(context),
      );
      expect(find.text('Account Not Found'), findsOneWidget);
      expect(
        find.text(
          "No manager account uses this email. Manager accounts are created by the platform's team, not in the app.",
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await pumpOpener<void>(
        tester,
        (context) => ErrorDialog.showInvalidCredentials(context),
      );
      expect(find.text('Login Failed'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('fits a phone in Arabic', (tester) async {
      await pumpOpener<void>(
        tester,
        (context) => ErrorDialog.showInvalidCredentials(context),
        locale: const Locale('ar'),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('UnsavedChangesDialog', () {
    testWidgets('discard answers true', (tester) async {
      var saved = 0;
      final answer = await pumpOpener<bool>(
        tester,
        (context) => UnsavedChangesDialog.show(context, onSave: () => saved++),
      );

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(await answer, isTrue);
      expect(saved, 0);
    });

    testWidgets('save answers false and saves', (tester) async {
      var saved = 0;
      final answer = await pumpOpener<bool>(
        tester,
        (context) => UnsavedChangesDialog.show(context, onSave: () => saved++),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(await answer, isFalse, reason: 'the caller stays until saved');
      expect(saved, 1);
    });

    testWidgets('tapping outside answers nothing', (tester) async {
      final answer = await pumpOpener<bool>(
        tester,
        (context) => UnsavedChangesDialog.show(context, onSave: () {}),
      );

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(await answer, isNull);
    });
  });

  group('InitializationErrorScreen', () {
    testWidgets('shows why the app could not start, with a retry', (
      tester,
    ) async {
      var retries = 0;
      usePhoneScreen(tester);
      await tester.pumpWidget(
        InitializationErrorScreen(
          errorMessage: 'Firebase initialization timed out after 10 seconds',
          onRetry: () => retries++,
        ),
      );

      expect(
        tester.takeException(),
        isNull,
        reason: 'it read its texts above its own MaterialApp and crashed (D12)',
      );
      expect(find.text('Initialization failed'), findsOneWidget);
      expect(
        find.text('Firebase initialization timed out after 10 seconds'),
        findsOneWidget,
      );
      await tester.tap(find.text('Retry'));

      expect(retries, 1);
    });

    testWidgets('speaks the phone\'s language', (tester) async {
      usePhoneScreen(tester);
      tester.platformDispatcher.localesTestValue = const [
        Locale('ar', 'DZ'),
        Locale('fr'),
      ];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(
        InitializationErrorScreen(errorMessage: 'Broken', onRetry: () {}),
      );

      expect(find.text('فشل في التهيئة'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('has no retry button when nothing can be retried', (
      tester,
    ) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(
        const InitializationErrorScreen(errorMessage: 'Broken'),
      );

      expect(find.text('Retry'), findsNothing);
    });
  });
}
