import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/bank/domain/entities/driver_balance.dart';
import 'package:delivery_manager/features/bank/domain/repositories/base_bank_repository.dart';

class GetDriverBalanceUseCase {
  final BaseBankRepository repository;

  GetDriverBalanceUseCase(this.repository);

  /// The balance; with [counterpartyType], [counterpartyId] and [side], that
  /// one line with its rows, 10 a [page]
  Future<Either<Failure, DriverBalance>> call({
    String? from,
    String? to,
    String? counterpartyType,
    int? counterpartyId,
    String? side,
    int page = 1,
  }) async {
    return await repository.getDriverBalance(
      from: from,
      to: to,
      counterpartyType: counterpartyType,
      counterpartyId: counterpartyId,
      side: side,
      page: page,
    );
  }
}
