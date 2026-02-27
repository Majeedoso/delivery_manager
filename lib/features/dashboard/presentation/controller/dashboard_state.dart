import 'package:equatable/equatable.dart';
import 'package:delivery_manager/features/dashboard/domain/entities/app_dashboard.dart';

enum DashboardSettingsStatus { initial, loading, loaded, error }

enum DashboardUpdateStatus { initial, loading, success, error }

class DashboardState extends Equatable {
  final List<AppDashboard> settings;
  final DashboardSettingsStatus settingsStatus;
  final DashboardUpdateStatus updateStatus;
  final String? errorMessage;
  final String? updateErrorMessage;
  final int currentPage;
  final int lastPage;
  final int? updatingSettingId;
  final int? updatedSettingId;

  const DashboardState({
    this.settings = const [],
    this.settingsStatus = DashboardSettingsStatus.initial,
    this.updateStatus = DashboardUpdateStatus.initial,
    this.errorMessage,
    this.updateErrorMessage,
    this.currentPage = 1,
    this.lastPage = 1,
    this.updatingSettingId,
    this.updatedSettingId,
  });

  bool get hasMore => currentPage < lastPage;

  DashboardState copyWith({
    List<AppDashboard>? settings,
    DashboardSettingsStatus? settingsStatus,
    DashboardUpdateStatus? updateStatus,
    String? errorMessage,
    String? updateErrorMessage,
    int? currentPage,
    int? lastPage,
    int? updatingSettingId,
    int? updatedSettingId,
    bool clearErrorMessage = false,
    bool clearUpdateErrorMessage = false,
    bool clearUpdatingSettingId = false,
    bool clearUpdatedSettingId = false,
  }) {
    return DashboardState(
      settings: settings ?? this.settings,
      settingsStatus: settingsStatus ?? this.settingsStatus,
      updateStatus: updateStatus ?? this.updateStatus,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      updateErrorMessage: clearUpdateErrorMessage ? null : updateErrorMessage ?? this.updateErrorMessage,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      updatingSettingId: clearUpdatingSettingId ? null : updatingSettingId ?? this.updatingSettingId,
      updatedSettingId: clearUpdatedSettingId ? null : updatedSettingId ?? this.updatedSettingId,
    );
  }

  @override
  List<Object?> get props => [
        settings,
        settingsStatus,
        updateStatus,
        errorMessage,
        updateErrorMessage,
        currentPage,
        lastPage,
        updatingSettingId,
        updatedSettingId,
      ];
}
