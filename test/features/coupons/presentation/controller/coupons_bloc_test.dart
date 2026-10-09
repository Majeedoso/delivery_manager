import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/coupons/data/models/coupon_model.dart';
import 'package:delivery_manager/features/coupons/data/models/delivery_zone_model.dart';
import 'package:delivery_manager/features/coupons/domain/entities/coupon.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_bloc.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_event.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fakes.dart';

/// The coupon pages' state: one kind of coupon page by page, the zones and
/// the restaurants the form offers, and what saving a coupon or a zone did.
void main() {
  late MockCouponsRepository repository;

  final rentree = CouponModel.fromJson(couponJson());
  final nuit = CouponModel.fromJson(couponJson(id: 32, code: 'NUIT20'));
  final midi = CouponModel.fromJson(couponJson(id: 33, code: 'MIDI15'));
  final babEzzouar = DeliveryZoneModel.fromJson(couponZoneJson());
  final hydra = DeliveryZoneModel.fromJson(
    couponZoneJson(id: 5, name: 'Hydra'),
  );

  Map<String, dynamic> page(
    List<Coupon> coupons, {
    int current = 1,
    int last = 1,
    int? total,
  }) => {
    'coupons': coupons,
    'current_page': current,
    'last_page': last,
    'total': total ?? coupons.length,
  };

  void couponsAnswer(Either<Failure, Map<String, dynamic>> answer) => when(
    () => repository.getCoupons(
      status: any(named: 'status'),
      discountTarget: any(named: 'discountTarget'),
      page: any(named: 'page'),
    ),
  ).thenAnswer((_) async => answer);

  CouponsBloc build() => CouponsBloc(repository: repository);

  setUp(() => repository = MockCouponsRepository());

  group('the coupons', () {
    blocTest<CouponsBloc, CouponsState>(
      'the first page of one kind of coupon',
      setUp: () =>
          couponsAnswer(Right(page([rentree, nuit], last: 2, total: 21))),
      build: build,
      act: (bloc) => bloc.add(
        const LoadCouponsEvent(refresh: true, discountTarget: 'subtotal'),
      ),
      expect: () => [
        const CouponsState(isLoading: true),
        CouponsState(coupons: [rentree, nuit], lastPage: 2, total: 21),
      ],
      verify: (_) => verify(
        () => repository.getCoupons(
          status: null,
          discountTarget: 'subtotal',
          page: 1,
        ),
      ).called(1),
    );

    blocTest<CouponsBloc, CouponsState>(
      'the next page is added below',
      setUp: () => couponsAnswer(Right(page([midi], current: 2, last: 2))),
      build: build,
      seed: () => CouponsState(coupons: [rentree, nuit], lastPage: 2, total: 3),
      act: (bloc) =>
          bloc.add(const LoadCouponsEvent(page: 2, discountTarget: 'subtotal')),
      expect: () => [
        CouponsState(
          coupons: [rentree, nuit],
          lastPage: 2,
          total: 3,
          isLoadingMore: true,
        ),
        CouponsState(
          coupons: [rentree, nuit, midi],
          currentPage: 2,
          lastPage: 2,
          total: 1,
        ),
      ],
    );

    blocTest<CouponsBloc, CouponsState>(
      'a status asks again from the first page',
      setUp: () => couponsAnswer(Right(page([nuit]))),
      build: build,
      seed: () => CouponsState(coupons: [rentree, nuit], total: 2),
      act: (bloc) => bloc.add(
        const LoadCouponsEvent(
          status: 'draft',
          refresh: true,
          discountTarget: 'subtotal',
        ),
      ),
      expect: () => [
        CouponsState(
          coupons: [rentree, nuit],
          total: 2,
          isLoading: true,
          statusFilter: 'draft',
        ),
        CouponsState(coupons: [nuit], total: 1, statusFilter: 'draft'),
      ],
      verify: (_) => verify(
        () => repository.getCoupons(
          status: 'draft',
          discountTarget: 'subtotal',
          page: 1,
        ),
      ).called(1),
    );

    blocTest<CouponsBloc, CouponsState>(
      'a failure says why',
      setUp: () =>
          couponsAnswer(const Left(NetworkFailure('Network connection error'))),
      build: build,
      act: (bloc) => bloc.add(const LoadCouponsEvent(refresh: true)),
      expect: () => [
        const CouponsState(isLoading: true),
        const CouponsState(errorMessage: 'Network connection error'),
      ],
    );
  });

  group('what the form offers', () {
    blocTest<CouponsBloc, CouponsState>(
      'the zones',
      setUp: () => when(
        () => repository.getDeliveryZones(),
      ).thenAnswer((_) async => Right([babEzzouar, hydra])),
      build: build,
      act: (bloc) => bloc.add(const LoadDeliveryZonesEvent()),
      expect: () => [
        const CouponsState(isLoadingZones: true),
        CouponsState(deliveryZones: [babEzzouar, hydra]),
      ],
    );

    blocTest<CouponsBloc, CouponsState>(
      'the zones could not be read',
      setUp: () => when(() => repository.getDeliveryZones()).thenAnswer(
        (_) async => const Left(NetworkFailure('Network connection error')),
      ),
      build: build,
      act: (bloc) => bloc.add(const LoadDeliveryZonesEvent()),
      expect: () => [
        const CouponsState(isLoadingZones: true),
        const CouponsState(zonesErrorMessage: 'Network connection error'),
      ],
    );

    blocTest<CouponsBloc, CouponsState>(
      'the restaurants',
      setUp: () => when(
        () => repository.getRestaurants(
          search: any(named: 'search'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async => Right([managerRestaurantJson()])),
      build: build,
      act: (bloc) => bloc.add(const LoadRestaurantsEvent()),
      expect: () => [
        const CouponsState(isLoadingRestaurants: true),
        CouponsState(restaurants: [managerRestaurantJson()]),
      ],
    );

    blocTest<CouponsBloc, CouponsState>(
      'the restaurants could not be read',
      setUp: () =>
          when(
            () => repository.getRestaurants(
              search: any(named: 'search'),
              page: any(named: 'page'),
            ),
          ).thenAnswer(
            (_) async => const Left(ServerFailure('Server error occurred')),
          ),
      build: build,
      act: (bloc) => bloc.add(const LoadRestaurantsEvent()),
      expect: () => [
        const CouponsState(isLoadingRestaurants: true),
        const CouponsState(restaurantsErrorMessage: 'Server error occurred'),
      ],
    );
  });

  // M17: the bloc's success sentences were English ("Coupon created
  // successfully!"); the pages show the saved result instead
  group('saving a coupon', () {
    blocTest<CouponsBloc, CouponsState>(
      'a new one goes on top, and nothing is said in English',
      setUp: () => when(
        () => repository.createCoupon(
          code: any(named: 'code'),
          type: any(named: 'type'),
          value: any(named: 'value'),
          status: any(named: 'status'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          restaurantId: any(named: 'restaurantId'),
          discountTarget: any(named: 'discountTarget'),
          maxUsesTotal: any(named: 'maxUsesTotal'),
          maxUsesPerCustomer: any(named: 'maxUsesPerCustomer'),
          minOrderValue: any(named: 'minOrderValue'),
          maxDiscountAmount: any(named: 'maxDiscountAmount'),
          description: any(named: 'description'),
          deliveryZoneIds: any(named: 'deliveryZoneIds'),
        ),
      ).thenAnswer((_) async => Right(midi)),
      build: build,
      seed: () => CouponsState(coupons: [rentree], total: 1),
      act: (bloc) => bloc.add(
        CreateCouponEvent(
          code: 'MIDI15',
          type: 'percentage',
          value: 15,
          status: 'active',
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 10, 31),
          restaurantId: 4,
          deliveryZoneIds: const [3],
        ),
      ),
      expect: () => [
        CouponsState(
          coupons: [rentree],
          total: 1,
          operationStatus: CouponOperationStatus.loading,
        ),
        CouponsState(
          coupons: [midi, rentree],
          total: 2,
          operationStatus: CouponOperationStatus.success,
        ),
      ],
      verify: (_) => verify(
        () => repository.createCoupon(
          code: 'MIDI15',
          type: 'percentage',
          value: 15,
          status: 'active',
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 10, 31),
          restaurantId: 4,
          discountTarget: 'subtotal',
          maxUsesTotal: null,
          maxUsesPerCustomer: null,
          minOrderValue: null,
          maxDiscountAmount: null,
          description: null,
          deliveryZoneIds: [3],
        ),
      ).called(1),
    );

    blocTest<CouponsBloc, CouponsState>(
      'a changed one replaces its old self',
      setUp: () =>
          when(
            () => repository.updateCoupon(
              id: any(named: 'id'),
              code: any(named: 'code'),
              type: any(named: 'type'),
              value: any(named: 'value'),
              status: any(named: 'status'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              restaurantId: any(named: 'restaurantId'),
              discountTarget: any(named: 'discountTarget'),
              maxUsesTotal: any(named: 'maxUsesTotal'),
              maxUsesPerCustomer: any(named: 'maxUsesPerCustomer'),
              minOrderValue: any(named: 'minOrderValue'),
              maxDiscountAmount: any(named: 'maxDiscountAmount'),
              description: any(named: 'description'),
              deliveryZoneIds: any(named: 'deliveryZoneIds'),
            ),
          ).thenAnswer(
            (_) async =>
                Right(CouponModel.fromJson(couponJson(status: 'disabled'))),
          ),
      build: build,
      seed: () => CouponsState(coupons: [rentree, nuit], total: 2),
      act: (bloc) =>
          bloc.add(const UpdateCouponEvent(id: 31, status: 'disabled')),
      expect: () => [
        CouponsState(
          coupons: [rentree, nuit],
          total: 2,
          operationStatus: CouponOperationStatus.loading,
        ),
        CouponsState(
          coupons: [
            CouponModel.fromJson(couponJson(status: 'disabled')),
            nuit,
          ],
          total: 2,
          operationStatus: CouponOperationStatus.success,
        ),
      ],
    );

    blocTest<CouponsBloc, CouponsState>(
      'a refusal keeps the list, with the reason',
      setUp: () =>
          when(
            () => repository.updateCoupon(
              id: any(named: 'id'),
              code: any(named: 'code'),
              type: any(named: 'type'),
              value: any(named: 'value'),
              status: any(named: 'status'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              restaurantId: any(named: 'restaurantId'),
              discountTarget: any(named: 'discountTarget'),
              maxUsesTotal: any(named: 'maxUsesTotal'),
              maxUsesPerCustomer: any(named: 'maxUsesPerCustomer'),
              minOrderValue: any(named: 'minOrderValue'),
              maxDiscountAmount: any(named: 'maxDiscountAmount'),
              description: any(named: 'description'),
              deliveryZoneIds: any(named: 'deliveryZoneIds'),
            ),
          ).thenAnswer(
            (_) async => const Left(
              ServerFailure('One or more selected zones are not available.'),
            ),
          ),
      build: build,
      seed: () => CouponsState(coupons: [rentree], total: 1),
      act: (bloc) =>
          bloc.add(const UpdateCouponEvent(id: 31, deliveryZoneIds: [9])),
      expect: () => [
        CouponsState(
          coupons: [rentree],
          total: 1,
          operationStatus: CouponOperationStatus.loading,
        ),
        CouponsState(
          coupons: [rentree],
          total: 1,
          operationStatus: CouponOperationStatus.failure,
          operationMessage: 'One or more selected zones are not available.',
        ),
      ],
    );
  });

  group('saving a zone', () {
    blocTest<CouponsBloc, CouponsState>(
      'a new zone is added, changed, then deleted',
      setUp: () {
        when(
          () => repository.createDeliveryZone(
            name: any(named: 'name'),
            description: any(named: 'description'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenAnswer((_) async => Right(hydra));
        when(
          () => repository.updateDeliveryZone(
            id: any(named: 'id'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: any(named: 'radiusKm'),
            isActive: any(named: 'isActive'),
          ),
        ).thenAnswer(
          (_) async => Right(
            DeliveryZoneModel.fromJson(
              couponZoneJson(id: 5, name: 'Hydra-Centre'),
            ),
          ),
        );
        when(
          () => repository.deleteDeliveryZone(any()),
        ).thenAnswer((_) async => const Right(null));
      },
      build: build,
      seed: () => CouponsState(deliveryZones: [babEzzouar]),
      act: (bloc) async {
        bloc.add(const CreateDeliveryZoneEvent(name: 'Hydra'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const UpdateDeliveryZoneEvent(id: 5, name: 'Hydra-Centre'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const DeleteDeliveryZoneEvent(id: 3));
      },
      expect: () => [
        CouponsState(
          deliveryZones: [babEzzouar],
          zoneOperationStatus: ZoneOperationStatus.loading,
        ),
        CouponsState(
          deliveryZones: [babEzzouar, hydra],
          zoneOperationStatus: ZoneOperationStatus.success,
        ),
        CouponsState(
          deliveryZones: [babEzzouar, hydra],
          zoneOperationStatus: ZoneOperationStatus.loading,
        ),
        CouponsState(
          deliveryZones: [
            babEzzouar,
            DeliveryZoneModel.fromJson(
              couponZoneJson(id: 5, name: 'Hydra-Centre'),
            ),
          ],
          zoneOperationStatus: ZoneOperationStatus.success,
        ),
        CouponsState(
          deliveryZones: [
            babEzzouar,
            DeliveryZoneModel.fromJson(
              couponZoneJson(id: 5, name: 'Hydra-Centre'),
            ),
          ],
          zoneOperationStatus: ZoneOperationStatus.loading,
        ),
        CouponsState(
          deliveryZones: [
            DeliveryZoneModel.fromJson(
              couponZoneJson(id: 5, name: 'Hydra-Centre'),
            ),
          ],
          zoneOperationStatus: ZoneOperationStatus.success,
        ),
      ],
    );

    blocTest<CouponsBloc, CouponsState>(
      'a refused zone keeps the list, with the reason',
      setUp: () =>
          when(
            () => repository.createDeliveryZone(
              name: any(named: 'name'),
              description: any(named: 'description'),
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              radiusKm: any(named: 'radiusKm'),
            ),
          ).thenAnswer(
            (_) async => const Left(
              ServerFailure('The latitude field must be between -90 and 90.'),
            ),
          ),
      build: build,
      seed: () => CouponsState(deliveryZones: [babEzzouar]),
      act: (bloc) => bloc.add(
        const CreateDeliveryZoneEvent(name: 'Nowhere', latitude: 120),
      ),
      expect: () => [
        CouponsState(
          deliveryZones: [babEzzouar],
          zoneOperationStatus: ZoneOperationStatus.loading,
        ),
        CouponsState(
          deliveryZones: [babEzzouar],
          zoneOperationStatus: ZoneOperationStatus.failure,
          zoneOperationMessage:
              'The latitude field must be between -90 and 90.',
        ),
      ],
    );
  });
}
