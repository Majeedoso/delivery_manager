import 'package:delivery_manager/features/delivery_areas/domain/entities/delivery_area.dart';
import 'package:equatable/equatable.dart';

enum DeliveryAreasStatus { loading, loaded, error }

class DeliveryAreasState extends Equatable {
  final DeliveryAreasStatus status;
  final List<DeliveryArea> areas;

  /// Why the zones could not be read.
  final String? errorMessage;

  /// The zone being switched or deleted.
  final int? busyId;

  /// A zone being sent from the form.
  final bool saving;

  /// Why a save, a switch or a deletion failed: the list stays, and the page
  /// says it once.
  final String? actionFailure;

  const DeliveryAreasState({
    this.status = DeliveryAreasStatus.loading,
    this.areas = const [],
    this.errorMessage,
    this.busyId,
    this.saving = false,
    this.actionFailure,
  });

  DeliveryAreasState copyWith({
    DeliveryAreasStatus? status,
    List<DeliveryArea>? areas,
    String? errorMessage,
    bool clearErrorMessage = false,
    int? busyId,
    bool clearBusyId = false,
    bool? saving,
    String? actionFailure,
    bool clearActionFailure = false,
  }) => DeliveryAreasState(
    status: status ?? this.status,
    areas: areas ?? this.areas,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    busyId: clearBusyId ? null : busyId ?? this.busyId,
    saving: saving ?? this.saving,
    actionFailure: clearActionFailure
        ? null
        : actionFailure ?? this.actionFailure,
  );

  @override
  List<Object?> get props => [
    status,
    areas,
    errorMessage,
    busyId,
    saving,
    actionFailure,
  ];
}
