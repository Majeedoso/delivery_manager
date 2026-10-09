import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The fonts an Android phone would use: Roboto for Latin text and Noto Naskh
/// Arabic for Arabic letters.
const _latin = 'Roboto';
const _arabic = 'NotoNaskhArabic';

/// Loads Roboto and the Material icons from the Flutter SDK's cache, and Noto
/// Naskh Arabic from test/fonts (OFL, see test/fonts/OFL.txt).
///
/// Without real fonts every glyph is drawn as a full square from the test
/// font, about twice as wide as real text, so layouts overflow in tests that
/// fit on a phone. With them, an overflow on the 360-wide test screen is a
/// real one. If the SDK cache isn't where expected, Latin text falls back to
/// the square font.
Future<void> loadAppFonts() async {
  Future<ByteData> read(File file) async =>
      ByteData.sublistView(await file.readAsBytes());

  final arabic = FontLoader(_arabic)
    ..addFont(read(File('test/fonts/NotoNaskhArabic-Regular.ttf')))
    ..addFont(read(File('test/fonts/NotoNaskhArabic-Bold.ttf')));
  await arabic.load();

  // .../bin/cache/artifacts/engine/<platform>/flutter_tester(.exe)
  final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
  final sdkFonts = Directory('${artifacts.path}/material_fonts');
  if (!sdkFonts.existsSync()) return;
  File sdk(String name) => File('${sdkFonts.path}/$name');

  final roboto = FontLoader(_latin);
  for (final name in const [
    'roboto-thin.ttf',
    'roboto-light.ttf',
    'roboto-regular.ttf',
    'roboto-italic.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
    'roboto-black.ttf',
  ]) {
    roboto.addFont(read(sdk(name)));
  }
  await roboto.load();

  final icons = FontLoader('MaterialIcons')
    ..addFont(read(sdk('materialicons-regular.otf')));
  await icons.load();
}

/// [theme] as a phone draws it.
///
/// The app's component styles (button labels, app bar titles, input labels...)
/// name no font family, which on a phone means the system font, Roboto; the
/// test engine would use its square font instead. And no style names an
/// Arabic font, which a phone finds by fallback. This gives every style
/// Roboto when it names nothing, and Noto Naskh Arabic as the fallback.
ThemeData withPhoneFonts(ThemeData theme) {
  TextStyle? phone(TextStyle? style) => style?.copyWith(
    fontFamily: style.fontFamily ?? _latin,
    fontFamilyFallback: style.fontFamilyFallback ?? const [_arabic],
  );

  TextTheme text(TextTheme textTheme) =>
      textTheme.apply(fontFamily: _latin, fontFamilyFallback: const [_arabic]);

  WidgetStateProperty<TextStyle?>? states(
    WidgetStateProperty<TextStyle?>? property,
  ) => property == null
      ? null
      : WidgetStateProperty.resolveWith((s) => phone(property.resolve(s)));

  ButtonStyle? button(ButtonStyle? style) =>
      style?.copyWith(textStyle: states(style.textStyle));

  final input = theme.inputDecorationTheme;
  return theme.copyWith(
    textTheme: text(theme.textTheme),
    primaryTextTheme: text(theme.primaryTextTheme),
    appBarTheme: theme.appBarTheme.copyWith(
      titleTextStyle: phone(theme.appBarTheme.titleTextStyle),
      toolbarTextStyle: phone(theme.appBarTheme.toolbarTextStyle),
    ),
    textButtonTheme: TextButtonThemeData(
      style: button(theme.textButtonTheme.style),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: button(theme.elevatedButtonTheme.style),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: button(theme.outlinedButtonTheme.style),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: button(theme.filledButtonTheme.style),
    ),
    inputDecorationTheme: input.copyWith(
      labelStyle: phone(input.labelStyle),
      floatingLabelStyle: phone(input.floatingLabelStyle),
      hintStyle: phone(input.hintStyle),
      helperStyle: phone(input.helperStyle),
      errorStyle: phone(input.errorStyle),
      prefixStyle: phone(input.prefixStyle),
      suffixStyle: phone(input.suffixStyle),
      counterStyle: phone(input.counterStyle),
    ),
    snackBarTheme: theme.snackBarTheme.copyWith(
      contentTextStyle: phone(theme.snackBarTheme.contentTextStyle),
    ),
    dialogTheme: theme.dialogTheme.copyWith(
      titleTextStyle: phone(theme.dialogTheme.titleTextStyle),
      contentTextStyle: phone(theme.dialogTheme.contentTextStyle),
    ),
    tabBarTheme: theme.tabBarTheme.copyWith(
      labelStyle: phone(theme.tabBarTheme.labelStyle),
      unselectedLabelStyle: phone(theme.tabBarTheme.unselectedLabelStyle),
    ),
    chipTheme: theme.chipTheme.copyWith(
      labelStyle: phone(theme.chipTheme.labelStyle),
      secondaryLabelStyle: phone(theme.chipTheme.secondaryLabelStyle),
    ),
    bottomNavigationBarTheme: theme.bottomNavigationBarTheme.copyWith(
      selectedLabelStyle: phone(
        theme.bottomNavigationBarTheme.selectedLabelStyle,
      ),
      unselectedLabelStyle: phone(
        theme.bottomNavigationBarTheme.unselectedLabelStyle,
      ),
    ),
    listTileTheme: theme.listTileTheme.copyWith(
      titleTextStyle: phone(theme.listTileTheme.titleTextStyle),
      subtitleTextStyle: phone(theme.listTileTheme.subtitleTextStyle),
    ),
  );
}
