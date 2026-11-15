import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/bank/domain/repositories/base_bank_repository.dart';

class GetTransactionsParams {
  final String? status;
  final String? type;

  /// Some local days, yyyy-MM-dd
  final String? from;
  final String? to;
  final int page;
  final int perPage;

  GetTransactionsParams({
    this.status,
    this.type,
    this.from,
    this.to,
    this.page = 1,
    this.perPage = 10,
  });
}

class GetTransactionsUseCase {
  final BaseBankRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, PaginatedTransactions>> call(
    GetTransactionsParams params,
  ) async {
    return await repository.getTransactions(
      status: params.status,
      type: params.type,
      from: params.from,
      to: params.to,
      page: params.page,
      perPage: params.perPage,
    );
  }
}
