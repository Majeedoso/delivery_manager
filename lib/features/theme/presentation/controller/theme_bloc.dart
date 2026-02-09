import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_event.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences _sharedPreferences;
  final LoggingService? _logger;
  static const String _themeKey = 'theme_mode';

  ThemeBloc({
    required SharedPreferences sharedPreferences,
    LoggingService? logger,
  })  : _sharedPreferences = sharedPreferences,
        _logger = logger,
        super(const ThemeState()) {
    on<GetCurrentThemeEvent>(_onGetCurrentTheme);
    on<ChangeThemeEvent>(_onChangeTheme);
    on<ToggleThemeEvent>(_onToggleTheme);

    // Load current theme on initialization
    add(const GetCurrentThemeEvent());
  }

  LoggingService get logger {
    try {
      return _logger ?? sl<LoggingService>();
    } catch (e) {
      return LoggingService();
    }
  }

  Future<void> _onGetCurrentTheme(
    GetCurrentThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    logger.debug('ThemeBloc: Getting current theme');
    emit(state.copyWith(requestState: RequestState.loading));

    try {
      final savedTheme = _sharedPreferences.getString(_themeKey);
      ThemeMode currentTheme = ThemeMode.system;

      if (savedTheme != null) {
        currentTheme = ThemeMode.values.firstWhere(
          (mode) => mode.name == savedTheme,
          orElse: () => ThemeMode.system,
        );
      }

      logger.info('ThemeBloc: Current theme loaded: ${currentTheme.name}');
      emit(state.copyWith(
        currentTheme: currentTheme,
        requestState: RequestState.loaded,
      ));
    } catch (e) {
      logger.error('ThemeBloc: Error getting current theme', error: e);
      emit(state.copyWith(
        requestState: RequestState.error,
        message: 'Failed to load theme: $e',
      ));
    }
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    logger.info('ThemeBloc: Changing theme to ${event.theme.name}');
    emit(state.copyWith(requestState: RequestState.loading));

    try {
      await _sharedPreferences.setString(_themeKey, event.theme.name);
      logger.info('ThemeBloc: Theme changed successfully to ${event.theme.name}');
      emit(state.copyWith(
        currentTheme: event.theme,
        requestState: RequestState.loaded,
        message: 'Theme changed successfully',
      ));
    } catch (e) {
      logger.error('ThemeBloc: Error changing theme', error: e);
      emit(state.copyWith(
        requestState: RequestState.error,
        message: 'Failed to change theme: $e',
      ));
    }
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    logger.debug('ThemeBloc: Toggling theme');
    final currentTheme = state.currentTheme;
    ThemeMode newTheme;

    if (currentTheme == ThemeMode.light) {
      newTheme = ThemeMode.dark;
    } else if (currentTheme == ThemeMode.dark) {
      newTheme = ThemeMode.light;
    } else {
      // If system, default to light
      newTheme = ThemeMode.light;
    }

    add(ChangeThemeEvent(newTheme));
  }

  // Helper methods for UI
  String getThemeDisplayName(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  String getThemeDisplayNameLocalized(ThemeMode theme, dynamic localizations) {
    switch (theme) {
      case ThemeMode.light:
        return localizations.light;
      case ThemeMode.dark:
        return localizations.dark;
      case ThemeMode.system:
        return localizations.system;
    }
  }

  IconData getThemeIcon(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

