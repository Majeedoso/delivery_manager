import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/utils/app_navigator.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';
import 'package:delivery_manager/features/auth/domain/usecases/load_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/save_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fakes.dart';
import '../../../../helpers/locator.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/routes.dart';

/// The login screen: email and password (with "remember me"), Google, and the
/// ways out to sign-up, forgotten password and settings. Its answer to a
/// failed login depends on why it failed.
void main() {
  late MockAuthBloc auth;
  late MockLoadCredentialsUseCase loadCredentials;
  late MockSaveCredentialsUseCase saveCredentials;
  late StreamController<AuthState> states;
  late RouteLog routes;

  setUpAll(registerFallbacks);

  setUp(() {
    auth = MockAuthBloc();
    loadCredentials = MockLoadCredentialsUseCase();
    saveCredentials = MockSaveCredentialsUseCase();
    states = StreamController<AuthState>.broadcast();
    routes = RouteLog();
    whenListen(auth, states.stream, initialState: const AuthState());
    when(
      () => loadCredentials(any()),
    ).thenAnswer((_) async => const Right({'email': null, 'rememberMe': null}));
    when(
      () => saveCredentials(any()),
    ).thenAnswer((_) async => const Right(true));
    registerUseCase<LoadCredentialsUseCase>(loadCredentials);
    registerUseCase<SaveCredentialsUseCase>(saveCredentials);
  });

  tearDown(() => states.close());

  /// The e-mail form unless [withEmail] is false: the sign-in page, two buttons.
  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool withEmail = true,
  }) => pumpPage(
    tester,
    LoginScreen(withEmail: withEmail),
    locale: locale,
    routes: routes,
    blocs: [BlocProvider<AuthBloc>.value(value: auth)],
  );

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'the footer says the copyright in the app\'s language, with this year',
    (tester) async {
      await withClock(
        Clock.fixed(DateTime(2027, 3, 1)),
        () => pump(tester, locale: const Locale('fr')),
      );

      expect(
        find.text('© 2027 LihLih Manager. Tous droits réservés.'),
        findsOneWidget,
      );
      expect(find.textContaining('2024'), findsNothing);
    },
  );

  testWidgets('a remembered email is filled in', (tester) async {
    when(() => loadCredentials(any())).thenAnswer(
      (_) async =>
          const Right({'email': 'karim@example.dz', 'rememberMe': 'true'}),
    );

    await pump(tester);

    expect(find.text('karim@example.dz'), findsOneWidget);
  });

  group('the form', () {
    testWidgets('empty fields are refused', (tester) async {
      await pump(tester);

      await submit(tester);

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
      verifyNever(() => auth.add(any()));
    });

    testWidgets('an email without @ and a short password are refused', (
      tester,
    ) async {
      await pump(tester);

      await tester.enterText(field('Email'), 'karim.example.dz');
      await tester.enterText(field('Password'), '12345');
      await submit(tester);

      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
      verifyNever(() => auth.add(any()));
    });

    testWidgets('a valid form remembers the email and logs in', (tester) async {
      await pump(tester);

      await tester.enterText(field('Email'), '  karim@example.dz ');
      await tester.enterText(field('Password'), 'Secret#2026');
      await submit(tester);

      final saved =
          verify(() => saveCredentials(captureAny())).captured.single
              as SaveCredentialsParameters;
      expect(saved.email, 'karim@example.dz', reason: 'trimmed');
      expect(saved.rememberMe, isTrue, reason: 'on by default');
      verify(
        () => auth.add(
          const LoginEvent(email: 'karim@example.dz', password: 'Secret#2026'),
        ),
      ).called(1);
    });

    testWidgets('unticking remember me forgets the email', (tester) async {
      await pump(tester);

      await tester.tap(find.byType(Checkbox));
      await tester.enterText(field('Email'), 'karim@example.dz');
      await tester.enterText(field('Password'), 'Secret#2026');
      await submit(tester);

      final saved =
          verify(() => saveCredentials(captureAny())).captured.single
              as SaveCredentialsParameters;
      expect(saved.rememberMe, isFalse);
    });

    testWidgets('the password can be shown and hidden', (tester) async {
      await pump(tester);
      EditableText password() => tester.widget<EditableText>(
        find.descendant(
          of: field('Password'),
          matching: find.byType(EditableText),
        ),
      );

      expect(password().obscureText, isTrue);
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      expect(password().obscureText, isFalse);
    });
  });

  group('the sign-in page', () {
    testWidgets('offers two buttons, Google and e-mail, and no form', (
      tester,
    ) async {
      await pump(tester, withEmail: false);

      // Google is the orange button, e-mail the outlined one
      expect(
        find.widgetWithText(ElevatedButton, 'Sign in with Google'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(OutlinedButton, 'Sign in with Email'),
        findsOneWidget,
      );
      expect(find.byType(TextFormField), findsNothing);
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('the e-mail button opens the form, with a way back', (
      tester,
    ) async {
      await pumpPage(
        tester,
        const LoginScreen(),
        routes: routes,
        blocs: [BlocProvider<AuthBloc>.value(value: auth)],
        onGenerateRoute: (settings) => settings.name == AppRoutes.loginEmail
            ? MaterialPageRoute(
                settings: settings,
                builder: (_) => const LoginScreen(withEmail: true),
              )
            : stubRoute(settings),
      );

      await tester.tap(find.text('Sign in with Email'));
      await tester.pumpAndSettle();

      expect(routes.last.name, AppRoutes.loginEmail);
      expect(find.byType(TextFormField), findsNWidgets(2));
      verifyNever(() => auth.add(any()));

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Sign in with Email'), findsOneWidget);
    });

    testWidgets('the form has no Google button and no sign-up link', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('Sign in with Google'), findsNothing);
      expect(find.text('Sign in with Email'), findsNothing);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Sign Up'), findsNothing);
    });
  });

  testWidgets('Google sign-in is one tap', (tester) async {
    await pump(tester, withEmail: false);

    await tester.tap(find.text('Sign in with Google'));

    verify(() => auth.add(GoogleSignInEvent())).called(1);
  });

  testWidgets('while signing in, the screen is covered and blocked', (
    tester,
  ) async {
    await pump(tester, withEmail: false);

    states.add(const AuthState(requestState: RequestState.loading));
    await tester.pump();
    await tester.pump(); // the mock bloc's stream adds a hop

    expect(find.byType(AbsorbPointer), findsWidgets);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Sign in with Google'),
          )
          .onPressed,
      isNull,
      reason: 'no second sign-in while one runs',
    );
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
      reason: 'nor the e-mail form',
    );
  });

  group('after the answer', () {
    testWidgets('a signed-in manager goes to the app', (tester) async {
      await pump(tester);

      states.add(
        AuthState(
          requestState: RequestState.loaded,
          isAuthenticated: true,
          user: UserModel.fromJson(userJson()),
        ),
      );
      await tester.pumpAndSettle();

      expect(routes.last.name, AppRoutes.main);
    });

    Future<void> failWith(
      WidgetTester tester,
      String message, {
      String? code,
    }) async {
      await pump(tester);
      states.add(
        AuthState(
          requestState: RequestState.error,
          message: message,
          errorCode: code,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }

    // The server names the refusals that need explaining; its message is in
    // the app's language, so the page never reads its words
    testWidgets('wrong credentials open the explaining dialog', (tester) async {
      await failWith(
        tester,
        'Identifiants invalides',
        code: 'INVALID_CREDENTIALS',
      );

      expect(find.text('Login Failed'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('an account of another app says so', (tester) async {
      await failWith(
        tester,
        "Ce compte est un compte client. Utilisez l'application client pour vous connecter.",
        code: 'ROLE_MISMATCH',
      );

      expect(find.text('Wrong App'), findsOneWidget);
      expect(
        find.text(
          "Ce compte est un compte client. Utilisez l'application client pour vous connecter.",
        ),
        findsOneWidget,
      );
    });

    testWidgets('an unknown account is told who creates managers', (
      tester,
    ) async {
      // The server's sentence says to sign up first, which a manager cannot
      // do (M1)
      await failWith(
        tester,
        'الحساب غير موجود. يرجى إنشاء حساب أولًا.',
        code: 'ACCOUNT_NOT_FOUND',
      );

      expect(find.text('Account Not Found'), findsOneWidget);
      expect(
        find.text(
          'No manager account uses this email. Manager accounts are created '
          "by the platform's team, not in the app.",
        ),
        findsOneWidget,
      );
      expect(find.text('الحساب غير موجود. يرجى إنشاء حساب أولًا.'), findsNothing);
    });

    testWidgets('the words alone decide nothing', (tester) async {
      // The English sentences the page used to look for, without a code
      await failWith(tester, 'Invalid credentials');

      expect(find.text('Login Failed'), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('anything else shows in a snackbar', (tester) async {
      await failWith(tester, 'Too many attempts. Try again in a minute.');

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Too many attempts. Try again in a minute.'),
        findsOneWidget,
      );
    });

    testWidgets('under "forgot password" it stays quiet', (tester) async {
      await pump(tester);
      navigatorKey.currentState!.pushNamed(AppRoutes.forgotPassword);
      await tester.pumpAndSettle();

      // Laravel's answer to an unknown email on "forgot password"
      states.add(
        const AuthState(
          requestState: RequestState.error,
          message: 'The selected email is invalid.',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.text('Login Failed'),
        findsNothing,
        reason: 'it read "invalid" and "email" as a failed login',
      );
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('the ways out', () {
    testWidgets('forgotten password', (tester) async {
      await pump(tester);

      await scrollTo(tester, find.text('Forgot Password'));
      await tester.tap(find.text('Forgot Password'));
      await tester.pumpAndSettle();

      expect(routes.last.name, AppRoutes.forgotPassword);
    });

    testWidgets('no way to sign up: managers are created on the server', (
      tester,
    ) async {
      await pump(tester);

      // The page offered "Sign Up", and the server refuses every manager
      // sign-up (M1)
      expect(find.text('Sign Up'), findsNothing);
      expect(find.text("Don't have an account? "), findsNothing);
    });

    testWidgets('settings', (tester) async {
      await pump(tester);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(routes.last.name, AppRoutes.settings);
    });
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    for (final withEmail in const [false, true]) {
      testWidgets(
        '${withEmail ? 'the form' : 'the sign-in page'} fits a phone in ${locale.languageCode}',
        (tester) async {
          await pump(tester, locale: locale, withEmail: withEmail);

          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
