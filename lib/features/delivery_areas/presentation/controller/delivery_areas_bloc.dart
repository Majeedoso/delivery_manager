import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/delivery_areas/domain/entities/delivery_area.dart';
import 'package:delivery_manager/features/delivery_areas/domain/usecases/delivery_areas_usecases.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_event.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The delivery zones: where customers can order (decision 4 of
/// manager_suite_report.md: the app had no page for them).
class DeliveryAreasBloc extends Bloc<DeliveryAreasEvent, DeliveryAreasState> {
  final GetDeliveryAreasUseCase getAreas;
  final SaveDeliveryAreaUseCase saveArea;
  final SwitchDeliveryAreaUseCase switchArea;
  final DeleteDeliveryAreaUseCase deleteArea;

  DeliveryAreasBloc({
    required this.getAreas,
    required this.saveArea,
    required this.switchArea,
    required this.deleteArea,
  }) : super(const DeliveryAreasState()) {
    on<LoadDeliveryAreasEvent>(_onLoad);
    on<SaveDeliveryAreaEvent>(_onSave);
    on<SwitchDeliveryAreaEvent>(_onSwitch);
    on<DeleteDeliveryAreaEvent>(_onDelete);
    on<ClearDeliveryAreaFailureEvent>(
      (event, emit) => emit(state.copyWith(clearActionFailure: true)),
    );
  }

  Future<void> _onLoad(
    LoadDeliveryAreasEvent event,
    Emitter<DeliveryAreasState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DeliveryAreasStatus.loading,
        clearErrorMessage: true,
      ),
    );
    final result = await getAreas(const NoParameters());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DeliveryAreasStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (areas) => emit(
        state.copyWith(
          status: DeliveryAreasStatus.loaded,
          areas: _byName(areas),
        ),
      ),
    );
  }

  Future<void> _onSave(
    SaveDeliveryAreaEvent event,
    Emitter<DeliveryAreasState> emit,
  ) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true, clearActionFailure: true));
    final result = await saveArea(event.draft);
    result.fold(
      (failure) =>
          emit(state.copyWith(saving: false, actionFailure: failure.message)),
      (area) => emit(state.copyWith(saving: false, areas: _with(area))),
    );
  }

  Future<void> _onSwitch(
    SwitchDeliveryAreaEvent event,
    Emitter<DeliveryAreasState> emit,
  ) async {
    // A second tap while the first is sent would switch it back
    if (state.busyId != null) return;
    emit(state.copyWith(busyId: event.id, clearActionFailure: true));
    final result = await switchArea(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(clearBusyId: true, actionFailure: failure.message),
      ),
      (area) => emit(state.copyWith(clearBusyId: true, areas: _with(area))),
    );
  }

  Future<void> _onDelete(
    DeleteDeliveryAreaEvent event,
    Emitter<DeliveryAreasState> emit,
  ) async {
    if (state.busyId != null) return;
    emit(state.copyWith(busyId: event.id, clearActionFailure: true));
    final result = await deleteArea(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(clearBusyId: true, actionFailure: failure.message),
      ),
      (_) => emit(
        state.copyWith(
          clearBusyId: true,
          areas: state.areas.where((area) => area.id != event.id).toList(),
        ),
      ),
    );
  }

  /// The zones with [area] in its place (or added), by name.
  List<DeliveryArea> _with(DeliveryArea area) =>
      _byName([...state.areas.where((other) => other.id != area.id), area]);

  static List<DeliveryArea> _byName(List<DeliveryArea> areas) =>
      [...areas]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}
