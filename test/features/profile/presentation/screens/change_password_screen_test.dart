import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_bloc.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_event.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_state.dart';
import 'package:delivery_manager/features/profile/presentation/screens/change_password_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/routes.dart';

/// "Change password": the current one (unless the account has none, like a
/// Google one), a strong new one typed twice; done, the page closes.
void main() {
  late MockProfileBloc profile;
  late MockAuthBloc auth;
  late StreamController<ProfileState> states;
  late RouteLog routes;
  final en = lookupAppLocalizations(const Locale('en'));

  User user({bool hasPassword = true}) => User(
    id: 7,
    name: 'Karim',
    email: 'karim@example.dz',
    phone: '0550123456',
    role: UserRole.manager,
    hasPassword: hasPassword,
  );

  setUpAll(registerFallbacks);

  setUp(() {
    profile = MockProfileBloc();
    auth = MockAuthBloc();
    states = StreamController<ProfileState>.broadcast();
    routes = RouteLog();
    whenListen(profile, states.stream, initialState: const ProfileState());
  });

  tearDown(() => states.close());

  Future<void> open(
    WidgetTester tester, {
    bool hasPassword = true,
    Locale locale = const Locale('en'),
  }) async {
    whenListen(
      auth,
      const Stream<AuthState>.empty(),
      initialState: AuthState(
        requestState: RequestState.loaded,
        user: user(hasPassword: hasPassword),
      ),
    );
    await pumpOpener<void>(
      tester,
      (context) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider<ProfileBloc>.value(
            value: profile,
            child: const ChangePasswordScreen(),
          ),
        ),
      ),
      locale: locale,
      routes: routes,
      blocs: [BlocProvider<AuthBloc>.value(value: auth)],
    );
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> submit(
    WidgetTester tester, {
    String? current = 'Old-pass1',
    String next = 'New-pass1!',
    String? confirmation,
  }) async {
    if (current != null) {
      await tester.enterText(field(en.currentPassword), current);
    }
    await tester.enterText(field(en.newPassword), next);
    await tester.enterText(field(en.confirmNewPassword), confirmation ?? next);
    await tester.tap(find.widgetWithText(ElevatedButton, en.changePassword));
    await tester.pump();
  }

  testWidgets('sends the current and the new password', (tester) async {
    await open(tester);

    await submit(tester);

    verify(
      () => profile.add(
        const ChangePasswordEvent(
          currentPassword: 'Old-pass1',
          newPassword: 'New-pass1!',
          newPasswordConfirmation: 'New-pass1!',
        ),
      ),
    ).called(1);
  });

  testWidgets('an account without a password only sets one', (tester) async {
    await open(tester, hasPassword: false);

    expect(field(en.currentPassword), findsNothing);
    await submit(tester, current: null);

    verify(
      () => profile.add(
        const ChangePasswordEvent(
          currentPassword: '',
          newPassword: 'New-pass1!',
          newPasswordConfirmation: 'New-pass1!',
        ),
      ),
    ).called(1);
  });

  group('checks before sending', () {
    testWidgets('the current password', (tester) async {
      await open(tester);

      await submit(tester, current: '');

      expect(find.text(en.currentPasswordRequired), findsOneWidget);
    });

    testWidgets('a new one of eight characters, mixed', (tester) async {
      await open(tester);

      await submit(tester, next: 'Ab1!');
      expect(find.text(en.passwordMinLength8), findsOneWidget);

      await submit(tester, next: 'alllowercase1');
      expect(find.text(en.passwordComplexity), findsOneWidget);

      verifyNever(() => profile.add(any(that: isA<ChangePasswordEvent>())));
    });

    testWidgets('typed the same twice', (tester) async {
      await open(tester);

      await submit(tester, confirmation: 'New-pass1?');

      expect(find.text(en.passwordsDoNotMatch), findsOneWidget);
      verifyNever(() => profile.add(any(that: isA<ChangePasswordEvent>())));
    });
  });

  testWidgets('forgot it: reset it with a code', (tester) async {
    await open(tester);

    await tester.tap(find.text(en.forgotPassword));
    await tester.pumpAndSettle();

    expect(routes.last.name, AppRoutes.resetPasswordAuthenticated);
  });

  testWidgets('changed: the page closes', (tester) async {
    await open(tester);

    states.add(
      const ProfileState(
        requestState: RequestState.loaded,
        message: 'Password changed successfully',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ChangePasswordScreen), findsNothing);
  });

  testWidgets('refused: says why, stays', (tester) async {
    await open(tester);

    states.add(
      const ProfileState(
        requestState: RequestState.error,
        message: 'The current password is incorrect.',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('The current password is incorrect.'), findsOneWidget);
    expect(find.byType(ChangePasswordScreen), findsOneWidget);
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await open(tester, locale: locale);

      expect(tester.takeException(), isNull);
    });
  }
}
