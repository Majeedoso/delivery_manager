import 'package:dio/dio.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/network/request_failure.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/bank/data/models/driver_balance_model.dart';
import 'package:delivery_manager/features/bank/data/models/transaction_model.dart';

class GetTransactionsResult {
  final List<TransactionModel> transactions;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  GetTransactionsResult({
    required this.transactions,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });
}

abstract class BankRemoteDataSource {
  Future<DriverBalanceModel> getDriverBalance({String? from, String? to});
  Future<Map<String, dynamic>> calculateRestaurantPaymentAmount({
    required int restaurantId,
    required String selectedPeriod,
    String? startDate,
    String? endDate,
  });
  Future<Map<String, dynamic>> calculateSystemPaymentAmount({
    required int driverId,
    required String selectedPeriod,
    String? startDate,
    String? endDate,
  });
  Future<TransactionModel> recordRestaurantPayment({
    required int restaurantId,
    required double amount,
    String? selectedPeriod,
    String? startDate,
    String? endDate,
    String? notes,
  });
  Future<TransactionModel> recordSystemPayment({
    required int driverId,
    required double amount,
    String? notes,
  });

  /// The platform pays a restaurant ([restaurantId]) or a driver
  /// ([driverId]) what it owes them: it counts at once.
  Future<TransactionModel> recordPlatformPayment({
    int? restaurantId,
    int? driverId,
    required double amount,
    String? notes,
  });

  /// Confirms (or refuses, saying why) a payment a driver or a restaurant
  /// sent to the platform from its app: it counts once confirmed.
  Future<void> answerPayment({
    required int transactionId,
    required bool confirm,
    String? notes,
  });
  Future<GetTransactionsResult> getTransactions({
    String? status,
    String? type,
    int page = 1,
    int perPage = 15,
  });
}

class BankRemoteDataSourceImpl implements BankRemoteDataSource {
  final Dio dio;
  final LoggingService? _logger;

  BankRemoteDataSourceImpl({required this.dio, LoggingService? logger})
    : _logger = logger;

  LoggingService get logger {
    try {
      return _logger ?? sl<LoggingService>();
    } catch (e) {
      return LoggingService();
    }
  }

