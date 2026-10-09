import 'package:delivery_manager/features/bank/domain/entities/restaurant_debt.dart';

class DriverBalance {
  final int driverId;
  final String driverName;
  final List<RestaurantDebt> restaurantDebts;
  final List<RestaurantDebt> restaurantCredits;
  final double systemDebt;
  final String formattedSystemDebt;
  final double totalDebt;
  final String formattedTotalDebt;
  final double totalCredits;
  final String formattedTotalCredits;

  const DriverBalance({
    required this.driverId,
    required this.driverName,
    required this.restaurantDebts,
    required this.restaurantCredits,
    required this.systemDebt,
    required this.formattedSystemDebt,
    required this.totalDebt,
    required this.formattedTotalDebt,
    required this.totalCredits,
    required this.formattedTotalCredits,
  });
}
