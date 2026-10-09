import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/delivery_areas/data/models/delivery_area_model.dart';
import 'package:delivery_manager/features/delivery_areas/domain/entities/delivery_area.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_bloc.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_event.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fakes.dart';

/// The delivery zones page's state: the zones by name, and a save, a switch
/// or a deletion that fails says why while the list stays.
void main() {
  late MockGetDeliveryAreasUseCase getAreas;
  late MockSaveDeliveryAreaUseCase saveArea;
  late MockSwitchDeliveryAreaUseCase switchArea;
  late MockDeleteDeliveryAreaUseCase deleteArea;

  DeliveryArea zone(int id, String name, {bool on = true}) =>
      DeliveryAreaModel.fromJson(
        deliveryAreaJson(id: id, name: name, isActive: on),
      );

  final hydra = zone(2, 'Hydra');
  final centre = zone(1, 'Alger Centre');
  const draft = DeliveryAreaDraft(
    name: 'Bab Ezzouar',
    latitude: 36.7167,
    longitude: 3.1833,
    radiusKm: 2.5,
  );

  setUpAll(registerFallbacks);

  setUp(() {
    getAreas = MockGetDeliveryAreasUseCase();
    saveArea = MockSaveDeliveryAreaUseCase();
    switchArea = MockSwitchDeliveryAreaUseCase();
    deleteArea = MockDeleteDeliveryAreaUseCase();
    when(() => getAreas(any())).thenAnswer((_) async => Right([hydra, centre]));
  });

  DeliveryAreasBloc build() => DeliveryAreasBloc(
    getAreas: getAreas,
    saveArea: saveArea,
    switchArea: switchArea,
    deleteArea: deleteArea,
  );

  final loaded = DeliveryAreasState(
    status: DeliveryAreasStatus.loaded,
    areas: [centre, hydra],
  );

  group('the zones', () {
    blocTest<DeliveryAreasBloc, DeliveryAreasState>(
      'come by name',
      build: build,
      act: (bloc) => bloc.add(const LoadDeliveryAreasEvent()),
      expect: () => [const DeliveryAreasState(), loaded],
    );

    blocTest<DeliveryAreasBloc, DeliveryAreasState>(
      'that cannot be read say why',
      setUp: () => when(() => getAreas(any())).thenAnswer(
        (_) async => const Left(NetworkFailure('Network connection error')),
      ),
      build: build,
      act: (bloc) => bloc.add(const LoadDeliveryAreasEvent()),
      expect: () => [
        const DeliveryAreasState(),
        const DeliveryAreasState(
          status: DeliveryAreasStatus.error,
          errorMessage: 'Network connection error',
        ),
      ],
    );
  });

  group('a zone saved', () {
    blocTest<DeliveryAreasBloc, DeliveryAreasState>(
      'a new one takes its place by name',
      setUp: () => when(
        () => saveArea(draft),
      ).thenAnswer((_) async => Right(zone(7, 'Bab Ezzouar'))),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const SaveDeliveryAreaEvent(draft)),
      expect: () => [
        loaded.copyWith(saving: true),
        loaded.copyWith(areas: [centre, zone(7, 'Bab Ezzouar'), hydra]),
      ],
    );

    blocTest<DeliveryAreasBloc, DeliveryAreasState>(
      'a changed one replaces itself',
      setUp: () => when(
        () => saveArea(any()),
      ).thenAnswer((_) async => Right(zone(2, 'Hydra et Ben Aknoun'))),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(
        const SaveDeliveryAreaEvent(
          DeliveryAreaDraft(
            id: 2,
            name: 'Hydra et Ben Aknoun',
            latitude: 36.74,
            longitude: 3.03,
            radiusKm: 4,
          ),
        ),
      ),
      expect: () => [
        loaded.copyWith(saving: true),
        loaded.copyWith(areas: [centre, zone(2, 'Hydra et Ben Aknoun')]),
      ],
    );

    blocTest<DeliveryAreasBloc, DeliveryAreasState>(
      'refused: the list stays, and why is said',
      setUp: () => when(() => saveArea(any())).thenAnswer(
        (_) async => const Left(
          ServerFailure('The radius km field must not be greater than 100.'),
        ),
      ),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const SaveDeliveryAreaEvent(draft)),
      expect: () => [
        loaded.copyWith(saving: true),
        loaded.copyWith(
          actionFailure: 'The radius km field must not be greater than 100.',
        ),
      ],
    );
  });

  group('a zone switched', () {
    blocTest<DeliveryAreasBloc, DeliveryAreasState>(
      'off: it says so in the list',
      setUp: () => when(
        () => switchArea(2),
      ).thenAnswer((_) async => Right(zone(2, 'Hydra', on: false))),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const SwitchDeliveryAreaEvent(2)),
      expect: () => [
        loaded.copyWith(busyId: 2),
        loaded.copyWith(areas: [centre, zone(2, 'Hydra', on: false)]),
      ],
    );

    blocTest<DeliveryAreasBloc, DeliveryAreasState>(
      'a second tap while the first is sent would switch it back: ignored',
      setUp: () {
        final answer = Completer<Either<Failure, DeliveryArea>>();
        when(() => switchArea(2)).thenAnswer((_) => answer.future);
        Future.delayed(
          const Duration(milliseconds: 50),
          () => answer.complete(Right(zone(2, 'Hydra', on: false))),
        );
      },
      build: build,
      seed: () => loaded,
      act: (bloc) async {
        bloc.add(const SwitchDeliveryAreaEvent(2));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const SwitchDeliveryAreaEvent(2));
      },
      wait: const Duration(milliseconds: 100),
      verify: (_) => verify(() => switchArea(2)).called(1),
    );

    blocTest<DeliveryAreasBloc, DeliveryAreasState>(
      'failed: the list stays as it was, and why is said',
      setUp: () => when(() => switchArea(2)).thenAnswer(
        (_) async => const Left(ServerFailure('Delivery zone not found')),
      ),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const SwitchDeliveryAreaEvent(2)),
      expect: () => [
        loaded.copyWith(busyId: 2),
        loaded.copyWith(actionFailure: 'Delivery zone not found'),
      ],
    );
  });

  group('a zone deleted', () {
    blocTest<DeliveryAreasBloc, DeliveryAreasState>(
      'leaves the list',
      setUp: () =>
          when(() => deleteArea(2)).thenAnswer((_) async => const Right(unit)),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const DeleteDeliveryAreaEvent(2)),
      expect: () => [
        loaded.copyWith(busyId: 2),
        loaded.copyWith(areas: [centre]),
      ],
    );

    blocTest<DeliveryAreasBloc, DeliveryAreasState>(
      'refused: it stays, and why is said',
      setUp: () => when(
        () => deleteArea(2),
      ).thenAnswer((_) async => const Left(NetworkFailure('Request timeout'))),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const DeleteDeliveryAreaEvent(2)),
      expect: () => [
        loaded.copyWith(busyId: 2),
        loaded.copyWith(actionFailure: 'Request timeout'),
      ],
    );
  });

  blocTest<DeliveryAreasBloc, DeliveryAreasState>(
    'once said, a failure is cleared',
    build: build,
    seed: () => loaded.copyWith(actionFailure: 'Request timeout'),
    act: (bloc) => bloc.add(const ClearDeliveryAreaFailureEvent()),
    expect: () => [loaded],
  );
}
