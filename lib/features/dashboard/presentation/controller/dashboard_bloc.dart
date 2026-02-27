import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/features/dashboard/domain/entities/app_dashboard.dart';
import 'package:delivery_manager/features/dashboard/domain/repository/base_dashboard_repository.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_event.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final BaseDashboardRepository repository;

  DashboardBloc({required this.repository}) : super(const DashboardState()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateSettingEvent>(_onUpdateSetting);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.page == 1 || event.refresh) {
      emit(state.copyWith(
        settingsStatus: DashboardSettingsStatus.loading,
        clearErrorMessage: true,
      ));
    }

    final result = await repository.getSettings(
      category: event.category,
      search: event.search,
      page: event.page,
      perPage: 50,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          settingsStatus: DashboardSettingsStatus.error,
          errorMessage: failure.message,
        ));
      },
      (data) {
        final newSettings = data['settings'] as List<AppDashboard>;
        final currentPage = data['current_page'] as int;
        final lastPage = data['last_page'] as int;

        final updatedSettings = (event.page == 1 || event.refresh)
            ? newSettings
            : [...state.settings, ...newSettings];

        emit(state.copyWith(
          settings: updatedSettings,
          settingsStatus: DashboardSettingsStatus.loaded,
          currentPage: currentPage,
          lastPage: lastPage,
          clearErrorMessage: true,
        ));
      },
    );
  }

  Future<void> _onUpdateSetting(
    UpdateSettingEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(
      updateStatus: DashboardUpdateStatus.loading,
      updatingSettingId: event.id,
      clearUpdateErrorMessage: true,
      clearUpdatedSettingId: true,
    ));

    final result = await repository.updateSetting(event.id, event.value);

    result.fold(
      (failure) {
        emit(state.copyWith(
          updateStatus: DashboardUpdateStatus.error,
          updateErrorMessage: failure.message,
          clearUpdatingSettingId: true,
        ));
      },
      (updatedSetting) {
        final updatedList = state.settings.map((s) {
          return s.id == updatedSetting.id ? updatedSetting : s;
        }).toList();

        emit(state.copyWith(
          settings: updatedList,
          updateStatus: DashboardUpdateStatus.success,
          updatedSettingId: updatedSetting.id,
          clearUpdatingSettingId: true,
          clearUpdateErrorMessage: true,
        ));
      },
    );
  }
}
