import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/dashboard/domain/entities/app_dashboard.dart';

abstract class BaseDashboardRepository {
  Future<Either<Failure, Map<String, dynamic>>> getSettings({
    String? category,
    String? search,
    int page = 1,
    int perPage = 50,
  });

  Future<Either<Failure, AppDashboard>> updateSetting(int id, String value);
}
