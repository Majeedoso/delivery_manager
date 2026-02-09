import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/utils/version_helper.dart';
import 'package:delivery_manager/features/app_version/domain/usecases/check_app_version_usecase.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_event.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_state.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/error/failure.dart';

/// Business Logic Component (BLoC) for managing app version checking
/// 
/// This BLoC handles app version checking operations:
/// - Check if current app version meets minimum requirements
/// - Compare app version with server requirements
/// 
/// It uses CheckAppVersionUseCase from the domain layer to perform these operations
/// and emits AppVersionState changes that the UI can react to.
/// 
/// The BLoC follows Clean Architecture principles:
/// - Presentation layer (this file) depends on Domain layer (use cases)
/// - Domain layer is independent and contains business logic
/// - Data layer implements domain interfaces
class AppVersionBloc extends Bloc<AppVersionEvent, AppVersionState> {
  /// Use case for checking app version
  final CheckAppVersionUseCase checkAppVersionUseCase;
  
  /// Logging service for centralized logging
  final LoggingService? _logger;

  AppVersionBloc({
    required this.checkAppVersionUseCase,
    LoggingService? logger,
  })  : _logger = logger,
        super(const AppVersionState()) {
    on<CheckAppVersionEvent>(_onCheckAppVersion);
  }
  
  LoggingService get logger {
    try {
      return _logger ?? sl<LoggingService>();
    } catch (e) {
      return LoggingService();
    }
  }

  /// Handle CheckAppVersionEvent
  /// 
  /// This method:
  /// 1. Gets the current app version from package_info
  /// 2. Calls the use case to get server version requirements
  /// 3. Compares versions to determine if update is needed
  /// 4. Emits appropriate state
  Future<void> _onCheckAppVersion(
    CheckAppVersionEvent event,
    Emitter<AppVersionState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      logger.debug('AppVersionBloc: Current app version: $currentVersion');

      // Get server version requirements
      final result = await checkAppVersionUseCase(NoParameters());

      result.fold(
        (failure) {
          // If version check fails, we need to decide: block or allow?
          // For network errors, we might want to allow, but for other errors, block
          logger.warning('AppVersionBloc: Version check failed: ${failure.message}');
          logger.warning('AppVersionBloc: Failure type - NetworkFailure: ${failure is NetworkFailure}, ServerFailure: ${failure is ServerFailure}');
          
          // Check if it's a network error - if so, allow app to continue
          // Otherwise, block the app (could be a critical error)
          final isNetworkError = failure is NetworkFailure;
          
          emit(state.copyWith(
            requestState: RequestState.loaded,
            userCurrentVersion: currentVersion,
            message: failure.message,
            isVersionSupported: isNetworkError, // Only allow on network errors
          ));
        },
        (appVersion) {
          logger.debug('AppVersionBloc: Server minimum version: ${appVersion.minimumVersion}');
          logger.debug('AppVersionBloc: Server current version: ${appVersion.currentVersion}');
          
          // Check if current version meets minimum requirement
          final isSupported = VersionHelper.isVersionSupported(
            currentVersion,
            appVersion.minimumVersion,
          );
          
          logger.info('AppVersionBloc: Version comparison - Current: $currentVersion, Minimum: ${appVersion.minimumVersion}, Supported: $isSupported');

          emit(state.copyWith(
            requestState: RequestState.loaded,
            appVersion: appVersion,
            userCurrentVersion: currentVersion,
            isVersionSupported: isSupported,
            message: isSupported
                ? 'App version is up to date'
                : 'App update required. Please update to version ${appVersion.minimumVersion} or higher.',
          ));
        },
      );
    } catch (e) {
      // If any error occurs, check if it's a plugin/package error
      logger.error('AppVersionBloc: Exception caught', error: e);
      
      // If it's a MissingPluginException, this means package_info_plus isn't properly installed
      // For now, allow app to continue but log a warning
      // In production, you might want to block the app
      final errorString = e.toString().toLowerCase();
      final isPluginError = errorString.contains('missingpluginexception') ||
                           errorString.contains('package_info') ||
                           errorString.contains('no implementation found');
      
      logger.warning('AppVersionBloc: Is plugin error: $isPluginError');
      
      // For plugin errors, we'll allow the app but log a warning
      // This is because the plugin needs a full rebuild, not hot restart
      emit(state.copyWith(
        requestState: RequestState.loaded,
        userCurrentVersion: null, // Can't get version if plugin error
        message: 'Version check failed: ${e.toString()}',
        isVersionSupported: true, // Allow app even if plugin error (needs full rebuild)
      ));
    }
  }
}

