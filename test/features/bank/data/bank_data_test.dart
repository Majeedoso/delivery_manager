import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/bank/data/datasource/bank_remote_data_source.dart';
import 'package:delivery_manager/features/bank/data/models/driver_balance_model.dart';
import 'package:delivery_manager/features/bank/data/models/restaurant_debt_model.dart';
import 'package:delivery_manager/features/bank/data/models/transaction_model.dart';
import 'package:delivery_manager/features/bank/data/repositories/bank_repository_impl.dart';
import 'package:delivery_manager/features/bank/domain/usecases/answer_payment_usecase.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/api_json.dart';
import '../../../helpers/fake_backend.dart';
import '../../../helpers/fakes.dart';
import '../../../helpers/locator.dart';

/// The manager's bank as CashReconciliationController keeps it: who owes the
/// platform and whom it owes, the amount due for some days, the payments the
/// manager records, and those drivers and restaurants send from their apps,
/// which the manager confirms or refuses.
void main() {
  const balancePath = '/manager/credits-debts';
  const restaurantAmountPath = '/manager/restaurant-payment-amount';
  const driverAmountPath = '/manager/system-payment-amount';
  const restaurantPaymentsPath = '/manager/restaurant-payments';
  const paymentsPath = '/manager/system-payments';

  setUpAll(registerFallbacks);

  group('the balance', () {
    // M27: a restaurant is named by its owner's user id (21); the payment
    // endpoints take the restaurant's own id (4), which was not read: a
    // payment was refused, or went to another restaurant
    test('a restaurant by its own id, which the payments take', () {
      final restaurant = RestaurantDebtModel.fromJson(balanceEntryJson());

      expect(restaurant.restaurantId, 4);
      expect(restaurant.restaurantName, 'Pizzeria Le Phare');
      expect(restaurant.counterpartyType, 'restaurant');
      expect(restaurant.amount, 500);
    });

    test('a driver by their user id', () {
      final driver = RestaurantDebtModel.fromJson(
        balanceEntryJson(
          type: 'driver',
          counterpartyId: 25,
          name: 'Yacine Bouzid',
          balance: 200,
        ),
      );

      expect((driver.restaurantId, driver.counterpartyType), (25, 'driver'));
    });

    test('what the payments already paid of these orders', () {
      expect(
        RestaurantDebtModel.fromJson(
          balanceEntryJson(balance: 300, paidTowardsOrders: 200),
        ).paidTowardsOrders,
        200,
      );
      expect(
        RestaurantDebtModel.fromJson(
          balanceEntryJson(paidTowardsOrders: null),
        ).paidTowardsOrders,
        isNull,
      );
    });

    test('the lines of an entry: the orders\' shares and the payments', () {
      final entry = RestaurantDebtModel.fromJson(
        balanceEntryJson(
          details: [
            balanceDetailJson(id: 31, amount: 500),
            balanceDetailJson(
              source: 'cash_transactions',
              direction: 'incoming',
              id: 70,
              amount: 400,
              reason: 'payment',
            ),
          ],
        ),
      );

      expect(entry.details.map((d) => (d.source, d.amount, d.reason)), [
        ('order_settlements', 500, 'settlement'),
        ('cash_transactions', 400, 'payment'),
      ]);
      expect(entry.details.first.orderNumber, orderNumberOf(31));
      expect(entry.details.last.direction, 'incoming');
    });

    test('who owes the platform, whom it owes, and the sums', () {
      final balance = DriverBalanceModel.fromJson(
        managerBalanceJson(
          credits: [
            balanceEntryJson(),
            balanceEntryJson(
              type: 'driver',
              counterpartyId: 25,
              name: 'Yacine Bouzid',
              balance: 200,
            ),
          ],
          debts: [balanceEntryJson(balance: 150)],
        ),
      );

      expect(balance.restaurantCredits.map((c) => c.restaurantName), [
        'Pizzeria Le Phare',
        'Yacine Bouzid',
      ]);
      expect(balance.restaurantDebts.single.amount, 150);
      expect((balance.totalCredits, balance.totalDebt), (700, 150));
    });

    // M35: the platform's debts come as positive amounts: read by their
    // sign, each was a credit (its page read "Credit Details", a green +)
    test('each list says its side: what the platform owes is a debt', () {
      final balance = DriverBalanceModel.fromJson(
        managerBalanceJson(
          credits: [balanceEntryJson()],
          debts: [balanceEntryJson(balance: 150)],
        ),
      );

      expect(balance.restaurantCredits.single.isCredit, isTrue);
      expect(balance.restaurantDebts.single.isCredit, isFalse);
    });
  });

  group('a payment', () {
    test('who sent it, how much, what they wrote, waiting', () {
      final payment = TransactionModel.fromJson(systemPaymentJson());

      expect(payment.id, 70);
      expect(payment.transactionType, 'restaurant_to_system_payment');
      expect((payment.amount, payment.formattedAmount), (500, '500.00 DZD'));
      expect(payment.status, 'pending');
      expect(payment.notes, 'Cash given at the office');
      expect(payment.restaurantName, 'Pizzeria Le Phare');
      expect(payment.fromUserName, 'Samir Benali');
      expect(payment.confirmedAt, isNull);
    });

    test('its times on the phone\'s clock (the server\'s are UTC)', () {
      final payment = TransactionModel.fromJson(
        systemPaymentJson(
          status: 'confirmed',
          confirmedAt: '2026-09-30T10:05:00.000000Z',
          confirmedBy: 'Karim Haddad',
        ),
      );

      expect(payment.createdAt.isUtc, isFalse);
      expect(payment.createdAt.toUtc(), DateTime.utc(2026, 9, 30, 9, 15));
      expect(payment.confirmedAt!.toUtc(), DateTime.utc(2026, 9, 30, 10, 5));
    });

    // M34: the manager who answered was read from a key the server does not
    // send (confirmed_by_user)
    test('answered: the answer, and the manager who gave it', () {
      final payment = TransactionModel.fromJson(
        systemPaymentJson(
          status: 'rejected',
          responseNotes: 'Nothing received',
          confirmedAt: '2026-09-30T10:05:00.000000Z',
          confirmedBy: 'Karim Haddad',
        ),
      );

      expect(payment.responseNotes, 'Nothing received');
      expect(payment.confirmedByName, 'Karim Haddad');
      expect(payment.confirmedBy, 1);
    });

    test('a driver\'s, by the driver\'s name', () {
      final payment = TransactionModel.fromJson(
        systemPaymentJson(type: 'driver_to_system_payment', amount: 200),
      );

      expect(payment.restaurantName, isNull);
      expect(payment.fromUserName, 'Yacine Bouzid');
    });
  });

  group('the API', () {
    late FakeBackend backend;
    late BankRemoteDataSource source;

    setUp(() {
      backend = FakeBackend();
      source = BankRemoteDataSourceImpl(
        dio: testDio(backend),
        logger: silentLogger(),
      );
    });

    test('the balance, every day or some', () async {
      backend.reply(
        'GET',
        balancePath,
        body: ok(managerBalanceJson(credits: [balanceEntryJson()])),
      );

      final all = await source.getDriverBalance();
      await source.getDriverBalance(from: '2026-09-27', to: '2026-09-30');

      expect(all.restaurantCredits.single.restaurantId, 4);
      expect(backend.requests.map((r) => r.query), [
        <String, dynamic>{},
        {'from': '2026-09-27', 'to': '2026-09-30'},
      ]);
    });

    test('the amount a restaurant owes for some days', () async {
      backend.reply(
        'GET',
        restaurantAmountPath,
        body: paymentAmountJson(amount: 300),
      );

      final due = await source.calculateRestaurantPaymentAmount(
        restaurantId: 4,
        selectedPeriod: 'dateRange',
        startDate: '2026-09-20',
        endDate: '2026-09-26',
      );

      expect(due['amount'], 300);
      expect(backend.last('GET', restaurantAmountPath).query, {
        'restaurant_id': 4,
        'selected_period': 'dateRange',
        'start_date': '2026-09-20',
        'end_date': '2026-09-26',
      });
    });

    test('the amount a driver owes', () async {
      backend.reply(
        'GET',
        driverAmountPath,
        body: paymentAmountJson(amount: 200, waiting: true),
      );

      final due = await source.calculateSystemPaymentAmount(
        driverId: 25,
        selectedPeriod: 'all',
      );

      expect(due['has_existing_transaction'], isTrue);
      expect(backend.last('GET', driverAmountPath).query, {
        'selected_period': 'all',
        'driver_id': 25,
      });
    });

    test('a restaurant\'s payment is recorded, for its days', () async {
      backend.reply(
        'POST',
        restaurantPaymentsPath,
        status: 201,
        body: ok(systemPaymentJson(status: 'confirmed', notes: 'Cash')),
      );

      final recorded = await source.recordRestaurantPayment(
        restaurantId: 4,
        amount: 500,
        selectedPeriod: 'all',
        notes: 'Cash',
      );

      expect(backend.last('POST', restaurantPaymentsPath).json, {
        'restaurant_id': 4,
        'amount': 500.0,
        'selected_period': 'all',
        'notes': 'Cash',
      });
      expect(recorded.status, 'confirmed');
    });

    test('a driver\'s payment is recorded', () async {
      backend.reply(
        'POST',
        paymentsPath,
        status: 201,
        body: ok(
          systemPaymentJson(type: 'driver_to_system_payment', amount: 200),
        ),
      );

      await source.recordSystemPayment(driverId: 25, amount: 200);

      expect(backend.last('POST', paymentsPath).json, {
        'amount': 200.0,
        'driver_id': 25,
      });
    });

    // Decision 6 of manager_suite_report.md: no payment from the platform
    // could be recorded
    test('a payment from the platform: to a restaurant by its own id, or a '
        'driver by their user id', () async {
      const platformPaymentsPath = '/manager/platform-payments';
      backend.reply(
        'POST',
        platformPaymentsPath,
        status: 201,
        body: ok(
          systemPaymentJson(
            id: 80,
            type: 'system_to_restaurant_payment',
            amount: 150,
            status: 'confirmed',
          ),
        ),
      );

      final paid = await source.recordPlatformPayment(
        restaurantId: 4,
        amount: 150,
        notes: 'Coupons of September',
      );
      expect(paid.transactionType, 'system_to_restaurant_payment');
      expect(paid.restaurantName, 'Pizzeria Le Phare');
      expect(backend.last('POST', platformPaymentsPath).json, {
        'restaurant_id': 4,
        'amount': 150.0,
        'notes': 'Coupons of September',
      });

      await source.recordPlatformPayment(driverId: 25, amount: 80);
      expect(backend.last('POST', platformPaymentsPath).json, {
        'driver_id': 25,
        'amount': 80.0,
      });
    });

    test('the payments sent from the apps, a page at a time', () async {
      backend.reply(
        'GET',
        paymentsPath,
        body: systemPaymentsPageJson([systemPaymentJson()], lastPage: 2),
      );

      final page = await source.getTransactions(status: 'pending');

      expect(backend.last('GET', paymentsPath).query, {
        'page': 1,
        'per_page': 15,
        'status': 'pending',
      });
      expect(page.transactions.single.id, 70);
      expect((page.currentPage, page.totalPages, page.hasMore), (1, 2, true));
    });

    // M28: they waited for good: no page could answer them
    group('a payment answered', () {
      test('confirmed', () async {
        backend.reply(
          'POST',
          '$paymentsPath/70/confirm',
          body: ok(systemPaymentJson(status: 'confirmed')),
        );

        await source.answerPayment(transactionId: 70, confirm: true);

        expect(backend.last('POST', '$paymentsPath/70/confirm').json, {
          'action': 'confirm',
        });
      });

      test('refused, saying why', () async {
        backend.reply(
          'POST',
          '$paymentsPath/70/confirm',
          body: ok(systemPaymentJson(status: 'rejected')),
        );

        await source.answerPayment(
          transactionId: 70,
          confirm: false,
          notes: 'Nothing received',
        );

        expect(backend.last('POST', '$paymentsPath/70/confirm').json, {
          'action': 'reject',
          'notes': 'Nothing received',
        });
      });

      test('answered already (a colleague): the server says so', () async {
        backend.reply(
          'POST',
          '$paymentsPath/70/confirm',
          status: 409,
          body: {
            ...failure('Ce paiement a déjà été confirmé ou refusé.'),
            'data': systemPaymentJson(status: 'confirmed'),
          },
        );

        await expectLater(
          source.answerPayment(transactionId: 70, confirm: false),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Ce paiement a déjà été confirmé ou refusé.',
            ),
          ),
        );
      });
    });

    // M31: they read "Exception: Connection error: Unable to reach the
    // server", in English whatever the language, or Dio's own text
    group('a failed request', () {
      test('offline, or too slow: the network\'s two texts', () async {
        backend
          ..fail('GET', balancePath, DioExceptionType.connectionError)
          ..fail('GET', paymentsPath, DioExceptionType.receiveTimeout);

        await expectLater(
          source.getDriverBalance(),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              'Network connection error',
            ),
          ),
        );
        await expectLater(
          source.getTransactions(),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              'Request timeout',
            ),
          ),
        );
      });

      test('the server\'s reason, the field it refused', () async {
        backend
          ..reply(
            'POST',
            restaurantPaymentsPath,
            status: 409,
            body: failure(
              'Une transaction est déjà en attente pour cette période.',
            ),
          )
          ..reply(
            'POST',
            paymentsPath,
            status: 422,
            body: validationFailure({
              'amount': ['Le montant doit être au moins 0,01.'],
            }),
          );

        await expectLater(
          source.recordRestaurantPayment(restaurantId: 4, amount: 500),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Une transaction est déjà en attente pour cette période.',
            ),
          ),
        );
        await expectLater(
          source.recordSystemPayment(driverId: 25, amount: 0),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Le montant doit être au moins 0,01.',
            ),
          ),
        );
      });

      test('an error page is a server error', () async {
        backend.reply(
          'GET',
          restaurantAmountPath,
          status: 500,
          body: htmlErrorPage,
        );

        await expectLater(
          source.calculateRestaurantPaymentAmount(
            restaurantId: 4,
            selectedPeriod: 'all',
          ),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Server error occurred',
            ),
          ),
        );
      });
    });
  });

  group('the repository', () {
    late MockBankRemoteDataSource remote;
    late BankRepositoryImpl repository;

    setUp(() {
      remote = MockBankRemoteDataSource();
      repository = BankRepositoryImpl(remoteDataSource: remote);
    });

    // M31: "Exception: " stood before every reason on the pages
    test('a failure keeps its words and its kind', () async {
      when(
        () => remote.getDriverBalance(),
      ).thenThrow(const ServerException(message: 'Paiement introuvable.'));
      when(
        () => remote.getTransactions(),
      ).thenThrow(const NetworkException(message: 'Network connection error'));

      expect(
        await repository.getDriverBalance(),
        const Left(ServerFailure('Paiement introuvable.')),
      );
      expect(
        await repository.getTransactions(),
        const Left(NetworkFailure('Network connection error')),
      );
    });

    test('an answer goes through', () async {
      when(
        () => remote.answerPayment(
          transactionId: any(named: 'transactionId'),
          confirm: any(named: 'confirm'),
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async {});

      final answered = await repository.answerPayment(
        transactionId: 70,
        confirm: false,
        notes: 'Nothing received',
      );

      expect(answered, const Right(unit));
      verify(
        () => remote.answerPayment(
          transactionId: 70,
          confirm: false,
          notes: 'Nothing received',
        ),
      ).called(1);
    });

    test('an answer the server refused', () async {
      when(
        () => remote.answerPayment(
          transactionId: any(named: 'transactionId'),
          confirm: any(named: 'confirm'),
          notes: any(named: 'notes'),
        ),
      ).thenThrow(
        const ServerException(
          message: 'This payment has already been confirmed or refused.',
        ),
      );

      expect(
        await repository.answerPayment(transactionId: 70, confirm: true),
        const Left(
          ServerFailure('This payment has already been confirmed or refused.'),
        ),
      );
    });
  });

  test('the answer, as the page gives it', () async {
    final repository = MockBankRepository();
    when(
      () => repository.answerPayment(
        transactionId: any(named: 'transactionId'),
        confirm: any(named: 'confirm'),
        notes: any(named: 'notes'),
      ),
    ).thenAnswer((_) async => const Right(unit));

    await AnswerPaymentUseCase(repository)(
      const AnswerPaymentParams(
        transactionId: 70,
        confirm: false,
        notes: 'Sent twice',
      ),
    );

    verify(
      () => repository.answerPayment(
        transactionId: 70,
        confirm: false,
        notes: 'Sent twice',
      ),
    ).called(1);
  });
}
