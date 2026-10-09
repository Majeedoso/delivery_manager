import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/bank/data/models/driver_balance_model.dart';
import 'package:delivery_manager/features/bank/data/models/transaction_model.dart';
import 'package:delivery_manager/features/bank/domain/entities/transaction.dart';
import 'package:delivery_manager/features/bank/domain/repositories/base_bank_repository.dart';
import 'package:delivery_manager/features/bank/domain/usecases/record_platform_payment_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/answer_payment_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/get_transactions_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/record_restaurant_payment_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/record_system_payment_usecase.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_bloc.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_event.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fakes.dart';

/// The bank pages' state: the balance, a payment the manager records, the
/// amount due, and the payments sent from the apps, which the manager
/// answers one at a time.
void main() {
  late MockGetDriverBalanceUseCase getBalance;
  late MockRecordRestaurantPaymentUseCase recordRestaurant;
  late MockRecordSystemPaymentUseCase recordDriver;
  late MockGetTransactionsUseCase getPayments;
  late MockAnswerPaymentUseCase answerPayment;
  late MockRecordPlatformPaymentUseCase recordPlatform;
  late MockBankRepository repository;

  final balance = DriverBalanceModel.fromJson(
    managerBalanceJson(credits: [balanceEntryJson()]),
  );
  final paidBalance = DriverBalanceModel.fromJson(managerBalanceJson());
  final waiting = TransactionModel.fromJson(systemPaymentJson());
  final confirmed = TransactionModel.fromJson(
    systemPaymentJson(
      status: 'confirmed',
      confirmedAt: '2026-09-30T10:05:00.000000Z',
      confirmedBy: 'Karim Haddad',
    ),
  );
  final fromDriver = TransactionModel.fromJson(
    systemPaymentJson(id: 71, type: 'driver_to_system_payment', amount: 200),
  );

  PaginatedTransactions page(
    List<Transaction> payments, {
    int current = 1,
    int last = 1,
  }) => PaginatedTransactions(
    transactions: payments,
    currentPage: current,
    totalPages: last,
    hasMore: current < last,
  );

  void paymentsAnswer(Either<Failure, PaginatedTransactions> answer) =>
      when(() => getPayments(any())).thenAnswer((_) async => answer);

  void answerAnswer(Either<Failure, Unit> answer) =>
      when(() => answerPayment(any())).thenAnswer((_) async => answer);

  BankBloc build() => BankBloc(
    getDriverBalanceUseCase: getBalance,
    recordRestaurantPaymentUseCase: recordRestaurant,
    recordSystemPaymentUseCase: recordDriver,
    getTransactionsUseCase: getPayments,
    answerPaymentUseCase: answerPayment,
    recordPlatformPaymentUseCase: recordPlatform,
    bankRepository: repository,
  );

  setUpAll(registerFallbacks);

  setUp(() {
    getBalance = MockGetDriverBalanceUseCase();
    recordRestaurant = MockRecordRestaurantPaymentUseCase();
    recordDriver = MockRecordSystemPaymentUseCase();
    getPayments = MockGetTransactionsUseCase();
    answerPayment = MockAnswerPaymentUseCase();
    recordPlatform = MockRecordPlatformPaymentUseCase();
    repository = MockBankRepository();
    when(
      () => getBalance(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => Right(balance));
  });

  group('the balance', () {
    blocTest<BankBloc, BankState>(
      'is read for the days chosen',
      build: build,
      act: (bloc) => bloc.add(
        const GetDriverBalanceEvent(from: '2026-09-27', to: '2026-09-30'),
      ),
      expect: () => [const BankLoading(), BalanceLoaded(balance: balance)],
      verify: (_) => verify(
        () => getBalance(from: '2026-09-27', to: '2026-09-30'),
      ).called(1),
    );

    blocTest<BankBloc, BankState>(
      'not read: the reason',
      setUp: () =>
          when(
            () => getBalance(
              from: any(named: 'from'),
              to: any(named: 'to'),
            ),
          ).thenAnswer(
            (_) async => const Left(NetworkFailure('Network connection error')),
          ),
      build: build,
      act: (bloc) => bloc.add(const GetDriverBalanceEvent()),
      expect: () => [
        const BankLoading(),
        const BalanceError('Network connection error'),
      ],
    );

    blocTest<BankBloc, BankState>(
      'read again: the figures stay on screen meanwhile',
      setUp: () => when(
        () => getBalance(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => Right(paidBalance)),
      build: build,
      seed: () => BalanceLoaded(balance: balance),
      act: (bloc) => bloc.add(const RefreshBalanceEvent()),
      expect: () => [
        BalanceLoaded(balance: balance, balanceState: RequestState.loading),
        BalanceLoaded(balance: paidBalance),
      ],
    );
  });

  group('a payment recorded', () {
    blocTest<BankBloc, BankState>(
      'a restaurant\'s, for its days: then the balance is read again',
      setUp: () => when(
        () => recordRestaurant(any()),
      ).thenAnswer((_) async => Right(confirmed)),
      build: build,
      act: (bloc) => bloc.add(
        const RecordRestaurantPaymentEvent(
          restaurantId: 4,
          amount: 500,
          selectedPeriod: 'all',
          notes: 'Cash',
        ),
      ),
      expect: () => [
        const PaymentRecording(),
        PaymentRecorded(transaction: confirmed),
        BalanceLoaded(balance: balance),
      ],
      verify: (_) {
        final sent =
            verify(() => recordRestaurant(captureAny())).captured.single
                as RecordRestaurantPaymentParams;
        expect(
          (sent.restaurantId, sent.amount, sent.selectedPeriod, sent.notes),
          (4, 500, 'all', 'Cash'),
        );
      },
    );

    blocTest<BankBloc, BankState>(
      'a driver\'s',
      setUp: () => when(
        () => recordDriver(any()),
      ).thenAnswer((_) async => Right(fromDriver)),
      build: build,
      act: (bloc) =>
          bloc.add(const RecordSystemPaymentEvent(driverId: 25, amount: 200)),
      expect: () => [
        const PaymentRecording(),
        PaymentRecorded(transaction: fromDriver),
        BalanceLoaded(balance: balance),
      ],
      verify: (_) {
        final sent =
            verify(() => recordDriver(captureAny())).captured.single
                as RecordSystemPaymentParams;
        expect((sent.driverId, sent.amount), (25, 200));
      },
    );

    blocTest<BankBloc, BankState>(
      'refused: the server\'s reason, and nothing read again',
      setUp: () => when(() => recordRestaurant(any())).thenAnswer(
        (_) async => const Left(
          ServerFailure(
            'Une transaction est déjà en attente pour cette période.',
          ),
        ),
      ),
      build: build,
      act: (bloc) => bloc.add(
        const RecordRestaurantPaymentEvent(restaurantId: 4, amount: 500),
      ),
      expect: () => [
        const PaymentRecording(),
        const PaymentError(
          'Une transaction est déjà en attente pour cette période.',
        ),
      ],
      verify: (_) => verifyNever(
        () => getBalance(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ),
    );
  });

  group('the amount due', () {
    void dueAnswer(Map<String, dynamic> data) {
      when(
        () => repository.calculateRestaurantPaymentAmount(
          restaurantId: any(named: 'restaurantId'),
          selectedPeriod: any(named: 'selectedPeriod'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(data));
      when(
        () => repository.calculateSystemPaymentAmount(
          driverId: any(named: 'driverId'),
          selectedPeriod: any(named: 'selectedPeriod'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(data));
    }

    blocTest<BankBloc, BankState>(
      'a restaurant\'s, for the days chosen',
      setUp: () => dueAnswer(
        paymentAmountJson(amount: 300)['data'] as Map<String, dynamic>,
      ),
      build: build,
      act: (bloc) => bloc.add(
        const CalculateRestaurantPaymentAmountEvent(
          restaurantId: 4,
          selectedPeriod: 'dateRange',
          startDate: '2026-09-20',
          endDate: '2026-09-26',
        ),
      ),
      expect: () => [
        const AmountCalculating(),
        const AmountCalculated(amount: 300, formattedAmount: '300.00 DZD'),
      ],
      verify: (_) => verify(
        () => repository.calculateRestaurantPaymentAmount(
          restaurantId: 4,
          selectedPeriod: 'dateRange',
          startDate: '2026-09-20',
          endDate: '2026-09-26',
        ),
      ).called(1),
    );

    blocTest<BankBloc, BankState>(
      'a payment of theirs waits for the manager: said',
      setUp: () => dueAnswer(
        paymentAmountJson(amount: 0, waiting: true)['data']
            as Map<String, dynamic>,
      ),
      build: build,
      act: (bloc) => bloc.add(
        const CalculateSystemPaymentAmountEvent(
          driverId: 25,
          selectedPeriod: 'all',
        ),
      ),
      expect: () => [
        const SystemAmountCalculating(),
        const SystemAmountCalculated(
          amount: 0,
          formattedAmount: '0.00 DZD',
          hasExistingTransaction: true,
          existingTransactionStatus: 'pending',
        ),
      ],
    );

    blocTest<BankBloc, BankState>(
      'not read: the reason',
      setUp: () => when(
        () => repository.calculateRestaurantPaymentAmount(
          restaurantId: any(named: 'restaurantId'),
          selectedPeriod: any(named: 'selectedPeriod'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => const Left(NetworkFailure('Request timeout'))),
      build: build,
      act: (bloc) => bloc.add(
        const CalculateRestaurantPaymentAmountEvent(
          restaurantId: 4,
          selectedPeriod: 'all',
        ),
      ),
      expect: () => [
        const AmountCalculating(),
        const AmountCalculationError('Request timeout'),
      ],
    );
  });

  group('the payments sent from the apps', () {
    blocTest<BankBloc, BankState>(
      'those of one status',
      setUp: () => paymentsAnswer(Right(page([waiting], last: 2))),
      build: build,
      act: (bloc) => bloc.add(const GetTransactionsEvent(status: 'pending')),
      expect: () => [
        const BankLoading(),
        TransactionsLoaded(
          transactions: [waiting],
          currentPage: 1,
          totalPages: 2,
          hasMore: true,
          statusFilter: 'pending',
        ),
      ],
    );

    blocTest<BankBloc, BankState>(
      'the next page joins the first, with the same status',
      setUp: () =>
          paymentsAnswer(Right(page([fromDriver], current: 2, last: 2))),
      build: build,
      seed: () => TransactionsLoaded(
        transactions: [waiting],
        currentPage: 1,
        totalPages: 2,
        hasMore: true,
        statusFilter: 'pending',
      ),
      act: (bloc) => bloc.add(const LoadMoreTransactionsEvent()),
      expect: () => [
        TransactionsLoaded(
          transactions: [waiting],
          currentPage: 1,
          totalPages: 2,
          hasMore: true,
          transactionsState: RequestState.loading,
          statusFilter: 'pending',
        ),
        TransactionsLoaded(
          transactions: [waiting, fromDriver],
          currentPage: 2,
          totalPages: 2,
          hasMore: false,
          statusFilter: 'pending',
        ),
      ],
      verify: (_) {
        final asked =
            verify(() => getPayments(captureAny())).captured.single
                as GetTransactionsParams;
        expect((asked.page, asked.status), (2, 'pending'));
      },
    );

    // As M11: the answer to an earlier filter, arriving late, replaced the
    // list of the one chosen after it
    final slow = Completer<Either<Failure, PaginatedTransactions>>();
    blocTest<BankBloc, BankState>(
      'a late answer to an earlier filter is dropped',
      setUp: () => when(() => getPayments(any())).thenAnswer((invocation) {
        final asked =
            invocation.positionalArguments.single as GetTransactionsParams;
        return asked.status == 'pending'
            ? slow.future
            : Future.value(Right(page([confirmed])));
      }),
      build: build,
      act: (bloc) async {
        bloc
          ..add(const GetTransactionsEvent(status: 'pending'))
          ..add(const GetTransactionsEvent(status: 'confirmed'));
        await Future<void>.delayed(Duration.zero);
        slow.complete(Right(page([waiting])));
      },
      wait: const Duration(milliseconds: 10),
      expect: () => [
        const BankLoading(),
        TransactionsLoaded(
          transactions: [confirmed],
          currentPage: 1,
          totalPages: 1,
          hasMore: false,
          statusFilter: 'confirmed',
        ),
      ],
    );
  });

  // M28: the payments drivers and restaurants send waited for good: no page
  // could answer them
  group('a payment answered', () {
    final list = TransactionsLoaded(
      transactions: [waiting, fromDriver],
      currentPage: 1,
      totalPages: 1,
      hasMore: false,
      statusFilter: 'pending',
    );

    blocTest<BankBloc, BankState>(
      'confirmed: the list is read again, with its status',
      setUp: () {
        answerAnswer(const Right(unit));
        paymentsAnswer(Right(page([fromDriver])));
      },
      build: build,
      seed: () => list,
      act: (bloc) =>
          bloc.add(const AnswerPaymentEvent(transactionId: 70, confirm: true)),
      expect: () => [
        TransactionsLoaded(
          transactions: [waiting, fromDriver],
          currentPage: 1,
          totalPages: 1,
          hasMore: false,
          statusFilter: 'pending',
          answeringPaymentId: 70,
        ),
        TransactionsLoaded(
          transactions: [fromDriver],
          currentPage: 1,
          totalPages: 1,
          hasMore: false,
          statusFilter: 'pending',
          lastAnswer: const PaymentAnswer(transactionId: 70, confirmed: true),
        ),
      ],
      verify: (_) {
        final sent =
            verify(() => answerPayment(captureAny())).captured.single
                as AnswerPaymentParams;
        expect(
          (sent.transactionId, sent.confirm, sent.notes),
          (70, true, null),
        );
        final asked =
            verify(() => getPayments(captureAny())).captured.single
                as GetTransactionsParams;
        expect((asked.page, asked.status), (1, 'pending'));
      },
    );

    blocTest<BankBloc, BankState>(
      'refused, saying why',
      setUp: () {
        answerAnswer(const Right(unit));
        paymentsAnswer(Right(page([fromDriver])));
      },
      build: build,
      seed: () => list,
      act: (bloc) => bloc.add(
        const AnswerPaymentEvent(
          transactionId: 70,
          confirm: false,
          notes: 'Nothing received',
        ),
      ),
      skip: 1,
      expect: () => [
        TransactionsLoaded(
          transactions: [fromDriver],
          currentPage: 1,
          totalPages: 1,
          hasMore: false,
          statusFilter: 'pending',
          lastAnswer: const PaymentAnswer(transactionId: 70, confirmed: false),
        ),
      ],
      verify: (_) {
        final sent =
            verify(() => answerPayment(captureAny())).captured.single
                as AnswerPaymentParams;
        expect((sent.confirm, sent.notes), (false, 'Nothing received'));
      },
    );

    blocTest<BankBloc, BankState>(
      'answered already by a colleague: the reason, and the list as it is now',
      setUp: () {
        answerAnswer(
          const Left(
            ServerFailure('Ce paiement a déjà été confirmé ou refusé.'),
          ),
        );
        paymentsAnswer(Right(page([confirmed, fromDriver])));
      },
      build: build,
      seed: () => list,
      act: (bloc) =>
          bloc.add(const AnswerPaymentEvent(transactionId: 70, confirm: false)),
      skip: 1,
      expect: () => [
        TransactionsLoaded(
          transactions: [confirmed, fromDriver],
          currentPage: 1,
          totalPages: 1,
          hasMore: false,
          statusFilter: 'pending',
          lastAnswer: const PaymentAnswer(
            transactionId: 70,
            confirmed: false,
            failure: 'Ce paiement a déjà été confirmé ou refusé.',
          ),
        ),
      ],
    );

    blocTest<BankBloc, BankState>(
      'the list not read again (offline): it stays, the answer is said',
      setUp: () {
        answerAnswer(const Right(unit));
        paymentsAnswer(const Left(NetworkFailure('Network connection error')));
      },
      build: build,
      seed: () => list,
      act: (bloc) =>
          bloc.add(const AnswerPaymentEvent(transactionId: 70, confirm: true)),
      skip: 1,
      expect: () => [
        TransactionsLoaded(
          transactions: [waiting, fromDriver],
          currentPage: 1,
          totalPages: 1,
          hasMore: false,
          statusFilter: 'pending',
          lastAnswer: const PaymentAnswer(transactionId: 70, confirmed: true),
        ),
      ],
    );

    blocTest<BankBloc, BankState>(
      'one at a time: another answer waits for the first',
      build: build,
      seed: () => TransactionsLoaded(
        transactions: [waiting, fromDriver],
        currentPage: 1,
        totalPages: 1,
        hasMore: false,
        answeringPaymentId: 70,
      ),
      act: (bloc) =>
          bloc.add(const AnswerPaymentEvent(transactionId: 71, confirm: true)),
      expect: () => <BankState>[],
      verify: (_) => verifyNever(() => answerPayment(any())),
    );

    blocTest<BankBloc, BankState>(
      'no next page while an answer is on its way',
      build: build,
      seed: () => TransactionsLoaded(
        transactions: [waiting],
        currentPage: 1,
        totalPages: 2,
        hasMore: true,
        answeringPaymentId: 70,
      ),
      act: (bloc) => bloc.add(const LoadMoreTransactionsEvent()),
      expect: () => <BankState>[],
      verify: (_) => verifyNever(() => getPayments(any())),
    );
  });

  // Decision 6 of manager_suite_report.md: no payment from the platform could
  // be recorded
  group('a payment from the platform', () {
    final paid = TransactionModel.fromJson(
      systemPaymentJson(
        id: 80,
        type: 'system_to_restaurant_payment',
        amount: 150,
        status: 'confirmed',
      ),
    );

    blocTest<BankBloc, BankState>(
      'recorded: what was paid',
      setUp: () => when(
        () => recordPlatform(any()),
      ).thenAnswer((_) async => Right(paid)),
      build: build,
      act: (bloc) => bloc.add(
        const RecordPlatformPaymentEvent(restaurantId: 4, amount: 150),
      ),
      expect: () => [
        const PaymentRecording(),
        PaymentRecorded(transaction: paid),
      ],
      verify: (_) => verify(
        () => recordPlatform(
          const RecordPlatformPaymentParams(restaurantId: 4, amount: 150),
        ),
      ).called(1),
    );

    blocTest<BankBloc, BankState>(
      'refused: why',
      setUp: () => when(() => recordPlatform(any())).thenAnswer(
        (_) async => const Left(
          ServerFailure('That is more than the platform owes: 150.00 DZD.'),
        ),
      ),
      build: build,
      act: (bloc) =>
          bloc.add(const RecordPlatformPaymentEvent(driverId: 25, amount: 200)),
      expect: () => [
        const PaymentRecording(),
        const PaymentError('That is more than the platform owes: 150.00 DZD.'),
      ],
    );
  });
}
