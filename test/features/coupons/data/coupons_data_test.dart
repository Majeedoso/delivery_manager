import 'package:clock/clock.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/coupons/data/datasource/coupons_remote_data_source.dart';
import 'package:delivery_manager/features/coupons/data/models/coupon_model.dart';
import 'package:delivery_manager/features/coupons/data/models/delivery_zone_model.dart';
import 'package:delivery_manager/features/coupons/data/repository/coupons_repository.dart';
import 'package:delivery_manager/features/coupons/domain/entities/coupon.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/api_json.dart';
import '../../../helpers/fake_backend.dart';
import '../../../helpers/fakes.dart';
import '../../../helpers/locator.dart';

/// The coupons the manager issues, and the zones a coupon can be limited to,
/// as CouponController keeps them; the restaurants a coupon can target.
void main() {
  const couponsPath = '/manager/coupons';
  const zonesPath = '/manager/coupon-zones';
  const restaurantsPath = '/manager/restaurants';

  group('a coupon', () {
    test('reads what the server sends', () {
      final coupon = CouponModel.fromJson(
        couponJson(
          zones: [
            {'id': 3, 'name': 'Bab Ezzouar'},
            {'id': 5, 'name': 'Hydra'},
          ],
        ),
      );

      expect(coupon.id, 31);
      expect(coupon.code, 'RENTREE10');
      expect((coupon.type, coupon.value), ('percentage', 10));
      expect(coupon.status, 'active');
      expect(coupon.startDate, DateTime.utc(2026, 9, 25));
      expect(coupon.endDate, DateTime.utc(2026, 10, 31));
      expect(
        (
          coupon.maxUsesTotal,
          coupon.maxUsesPerCustomer,
          coupon.minOrderValue,
          coupon.maxDiscountAmount,
        ),
        (100, 1, 1500, 500),
      );
      expect(coupon.usagesCount, 12);
      expect(coupon.issuerType, 'manager');
      expect(coupon.issuerName, 'Karim Haddad');
      expect(
        (coupon.restaurantId, coupon.restaurantName),
        (4, 'Pizzeria Le Phare'),
      );
      expect(coupon.discountTarget, 'subtotal');
      expect(coupon.deliveryZoneIds, [3, 5]);
    });

    test('a coupon for every restaurant, with no limit', () {
      final coupon = CouponModel.fromJson(
        couponJson(
          restaurant: null,
          maxUsesTotal: null,
          maxUsesPerCustomer: null,
          minOrderValue: null,
          maxDiscountAmount: null,
          description: null,
        ),
      );

      expect(coupon.restaurantId, isNull);
      expect(coupon.maxUsesTotal, isNull);
      expect(coupon.deliveryZoneIds, isEmpty);
    });

    // M18: it read "Expired" all its last day, which the server accepts
    group('expires after its last day', () {
      final coupon = CouponModel.fromJson(couponJson(endDate: '2026-10-31'));

      bool expiredAt(DateTime moment) =>
          withClock(Clock.fixed(moment), () => coupon.isExpired);

      test('not on the last day, morning or night', () {
        expect(expiredAt(DateTime(2026, 10, 31, 0, 30)), isFalse);
        expect(expiredAt(DateTime(2026, 10, 31, 23, 59)), isFalse);
      });

      test('from the next day', () {
        expect(expiredAt(DateTime(2026, 11, 1, 0, 1)), isTrue);
      });
    });
  });

  group('a zone', () {
    test('reads its position from MySQL\'s decimal strings', () {
      final zone = DeliveryZoneModel.fromJson(couponZoneJson());

      expect(zone.id, 3);
      expect(zone.name, 'Bab Ezzouar');
      expect(zone.description, 'Around the university');
      expect(
        (zone.latitude, zone.longitude, zone.radiusKm),
        (36.7167, 3.1833, 2.5),
      );
      expect(zone.isActive, isTrue);
      expect(zone.hasLocation, isTrue);
    });

    test('a zone without a position, switched off', () {
      final zone = DeliveryZoneModel.fromJson(
        couponZoneJson(
          latitude: null,
          longitude: null,
          radiusKm: null,
          isActive: false,
        ),
      );

      expect(zone.hasLocation, isFalse);
      expect(zone.radiusKm, isNull);
      expect(zone.isActive, isFalse);
    });

    test('a switch the database wrote as 1 or 0', () {
      expect(
        DeliveryZoneModel.fromJson({
          ...couponZoneJson(),
          'is_active': 1,
        }).isActive,
        isTrue,
      );
      expect(
        DeliveryZoneModel.fromJson({
          ...couponZoneJson(),
          'is_active': 0,
        }).isActive,
        isFalse,
      );
    });
  });

  group('the API', () {
    late FakeBackend backend;
    late CouponsRemoteDataSource source;

    setUp(() {
      backend = FakeBackend();
      source = CouponsRemoteDataSource(
        dio: testDio(backend),
        logger: silentLogger(),
      );
    });

    group('the coupons', () {
      test('one kind of coupon at a time, 20 a page', () async {
        backend.reply(
          'GET',
          couponsPath,
          body: couponsPageJson([couponJson()], lastPage: 2, total: 21),
        );

        final page = await source.getCoupons(discountTarget: 'delivery_fee');

        expect(backend.last('GET', couponsPath).query, {
          'page': 1,
          'per_page': 20,
          'discount_target': 'delivery_fee',
        });
        expect((page['coupons'] as List<CouponModel>).single.code, 'RENTREE10');
        expect(
          (page['current_page'], page['last_page'], page['total']),
          (1, 2, 21),
        );
      });

      test('a status and a page are asked for', () async {
        backend.reply('GET', couponsPath, body: couponsPageJson([]));

        await source.getCoupons(
          status: 'draft',
          discountTarget: 'subtotal',
          page: 2,
        );

        expect(backend.last('GET', couponsPath).query, {
          'page': 2,
          'per_page': 20,
          'status': 'draft',
          'discount_target': 'subtotal',
        });
      });

      test('a new coupon is sent, and read back', () async {
        backend.reply(
          'POST',
          couponsPath,
          status: 201,
          body: {
            'success': true,
            'message': 'Coupon created successfully.',
            'data': couponJson(id: 40, code: 'NUIT20', value: 20),
          },
        );

        final created = await source.createCoupon({
          'code': 'NUIT20',
          'type': 'percentage',
          'value': 20,
        });

        expect(backend.last('POST', couponsPath).json, {
          'code': 'NUIT20',
          'type': 'percentage',
          'value': 20,
        });
        expect((created.id, created.code), (40, 'NUIT20'));
      });

      test('a change is sent to that coupon', () async {
        backend.reply(
          'PUT',
          '$couponsPath/31',
          body: {
            'success': true,
            'message': 'Coupon updated successfully.',
            'data': couponJson(status: 'disabled'),
          },
        );

        final updated = await source.updateCoupon(31, {'status': 'disabled'});

        expect(backend.last('PUT', '$couponsPath/31').json, {
          'status': 'disabled',
        });
        expect(updated.status, 'disabled');
      });
    });

    group('the zones', () {
      test('are listed', () async {
        backend.reply(
          'GET',
          zonesPath,
          body: ok([
            couponZoneJson(),
            couponZoneJson(id: 5, name: 'Hydra', latitude: null),
          ]),
        );

        final zones = await source.getDeliveryZones();

        expect(zones.map((z) => z.name), ['Bab Ezzouar', 'Hydra']);
      });

      test('are created, changed and deleted', () async {
        backend
          ..reply(
            'POST',
            zonesPath,
            status: 201,
            body: ok(couponZoneJson(id: 6, name: 'Kouba')),
          )
          ..reply('PUT', '$zonesPath/6', body: ok(couponZoneJson(id: 6)))
          ..reply('DELETE', '$zonesPath/6', body: ok(null));

        expect(
          (await source.createDeliveryZone({'name': 'Kouba'})).name,
          'Kouba',
        );
        await source.updateDeliveryZone(6, {'radius_km': 3.0});
        await source.deleteDeliveryZone(6);

        expect(backend.last('POST', zonesPath).json, {'name': 'Kouba'});
        expect(backend.last('PUT', '$zonesPath/6').json, {'radius_km': 3.0});
        expect(backend.count('DELETE', '$zonesPath/6'), 1);
      });
    });

    // M14: they came from the customers' list, which only has the
    // restaurants open at that moment: at night it was empty, and the
    // coupon went out for every restaurant
    group('the restaurants a coupon can target', () {
      test('come from the manager\'s list: all of them, by name', () async {
        backend.reply(
          'GET',
          restaurantsPath,
          body: managerRestaurantsJson([
            managerRestaurantJson(id: 4, name: 'Le Phare', isOpen: false),
            managerRestaurantJson(id: 9, name: 'Tacos Hydra', isOpen: false),
          ]),
        );

        final restaurants = await source.getRestaurants();

        expect(restaurants.map((r) => r['name']), ['Le Phare', 'Tacos Hydra']);
        expect(backend.last('GET', restaurantsPath).query, {
          'page': 1,
          'per_page': 100,
          'sort_by': 'name',
          'sort_order': 'asc',
        });
        expect(backend.count('GET', '/restaurants'), 0);
      });

      test('a name searched for is sent', () async {
        backend.reply(
          'GET',
          restaurantsPath,
          body: managerRestaurantsJson([managerRestaurantJson()]),
        );

        await source.getRestaurants(search: 'phare');

        expect(backend.last('GET', restaurantsPath).query['search'], 'phare');
      });
    });

    // M19: an error page read as a map threw, and the page read "An
    // unexpected error occurred: type 'String' is not a subtype..."
    group('a failed request', () {
      test('an error page is a server error', () async {
        backend.reply('GET', couponsPath, status: 500, body: htmlErrorPage);

        await expectLater(
          source.getCoupons(),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Server error occurred',
            ),
          ),
        );
      });

      test('the server\'s reason is kept', () async {
        backend.reply(
          'POST',
          couponsPath,
          status: 422,
          body: {
            'success': false,
            'message': 'One or more selected zones are not available.',
          },
        );

        await expectLater(
          source.createCoupon({'code': 'NUIT20'}),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'One or more selected zones are not available.',
            ),
          ),
        );
      });

      test('a field refused says which', () async {
        backend.reply(
          'POST',
          couponsPath,
          status: 422,
          body: validationError({
            'code': ['The code has already been taken.'],
          }),
        );

        await expectLater(
          source.createCoupon({'code': 'RENTREE10'}),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'The code has already been taken.',
            ),
          ),
        );
      });

      test('offline, or too slow', () async {
        backend
          ..fail('GET', zonesPath, DioExceptionType.connectionError)
          ..fail('DELETE', '$zonesPath/6', DioExceptionType.receiveTimeout);

        await expectLater(
          source.getDeliveryZones(),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              'Network connection error',
            ),
          ),
        );
        await expectLater(
          source.deleteDeliveryZone(6),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              'Request timeout',
            ),
          ),
        );
      });
    });
  });

  group('the repository', () {
    late MockCouponsRemoteDataSource remote;
    late CouponsRepository repository;

    setUp(() {
      remote = MockCouponsRemoteDataSource();
      repository = CouponsRepository(remoteDataSource: remote);
      when(
        () => remote.createCoupon(any()),
      ).thenAnswer((_) async => CouponModel.fromJson(couponJson()));
      when(
        () => remote.updateCoupon(any(), any()),
      ).thenAnswer((_) async => CouponModel.fromJson(couponJson()));
    });

    test(
      'a new coupon: its days as dates, its zones, only what is set',
      () async {
        await repository.createCoupon(
          code: 'NUIT20',
          type: 'fixed_amount',
          value: 300,
          status: 'draft',
          startDate: DateTime(2026, 10, 1, 18, 45),
          endDate: DateTime(2026, 10, 15),
          discountTarget: 'delivery_fee',
          maxUsesPerCustomer: 2,
          description: '',
          deliveryZoneIds: [3, 5],
        );

        expect(
          verify(() => remote.createCoupon(captureAny())).captured.single,
          {
            'code': 'NUIT20',
            'type': 'fixed_amount',
            'value': 300,
            'status': 'draft',
            'start_date': '2026-10-01',
            'end_date': '2026-10-15',
            'max_uses_per_customer': 2,
            'discount_target': 'delivery_fee',
            'zone_ids': [3, 5],
          },
        );
      },
    );

    test('a change sends the restaurant even when there is none: the '
        'coupon is then for every restaurant', () async {
      await repository.updateCoupon(
        id: 31,
        status: 'active',
        startDate: DateTime.utc(2026, 9, 25),
        deliveryZoneIds: const [],
      );

      expect(
        verify(() => remote.updateCoupon(31, captureAny())).captured.single,
        {
          'status': 'active',
          'start_date': '2026-09-25',
          'restaurant_id': null,
          'zone_ids': <int>[],
        },
      );
    });

    test('a zone is sent with only what it has', () async {
      when(() => remote.createDeliveryZone(any())).thenAnswer(
        (_) async => DeliveryZoneModel.fromJson(couponZoneJson(id: 6)),
      );
      when(() => remote.updateDeliveryZone(any(), any())).thenAnswer(
        (_) async => DeliveryZoneModel.fromJson(couponZoneJson(id: 6)),
      );

      await repository.createDeliveryZone(name: 'Kouba', description: '');
      await repository.updateDeliveryZone(id: 6, radiusKm: 3, isActive: false);

      expect(
        verify(() => remote.createDeliveryZone(captureAny())).captured.single,
        {'name': 'Kouba'},
      );
      expect(
        verify(
          () => remote.updateDeliveryZone(6, captureAny()),
        ).captured.single,
        {'radius_km': 3.0, 'is_active': false},
      );
    });

    test('failures keep their message', () async {
      when(
        () => remote.getDeliveryZones(),
      ).thenThrow(const NetworkException(message: 'Network connection error'));
      when(
        () => remote.deleteDeliveryZone(6),
      ).thenThrow(const ServerException(message: 'Zone not found'));

      expect(
        await repository.getDeliveryZones(),
        isA<Left<Failure, dynamic>>().having(
          (l) => l.value,
          'failure',
          const NetworkFailure('Network connection error'),
        ),
      );
      expect(
        await repository.deleteDeliveryZone(6),
        const Left<Failure, void>(ServerFailure('Zone not found')),
      );
    });

    test('a page of coupons passes through', () async {
      final page = {
        'coupons': <Coupon>[CouponModel.fromJson(couponJson())],
        'current_page': 1,
        'last_page': 1,
        'total': 1,
      };
      when(
        () => remote.getCoupons(
          status: any(named: 'status'),
          issuerType: any(named: 'issuerType'),
          search: any(named: 'search'),
          discountTarget: any(named: 'discountTarget'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => page);

      expect(
        await repository.getCoupons(status: 'active', page: 2),
        Right<Failure, Map<String, dynamic>>(page),
      );
      verify(
        () => remote.getCoupons(
          status: 'active',
          issuerType: null,
          search: null,
          discountTarget: null,
          page: 2,
          perPage: 20,
        ),
      ).called(1);
    });
  });
}
