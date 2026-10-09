import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/delivery_areas/data/datasource/delivery_areas_remote_data_source.dart';
import 'package:delivery_manager/features/delivery_areas/data/models/delivery_area_model.dart';
import 'package:delivery_manager/features/delivery_areas/data/repository/delivery_areas_repository_impl.dart';
import 'package:delivery_manager/features/delivery_areas/domain/entities/delivery_area.dart';
import 'package:delivery_manager/features/delivery_areas/domain/repository/base_delivery_areas_repository.dart';
import 'package:delivery_manager/features/delivery_areas/domain/usecases/delivery_areas_usecases.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/api_json.dart';
import '../../../helpers/fake_backend.dart';
import '../../../helpers/locator.dart';
import '../../../helpers/usecases.dart';

class _MockSource extends Mock implements BaseDeliveryAreasRemoteDataSource {}

class _MockRepository extends Mock implements BaseDeliveryAreasRepository {}

/// The delivery zones, where customers can order, as the server's
/// `/manager/delivery-zones` keeps them (DeliveryZoneController). The app had
/// no page for them (decision 4 of manager_suite_report.md).
void main() {
  const listPath = '/manager/delivery-zones';
  const draft = DeliveryAreaDraft(
    name: 'Bab Ezzouar',
    description: 'Around the university',
    latitude: 36.7167,
    longitude: 3.1833,
    radiusKm: 2.5,
  );

  setUpAll(() => registerFallbackValue(draft));

  group('a zone', () {
    test('reads MySQL\'s decimals, sent as strings', () {
      final zone = DeliveryAreaModel.fromJson(deliveryAreaJson());

      expect(zone.id, 1);
      expect(zone.name, 'Alger Centre');
      expect(zone.description, 'The Grande Poste and Didouche Mourad');
      expect(zone.latitude, 36.7538);
      expect(zone.longitude, 3.0588);
      expect(zone.radiusKm, 5);
      expect(zone.isActive, isTrue);
    });

    test('an empty description is none', () {
      expect(
        DeliveryAreaModel.fromJson(
          deliveryAreaJson(description: '  '),
        ).description,
        isNull,
      );
    });

    test('is sent with its centre, its radius and whether it is on', () {
      expect(deliveryAreaBody(draft), {
        'name': 'Bab Ezzouar',
        'description': 'Around the university',
        'latitude': 36.7167,
        'longitude': 3.1833,
        'radius_km': 2.5,
        'is_active': true,
      });
    });
  });

  group('the server', () {
    late FakeBackend backend;
    late DeliveryAreasRemoteDataSource source;

    setUp(() {
      backend = FakeBackend();
      source = DeliveryAreasRemoteDataSource(
        dio: testDio(backend),
        logger: silentLogger(),
      );
    });

    test('lists the zones', () async {
      backend.reply(
        'GET',
        listPath,
        body: deliveryAreasJson([
          deliveryAreaJson(),
          deliveryAreaJson(id: 2, name: 'Hydra', isActive: false),
        ]),
      );

      final zones = await source.getAreas();

      expect(zones.map((zone) => zone.name), ['Alger Centre', 'Hydra']);
      expect(zones.last.isActive, isFalse);
    });

    test('creates a new zone', () async {
      backend.reply(
        'POST',
        listPath,
        status: 201,
        body: ok(deliveryAreaJson(id: 7, name: 'Bab Ezzouar')),
      );

      final zone = await source.saveArea(draft);

      expect(zone.id, 7);
      expect(backend.last('POST', listPath).json, deliveryAreaBody(draft));
    });

    test('changes a zone that has an id', () async {
      backend.reply(
        'PUT',
        '$listPath/7',
        body: ok(
          deliveryAreaJson(id: 7, name: 'Bab Ezzouar', radiusKm: '4.00'),
        ),
      );

      final zone = await source.saveArea(
        const DeliveryAreaDraft(
          id: 7,
          name: 'Bab Ezzouar',
          latitude: 36.7167,
          longitude: 3.1833,
          radiusKm: 4,
          isActive: false,
        ),
      );

      expect(zone.radiusKm, 4);
      expect(backend.last('PUT', '$listPath/7').json['is_active'], isFalse);
    });

    test('switches a zone on or off', () async {
      backend.reply(
        'POST',
        '$listPath/2/toggle-active',
        body: ok(deliveryAreaJson(id: 2, isActive: false)),
      );

      final zone = await source.switchArea(2);

      expect(zone.isActive, isFalse);
    });

    test('deletes a zone', () async {
      backend.reply('DELETE', '$listPath/2', body: ok(null));

      await source.deleteArea(2);

      expect(backend.count('DELETE', '$listPath/2'), 1);
    });

    group('a failed request', () {
      test('offline: the network failed', () async {
        backend.fail('GET', listPath, DioExceptionType.connectionError);

        await expectLater(
          source.getAreas(),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              'Network connection error',
            ),
          ),
        );
      });

      test('a field the server refused says why', () async {
        backend.reply(
          'POST',
          listPath,
          status: 422,
          body: validationFailure({
            'radius_km': ['The radius km field must not be greater than 100.'],
          }),
        );

        await expectLater(
          source.saveArea(draft),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'The radius km field must not be greater than 100.',
            ),
          ),
        );
      });

      test('a zone gone meanwhile', () async {
        backend.reply(
          'POST',
          '$listPath/9/toggle-active',
          status: 404,
          body: failure('Delivery zone not found'),
        );

        await expectLater(
          source.switchArea(9),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Delivery zone not found',
            ),
          ),
        );
      });
    });
  });

  group('the repository', () {
    late _MockSource source;
    late DeliveryAreasRepositoryImpl repository;
    final zone = DeliveryAreaModel.fromJson(deliveryAreaJson());

    setUp(() {
      source = _MockSource();
      repository = DeliveryAreasRepositoryImpl(remoteDataSource: source);
    });

    test('passes the zones through', () async {
      when(() => source.getAreas()).thenAnswer((_) async => [zone]);

      expect(await repository.getAreas(), isA<Right>());
      expect((await repository.getAreas()).getOrElse(() => []), [zone]);
    });

    test('a server\'s reason is a server failure, with its words', () async {
      when(() => source.saveArea(any())).thenAnswer(
        (_) async => throw const ServerException(message: 'Validation failed'),
      );

      expect(
        await repository.saveArea(draft),
        const Left<Failure, DeliveryArea>(ServerFailure('Validation failed')),
      );
    });

    test('the network is a network failure', () async {
      when(() => source.switchArea(any())).thenAnswer(
        (_) async =>
            throw const NetworkException(message: 'Network connection error'),
      );

      expect(
        await repository.switchArea(2),
        const Left<Failure, DeliveryArea>(
          NetworkFailure('Network connection error'),
        ),
      );
    });

    test('a deletion that went through is unit', () async {
      when(() => source.deleteArea(any())).thenAnswer((_) async {});

      expect(await repository.deleteArea(2), const Right<Failure, Unit>(unit));
      verify(() => source.deleteArea(2)).called(1);
    });
  });

  group('the use cases', () {
    late _MockRepository repository;
    final zone = DeliveryAreaModel.fromJson(deliveryAreaJson());

    setUp(() => repository = _MockRepository());

    test('get the zones', () async {
      await expectPassThrough<List<DeliveryArea>>(
        stub: (answer) =>
            when(() => repository.getAreas()).thenAnswer((_) async => answer),
        run: () => GetDeliveryAreasUseCase(repository)(const NoParameters()),
        value: [zone],
        verifyForwarded: () => verify(() => repository.getAreas()),
      );
    });

    test('save one', () async {
      await expectPassThrough<DeliveryArea>(
        stub: (answer) => when(
          () => repository.saveArea(draft),
        ).thenAnswer((_) async => answer),
        run: () => SaveDeliveryAreaUseCase(repository)(draft),
        value: zone,
        verifyForwarded: () => verify(() => repository.saveArea(draft)),
      );
    });

    test('switch one', () async {
      await expectPassThrough<DeliveryArea>(
        stub: (answer) => when(
          () => repository.switchArea(2),
        ).thenAnswer((_) async => answer),
        run: () => SwitchDeliveryAreaUseCase(repository)(2),
        value: zone,
        verifyForwarded: () => verify(() => repository.switchArea(2)),
      );
    });

    test('delete one', () async {
      await expectPassThrough<Unit>(
        stub: (answer) => when(
          () => repository.deleteArea(2),
        ).thenAnswer((_) async => answer),
        run: () => DeleteDeliveryAreaUseCase(repository)(2),
        value: unit,
        verifyForwarded: () => verify(() => repository.deleteArea(2)),
      );
    });
  });
}