  @override
  Future<DriverBalanceModel> getDriverBalance({
    String? from,
    String? to,
  }) async {
    logger.debug(
      'BankRemoteDataSource: Starting to fetch manager credits/debts from ${ApiConstance.managerCreditsDebtsPath}',
    );

    try {
      final queryParams = <String, dynamic>{};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      logger.info(
        'BankRemoteDataSource: Making GET request to ${ApiConstance.managerCreditsDebtsPath} with params: $queryParams',
      );

      final response = await dio.get(
        ApiConstance.managerCreditsDebtsPath,
        queryParameters: queryParams,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      logger.info(
        'BankRemoteDataSource: Received response with status code: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          throw Exception('No data received from server');
        }

        try {
          final balance = DriverBalanceModel.fromJson(
            response.data['data'] as Map<String, dynamic>,
          );
          logger.info(
            'BankRemoteDataSource: Successfully parsed driver balance for driver ${balance.driverId}',
          );
          return balance;
        } catch (e, stack) {
          logger.error(
            'BankRemoteDataSource: Error parsing driver balance',
            error: e,
            stackTrace: stack,
          );
          rethrow;
        }
      } else {
        logger.error(
          'BankRemoteDataSource: Non-200 status code: ${response.statusCode}',
        );
        throw Exception(
          'Failed to load driver balance: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw _failure(e, 'Balance');
    }
  }

  @override
  Future<Map<String, dynamic>> calculateRestaurantPaymentAmount({
    required int restaurantId,
    required String selectedPeriod,
    String? startDate,
    String? endDate,
  }) async {
    logger.debug(
      'BankRemoteDataSource: Calculating restaurant payment amount for restaurant $restaurantId, period: $selectedPeriod',
    );

    try {
      final queryParams = <String, dynamic>{
        'restaurant_id': restaurantId,
        'selected_period': selectedPeriod,
      };

      if (startDate != null) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate;
      }

      logger.info(
        'BankRemoteDataSource: Making GET request to ${ApiConstance.managerRestaurantPaymentAmountPath}',
      );
      logger.debug('BankRemoteDataSource: Query params: $queryParams');

      final response = await dio.get(
        ApiConstance.managerRestaurantPaymentAmountPath,
        queryParameters: queryParams,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      logger.info(
        'BankRemoteDataSource: Received response with status code: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        logger.info(
          'BankRemoteDataSource: Successfully calculated amount: ${data['amount']}',
        );
        return data;
      } else {
        throw Exception('Failed to calculate amount: ${response.statusCode}');
      }
    } catch (e) {
      throw _failure(e, 'Restaurant amount');
    }
  }

  @override
  Future<Map<String, dynamic>> calculateSystemPaymentAmount({
    required int driverId,
    required String selectedPeriod,
    String? startDate,
    String? endDate,
  }) async {
    logger.debug(
      'BankRemoteDataSource: Calculating system payment amount, driver: $driverId, period: $selectedPeriod',
    );

    try {
      final queryParams = <String, dynamic>{
        'selected_period': selectedPeriod,
        'driver_id': driverId,
      };

      if (startDate != null) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate;
      }

      logger.info(
        'BankRemoteDataSource: Making GET request to ${ApiConstance.managerSystemPaymentAmountPath}',
      );
      logger.debug('BankRemoteDataSource: Query params: $queryParams');

      final response = await dio.get(
        ApiConstance.managerSystemPaymentAmountPath,
        queryParameters: queryParams,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      logger.info(
        'BankRemoteDataSource: Received response with status code: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        logger.info(
          'BankRemoteDataSource: Successfully calculated system amount: ${data['amount']}',
        );
        return data;
      } else {
        throw Exception(
          'Failed to calculate system amount: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw _failure(e, 'Driver amount');
    }
  }

  @override
  Future<TransactionModel> recordRestaurantPayment({
    required int restaurantId,
    required double amount,
    String? selectedPeriod,
    String? startDate,
    String? endDate,
    String? notes,
  }) async {
    logger.debug(
      'BankRemoteDataSource: Recording restaurant payment for restaurant $restaurantId, amount: $amount',
    );

    try {
      final data = <String, dynamic>{
        'restaurant_id': restaurantId,
        'amount': amount,
      };

      if (selectedPeriod != null && selectedPeriod.isNotEmpty) {
        data['selected_period'] = selectedPeriod;
      }
      if (startDate != null) {
        data['start_date'] = startDate;
      }
      if (endDate != null) {
        data['end_date'] = endDate;
      }
      if (notes != null && notes.isNotEmpty) {
        data['notes'] = notes;
      }

      logger.info(
        'BankRemoteDataSource: Making POST request to ${ApiConstance.managerRestaurantPaymentsPath}',
      );

      final response = await dio.post(
        ApiConstance.managerRestaurantPaymentsPath,
        data: data,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      logger.info(
        'BankRemoteDataSource: Received response with status code: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final transaction = TransactionModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
        logger.info(
          'BankRemoteDataSource: Successfully recorded restaurant payment transaction ${transaction.id}',
        );
        return transaction;
      } else {
        logger.error(
          'BankRemoteDataSource: Non-200 status code: ${response.statusCode}',
        );
        throw Exception(
          'Failed to record restaurant payment: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw _failure(e, 'Restaurant payment');
    }
  }

  @override
  Future<TransactionModel> recordPlatformPayment({
    int? restaurantId,
    int? driverId,
    required double amount,
    String? notes,
  }) async {
    try {
      final response = await dio.post(
        ApiConstance.managerPlatformPaymentsPath,
        data: {
          'restaurant_id': ?restaurantId,
          'driver_id': ?driverId,
          'amount': amount,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
      return TransactionModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw _failure(e, 'record a payment from the platform');
    }
  }

  @override
  Future<TransactionModel> recordSystemPayment({
    required int driverId,
    required double amount,
    String? notes,
  }) async {
    logger.debug(
      'BankRemoteDataSource: Recording system payment, driver: $driverId, amount: $amount',
    );

    try {
      final data = <String, dynamic>{'amount': amount, 'driver_id': driverId};

      if (notes != null && notes.isNotEmpty) {
        data['notes'] = notes;
      }

      logger.info(
        'BankRemoteDataSource: Making POST request to ${ApiConstance.managerSystemPaymentsPath}',
      );

      final response = await dio.post(
        ApiConstance.managerSystemPaymentsPath,
        data: data,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      logger.info(
        'BankRemoteDataSource: Received response with status code: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final transaction = TransactionModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
        logger.info(
          'BankRemoteDataSource: Successfully recorded system payment transaction ${transaction.id}',
        );
        return transaction;
      } else {
        logger.error(
          'BankRemoteDataSource: Non-200 status code: ${response.statusCode}',
        );
        throw Exception(
          'Failed to record system payment: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw _failure(e, 'Driver payment');
    }
  }

  @override
  Future<GetTransactionsResult> getTransactions({
    String? status,
    String? type,
    int page = 1,
    int perPage = 15,
  }) async {
    logger.debug('BankRemoteDataSource: Getting transactions with filters');

    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      logger.info(
        'BankRemoteDataSource: Making GET request to ${ApiConstance.managerSystemPaymentsPath}',
      );
      logger.debug('BankRemoteDataSource: Query params: $queryParams');

      final response = await dio.get(
        ApiConstance.managerSystemPaymentsPath,
        queryParameters: queryParams,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      logger.info(
        'BankRemoteDataSource: Received response with status code: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        final pagination = response.data['pagination'] as Map<String, dynamic>;

        final transactions = data
            .map(
              (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        logger.info(
          'BankRemoteDataSource: Successfully loaded ${transactions.length} transactions',
        );

        return GetTransactionsResult(
          transactions: transactions,
          currentPage: pagination['current_page'] as int,
          totalPages: pagination['last_page'] as int,
          hasMore: pagination['has_more_pages'] as bool? ?? false,
        );
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw _failure(e, 'Payments list');
    }
  }

  @override
  Future<void> answerPayment({
    required int transactionId,
    required bool confirm,
    String? notes,
  }) async {
    try {
      await dio.post(
        ApiConstance.managerAnswerPaymentPath(transactionId),
        data: {
          'action': confirm ? 'confirm' : 'reject',
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
    } catch (e) {
      throw _failure(e, 'Answer to a payment');
    }
  }

  /// What a failed request tells the manager: the server's reason, or that
  /// the network failed ([requestFailureOf]). The pages read "Exception:
  /// Connection error: Unable to reach the server", in English whatever the
  /// language.
  Exception _failure(Object error, String request) {
    logger.error('BankRemoteDataSource: $request failed', error: error);
    return requestFailureOf(error);
  }
}
