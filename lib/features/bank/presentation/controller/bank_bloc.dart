import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/bank/domain/repositories/base_bank_repository.dart';
import 'package:delivery_manager/features/bank/domain/usecases/get_driver_balance_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/record_restaurant_payment_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/record_system_payment_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/get_transactions_usecase.dart';
import 'package:delivery_manager/core/utils/currency.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_event.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_state.dart';

class BankBloc extends Bloc<BankEvent, BankState> {
  final GetDriverBalanceUseCase getDriverBalanceUseCase;
  final RecordRestaurantPaymentUseCase recordRestaurantPaymentUseCase;
  final RecordSystemPaymentUseCase recordSystemPaymentUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;
  final BaseBankRepository? bankRepository;

  final LoggingService logger = sl<LoggingService>();

  BankBloc({
    required this.getDriverBalanceUseCase,
    required this.recordRestaurantPaymentUseCase,
    required this.recordSystemPaymentUseCase,
    required this.getTransactionsUseCase,
    this.bankRepository,
  }) : super(const BankInitial()) {
    on<GetDriverBalanceEvent>(_onGetDriverBalance);
    on<RefreshBalanceEvent>(_onRefreshBalance);
    on<RecordRestaurantPaymentEvent>(_onRecordRestaurantPayment);
    on<RecordSystemPaymentEvent>(_onRecordSystemPayment);
    on<GetTransactionsEvent>(_onGetTransactions);
    on<LoadMoreTransactionsEvent>(_onLoadMoreTransactions);
    on<CalculateRestaurantPaymentAmountEvent>(
      _onCalculateRestaurantPaymentAmount,
    );
    on<CalculateSystemPaymentAmountEvent>(_onCalculateSystemPaymentAmount);
  }

  Future<void> _onGetDriverBalance(
    GetDriverBalanceEvent event,
    Emitter<BankState> emit,
  ) async {
    logger.info(
      'BankBloc: Getting driver balance with range: ${event.from} - ${event.to}',
    );
    emit(const BankLoading());

    final result = await getDriverBalanceUseCase(
      from: event.from,
      to: event.to,
    );

    result.fold(
      (failure) {
        logger.error(
          'BankBloc: Failed to get driver balance: ${failure.message}',
        );
        emit(BalanceError(failure.message));
      },
      (balance) {
        logger.info('BankBloc: Successfully loaded driver balance');
        emit(BalanceLoaded(balance: balance));
      },
    );
  }

  Future<void> _onRefreshBalance(
    RefreshBalanceEvent event,
    Emitter<BankState> emit,
  ) async {
    logger.info(
      'BankBloc: Refreshing driver balance with range: ${event.from} - ${event.to}',
    );

    if (state is BalanceLoaded) {
      emit(
        (state as BalanceLoaded).copyWith(balanceState: RequestState.loading),
      );
    }

    final result = await getDriverBalanceUseCase(
      from: event.from,
      to: event.to,
    );

    result.fold(
      (failure) {
        logger.error(
          'BankBloc: Failed to refresh driver balance: ${failure.message}',
        );
        if (state is BalanceLoaded) {
          emit(
            (state as BalanceLoaded).copyWith(balanceState: RequestState.error),
          );
        } else {
          emit(BalanceError(failure.message));
        }
      },
      (balance) {
        logger.info('BankBloc: Successfully refreshed driver balance');
        emit(
          BalanceLoaded(balance: balance, balanceState: RequestState.loaded),
        );
      },
    );
  }

  Future<void> _onRecordRestaurantPayment(
    RecordRestaurantPaymentEvent event,
    Emitter<BankState> emit,
  ) async {
    logger.info('BankBloc: Recording restaurant payment');
    emit(const PaymentRecording());

    final result = await recordRestaurantPaymentUseCase(
      RecordRestaurantPaymentParams(
        restaurantId: event.restaurantId,
        amount: event.amount,
        selectedPeriod: event.selectedPeriod,
        startDate: event.startDate,
        endDate: event.endDate,
        notes: event.notes,
      ),
    );

    result.fold(
      (failure) {
        logger.error(
          'BankBloc: Failed to record restaurant payment: ${failure.message}',
        );
        emit(PaymentError(failure.message));
      },
      (transaction) {
        logger.info('BankBloc: Successfully recorded restaurant payment');
        emit(
          PaymentRecorded(
            transaction: transaction,
            message: 'Payment recorded successfully',
          ),
        );
        // Refresh balance after recording payment
        add(const RefreshBalanceEvent());
      },
    );
  }

  Future<void> _onRecordSystemPayment(
    RecordSystemPaymentEvent event,
    Emitter<BankState> emit,
  ) async {
    logger.info('BankBloc: Recording system payment');
    emit(const PaymentRecording());

    final result = await recordSystemPaymentUseCase(
      RecordSystemPaymentParams(
        driverId: event.driverId,
        amount: event.amount,
        notes: event.notes,
      ),
    );

    result.fold(
      (failure) {
        logger.error(
          'BankBloc: Failed to record system payment: ${failure.message}',
        );
        emit(PaymentError(failure.message));
      },
      (transaction) {
        logger.info('BankBloc: Successfully recorded system payment');
        emit(
          PaymentRecorded(
            transaction: transaction,
            message: 'System payment recorded successfully',
          ),
        );
        // Refresh balance after recording payment
        add(const RefreshBalanceEvent());
      },
    );
  }

