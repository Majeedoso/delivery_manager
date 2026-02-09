import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:delivery_manager/core/utils/enums.dart';

class ThemeState extends Equatable {
  final ThemeMode currentTheme;
  final RequestState requestState;
  final String message;

  const ThemeState({
    this.currentTheme = ThemeMode.system,
    this.requestState = RequestState.loading,
    this.message = '',
  });

  ThemeState copyWith({
    ThemeMode? currentTheme,
    RequestState? requestState,
    String? message,
  }) {
    return ThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        currentTheme,
        requestState,
        message,
      ];
}

