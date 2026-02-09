import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class GetCurrentThemeEvent extends ThemeEvent {
  const GetCurrentThemeEvent();
}

class ChangeThemeEvent extends ThemeEvent {
  final ThemeMode theme;

  const ChangeThemeEvent(this.theme);

  @override
  List<Object?> get props => [theme];
}

class ToggleThemeEvent extends ThemeEvent {
  const ToggleThemeEvent();
}

