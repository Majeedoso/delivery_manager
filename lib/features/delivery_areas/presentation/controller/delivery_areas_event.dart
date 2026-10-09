import 'package:delivery_manager/features/delivery_areas/domain/entities/delivery_area.dart';
import 'package:equatable/equatable.dart';

abstract class DeliveryAreasEvent extends Equatable {
  const DeliveryAreasEvent();

  @override
  List<Object?> get props => [];
}

/// Reads the zones (again).
class LoadDeliveryAreasEvent extends DeliveryAreasEvent {
  const LoadDeliveryAreasEvent();
}

/// A new zone, or a zone changed.
class SaveDeliveryAreaEvent extends DeliveryAreasEvent {
  final DeliveryAreaDraft draft;

  const SaveDeliveryAreaEvent(this.draft);

  @override
  List<Object?> get props => [draft];
}

/// Switches a zone on or off.
class SwitchDeliveryAreaEvent extends DeliveryAreasEvent {
  final int id;

  const SwitchDeliveryAreaEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteDeliveryAreaEvent extends DeliveryAreasEvent {
  final int id;

  const DeleteDeliveryAreaEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// The page said why an action failed.
class ClearDeliveryAreaFailureEvent extends DeliveryAreasEvent {
  const ClearDeliveryAreaFailureEvent();
}
