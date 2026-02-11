import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/features/coupons/domain/repository/base_coupons_repository.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_event.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_state.dart';
import 'package:delivery_manager/features/coupons/domain/entities/coupon.dart';

/// BLoC for managing coupons.
class CouponsBloc extends Bloc<CouponsEvent, CouponsState> {
  final BaseCouponsRepository repository;

  CouponsBloc({required this.repository}) : super(const CouponsState()) {
    on<LoadCouponsEvent>(_onLoadCoupons);
    on<LoadDeliveryZonesEvent>(_onLoadDeliveryZones);
    on<LoadRestaurantsEvent>(_onLoadRestaurants);
    on<CreateDeliveryZoneEvent>(_onCreateDeliveryZone);
    on<UpdateDeliveryZoneEvent>(_onUpdateDeliveryZone);
    on<DeleteDeliveryZoneEvent>(_onDeleteDeliveryZone);
    on<CreateCouponEvent>(_onCreateCoupon);
    on<UpdateCouponEvent>(_onUpdateCoupon);
  }

  Future<void> _onLoadCoupons(
    LoadCouponsEvent event,
    Emitter<CouponsState> emit,
  ) async {
    // If refreshing or first page, show loading
    if (event.refresh || event.page == 1) {
      emit(
        state.copyWith(
          isLoading: true,
          clearError: true,
          statusFilter: event.status,
        ),
      );
    } else {
      // Loading more pages
      emit(state.copyWith(isLoadingMore: true));
    }

    final result = await repository.getCoupons(
      status: event.status,
      discountTarget: event.discountTarget,
      page: event.page,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        );
      },
      (data) {
        final List<Coupon> coupons = data['coupons'] as List<Coupon>;
        final int currentPage = data['current_page'] as int;
        final int lastPage = data['last_page'] as int;
        final int total = data['total'] as int;

        // If first page, replace; otherwise append
        final allCoupons = event.page == 1 || event.refresh
            ? coupons
            : [...state.coupons, ...coupons];

        emit(
          state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            coupons: allCoupons,
            currentPage: currentPage,
            lastPage: lastPage,
            total: total,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onLoadDeliveryZones(
    LoadDeliveryZonesEvent event,
    Emitter<CouponsState> emit,
  ) async {
    emit(state.copyWith(isLoadingZones: true, clearZonesError: true));

    final result = await repository.getDeliveryZones();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoadingZones: false,
            zonesErrorMessage: failure.message,
          ),
        );
      },
      (zones) {
        emit(
          state.copyWith(
            isLoadingZones: false,
            deliveryZones: zones,
            clearZonesError: true,
          ),
        );
      },
    );
  }

  Future<void> _onLoadRestaurants(
    LoadRestaurantsEvent event,
    Emitter<CouponsState> emit,
  ) async {
    if (event.refresh || event.page == 1) {
      emit(
        state.copyWith(
          isLoadingRestaurants: true,
          clearRestaurantsError: true,
        ),
      );
    }

    final result = await repository.getRestaurants(
      search: event.search,
      page: event.page,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoadingRestaurants: false,
            restaurantsErrorMessage: failure.message,
          ),
        );
      },
      (restaurants) {
        emit(
          state.copyWith(
            isLoadingRestaurants: false,
            restaurants: restaurants,
            clearRestaurantsError: true,
          ),
        );
      },
    );
  }

  Future<void> _onCreateDeliveryZone(
    CreateDeliveryZoneEvent event,
    Emitter<CouponsState> emit,
  ) async {
    emit(
      state.copyWith(
        zoneOperationStatus: ZoneOperationStatus.loading,
        clearZoneOperationMessage: true,
      ),
    );

    final result = await repository.createDeliveryZone(
      name: event.name,
      description: event.description,
      latitude: event.latitude,
      longitude: event.longitude,
      radiusKm: event.radiusKm,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            zoneOperationStatus: ZoneOperationStatus.failure,
            zoneOperationMessage: failure.message,
          ),
        );
      },
      (zone) {
        emit(
          state.copyWith(
            zoneOperationStatus: ZoneOperationStatus.success,
            zoneOperationMessage: 'Zone created successfully!',
            deliveryZones: [...state.deliveryZones, zone],
          ),
        );
      },
    );
  }

  Future<void> _onUpdateDeliveryZone(
    UpdateDeliveryZoneEvent event,
    Emitter<CouponsState> emit,
  ) async {
    emit(
      state.copyWith(
        zoneOperationStatus: ZoneOperationStatus.loading,
        clearZoneOperationMessage: true,
      ),
    );

    final result = await repository.updateDeliveryZone(
      id: event.id,
      name: event.name,
      description: event.description,
      latitude: event.latitude,
      longitude: event.longitude,
      radiusKm: event.radiusKm,
      isActive: event.isActive,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            zoneOperationStatus: ZoneOperationStatus.failure,
            zoneOperationMessage: failure.message,
          ),
        );
      },
      (zone) {
        final updatedZones = state.deliveryZones.map((z) {
          return z.id == zone.id ? zone : z;
        }).toList();

        emit(
          state.copyWith(
            zoneOperationStatus: ZoneOperationStatus.success,
            zoneOperationMessage: 'Zone updated successfully!',
            deliveryZones: updatedZones,
          ),
        );
      },
    );
  }

  Future<void> _onDeleteDeliveryZone(
    DeleteDeliveryZoneEvent event,
    Emitter<CouponsState> emit,
  ) async {
    emit(
      state.copyWith(
        zoneOperationStatus: ZoneOperationStatus.loading,
        clearZoneOperationMessage: true,
      ),
    );

    final result = await repository.deleteDeliveryZone(event.id);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            zoneOperationStatus: ZoneOperationStatus.failure,
            zoneOperationMessage: failure.message,
          ),
        );
      },
      (_) {
        final updatedZones = state.deliveryZones
            .where((z) => z.id != event.id)
            .toList();

        emit(
          state.copyWith(
            zoneOperationStatus: ZoneOperationStatus.success,
            zoneOperationMessage: 'Zone deleted successfully!',
            deliveryZones: updatedZones,
          ),
        );
      },
    );
  }

  Future<void> _onCreateCoupon(
    CreateCouponEvent event,
    Emitter<CouponsState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: CouponOperationStatus.loading,
        clearOperationMessage: true,
      ),
    );

    final result = await repository.createCoupon(
      code: event.code,
      type: event.type,
      value: event.value,
      status: event.status,
      startDate: event.startDate,
      endDate: event.endDate,
      restaurantId: event.restaurantId,
      discountTarget: event.discountTarget,
      maxUsesTotal: event.maxUsesTotal,
      maxUsesPerCustomer: event.maxUsesPerCustomer,
      minOrderValue: event.minOrderValue,
      maxDiscountAmount: event.maxDiscountAmount,
      description: event.description,
      deliveryZoneIds: event.deliveryZoneIds,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            operationStatus: CouponOperationStatus.failure,
            operationMessage: failure.message,
          ),
        );
      },
      (coupon) {
        // Add the new coupon to the list
        emit(
          state.copyWith(
            operationStatus: CouponOperationStatus.success,
            operationMessage: 'Coupon created successfully!',
            coupons: [coupon, ...state.coupons],
            total: state.total + 1,
          ),
        );
      },
    );
  }

  Future<void> _onUpdateCoupon(
    UpdateCouponEvent event,
    Emitter<CouponsState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: CouponOperationStatus.loading,
        clearOperationMessage: true,
      ),
    );

    final result = await repository.updateCoupon(
      id: event.id,
      code: event.code,
      type: event.type,
      value: event.value,
      status: event.status,
      startDate: event.startDate,
      endDate: event.endDate,
      restaurantId: event.restaurantId,
      discountTarget: event.discountTarget,
      maxUsesTotal: event.maxUsesTotal,
      maxUsesPerCustomer: event.maxUsesPerCustomer,
      minOrderValue: event.minOrderValue,
      maxDiscountAmount: event.maxDiscountAmount,
      description: event.description,
      deliveryZoneIds: event.deliveryZoneIds,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            operationStatus: CouponOperationStatus.failure,
            operationMessage: failure.message,
          ),
        );
      },
      (coupon) {
        // Update the coupon in the list
        final updatedCoupons = state.coupons.map((c) {
          return c.id == coupon.id ? coupon : c;
        }).toList();

        emit(
          state.copyWith(
            operationStatus: CouponOperationStatus.success,
            operationMessage: 'Coupon updated successfully!',
            coupons: updatedCoupons,
          ),
        );
      },
    );
  }
}
