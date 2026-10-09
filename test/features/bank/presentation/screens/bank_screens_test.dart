import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/utils/app_navigator.dart';
import 'package:delivery_manager/features/bank/data/models/driver_balance_model.dart';
import 'package:delivery_manager/features/bank/data/models/transaction_model.dart';
import 'package:delivery_manager/features/bank/domain/entities/driver_balance.dart';
import 'package:delivery_manager/features/bank/domain/entities/restaurant_debt.dart';
import 'package:delivery_manager/features/bank/domain/entities/transaction.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_bloc.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_event.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_state.dart';
import 'package:delivery_manager/features/bank/presentation/screens/bank_archive_screen.dart';
import 'package:delivery_manager/features/bank/presentation/screens/bank_main_screen.dart';
import 'package:delivery_manager/features/bank/presentation/screens/driver_debt_details_screen.dart';
import 'package:delivery_manager/features/bank/presentation/screens/new_transaction_screen.dart';
import 'package:delivery_manager/features/bank/presentation/screens/receivables_payables_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fakes.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/readable.dart';
import '../../../../helpers/routes.dart';

/// The bank's pages: its doors, who owes the platform and whom it owes, a
/// payment the manager records, the payments drivers and restaurants send
/// from their apps (answered here), and the details of one amount.
void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final fr = lookupAppLocalizations(const Locale('fr'));
  final ar = lookupAppLocalizations(const Locale('ar'));
  late MockBankBloc bloc;
  late StreamController<BankState> states;

  DriverBalance balanceOf({
    List<Map<String, dynamic>> credits = const [],
    List<Map<String, dynamic>> debts = const [],
  }) => DriverBalanceModel.fromJson(
    managerBalanceJson(credits: credits, debts: debts),
  );

  /// The pizzeria (its own id 4, its owner's 21) owes the platform 500 and
  /// Yacine (user 25) 200; the platform owes the pizzeria 150 for a coupon.
  final owed = balanceOf(
    credits: [
      balanceEntryJson(
        details: [
          balanceDetailJson(id: 31),
          balanceDetailJson(
            source: 'cash_transactions',
            direction: 'incoming',
            id: 70,
            amount: 400,
            reason: 'payment',
            fullDate: '2026-09-30T10:40:00+00:00',
          ),
        ],
      ),
      balanceEntryJson(
        type: 'driver',
        counterpartyId: 25,
        name: 'Yacine Bouzid',
        balance: 200,
      ),
    ],
    debts: [
      balanceEntryJson(
        balance: 150,
        details: [
          balanceDetailJson(id: 32, amount: 150, reason: 'coupon_credit'),
        ],
      ),
    ],
  );

  /// 'yyyy-MM-dd HH:mm' on this machine's clock for a moment the server wrote
  /// in UTC (tests pass in any time zone).
  String shown(DateTime utc) {
    final local = utc.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  setUpAll(registerFallbacks);

  setUp(() {
    bloc = MockBankBloc();
    states = StreamController<BankState>.broadcast();
  });

  tearDown(() => states.close());

  Future<void> emit(WidgetTester tester, BankState state) async {
    states.add(state);
    await tester.pump();
    await tester.pump();
  }

  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    BankState initial = const BankInitial(),
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
    RouteLog? routes,
    bool settle = true,
  }) async {
    whenListen(bloc, states.stream, initialState: initial);
    await withClock(
      Clock.fixed(testNow),
      () => pumpPage(
        tester,
        BlocProvider<BankBloc>.value(value: bloc, child: page),
        locale: locale,
        themeMode: themeMode,
        routes: routes,
        settle: settle,
      ),
    );
  }

  /// Every event the page sent, oldest first.
  List<BankEvent> sent() =>
      verify(() => bloc.add(captureAny())).captured.cast<BankEvent>();

  Future<void> tapOn(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('the bank', () {
    testWidgets('each door opens its page', (tester) async {
      final routes = RouteLog();
      await pumpPage(tester, const BankMainScreen(), routes: routes);

      for (final (door, route) in [
        (en.receivablesAndPayables, AppRoutes.bankReceivables),
        (en.newTransaction, AppRoutes.bankNewTransaction),
        (en.transactionsHistory, AppRoutes.bankArchive),
      ]) {
        await tester.tap(find.text(door));
        await tester.pumpAndSettle();

        expect(routes.last.name, route, reason: door);
        navigatorKey.currentState!.pop();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('can be read in dark mode', (tester) async {
      await pumpPage(tester, const BankMainScreen(), themeMode: ThemeMode.dark);

      expectReadable(tester);
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        await pumpPage(tester, const BankMainScreen(), locale: locale);

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('who owes the platform, whom it owes', () {
    Future<void> openPayables(
      WidgetTester tester, {
      AppLocalizations? l10n,
    }) async {
      await tester.tap(find.text((l10n ?? en).payables));
      await tester.pumpAndSettle();
    }

    testWidgets('asks for the balance of every day, once', (tester) async {
      await pump(tester, const ReceivablesPayablesScreen());

      expect(sent(), [const GetDriverBalanceEvent()]);
    });

    testWidgets('each driver and restaurant that owes, with the total', (
      tester,
    ) async {
      await pump(
        tester,
        const ReceivablesPayablesScreen(),
        initial: BalanceLoaded(balance: owed),
      );

      expect(find.text(en.drivers), findsOneWidget);
      expect(find.text('Yacine Bouzid'), findsOneWidget);
      expect(find.text('200.00 DZD'), findsOneWidget);
      expect(find.text(en.restaurantCredits), findsOneWidget);
      expect(find.text('Pizzeria Le Phare'), findsOneWidget);
      expect(find.text('500.00 DZD'), findsOneWidget);
      expect(find.text('+700,00'), findsOneWidget);
    });

    // M36: each was badged "Overpay", the driver's word for a restaurant
    // owing it money back: it is their share of orders
    testWidgets('what they owe is not called an overpayment', (tester) async {
      await pump(
        tester,
        const ReceivablesPayablesScreen(),
        initial: BalanceLoaded(balance: owed),
        locale: const Locale('fr'),
      );

      expect(find.text(fr.overpay), findsNothing);
    });

    // M27: a restaurant was named by its owner's user id, which the pages
    // after sent as the restaurant's
    testWidgets(
      'a restaurant opens its details, by its own id, with the days',
      (tester) async {
        final routes = RouteLog();
        await pump(
          tester,
          const ReceivablesPayablesScreen(),
          initial: BalanceLoaded(balance: owed),
          routes: routes,
        );

        await tapOn(tester, find.text('Pizzeria Le Phare'));

        expect(routes.last.name, AppRoutes.driverDebtDetails);
        final item = routes.lastArguments['item'] as RestaurantDebt;
        expect((item.restaurantId, item.isCredit), (4, true));
        expect(routes.lastArguments['period'], 'all');
      },
    );

    // M35: the platform's debts come as positive amounts, and each opened as
    // a credit ("Credit Details", a green +)
    testWidgets('what the platform owes opens as a debt', (tester) async {
      final routes = RouteLog();
      await pump(
        tester,
        const ReceivablesPayablesScreen(),
        initial: BalanceLoaded(balance: owed),
        routes: routes,
      );
      await openPayables(tester);

      expect(find.text('-150.00 DZD'), findsOneWidget);
      await tapOn(tester, find.text('Pizzeria Le Phare').last);

      final item = routes.lastArguments['item'] as RestaurantDebt;
      expect((item.restaurantId, item.isCredit, item.amount), (4, false, 150));
    });

    testWidgets('a period asks for its days', (tester) async {
      await pump(
        tester,
        const ReceivablesPayablesScreen(),
        initial: BalanceLoaded(balance: owed),
      );

      await withClock(Clock.fixed(testNow), () async {
        await tester.tap(find.byType(DropdownButton2<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(en.thisWeek).last);
        await tester.pumpAndSettle();
      });

      // Since Sunday
      expect(
        sent().last,
        const GetDriverBalanceEvent(from: '2026-09-27', to: '2026-09-30'),
      );
    });

    // M31: the page showed the failure's own text ("Exception: Connection
    // error...", English in every language), and its retry read every day
    testWidgets('a balance that cannot be read: why, in the manager\'s '
        'language, and a retry for the same days', (tester) async {
      await pump(
        tester,
        const ReceivablesPayablesScreen(),
        initial: BalanceLoaded(balance: owed),
        locale: const Locale('fr'),
      );
      await withClock(Clock.fixed(testNow), () async {
        await tester.tap(find.byType(DropdownButton2<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(fr.thisWeek).last);
        await tester.pumpAndSettle();
      });

      await emit(tester, const BalanceError('Network connection error'));

      expect(find.text(fr.errorConnectionError), findsWidgets);
      expect(find.text('Network connection error'), findsNothing);

      await tester.tap(find.text(fr.retry));
      expect(
        sent().last,
        const GetDriverBalanceEvent(from: '2026-09-27', to: '2026-09-30'),
      );
    });

    // M31: "DZD TOTAL" under each total, in English; decision 7 of
    // manager_suite_report.md: the dinar too, in the manager's language
    testWidgets('"TOTAL" in the manager\'s language', (tester) async {
      await pump(
        tester,
        const ReceivablesPayablesScreen(),
        initial: BalanceLoaded(balance: owed),
        locale: const Locale('ar'),
      );

      expect(find.text('دج ${ar.total.toUpperCase()}'), findsOneWidget);
      expect(find.text('DZD TOTAL'), findsNothing);
    });

    // Decision 7 of manager_suite_report.md: the bank wrote "DZD" in Arabic,
    // where the statistics and coupon pages say "دج"
    testWidgets('in Arabic, the dinar is دج, the cents kept', (tester) async {
      await pump(
        tester,
        const ReceivablesPayablesScreen(),
        initial: BalanceLoaded(balance: owed),
        locale: const Locale('ar'),
      );

      expect(find.text('200.00 دج'), findsOneWidget);
      expect(find.text('500.00 دج'), findsOneWidget);
      expect(find.textContaining('DZD'), findsNothing);

      await openPayables(tester, l10n: ar);
      expect(find.text('-150.00 دج'), findsOneWidget);
      expect(find.textContaining('DZD'), findsNothing);
    });

    for (final themeMode in ThemeMode.values.skip(1)) {
      testWidgets('can be read in ${themeMode.name} mode', (tester) async {
        await pump(
          tester,
          const ReceivablesPayablesScreen(),
          initial: BalanceLoaded(balance: owed),
          themeMode: themeMode,
        );
        expectReadable(tester);

        await openPayables(tester);
        expectReadable(tester);
      });
    }

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        final l10n = lookupAppLocalizations(locale);
        await pump(
          tester,
          const ReceivablesPayablesScreen(),
          initial: BalanceLoaded(balance: owed),
          locale: locale,
        );
        expect(tester.takeException(), isNull);

        await openPayables(tester, l10n: l10n);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('a payment recorded', () {
    Future<void> choose(WidgetTester tester, String name) async {
      await tester.tap(find.byType(DropdownButton2<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name).last);
      await tester.pumpAndSettle();
    }

    Future<void> chooseDriver(
      WidgetTester tester, {
      AppLocalizations? l10n,
    }) async {
      await tapOn(tester, find.text((l10n ?? en).driver));
      await choose(tester, 'Yacine Bouzid');
    }

    Future<void> fillIn(
      WidgetTester tester, {
      required String amount,
      String? notes,
      AppLocalizations? l10n,
    }) async {
      await tester.enterText(
        find.widgetWithText(TextFormField, (l10n ?? en).amount),
        amount,
      );
      if (notes != null) {
        await tester.enterText(
          find.widgetWithText(TextFormField, (l10n ?? en).notes),
          notes,
        );
      }
      await tester.pump();
    }

    Finder submit([AppLocalizations? l10n]) =>
        find.widgetWithText(ElevatedButton, (l10n ?? en).recordPayment);

    final recorded = TransactionModel.fromJson(
      systemPaymentJson(status: 'confirmed'),
    );

    testWidgets('lists who owes, after asking the balance', (tester) async {
      await pump(tester, const NewTransactionScreen());
      expect(sent(), [const GetDriverBalanceEvent()]);

      await emit(tester, BalanceLoaded(balance: owed));
      await tester.tap(find.byType(DropdownButton2<int>));
      await tester.pumpAndSettle();

      expect(find.text('Pizzeria Le Phare'), findsWidgets);
      expect(find.text('Yacine Bouzid'), findsNothing);
    });

    // M33: "This Week" by default left the older debts out; M27: the
    // restaurant was asked for by its owner's user id
    testWidgets('a restaurant chosen: what it owes now, by its own id', (
      tester,
    ) async {
      await pump(tester, const NewTransactionScreen());
      await emit(tester, BalanceLoaded(balance: owed));

      await choose(tester, 'Pizzeria Le Phare');

      expect(
        sent().last,
        const CalculateRestaurantPaymentAmountEvent(
          restaurantId: 4,
          selectedPeriod: 'all',
        ),
      );
      expect(find.text(en.all), findsOneWidget);

      await emit(
        tester,
        const AmountCalculated(amount: 500, formattedAmount: '500.00 DZD'),
      );
      expect(find.text('500.00 DZD'), findsOneWidget);
      expect(find.text(en.paymentWaitingForAnswer), findsNothing);
    });

    // Decision 7 of manager_suite_report.md: the dinar in the manager's
    // language, the cents kept
    testWidgets('in Arabic, the dinar is دج', (tester) async {
      await pump(
        tester,
        const NewTransactionScreen(),
        locale: const Locale('ar'),
      );
      await emit(tester, BalanceLoaded(balance: owed));
      await choose(tester, 'Pizzeria Le Phare');
      await emit(
        tester,
        const AmountCalculated(amount: 500, formattedAmount: '500.00 DZD'),
      );

      expect(find.text('500.00 دج'), findsOneWidget);
      expect(find.textContaining('DZD'), findsNothing);
    });

    // M33: the amount read 0, with no reason, and another payment was refused
    testWidgets('a payment they sent, waiting for the manager, is said', (
      tester,
    ) async {
      await pump(tester, const NewTransactionScreen());
      await emit(tester, BalanceLoaded(balance: owed));
      await choose(tester, 'Pizzeria Le Phare');

      await emit(
        tester,
        const AmountCalculated(
          amount: 0,
          formattedAmount: '0.00 DZD',
          hasExistingTransaction: true,
          existingTransactionStatus: 'pending',
        ),
      );

      expect(find.text(en.paymentWaitingForAnswer), findsOneWidget);
    });

    testWidgets('records the restaurant\'s payment, with the note', (
      tester,
    ) async {
      await pump(tester, const NewTransactionScreen());
      await emit(tester, BalanceLoaded(balance: owed));
      await choose(tester, 'Pizzeria Le Phare');

      await fillIn(tester, amount: '500', notes: 'Cash of the week');
      await tapOn(tester, submit());

      expect(
        sent().last,
        const RecordRestaurantPaymentEvent(
          restaurantId: 4,
          amount: 500,
          selectedPeriod: 'all',
          notes: 'Cash of the week',
        ),
      );
    });

    testWidgets('a driver: what they owe, then their payment', (tester) async {
      await pump(tester, const NewTransactionScreen());
      await emit(tester, BalanceLoaded(balance: owed));

      await chooseDriver(tester);
      expect(
        sent().last,
        const CalculateSystemPaymentAmountEvent(
          driverId: 25,
          selectedPeriod: 'all',
        ),
      );
      await emit(
        tester,
        const SystemAmountCalculated(
          amount: 200,
          formattedAmount: '200.00 DZD',
        ),
      );
      expect(find.text('200.00 DZD'), findsOneWidget);

      await fillIn(tester, amount: '200');
      await tapOn(tester, submit());

      expect(
        sent().last,
        const RecordSystemPaymentEvent(driverId: 25, amount: 200),
      );
    });

    // M33: "12,5" was refused as an invalid amount, Arabic digits too
    testWidgets('an amount typed with a comma, or in Arabic digits', (
      tester,
    ) async {
      await pump(tester, const NewTransactionScreen());
      await emit(tester, BalanceLoaded(balance: owed));
      await choose(tester, 'Pizzeria Le Phare');

      await fillIn(tester, amount: '1250,5');
      await tapOn(tester, submit());
      await fillIn(tester, amount: '٥٠٠');
      await tapOn(tester, submit());

      expect(find.text(en.invalidAmount), findsNothing);
      expect(
        sent().whereType<RecordRestaurantPaymentEvent>().map((e) => e.amount),
        [1250.5, 500],
      );
    });

    testWidgets('no amount, or none above 0: nothing is sent', (tester) async {
      await pump(tester, const NewTransactionScreen());
      await emit(tester, BalanceLoaded(balance: owed));
      await choose(tester, 'Pizzeria Le Phare');

      for (final amount in ['', '0', 'abc']) {
        await fillIn(tester, amount: amount);
        await tapOn(tester, submit());

        expect(find.text(en.invalidAmount), findsOneWidget, reason: amount);
      }
      expect(sent().whereType<RecordRestaurantPaymentEvent>(), isEmpty);
    });

    testWidgets('while it is sent, the button waits', (tester) async {
      await pump(
        tester,
        const NewTransactionScreen(),
        initial: const PaymentRecording(),
        settle: false,
      );

      // A spinner stands in for its words
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
    });

    // M31: it showed the bloc's English sentence; M33: the driver chosen
    // stayed, with its old total
    testWidgets('recorded: said in the manager\'s language, and the form '
        'starts again', (tester) async {
      await pump(
        tester,
        const NewTransactionScreen(),
        locale: const Locale('fr'),
      );
      await emit(tester, BalanceLoaded(balance: owed));
      await chooseDriver(tester, l10n: fr);
      await emit(
        tester,
        const SystemAmountCalculated(
          amount: 200,
          formattedAmount: '200.00 DZD',
        ),
      );
      await fillIn(tester, amount: '200', notes: 'Espèces', l10n: fr);

      await emit(tester, PaymentRecorded(transaction: recorded));

      expect(
        find.widgetWithText(SnackBar, fr.paymentRecordedNotice),
        findsOneWidget,
      );
      expect(
        tester
            .widget<DropdownButton2<int>>(find.byType(DropdownButton2<int>))
            .value,
        isNull,
      );
      expect(find.text('200.00 DZD'), findsNothing);
      expect(find.text('Espèces'), findsNothing);
    });

    testWidgets('a payment refused says why', (tester) async {
      await pump(
        tester,
        const NewTransactionScreen(),
        locale: const Locale('fr'),
      );

      await emit(
        tester,
        const PaymentError(
          'Une transaction est déjà en attente pour cette période.',
        ),
      );

      expect(
        find.widgetWithText(
          SnackBar,
          'Une transaction est déjà en attente pour cette période.',
        ),
        findsOneWidget,
      );
    });

    // M33: the amount due was written in black, on a dark page in dark mode
    for (final themeMode in ThemeMode.values.skip(1)) {
      testWidgets('can be read in ${themeMode.name} mode', (tester) async {
        await pump(tester, const NewTransactionScreen(), themeMode: themeMode);
        await emit(tester, BalanceLoaded(balance: owed));
        await choose(tester, 'Pizzeria Le Phare');
        await emit(
          tester,
          const AmountCalculated(
            amount: 500,
            formattedAmount: '500.00 DZD',
            hasExistingTransaction: true,
          ),
        );

        expectReadable(tester);
      });
    }

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        await pump(tester, const NewTransactionScreen(), locale: locale);
        await emit(tester, BalanceLoaded(balance: owed));
        await choose(tester, 'Pizzeria Le Phare');
        await emit(
          tester,
          const AmountCalculated(
            amount: 0,
            formattedAmount: '0.00 DZD',
            hasExistingTransaction: true,
          ),
        );

        expect(tester.takeException(), isNull);
        expect(
          find.text(lookupAppLocalizations(locale).paymentWaitingForAnswer),
          findsOneWidget,
        );
      });
    }
  });

  // M28: the payments drivers and restaurants send from their apps waited
  // for good: no page could answer them
  group('the payments sent from the apps', () {
    final waiting = TransactionModel.fromJson(systemPaymentJson());
    final refused = TransactionModel.fromJson(
      systemPaymentJson(
        id: 71,
        type: 'driver_to_system_payment',
        amount: 200,
        status: 'rejected',
        notes: 'Paid at the depot',
        responseNotes: 'Nothing received',
        createdAt: '2026-09-29T17:20:00.000000Z',
        confirmedAt: '2026-09-30T10:05:00.000000Z',
        confirmedBy: 'Karim Haddad',
      ),
    );
    final confirmed = TransactionModel.fromJson(
      systemPaymentJson(
        id: 72,
        status: 'confirmed',
        notes: null,
        createdAt: '2026-09-28T08:00:00.000000Z',
        confirmedAt: '2026-09-28T09:30:00.000000Z',
        confirmedBy: 'Nadia Mansouri',
      ),
    );

    TransactionsLoaded listOf(
      List<Transaction> payments, {
      String? status,
      bool hasMore = false,
      int? answering,
      PaymentAnswer? answer,
    }) => TransactionsLoaded(
      transactions: payments,
      currentPage: 1,
      totalPages: hasMore ? 2 : 1,
      hasMore: hasMore,
      statusFilter: status,
      answeringPaymentId: answering,
      lastAnswer: answer,
    );

    final all = listOf([waiting, refused, confirmed]);

    Finder inDialog(Finder finder) =>
        find.descendant(of: find.byType(AlertDialog), matching: finder);

    testWidgets('asks for all of them on arrival, once', (tester) async {
      await pump(tester, const BankArchiveScreen());

      expect(sent(), [const GetTransactionsEvent()]);
    });

    testWidgets('each: who sent it, how much, when, what they wrote', (
      tester,
    ) async {
      await pump(tester, const BankArchiveScreen(), initial: all);

      expect(find.text('Pizzeria Le Phare'), findsNWidgets(2));
      expect(find.text(en.restaurant), findsWidgets);
      expect(find.text('500.00 DZD'), findsWidgets);
      expect(
        find.text(en.paymentNote('Cash given at the office')),
        findsOneWidget,
      );
      expect(
        find.text(shown(DateTime.utc(2026, 9, 30, 9, 15))),
        findsOneWidget,
      );

      // A restaurant's payment read "Payment to Restaurant"
      expect(find.text('Payment to Restaurant'), findsNothing);
      expect(find.text('Yacine Bouzid'), findsOneWidget);
      expect(find.text(en.driver), findsOneWidget);
    });

    // M34: the manager who answered was never read, and a refused payment
    // read "Confirmed At"
    testWidgets('answered: when, by which manager, and why', (tester) async {
      await pump(tester, const BankArchiveScreen(), initial: all);

      expect(
        find.text(
          '${en.refusedAt}: ${shown(DateTime.utc(2026, 9, 30, 10, 5))} · '
          'Karim Haddad',
        ),
        findsOneWidget,
      );
      expect(find.text(en.paymentAnswer('Nothing received')), findsOneWidget);
      expect(
        find.text(
          '${en.confirmedAt}: ${shown(DateTime.utc(2026, 9, 28, 9, 30))} · '
          'Nadia Mansouri',
        ),
        findsOneWidget,
      );
    });

    testWidgets('only a waiting payment can be answered', (tester) async {
      await pump(tester, const BankArchiveScreen(), initial: all);

      expect(find.widgetWithText(ElevatedButton, en.confirm), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, en.reject), findsOneWidget);
    });

    testWidgets('a status chosen asks for those payments', (tester) async {
      await pump(tester, const BankArchiveScreen(), initial: all);

      await tapOn(tester, find.widgetWithText(ChoiceChip, en.pending));

      expect(sent().last, const GetTransactionsEvent(status: 'pending'));
    });

    testWidgets('confirmed after a last look at the amount and who sent it', (
      tester,
    ) async {
      await pump(tester, const BankArchiveScreen(), initial: all);

      await tapOn(tester, find.widgetWithText(ElevatedButton, en.confirm));
      expect(
        inDialog(
          find.text(
            en.confirmPaymentReceived('500.00 DZD', 'Pizzeria Le Phare'),
          ),
        ),
        findsOneWidget,
      );
      await tapOn(
        tester,
        inDialog(find.widgetWithText(ElevatedButton, en.confirm)),
      );

      expect(
        sent().last,
        const AnswerPaymentEvent(transactionId: 70, confirm: true),
      );
    });

    // Decision 7 of manager_suite_report.md: the dinar in the manager's
    // language, in the list and in the last look
    testWidgets('in Arabic, the dinar is دج', (tester) async {
      await pump(
        tester,
        const BankArchiveScreen(),
        initial: all,
        locale: const Locale('ar'),
      );

      expect(find.text('500.00 دج'), findsWidgets);
      expect(find.text('200.00 دج'), findsOneWidget);
      expect(find.textContaining('DZD'), findsNothing);

      await tapOn(tester, find.widgetWithText(ElevatedButton, ar.confirm));
      expect(
        inDialog(
          find.text(
            ar.confirmPaymentReceived('500.00 دج', 'Pizzeria Le Phare'),
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a confirmation called off sends nothing', (tester) async {
      await pump(tester, const BankArchiveScreen(), initial: all);

      await tapOn(tester, find.widgetWithText(ElevatedButton, en.confirm));
      await tapOn(tester, inDialog(find.text(en.cancel)));

      expect(sent().whereType<AnswerPaymentEvent>(), isEmpty);
    });

    testWidgets('refused with a reason, which is required', (tester) async {
      await pump(tester, const BankArchiveScreen(), initial: all);

      await tapOn(tester, find.widgetWithText(ElevatedButton, en.reject));
      final refuse = inDialog(find.widgetWithText(ElevatedButton, en.reject));
      expect(tester.widget<ElevatedButton>(refuse).onPressed, isNull);

      await tester.enterText(
        inDialog(find.byType(TextField)),
        'Nothing received',
      );
      await tester.pump();
      await tapOn(tester, refuse);

      expect(
        sent().last,
        const AnswerPaymentEvent(
          transactionId: 70,
          confirm: false,
          notes: 'Nothing received',
        ),
      );
    });

    testWidgets('while an answer is on its way, the buttons wait', (
      tester,
    ) async {
      await pump(
        tester,
        const BankArchiveScreen(),
        initial: listOf([waiting], answering: 70),
      );

      for (final label in [en.confirm, en.reject]) {
        expect(
          tester
              .widget<ElevatedButton>(
                find.widgetWithText(ElevatedButton, label),
              )
              .onPressed,
          isNull,
          reason: label,
        );
      }
    });

    testWidgets('the answer is said, in the manager\'s words', (tester) async {
      await pump(
        tester,
        const BankArchiveScreen(),
        initial: listOf([waiting]),
        locale: const Locale('fr'),
      );

      await emit(
        tester,
        listOf([
          confirmed,
        ], answer: const PaymentAnswer(transactionId: 70, confirmed: true)),
      );
      expect(
        find.widgetWithText(SnackBar, fr.paymentConfirmedNotice),
        findsOneWidget,
      );
    });

    testWidgets('a refusal is said too', (tester) async {
      await pump(tester, const BankArchiveScreen(), initial: listOf([waiting]));

      await emit(
        tester,
        listOf([
          refused,
        ], answer: const PaymentAnswer(transactionId: 70, confirmed: false)),
      );
      expect(
        find.widgetWithText(SnackBar, en.paymentRefusedNotice),
        findsOneWidget,
      );
    });

    testWidgets('answered already by a colleague: the server\'s reason', (
      tester,
    ) async {
      await pump(tester, const BankArchiveScreen(), initial: listOf([waiting]));

      await emit(
        tester,
        listOf(
          [confirmed],
          answer: const PaymentAnswer(
            transactionId: 70,
            confirmed: false,
            failure: 'This payment has already been confirmed or refused.',
          ),
        ),
      );
      expect(
        find.widgetWithText(
          SnackBar,
          'This payment has already been confirmed or refused.',
        ),
        findsOneWidget,
      );
      expect(find.text(en.paymentRefusedNotice), findsNothing);
    });

    // M31: offline, the page read "Exception: Connection error: Unable to
    // reach the server", in English
    testWidgets('a list that cannot be read: why, in the manager\'s '
        'language, and a retry with its status', (tester) async {
      await pump(
        tester,
        const BankArchiveScreen(),
        initial: listOf([waiting], status: 'pending'),
        locale: const Locale('fr'),
      );
      await tapOn(tester, find.widgetWithText(ChoiceChip, fr.pending));

      await emit(tester, const TransactionsError('Network connection error'));
      expect(find.text(fr.errorConnectionError), findsWidgets);
      expect(find.text('Network connection error'), findsNothing);

      await tester.tap(find.text(fr.retry));
      expect(sent().last, const GetTransactionsEvent(status: 'pending'));
    });

    testWidgets('none: says so', (tester) async {
      await pump(tester, const BankArchiveScreen(), initial: listOf([]));

      expect(find.text(en.noTransactionsFound), findsOneWidget);
    });

    testWidgets('near the end, the next page is asked', (tester) async {
      await pump(
        tester,
        const BankArchiveScreen(),
        initial: listOf([
          for (var id = 80; id < 90; id++)
            TransactionModel.fromJson(
              systemPaymentJson(id: id, status: 'confirmed'),
            ),
        ], hasMore: true),
        settle: false,
      );

      await tester.drag(find.byType(ListView), const Offset(0, -6000));
      await tester.pump();

      expect(sent().last, const LoadMoreTransactionsEvent());
    });

    for (final themeMode in ThemeMode.values.skip(1)) {
      testWidgets('can be read in ${themeMode.name} mode', (tester) async {
        await pump(
          tester,
          const BankArchiveScreen(),
          initial: all,
          themeMode: themeMode,
        );

        expectReadable(tester);
      });
    }

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        final l10n = lookupAppLocalizations(locale);
        await pump(
          tester,
          const BankArchiveScreen(),
          initial: all,
          locale: locale,
        );
        expect(tester.takeException(), isNull);

        await tapOn(tester, find.widgetWithText(ElevatedButton, l10n.reject));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('the details of an amount', () {
    RestaurantDebt pizzeria({bool credit = true}) => credit
        ? owed.restaurantCredits.firstWhere(
            (c) => c.counterpartyType == 'restaurant',
          )
        : owed.restaurantDebts.single;

    Widget details(
      RestaurantDebt item, {
      String? period,
      DateTime? from,
      DateTime? to,
    }) => DriverDebtDetailsScreen(
      debtItem: item,
      initialPeriod: period,
      initialDateFrom: from,
      initialDateTo: to,
    );

    Future<void> open(
      WidgetTester tester,
      RestaurantDebt item, {
      DriverBalance? balance,
      Locale locale = const Locale('en'),
      ThemeMode themeMode = ThemeMode.light,
      String? period,
      DateTime? from,
      DateTime? to,
    }) async {
      await pump(
        tester,
        details(item, period: period, from: from, to: to),
        locale: locale,
        themeMode: themeMode,
      );
      await emit(tester, BalanceLoaded(balance: balance ?? owed));
      await tester.pumpAndSettle();
    }

    testWidgets('reads the balance again for its days', (tester) async {
      await pump(
        tester,
        details(
          pizzeria(),
          period: 'week',
          from: DateTime(2026, 9, 27),
          to: DateTime(2026, 9, 30),
        ),
      );

      expect(sent(), [
        const GetDriverBalanceEvent(from: '2026-09-27', to: '2026-09-30'),
      ]);
      expect(find.text(en.balanceForPeriod(en.thisWeek)), findsOneWidget);
    });

    testWidgets('each order and each payment, then the totals', (tester) async {
      await open(tester, pizzeria());

      expect(find.text(en.creditDetails), findsOneWidget);
      // At the top, and as the net balance at the bottom
      expect(find.text('+500.00 DZD'), findsNWidgets(2));
      expect(find.text(en.orderSettlements), findsOneWidget);
      expect(find.text(orderNumberOf(31)), findsOneWidget);
      expect(find.text(en.reasonOrderSettlement), findsOneWidget);
      expect(find.text(en.cashTransactions), findsOneWidget);
      expect(find.text(en.receivedPayment), findsWidgets);
      expect(find.text(en.totalOrderSettlements), findsOneWidget);
      expect(find.text(en.totalCashIncoming), findsOneWidget);
      expect(find.text('400.00 DZD'), findsWidgets);
      expect(find.text(en.netBalance), findsOneWidget);
    });

    // Decision 7 of manager_suite_report.md: the dinar in the manager's
    // language, the cents kept
    testWidgets('in Arabic, the dinar is دج', (tester) async {
      await open(tester, pizzeria(), locale: const Locale('ar'));

      expect(find.text('+500.00 دج'), findsNWidgets(2));
      expect(find.text('400.00 دج'), findsWidgets);
      expect(find.textContaining('DZD'), findsNothing);
    });

    // Anyone may pay more than they owe: what a side paid beyond its debts is
    // owed back by the other, and a row of its own says it
    testWidgets('a payment beyond what was owed says so', (tester) async {
      final overpaid = balanceOf(
        debts: [
          balanceEntryJson(
            balance: 2000,
            details: [
              balanceDetailJson(
                source: 'cash_transactions',
                direction: 'incoming',
                id: 0,
                amount: 2000,
                reason: 'overpayment',
                fullDate: '2026-09-30T10:40:00+00:00',
              ),
            ],
          ),
        ],
      );
      await open(tester, overpaid.restaurantDebts.single, balance: overpaid);

      expect(find.text(en.paidBeyondWhatWasOwed), findsOneWidget);
      expect(find.text(en.receivedPayment), findsNothing);
    });

    // M35: a restaurant both owing the platform and owed by it showed its
    // credit on its debt's page, and the debt read "Credit Details"
    testWidgets('what the platform owes a restaurant that also owes it: its '
        'own page', (tester) async {
      await open(tester, pizzeria(credit: false));

      expect(find.text(en.debtDetails), findsOneWidget);
      expect(find.text('-150.00 DZD'), findsNWidgets(2));
      expect(find.text('+500.00 DZD'), findsNothing);
      expect(find.text(en.reasonCouponCredit), findsOneWidget);
    });

    // M32, with M27: a restaurant is now named by its own id, which a
    // driver's user id can equal
    testWidgets('a driver with the same number is another counterparty', (
      tester,
    ) async {
      final sameNumber = balanceOf(
        credits: [
          balanceEntryJson(
            type: 'driver',
            counterpartyId: 4,
            name: 'Yacine Bouzid',
            balance: 200,
          ),
          balanceEntryJson(),
        ],
      );
      await open(
        tester,
        sameNumber.restaurantCredits.last,
        balance: sameNumber,
      );

      expect(find.text('+500.00 DZD'), findsNWidgets(2));
      expect(find.text('+200.00 DZD'), findsNothing);
    });

    // M32: they were the server's, in UTC
    testWidgets('its times on the phone\'s clock', (tester) async {
      await open(tester, pizzeria());

      expect(
        find.text(shown(DateTime.utc(2026, 9, 30, 10, 40))),
        findsOneWidget,
      );
      expect(
        find.text(shown(DateTime.utc(2026, 9, 29, 11, 0))),
        findsOneWidget,
      );
    });

    // M32: every label was English
    testWidgets('every label in the manager\'s language', (tester) async {
      await open(
        tester,
        pizzeria(),
        locale: const Locale('fr'),
        period: 'week',
        from: DateTime(2026, 9, 27),
        to: DateTime(2026, 9, 30),
      );

      for (final label in [
        fr.creditDetails,
        fr.balanceForPeriod(fr.thisWeek),
        fr.orderSettlements,
        fr.reasonOrderSettlement,
        fr.cashTransactions,
        fr.totalOrderSettlements,
        // Some days: the cash of those days (it may pay other days' orders)
        fr.cashPaidInTheseDays,
        fr.cashReceivedInTheseDays,
        fr.netBalance,
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.text(fr.receivedPayment), findsWidgets);
    });

    // M30: what the payments of any day paid of these days' orders
    testWidgets('for some days, what was paid of their orders', (tester) async {
      final thisWeek = balanceOf(
        credits: [balanceEntryJson(balance: 300, paidTowardsOrders: 200)],
      );
      await open(
        tester,
        thisWeek.restaurantCredits.single,
        balance: thisWeek,
        period: 'week',
        from: DateTime(2026, 9, 27),
        to: DateTime(2026, 9, 30),
      );

      expect(find.text(en.paidTowardsOrders), findsOneWidget);
      expect(find.text('200.00 DZD'), findsOneWidget);
      expect(find.text(en.totalCashIncoming), findsNothing);
    });

    testWidgets('a refresh that fails says why, and keeps the last figures', (
      tester,
    ) async {
      await open(tester, pizzeria());

      await emit(tester, const BalanceError('Network connection error'));

      expect(
        find.widgetWithText(SnackBar, en.errorConnectionError),
        findsOneWidget,
      );
      expect(find.text('+500.00 DZD'), findsNWidgets(2));
    });

    testWidgets('nothing for it in those days: says so', (tester) async {
      await open(tester, pizzeria(), balance: balanceOf());

      expect(find.text(en.noDataAvailable), findsOneWidget);
    });

    // M37: the section titles were black, on the black page of dark mode
    for (final themeMode in ThemeMode.values.skip(1)) {
      testWidgets('can be read in ${themeMode.name} mode', (tester) async {
        await open(tester, pizzeria(), themeMode: themeMode);

        expectReadable(tester);
      });
    }

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        final l10n = lookupAppLocalizations(locale);
        await open(
          tester,
          pizzeria(),
          locale: locale,
          period: 'week',
          from: DateTime(2026, 9, 27),
          to: DateTime(2026, 9, 30),
        );

        expect(tester.takeException(), isNull);
        expect(find.text(l10n.creditDetails), findsOneWidget);
      });
    }
  });

  // Decision 6 of manager_suite_report.md: what the platform owes could not
  // be paid: no such payment could be recorded
  group('a payment from the platform', () {
    final toRestaurant = balanceOf(debts: [balanceEntryJson(balance: 150)]);
    final toDriver = balanceOf(
      debts: [
        balanceEntryJson(
          type: 'driver',
          counterpartyId: 25,
          name: 'Yacine Bouzid',
          balance: 80,
        ),
      ],
    );

    Future<void> openOwed(WidgetTester tester, DriverBalance balance) async {
      await pump(
        tester,
        DriverDebtDetailsScreen(debtItem: balance.restaurantDebts.single),
      );
      await emit(tester, BalanceLoaded(balance: balance));
      await tester.pumpAndSettle();
    }

    Future<void> pay(WidgetTester tester, String amount) async {
      await tapOn(tester, find.text(en.payFromPlatform));
      await tester.enterText(
        find
            .descendant(
              of: find.byType(AlertDialog),
              matching: find.byType(TextField),
            )
            .first,
        amount,
      );
      await tester.tap(find.text(en.confirm));
      await tester.pumpAndSettle();
    }

    testWidgets('what it owes a restaurant: the amount owed, at most', (
      tester,
    ) async {
      await openOwed(tester, toRestaurant);
      await tapOn(tester, find.text(en.payFromPlatform));

      expect(
        find.text(en.platformPaymentTitle('Pizzeria Le Phare')),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextField, '150.00'), findsOneWidget);
      await tester.tap(find.text(en.confirm));
      await tester.pumpAndSettle();

      expect(
        sent().last,
        const RecordPlatformPaymentEvent(restaurantId: 4, amount: 150),
      );
    });

    testWidgets('a driver: by their user id, typed the French way', (
      tester,
    ) async {
      await openOwed(tester, toDriver);
      await pay(tester, '75,5');

      expect(
        sent().last,
        const RecordPlatformPaymentEvent(driverId: 25, amount: 75.5),
      );
    });

    // Anyone may pay more than they owe, the difference owed back (the owner's
    // rule, 2026-10-08): it was refused, "No more than the platform owes"
    testWidgets('more than owed is sent: the difference becomes their debt', (
      tester,
    ) async {
      await openOwed(tester, toRestaurant);
      await pay(tester, '200');

      expect(
        sent().last,
        const RecordPlatformPaymentEvent(restaurantId: 4, amount: 200),
      );
    });

    testWidgets('what is owed to the platform has no such button', (
      tester,
    ) async {
      await pump(
        tester,
        DriverDebtDetailsScreen(debtItem: owed.restaurantCredits.first),
      );
      await emit(tester, BalanceLoaded(balance: owed));
      await tester.pumpAndSettle();

      expect(find.text(en.payFromPlatform), findsNothing);
    });

    testWidgets('recorded: said, and the figures read again', (tester) async {
      await openOwed(tester, toRestaurant);
      sent();

      await emit(
        tester,
        PaymentRecorded(
          transaction: TransactionModel.fromJson(
            systemPaymentJson(
              id: 80,
              type: 'system_to_restaurant_payment',
              amount: 150,
              status: 'confirmed',
            ),
          ),
        ),
      );

      expect(find.text(en.platformPaymentRecorded), findsOneWidget);
      expect(sent(), [const GetDriverBalanceEvent()]);
    });

    testWidgets('refused: why, as the server said it', (tester) async {
      await openOwed(tester, toRestaurant);

      await emit(
        tester,
        const PaymentError('That is more than the platform owes: 150.00 DZD.'),
      );

      expect(
        find.text('That is more than the platform owes: 150.00 DZD.'),
        findsOneWidget,
      );
    });

    // Decision 7 of manager_suite_report.md: the dinar in the manager's
    // language
    testWidgets('in Arabic, the dinar is دج', (tester) async {
      await pump(
        tester,
        DriverDebtDetailsScreen(debtItem: toRestaurant.restaurantDebts.single),
        locale: const Locale('ar'),
      );
      await emit(tester, BalanceLoaded(balance: toRestaurant));
      await tester.pumpAndSettle();
      await tapOn(tester, find.text(ar.payFromPlatform));

      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('دج'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('DZD'), findsNothing);
    });

    testWidgets('in the archive: named by who received it', (tester) async {
      await pump(
        tester,
        const BankArchiveScreen(),
        initial: TransactionsLoaded(
          transactions: [
            TransactionModel.fromJson(
              systemPaymentJson(
                id: 80,
                type: 'system_to_restaurant_payment',
                amount: 150,
                status: 'confirmed',
                notes: null,
              ),
            ),
            TransactionModel.fromJson(
              systemPaymentJson(
                id: 81,
                type: 'system_to_driver_payment',
                amount: 80,
                status: 'confirmed',
                notes: null,
              ),
            ),
          ],
          currentPage: 1,
          totalPages: 1,
          hasMore: false,
        ),
      );

      expect(find.text('Pizzeria Le Phare'), findsOneWidget);
      expect(find.text('Yacine Bouzid'), findsOneWidget);
      expect(
        find.text('${en.paidByThePlatform} · ${en.restaurant}'),
        findsOneWidget,
      );
      expect(
        find.text('${en.paidByThePlatform} · ${en.driver}'),
        findsOneWidget,
      );
      expect(find.text('Karim Haddad'), findsNothing, reason: 'not the payer');
    });
  });
}
