import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/bank/domain/repositories/base_bank_repository.dart';

class GetTransactionsParams {
  final String? status;
  final String? type;
  final int page;
  final int perPage;

  GetTransactionsParams({
    this.status,
    this.type,
    this.page = 1,
    this.perPage = 15,
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
      page: params.page,
      perPage: params.perPage,
    );
  }
}