  Future<void> _onGetTransactions(
    GetTransactionsEvent event,
    Emitter<BankState> emit,
  ) async {
    logger.info('BankBloc: Getting transactions');
    emit(const BankLoading());

    final result = await getTransactionsUseCase(
      GetTransactionsParams(
        status: event.status,
        type: event.type,
        page: event.page,
        perPage: event.perPage,
      ),
    );

    result.fold(
      (failure) {
        logger.error(
          'BankBloc: Failed to get transactions: ${failure.message}',
        );
        emit(TransactionsError(failure.message));
      },
      (paginatedTransactions) {
        logger.info(
          'BankBloc: Successfully loaded ${paginatedTransactions.transactions.length} transactions',
        );
        emit(
          TransactionsLoaded(
            transactions: paginatedTransactions.transactions,
            currentPage: paginatedTransactions.currentPage,
            totalPages: paginatedTransactions.totalPages,
            hasMore: paginatedTransactions.hasMore,
            statusFilter: event.status,
            typeFilter: event.type,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactionsEvent event,
    Emitter<BankState> emit,
  ) async {
    if (state is! TransactionsLoaded) return;

    final currentState = state as TransactionsLoaded;

    if (!currentState.hasMore) {
      logger.info('BankBloc: No more transactions to load');
      return;
    }

    logger.info('BankBloc: Loading more transactions');
    emit(currentState.copyWith(transactionsState: RequestState.loading));

    final result = await getTransactionsUseCase(
      GetTransactionsParams(
        status: currentState.statusFilter,
        type: currentState.typeFilter,
        page: currentState.currentPage + 1,
        perPage: 15,
      ),
    );

    result.fold(
      (failure) {
        logger.error(
          'BankBloc: Failed to load more transactions: ${failure.message}',
        );
        emit(currentState.copyWith(transactionsState: RequestState.error));
      },
      (paginatedTransactions) {
        logger.info(
          'BankBloc: Successfully loaded ${paginatedTransactions.transactions.length} more transactions',
        );
        final allTransactions = [
          ...currentState.transactions,
          ...paginatedTransactions.transactions,
        ];
        emit(
          TransactionsLoaded(
            transactions: allTransactions,
            currentPage: paginatedTransactions.currentPage,
            totalPages: paginatedTransactions.totalPages,
            hasMore: paginatedTransactions.hasMore,
            transactionsState: RequestState.loaded,
            statusFilter: currentState.statusFilter,
            typeFilter: currentState.typeFilter,
          ),
        );
      },
    );
  }

  Future<void> _onCalculateRestaurantPaymentAmount(
    CalculateRestaurantPaymentAmountEvent event,
    Emitter<BankState> emit,
  ) async {
    logger.info(
      'BankBloc: Calculating restaurant payment amount for restaurant ${event.restaurantId}, period: ${event.selectedPeriod}',
    );

    emit(const AmountCalculating());

    if (bankRepository == null) {
      logger.error('BankBloc: bankRepository is null');
      emit(const AmountCalculationError('Repository not available'));
      return;
    }

    final result = await bankRepository!.calculateRestaurantPaymentAmount(
      restaurantId: event.restaurantId,
      selectedPeriod: event.selectedPeriod,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) {
        logger.error(
          'BankBloc: Failed to calculate amount: ${failure.message}',
        );
        emit(AmountCalculationError(failure.message));
      },
      (data) {
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final formattedAmount =
            data['formatted_amount'] as String? ??
                '0.00 ${Currency.dzd.code}';
        final hasExisting = data['has_existing_transaction'] as bool? ?? false;
        final existingStatus = data['existing_transaction_status'] as String?;

        logger.info('BankBloc: Successfully calculated amount: $amount');
        emit(
          AmountCalculated(
            amount: amount,
            formattedAmount: formattedAmount,
            hasExistingTransaction: hasExisting,
            existingTransactionStatus: existingStatus,
          ),
        );
      },
    );
  }

  Future<void> _onCalculateSystemPaymentAmount(
    CalculateSystemPaymentAmountEvent event,
    Emitter<BankState> emit,
  ) async {
    logger.info(
      'BankBloc: Calculating system payment amount, period: ${event.selectedPeriod}',
    );

    emit(const SystemAmountCalculating());

    if (bankRepository == null) {
      logger.error('BankBloc: bankRepository is null');
      emit(const SystemAmountCalculationError('Repository not available'));
      return;
    }

    final result = await bankRepository!.calculateSystemPaymentAmount(
      driverId: event.driverId,
      selectedPeriod: event.selectedPeriod,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) {
        logger.error(
          'BankBloc: Failed to calculate system amount: ${failure.message}',
        );
        emit(SystemAmountCalculationError(failure.message));
      },
      (data) {
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final formattedAmount =
            data['formatted_amount'] as String? ??
                '0.00 ${Currency.dzd.code}';
        final hasExisting = data['has_existing_transaction'] as bool? ?? false;
        final existingStatus = data['existing_transaction_status'] as String?;

        logger.info('BankBloc: Successfully calculated system amount: $amount');
        emit(
          SystemAmountCalculated(
            amount: amount,
            formattedAmount: formattedAmount,
            hasExistingTransaction: hasExisting,
            existingTransactionStatus: existingStatus,
          ),
        );
      },
    );
  }
}
