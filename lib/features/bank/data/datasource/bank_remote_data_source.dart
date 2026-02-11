import 'package:dio/dio.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
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
      logger.debug('BankRemoteDataSource: Response data: ${response.data}');

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
      logger.error('BankRemoteDataSource: Exception occurred', error: e);
      logger.error('BankRemoteDataSource: Exception type: ${e.runtimeType}');

      if (e is DioException) {
        if (e.response != null) {
          logger.error(
            'BankRemoteDataSource: Response status code: ${e.response?.statusCode}',
          );

          try {
            final responseData = e.response?.data;
            if (responseData is String) {
              logger.error(
                'BankRemoteDataSource: Raw response body (String): ${responseData.substring(0, responseData.length > 500 ? 500 : responseData.length)}',
              );
            } else {
              logger.error(
                'BankRemoteDataSource: Raw response body: $responseData',
              );
            }
          } catch (logError) {
            logger.error(
              'BankRemoteDataSource: Failed to log response data: $logError',
            );
          }
        }

        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          logger.error('BankRemoteDataSource: Timeout error occurred');
          throw Exception(
            'Request timeout: Please check your internet connection and try again',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          logger.error('BankRemoteDataSource: Connection error occurred');
          throw Exception('Connection error: Unable to reach the server');
        } else if (e.type == DioExceptionType.badResponse) {
          logger.error('BankRemoteDataSource: Bad response error');
          String errorMessage =
              'Server returned an invalid response. Please try again.';
          if (e.response?.data != null) {
            final responseData = e.response!.data;
            if (responseData is Map<String, dynamic> &&
                responseData.containsKey('message')) {
              errorMessage = responseData['message'].toString();
            }
          }
          throw Exception(errorMessage);
        }
      }

      logger.error('BankRemoteDataSource: Stack trace: ${StackTrace.current}');
      throw Exception('Error fetching driver balance: $e');
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
      logger.error(
        'BankRemoteDataSource: Exception calculating restaurant payment amount',
        error: e,
      );

      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw Exception(
            'Request timeout: Please check your internet connection',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw Exception('Connection error: Unable to reach the server');
        } else if (e.type == DioExceptionType.badResponse) {
          String errorMessage = 'Server error. Please try again.';
          if (e.response?.data != null) {
            final responseData = e.response!.data;
            if (responseData is Map<String, dynamic> &&
                responseData.containsKey('message')) {
              errorMessage = responseData['message'].toString();
            }
          }
          throw Exception(errorMessage);
        }
      }

      throw Exception('Error calculating amount: $e');
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
      logger.error(
        'BankRemoteDataSource: Exception calculating system payment amount',
        error: e,
      );

      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw Exception(
            'Request timeout: Please check your internet connection',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw Exception('Connection error: Unable to reach the server');
        } else if (e.type == DioExceptionType.badResponse) {
          String errorMessage = 'Server error. Please try again.';
          if (e.response?.data != null) {
            final responseData = e.response!.data;
            if (responseData is Map<String, dynamic> &&
                responseData.containsKey('message')) {
              errorMessage = responseData['message'].toString();
            }
          }
          throw Exception(errorMessage);
        }
      }

      throw Exception('Error calculating system amount: $e');
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
      logger.debug('BankRemoteDataSource: Request data: $data');

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
      logger.debug('BankRemoteDataSource: Response data: ${response.data}');

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
      logger.error(
        'BankRemoteDataSource: Exception recording restaurant payment',
        error: e,
      );

      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw Exception(
            'Request timeout: Please check your internet connection and try again',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw Exception('Connection error: Unable to reach the server');
        } else if (e.type == DioExceptionType.badResponse) {
          String errorMessage =
              'Server returned an invalid response. Please try again.';
          if (e.response?.data != null) {
            final responseData = e.response!.data;
            if (responseData is Map<String, dynamic>) {
              if (responseData.containsKey('message')) {
                errorMessage = responseData['message'].toString();
              } else if (responseData.containsKey('errors')) {
                final errors = responseData['errors'] as Map<String, dynamic>;
                errorMessage = errors.values.first
                    .toString()
                    .replaceAll('[', '')
                    .replaceAll(']', '');
              }
            }
          }
          throw Exception(errorMessage);
        }
      }

      throw Exception('Error recording restaurant payment: $e');
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
      logger.debug('BankRemoteDataSource: Request data: $data');

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
      logger.debug('BankRemoteDataSource: Response data: ${response.data}');

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
      logger.error(
        'BankRemoteDataSource: Exception recording system payment',
        error: e,
      );

      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw Exception(
            'Request timeout: Please check your internet connection and try again',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw Exception('Connection error: Unable to reach the server');
        } else if (e.type == DioExceptionType.badResponse) {
          String errorMessage =
              'Server returned an invalid response. Please try again.';
          if (e.response?.data != null) {
            final responseData = e.response!.data;
            if (responseData is Map<String, dynamic>) {
              if (responseData.containsKey('message')) {
                errorMessage = responseData['message'].toString();
              } else if (responseData.containsKey('errors')) {
                final errors = responseData['errors'] as Map<String, dynamic>;
                errorMessage = errors.values.first
                    .toString()
                    .replaceAll('[', '')
                    .replaceAll(']', '');
              }
            }
          }
          throw Exception(errorMessage);
        }
      }

      throw Exception('Error recording system payment: $e');
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
      logger.error(
        'BankRemoteDataSource: Exception getting transactions',
        error: e,
      );

      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw Exception(
            'Request timeout: Please check your internet connection and try again',
          );
        } else if (e.type == DioExceptionType.connectionError) {
          throw Exception('Connection error: Unable to reach the server');
        } else if (e.type == DioExceptionType.badResponse) {
          String errorMessage =
              'Server returned an invalid response. Please try again.';
          if (e.response?.data != null) {
            final responseData = e.response!.data;
            if (responseData is Map<String, dynamic> &&
                responseData.containsKey('message')) {
              errorMessage = responseData['message'].toString();
            }
          }
          throw Exception(errorMessage);
        }
      }

      throw Exception('Error fetching transactions: $e');
    }
  }
}
