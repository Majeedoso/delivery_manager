import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_bloc.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_event.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/locator.dart';

/// Light, dark or the phone's setting, remembered on the phone.
void main() {
  Future<ThemeBloc> build([Map<String, Object> saved = const {}]) async {
    SharedPreferences.setMockInitialValues(saved);
    return ThemeBloc(
      sharedPreferences: await SharedPreferences.getInstance(),
      logger: silentLogger(),
    );
  }

  test('does nothing until asked', () async {
    final bloc = await build();
    final states = <ThemeState>[];
    bloc.stream.listen(states.add);

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(states, isEmpty, reason: 'it used to load the theme twice');
    await bloc.close();
  });

  test('nothing saved follows the phone', () async {
    final bloc = await build();

    bloc.add(const GetCurrentThemeEvent());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(bloc.state.currentTheme, ThemeMode.system);
    expect(bloc.state.requestState, RequestState.loaded);
    await bloc.close();
  });

  test('a saved choice comes back', () async {
    final bloc = await build({'theme_mode': 'dark'});

    bloc.add(const GetCurrentThemeEvent());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(bloc.state.currentTheme, ThemeMode.dark);
    await bloc.close();
  });

  test('an unknown saved value follows the phone', () async {
    final bloc = await build({'theme_mode': 'sepia'});

    bloc.add(const GetCurrentThemeEvent());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(bloc.state.currentTheme, ThemeMode.system);
    await bloc.close();
  });

  test('a change is kept for next time', () async {
    final bloc = await build();

    bloc.add(const ChangeThemeEvent(ThemeMode.dark));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(bloc.state.currentTheme, ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');
    await bloc.close();
  });

  test('toggling goes light ↔ dark, the phone\'s setting to light', () async {
    final bloc = await build();

    bloc.add(const ToggleThemeEvent());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.currentTheme, ThemeMode.light);

    bloc.add(const ToggleThemeEvent());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.currentTheme, ThemeMode.dark);
    await bloc.close();
  });
}
