import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends DashboardEvent {
  final String? category;
  final String? search;
  final int page;
  final bool refresh;

  const LoadSettingsEvent({
    this.category,
    this.search,
    this.page = 1,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [category, search, page, refresh];
}

class UpdateSettingEvent extends DashboardEvent {
  final int id;
  final String value;

  const UpdateSettingEvent({required this.id, required this.value});

  @override
  List<Object?> get props => [id, value];
}
