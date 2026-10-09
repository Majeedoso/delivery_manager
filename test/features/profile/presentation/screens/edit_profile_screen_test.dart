import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/profile/data/models/profile_model.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_bloc.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_event.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_state.dart';
import 'package:delivery_manager/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fakes.dart';
import '../../../../helpers/pump.dart';

/// "Edit profile": the name and the phone; leaving with unsaved changes asks
/// first.
void main() {
  late MockProfileBloc bloc;
  late StreamController<ProfileState> states;
  final en = lookupAppLocalizations(const Locale('en'));

  final profile = ProfileModel.fromJson(profileJson());

  ProfileState loaded(ProfileModel p) =>
      ProfileState(requestState: RequestState.loaded, profile: p);

  setUpAll(registerFallbacks);

  setUp(() {
    bloc = MockProfileBloc();
    states = StreamController<ProfileState>.broadcast();
    whenListen(
      bloc,
      states.stream,
      initialState: const ProfileState(requestState: RequestState.loading),
    );
  });

  tearDown(() => states.close());

  /// Opens the screen from a page below it (so it can be left), and lets the
  /// profile arrive.
  Future<void> open(
    WidgetTester tester, {
    ProfileModel? with_,
    Locale locale = const Locale('en'),
  }) async {
    await pumpOpener<void>(
      tester,
      (context) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider<ProfileBloc>.value(
            value: bloc,
            child: const EditProfileScreen(),
          ),
        ),
      ),
      locale: locale,
      settle: false,
    );
    await tester.pump(const Duration(milliseconds: 500));
    states.add(loaded(with_ ?? profile));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  UpdateProfileEvent sent() =>
      verify(
            () => bloc.add(captureAny(that: isA<UpdateProfileEvent>())),
          ).captured.single
          as UpdateProfileEvent;

  testWidgets('asks for the profile and fills the form', (tester) async {
    await open(tester);

    verify(() => bloc.add(const GetProfileEvent())).called(1);
    expect(find.text('Karim Haddad'), findsOneWidget);
    expect(find.text('0550123456'), findsOneWidget);
  });

  testWidgets('saves the name and phone, trimmed', (tester) async {
    await open(tester);

    await tester.enterText(field(en.name), '  Karim H.  ');
    await tester.enterText(field(en.phone), ' 0661234567 ');
    await tester.tap(find.text(en.updateProfile));
    await tester.pump();

    final event = sent();
    expect((event.name, event.phone), ('Karim H.', '0661234567'));
  });

  group('checks before saving', () {
    Future<void> saveWith(
      WidgetTester tester, {
      String name = 'Karim',
      String phone = '',
    }) async {
      await tester.enterText(field(en.name), name);
      await tester.enterText(field(en.phone), phone);
      await tester.tap(find.text(en.updateProfile));
      await tester.pump();
    }

    testWidgets('a name', (tester) async {
      await open(tester);

      await saveWith(tester, name: '  ');

      expect(find.text(en.nameIsRequired), findsOneWidget);
      verifyNever(() => bloc.add(any(that: isA<UpdateProfileEvent>())));
    });

    testWidgets('of two letters at least', (tester) async {
      await open(tester);

      await saveWith(tester, name: 'A');

      expect(find.text(en.nameTooShort), findsOneWidget);
    });

    testWidgets('a phone of ten digits, if any', (tester) async {
      await open(tester);

      await saveWith(tester, phone: '0550');
      expect(find.text(en.phoneTooShort), findsOneWidget);

      await saveWith(tester, phone: '');
      expect(find.text(en.phoneTooShort), findsNothing);
    });

    testWidgets('in the manager\'s language', (tester) async {
      final ar = lookupAppLocalizations(const Locale('ar'));
      await open(tester, locale: const Locale('ar'));

      await tester.enterText(field(ar.name), 'A');
      await tester.tap(find.text(ar.updateProfile));
      await tester.pump();

      expect(
        find.text(ar.nameTooShort),
        findsOneWidget,
        reason: 'the checks were written in English',
      );
    });
  });

  testWidgets('a refusal says why', (tester) async {
    await open(tester);

    states.add(
      loaded(profile).copyWith(
        requestState: RequestState.error,
        message: 'The phone field must not be greater than 20 characters.',
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('The phone field must not be greater than 20 characters.'),
      findsOneWidget,
    );
  });

  group('leaving', () {
    testWidgets('without changes: straight away', (tester) async {
      await open(tester);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileScreen), findsNothing);
      expect(find.text(en.unsavedChanges), findsNothing);
    });

    testWidgets('with changes: asks first, and can discard them', (
      tester,
    ) async {
      await open(tester);

      await tester.enterText(field(en.name), 'Karim H.');
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(
        find.text(en.unsavedChanges),
        findsOneWidget,
        reason: 'typing did not rebuild the page, so it left without asking',
      );

      await tester.tap(find.text(en.discard));
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileScreen), findsNothing);
      verifyNever(() => bloc.add(any(that: isA<UpdateProfileEvent>())));
    });

    testWidgets('with changes: or save them, then leave', (tester) async {
      await open(tester);

      await tester.enterText(field(en.name), 'Karim H.');
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.save));
      await tester.pumpAndSettle();

      expect(sent().name, 'Karim H.');
      expect(find.byType(EditProfileScreen), findsOneWidget);

      states.add(
        loaded(profile).copyWith(message: 'Profile updated successfully'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileScreen), findsNothing);
    });
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await open(tester, locale: locale);

      expect(tester.takeException(), isNull);
    });
  }
}
