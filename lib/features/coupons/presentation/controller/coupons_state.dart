import 'package:equatable/equatable.dart';
import 'package:delivery_manager/features/coupons/domain/entities/coupon.dart';
import 'package:delivery_manager/features/coupons/domain/entities/delivery_zone.dart';

/// Enum for coupon operation status.
enum CouponOperationStatus { initial, loading, success, failure }

/// Enum for zone operation status.
enum ZoneOperationStatus { initial, loading, success, failure }

/// State class for coupons feature.
class CouponsState extends Equatable {
  final List<Coupon> coupons;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int currentPage;
  final int lastPage;
  final int total;
  final String? statusFilter;

  // Operation states for create/update
  final CouponOperationStatus operationStatus;
  final String? operationMessage;

  // coupon zones for zone selection
  final List<DeliveryZone> deliveryZones;
  final bool isLoadingZones;
  final String? zonesErrorMessage;

  // Restaurants for targeting
  final List<Map<String, dynamic>> restaurants;
  final bool isLoadingRestaurants;
  final String? restaurantsErrorMessage;

  // Zone operation states for CRUD
  final ZoneOperationStatus zoneOperationStatus;
  final String? zoneOperationMessage;

  const CouponsState({
    this.coupons = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.statusFilter,
    this.operationStatus = CouponOperationStatus.initial,
    this.operationMessage,
    this.deliveryZones = const [],
    this.isLoadingZones = false,
    this.zonesErrorMessage,
    this.restaurants = const [],
    this.isLoadingRestaurants = false,
    this.restaurantsErrorMessage,
    this.zoneOperationStatus = ZoneOperationStatus.initial,
    this.zoneOperationMessage,
  });

  bool get hasMore => currentPage < lastPage;

  CouponsState copyWith({
    List<Coupon>? coupons,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    int? currentPage,
    int? lastPage,
    int? total,
    String? statusFilter,
    CouponOperationStatus? operationStatus,
    String? operationMessage,
    bool clearError = false,
    bool clearOperationMessage = false,
    List<DeliveryZone>? deliveryZones,
    bool? isLoadingZones,
    String? zonesErrorMessage,
    bool clearZonesError = false,
    List<Map<String, dynamic>>? restaurants,
    bool? isLoadingRestaurants,
    String? restaurantsErrorMessage,
    bool clearRestaurantsError = false,
    ZoneOperationStatus? zoneOperationStatus,
    String? zoneOperationMessage,
    bool clearZoneOperationMessage = false,
  }) {
    return CouponsState(
      coupons: coupons ?? this.coupons,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      statusFilter: statusFilter ?? this.statusFilter,
      operationStatus: operationStatus ?? this.operationStatus,
      operationMessage: clearOperationMessage
          ? null
          : (operationMessage ?? this.operationMessage),
      deliveryZones: deliveryZones ?? this.deliveryZones,
      isLoadingZones: isLoadingZones ?? this.isLoadingZones,
      zonesErrorMessage: clearZonesError
          ? null
          : (zonesErrorMessage ?? this.zonesErrorMessage),
      restaurants: restaurants ?? this.restaurants,
      isLoadingRestaurants: isLoadingRestaurants ?? this.isLoadingRestaurants,
      restaurantsErrorMessage: clearRestaurantsError
          ? null
          : (restaurantsErrorMessage ?? this.restaurantsErrorMessage),
      zoneOperationStatus: zoneOperationStatus ?? this.zoneOperationStatus,
      zoneOperationMessage: clearZoneOperationMessage
          ? null
          : (zoneOperationMessage ?? this.zoneOperationMessage),
    );
  }

  @override
  List<Object?> get props => [
    coupons,
    isLoading,
    isLoadingMore,
    errorMessage,
    currentPage,
    lastPage,
    total,
    statusFilter,
    operationStatus,
    operationMessage,
    deliveryZones,
    isLoadingZones,
    zonesErrorMessage,
    restaurants,
    isLoadingRestaurants,
    restaurantsErrorMessage,
    zoneOperationStatus,
    zoneOperationMessage,
  ];
}
