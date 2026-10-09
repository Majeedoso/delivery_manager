import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/users/data/models/user_management_model.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_bloc.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_event.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_state.dart';
import 'package:delivery_manager/features/users/presentation/screens/users_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fakes.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/readable.dart';
import 'package:delivery_manager/core/utils/phone_text.dart';

/// "User Management": every account but the managers', with a menu on each
/// to approve, refuse, suspend or activate it; filters by role and status,
/// a search, and the next page at the bottom.
void main() {
  late MockUsersBloc users;
  late StreamController<UsersState> states;
  final fr = lookupAppLocalizations(const Locale('fr'));

  ManagedUser account(
    int id,
    String name, {
    required String role,
    required String status,
    String? phone = '0661234567',
    String? reason,
    bool verified = true,
  }) => UserManagementModel.fromJson(
    managedUserJson(
      id: id,
      name: name,
      email: '${name.split(' ').first.toLowerCase()}@example.dz',
      phone: phone,
      role: role,
      status: status,
      rejectionReason: reason,
      emailVerifiedAt: verified ? '2026-09-29T08:00:00.000000Z' : null,
    ),
  );

  final yacine = account(
    12,
    'Yacine Bouzid',
    role: 'driver',
    status: 'pending_approval',
    verified: false,
  );
  final phare = account(
    13,
    'Pizzeria Le Phare',
    role: 'restaurant',
    status: 'active',
    phone: null,
  );
  final nadia = account(
    14,
    'Nadia Cherif',
    role: 'operator',
    status: 'suspended',
    reason: 'Orders refused without calling the customers',
  );
  final amina = account(
    15,
    'Amina Saidi',
    role: 'customer',
    status: 'rejected',
    reason: 'Several orders never collected',
  );

  UsersState loaded(
    List<ManagedUser> list, {
    bool hasMorePages = false,
    bool isLoadingMore = false,
    UserRole? role,
    UserStatus? status,
    String search = '',
    Set<int> updatingIds = const {},
    String errorMessage = '',
    UsersAction? action,
  }) => UsersState(
    requestState: RequestState.loaded,
    users: list,
    hasMorePages: hasMorePages,
    isLoadingMore: isLoadingMore,
    selectedRole: role,
    selectedStatus: status,
    searchQuery: search,
    updatingIds: updatingIds,
    errorMessage: errorMessage,
    action: action,
  );

  setUpAll(registerFallbacks);

  setUp(() {
    users = MockUsersBloc();
    states = StreamController<UsersState>.broadcast();
    addTearDown(states.close);
  });

  Future<void> pump(
    WidgetTester tester, {
    UsersState? state,
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
    bool settle = true,
  }) {
    whenListen(
      users,
      states.stream,
      initialState: state ?? loaded([yacine, phare, nadia, amina]),
    );
    return pumpPage(
      tester,
      const UsersScreen(),
      locale: locale,
      themeMode: themeMode,
      settle: settle,
      blocs: [BlocProvider<UsersBloc>.value(value: users)],
    );
  }

  /// The events the page added, oldest first (each read once).
  List<UsersEvent> added() =>
      verify(() => users.add(captureAny())).captured.cast<UsersEvent>();

  /// Scrolls the list of accounts until [finder] shows.
  Future<void> scrollList(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      150,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
  }

  /// The menu on [name]'s card.
  Finder menuOf(String name) => find.descendant(
    of: find.ancestor(of: find.text(name), matching: find.byType(Card)),
    matching: find.byType(DropdownButton2<UserStatus>),
  );

  /// Opens [name]'s menu and picks [choice].
  Future<void> choose(WidgetTester tester, String name, String choice) async {
    await scrollList(tester, find.text(name));
    await tester.tap(menuOf(name));
    await tester.pumpAndSettle();
    await tester.tap(find.text(choice).last);
    await tester.pumpAndSettle();
  }

  testWidgets('each account: who it is, and what the manager should know', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('User Management'), findsOneWidget);
    expect(find.text('Yacine Bouzid'), findsOneWidget);
    expect(find.text('yacine@example.dz'), findsOneWidget);
    expect(find.text(phoneText('0661234567')), findsWidgets);
    expect(find.text('Email Not Verified'), findsOneWidget);

    await scrollList(tester, find.text('Amina Saidi'));
    expect(
      find.text('Orders refused without calling the customers'),
      findsOneWidget,
    );
    expect(find.text('Several orders never collected'), findsOneWidget);
  });

  testWidgets('each menu shows where the account stands', (tester) async {
    await pump(tester);

    expect(
      find.descendant(
        of: menuOf('Yacine Bouzid'),
        matching: find.text('Pending Approval'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: menuOf('Pizzeria Le Phare'),
        matching: find.text('Active'),
      ),
      findsOneWidget,
    );
  });

  // M9: the roles and the statuses were written in English in every language
  group('in the manager\'s language', () {
    testWidgets('the roles of the filter', (tester) async {
      await pump(tester, locale: const Locale('fr'));

      await tester.tap(find.text(fr.allRoles));
      await tester.pumpAndSettle();

      for (final role in ['Client', 'Livreur', 'Restaurant', 'Opérateur']) {
        expect(find.text(role), findsWidgets, reason: role);
      }
      for (final english in ['Customer', 'Driver', 'Operator']) {
        expect(find.text(english), findsNothing, reason: english);
      }
      expect(
        find.text('Gestionnaire'),
        findsNothing,
        reason: 'the server never lists the managers',
      );
    });

    testWidgets('the statuses of the filter and of each account', (
      tester,
    ) async {
      await pump(tester, locale: const Locale('fr'));

      expect(
        find.descendant(
          of: menuOf('Yacine Bouzid'),
          matching: find.text("En attente d'approbation"),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text(fr.allStatuses));
      await tester.pumpAndSettle();
      for (final status in ['Actif', 'Suspendu', 'Rejeté']) {
        expect(find.text(status), findsWidgets, reason: status);
      }
      for (final english in ['Pending Approval', 'Active', 'Suspended']) {
        expect(find.text(english), findsNothing, reason: english);
      }
    });

    testWidgets('in Arabic too', (tester) async {
      await pump(tester, locale: const Locale('ar'));

      expect(
        find.descendant(
          of: menuOf('Yacine Bouzid'),
          matching: find.text('في انتظار الموافقة'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('جميع الأدوار'));
      await tester.pumpAndSettle();
      expect(find.text('مشغل'), findsWidgets);
      expect(find.text('Operator'), findsNothing);
    });
  });

  group('the filters', () {
    testWidgets('a role is asked for, keeping the status', (tester) async {
      await pump(
        tester,
        state: loaded([yacine], status: UserStatus.pendingApproval),
      );

      await tester.tap(find.text('All Roles'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Driver').last);
      await tester.pumpAndSettle();

      final filter = added().single as FilterUsersEvent;
      expect(
        (filter.role, filter.status),
        (UserRole.driver, UserStatus.pendingApproval),
      );
    });

    testWidgets('a status is asked for, keeping the role', (tester) async {
      await pump(tester, state: loaded([phare], role: UserRole.restaurant));

      await tester.tap(find.text('All Statuses'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Suspended').last);
      await tester.pumpAndSettle();

      final filter = added().single as FilterUsersEvent;
      expect(
        (filter.role, filter.status),
        (UserRole.restaurant, UserStatus.suspended),
      );
    });
  });

  group('the decisions', () {
    testWidgets('approving a new account', (tester) async {
      await pump(tester);

      await choose(tester, 'Yacine Bouzid', 'Active');

      expect((added().single as ApproveUserEvent).userId, 12);
    });

    testWidgets('refusing one asks for its reason first', (tester) async {
      await pump(tester);

      await choose(tester, 'Yacine Bouzid', 'Rejected');
      expect(find.text('Rejecting: Yacine Bouzid'), findsOneWidget);

      final send = find.widgetWithText(ElevatedButton, 'Reject User');
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(find.text('Rejection reason is required'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).last, 'Blurry');
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(
        find.text('Reason must be at least 10 characters'),
        findsOneWidget,
      );
      verifyNever(() => users.add(any()));

      await tester.enterText(
        find.byType(TextFormField).last,
        '  Documents unreadable  ',
      );
      await tester.tap(send);
      await tester.pumpAndSettle();

      expect(find.text('Rejecting: Yacine Bouzid'), findsNothing);
      final refusal = added().single as RejectUserEvent;
      expect((refusal.userId, refusal.reason), (12, 'Documents unreadable'));
    });

    testWidgets('a refusal cancelled sends nothing', (tester) async {
      await pump(tester);

      await choose(tester, 'Yacine Bouzid', 'Rejected');
      await tester.enterText(
        find.byType(TextFormField).last,
        'Documents unreadable',
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Rejecting: Yacine Bouzid'), findsNothing);
      verifyNever(() => users.add(any()));
    });

    testWidgets('suspending an active account asks for its reason', (
      tester,
    ) async {
      await pump(tester);

      await choose(tester, 'Pizzeria Le Phare', 'Suspended');
      expect(find.text('Suspending: Pizzeria Le Phare'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).last,
        'Too many orders refused',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Suspend User'));
      await tester.pumpAndSettle();

      final suspension = added().single as SuspendUserEvent;
      expect(
        (suspension.userId, suspension.reason),
        (13, 'Too many orders refused'),
      );
    });

    testWidgets('activating a suspended account', (tester) async {
      await pump(tester);

      await choose(tester, 'Nadia Cherif', 'Active');

      expect((added().single as ActivateUserEvent).userId, 14);
    });

    testWidgets('an account being changed shows it, and can\'t be changed '
        'twice', (tester) async {
      await pump(
        tester,
        state: loaded([yacine, phare], updatingIds: {12}),
        settle: false,
      );
      await tester.pump(const Duration(milliseconds: 300));

      final menu = tester.widget<DropdownButton2<UserStatus>>(
        menuOf('Yacine Bouzid'),
      );
      expect(menu.onChanged, isNull);
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('Yacine Bouzid'),
            matching: find.byType(Card),
          ),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<DropdownButton2<UserStatus>>(menuOf('Pizzeria Le Phare'))
            .onChanged,
        isNotNull,
      );
    });

    testWidgets('each result is said once, then cleared', (tester) async {
      await pump(tester);

      for (final (action, said) in [
        (UsersAction.approved, 'User approved successfully'),
        (UsersAction.rejected, 'User rejected successfully'),
        (UsersAction.suspended, 'User suspended successfully'),
        (UsersAction.activated, 'User activated successfully'),
      ]) {
        states.add(loaded([yacine], action: action));
        await tester.pumpAndSettle();
        expect(find.text(said), findsOneWidget, reason: said);
        expect(added().single, isA<ClearUsersFeedbackEvent>());

        states.add(loaded([yacine]));
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
      }
    });

    // M10: the account stayed as it was, and nothing was said
    testWidgets('a refused decision is said, and the list stays', (
      tester,
    ) async {
      await pump(tester);

      states.add(
        loaded([
          yacine,
          phare,
          nadia,
          amina,
        ], errorMessage: 'User is not pending approval'),
      );
      await tester.pumpAndSettle();

      expect(find.text('User is not pending approval'), findsOneWidget);
      expect(find.text('Yacine Bouzid'), findsOneWidget);
      expect(added().single, isA<ClearUsersFeedbackEvent>());
    });

    testWidgets('a failed one is said in the manager\'s language', (
      tester,
    ) async {
      await pump(tester, locale: const Locale('fr'));

      states.add(loaded([yacine], errorMessage: 'Network connection error'));
      await tester.pumpAndSettle();

      expect(find.text(fr.errorConnectionError), findsOneWidget);
      expect(find.text('Network connection error'), findsNothing);
    });

    testWidgets('the same message after another failure is said again', (
      tester,
    ) async {
      await pump(tester);

      for (var i = 0; i < 2; i++) {
        states.add(
          loaded([yacine], errorMessage: 'User is not pending approval'),
        );
        await tester.pumpAndSettle();
        expect(find.text('User is not pending approval'), findsOneWidget);
        states.add(loaded([yacine]));
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }
      expect(added(), hasLength(2));
    });
  });

  // M12: the sheets were white whatever the theme: in dark mode their title
  // and the reason typed were light text on white
  group('in dark mode', () {
    double contrast(Color a, Color b) {
      final (light, dark) = a.computeLuminance() > b.computeLuminance()
          ? (a, b)
          : (b, a);
      return (light.computeLuminance() + 0.05) /
          (dark.computeLuminance() + 0.05);
    }

    Color sheetColour(WidgetTester tester, String subtitle) => tester
        .widgetList<Container>(
          find.ancestor(
            of: find.text(subtitle),
            matching: find.byType(Container),
          ),
        )
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((d) => d.color != null)
        .color!;

    for (final (choice, subtitle, name) in [
      ('Rejected', 'Rejecting: Yacine Bouzid', 'Yacine Bouzid'),
      ('Suspended', 'Suspending: Pizzeria Le Phare', 'Pizzeria Le Phare'),
    ]) {
      testWidgets('the ${choice.toLowerCase()} sheet can be read', (
        tester,
      ) async {
        await pump(tester, themeMode: ThemeMode.dark);

        await choose(tester, name, choice);
        await tester.enterText(find.byType(TextFormField).last, 'A reason');
        await tester.pumpAndSettle();

        final background = sheetColour(tester, subtitle);
        final title = tester
            .renderObject<RenderParagraph>(
              find
                  .descendant(
                    of: find.byType(BottomSheet),
                    matching: find.byType(RichText),
                  )
                  .first,
            )
            .text
            .style!
            .color!;
        final typed = tester
            .widget<EditableText>(find.byType(EditableText).last)
            .style
            .color!;

        expect(contrast(title, background), greaterThan(4.5), reason: 'title');
        expect(contrast(typed, background), greaterThan(4.5), reason: 'typed');
      });
    }

    testWidgets('the page and its menus can be read', (tester) async {
      await pump(tester, themeMode: ThemeMode.dark);
      expectReadable(tester);

      await tester.tap(menuOf('Yacine Bouzid'));
      await tester.pumpAndSettle();
      expectReadable(tester);
    });

    testWidgets('in light mode too', (tester) async {
      await pump(tester);
      expectReadable(tester);

      await choose(tester, 'Yacine Bouzid', 'Rejected');
      await tester.enterText(find.byType(TextFormField).last, 'A reason');
      await tester.pump();
      expectReadable(tester);
    });

    testWidgets('in light mode the sheet stays white', (tester) async {
      await pump(tester);

      await choose(tester, 'Yacine Bouzid', 'Rejected');

      expect(sheetColour(tester, 'Rejecting: Yacine Bouzid'), Colors.white);
    });
  });

  group('the list', () {
    testWidgets('loading: a spinner', (tester) async {
      await pump(tester, state: const UsersState(), settle: false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('could not be loaded: why, in the manager\'s language, and '
        'a retry', (tester) async {
      await pump(
        tester,
        locale: const Locale('fr'),
        state: const UsersState(
          requestState: RequestState.error,
          errorMessage: 'Network connection error',
        ),
      );

      expect(find.text(fr.errorLoadingUsers), findsOneWidget);
      expect(find.text(fr.errorConnectionError), findsOneWidget);
      expect(find.text('Network connection error'), findsNothing);

      await tester.tap(find.text(fr.retry));
      await tester.pump();
      expect(added().single, isA<LoadUsersEvent>());
    });

    testWidgets('nobody yet', (tester) async {
      await pump(tester, state: loaded([]));

      expect(find.text('No Users Found'), findsOneWidget);
      expect(find.text('No users in the system'), findsOneWidget);
      expect(find.text('Clear Filters'), findsNothing);
    });

    testWidgets('nobody matches: the filters can be cleared', (tester) async {
      await pump(tester, state: loaded([], role: UserRole.operator));

      expect(find.text('No users match your filters'), findsOneWidget);
      await tester.tap(find.text('Clear Filters'));
      await tester.pump();

      final filter = added().single as FilterUsersEvent;
      expect((filter.role, filter.status), (null, null));
    });

    testWidgets('more accounts: the next page at the bottom', (tester) async {
      await pump(tester, state: loaded([yacine, phare], hasMorePages: true));

      await scrollList(tester, find.text('Load More'));
      await tester.tap(find.text('Load More'));
      await tester.pump();

      expect(added().single, isA<LoadMoreUsersEvent>());
    });

    testWidgets('while it comes, a spinner instead of the button', (
      tester,
    ) async {
      await pump(
        tester,
        state: loaded([yacine], hasMorePages: true, isLoadingMore: true),
        settle: false,
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Load More'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('pulled down, it is asked for again', (tester) async {
      await pump(tester);

      await tester.fling(
        find.text('Yacine Bouzid'),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      expect(added().whereType<LoadUsersEvent>(), hasLength(1));
    });
  });

  group('the search', () {
    testWidgets('waits for the typing to stop', (tester) async {
      await pump(tester);

      await tester.enterText(find.byType(TextField).first, 'pha');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextField).first, 'phare');
      await tester.pump(const Duration(milliseconds: 499));
      verifyNever(() => users.add(any()));
      await tester.pump(const Duration(milliseconds: 1));

      final search = added().single as SearchUsersEvent;
      expect(search.query, 'phare');
    });

    testWidgets('can be emptied in one tap', (tester) async {
      await pump(tester, state: loaded([phare], search: 'phare'));
      await tester.enterText(find.byType(TextField).first, 'phare');
      await tester.pump(const Duration(seconds: 1));
      added();

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump(const Duration(seconds: 1));

      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        isEmpty,
      );
      expect((added().last as SearchUsersEvent).query, '');
    });
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await pump(tester, locale: locale);
      expect(tester.takeException(), isNull);

      await scrollList(tester, find.text('Amina Saidi'));
      await tester.tap(menuOf('Amina Saidi'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('its sheets fit a phone in ${locale.languageCode}', (
      tester,
    ) async {
      await pump(tester, locale: locale);
      final l10n = lookupAppLocalizations(locale);

      await choose(tester, 'Yacine Bouzid', l10n.rejected);
      await tester.tap(find.widgetWithText(ElevatedButton, l10n.rejectUser));
      await tester.pumpAndSettle();

      expect(find.text(l10n.rejectionReasonRequired), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
