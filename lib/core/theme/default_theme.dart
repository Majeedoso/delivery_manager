import 'package:flutter/material.dart';

/// Default themes for first frame (no .sp calculations to avoid blocking)
/// These are exact copies of MaterialTheme.lightTheme()/darkTheme() but with fixed pixel values
/// Used to prevent white screen during app startup before screen dimensions are available
class DefaultTheme {
  /// Light theme with fixed pixel values (no .sp calculations)
  /// ColorScheme and all styling copied from MaterialTheme.lightTheme()
  static ThemeData get lightTheme {
    // ColorScheme copied directly from MaterialTheme.lightScheme()
    const lightScheme = ColorScheme(
      brightness: Brightness.light,
      // Primary (requested)
      primary: Color(0xFFFFB870), // warm light orange (seed)
      surfaceTint: Color(0xFFFFB870),
      // Text/icon on primary should be dark for contrast (light primary)
      onPrimary: Color(0xFF2C1600),
      // Container that complements primary (darker orange for solid controls)
      primaryContainer: Color(0xFFFF8A33),
      onPrimaryContainer: Color(0xFFFFFFFF),
      // Secondary - warm brown for accents
      secondary: Color(0xFF8E5A2F),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFFFD9B0),
      onSecondaryContainer: Color(0xFF4B2B12),
      // Tertiary - muted olive accent (freshness / small accent)
      tertiary: Color(0xFF6B7A00),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFDDEB4E),
      onTertiaryContainer: Color(0xFF2B3000),
      // Error
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      // Surfaces / background (warm cream family)
      surface: Color(0xFFFEF8F1),
      onSurface: Color(0xFF231A11),
      onSurfaceVariant: Color(0xFF554434),
      // Outlines / variants
      outline: Color(0xFF887361),
      outlineVariant: Color(0xFFDBC2AD),
      // Misc
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF392E25),
      // Inverse / fixed colors (useful for elevated surfaces or tone-contrasts)
      inversePrimary: Color(0xFFFF8A33),
      primaryFixed: Color(0xFFFFE5CC),
      onPrimaryFixed: Color(0xFF2C1600),
      primaryFixedDim: Color(0xFFFFB870),
      onPrimaryFixedVariant: Color(0xFF6A3E00),
      secondaryFixed: Color(0xFFFFE5CC),
      onSecondaryFixed: Color(0xFF2C1600),
      secondaryFixedDim: Color(0xFFF6BB81),
      onSecondaryFixedVariant: Color(0xFF663D0E),
      tertiaryFixed: Color(0xFFDDEB4E),
      onTertiaryFixed: Color(0xFF1A1E00),
      tertiaryFixedDim: Color(0xFFC0D033),
      onTertiaryFixedVariant: Color(0xFF444B00),
      // Surface container steps (subtle warm layers)
      surfaceDim: Color(0xFFE9D7C9),
      surfaceBright: Color(0xFFFEF8F1),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFFFF1E7),
      surfaceContainer: Color(0xFFFDEBDC),
      surfaceContainerHigh: Color(0xFFF7E5D7),
      surfaceContainerHighest: Color(0xFFF1DFD1),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: lightScheme,
      textTheme:
          TextTheme(
            displayLarge: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
            displayMedium: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
            displaySmall: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
            headlineLarge: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
            headlineMedium: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
            headlineSmall: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
            titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
            titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
            titleSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
            bodyMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
            bodySmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
            labelLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
            labelMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
            labelSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
          ).apply(
            bodyColor: lightScheme.onSurface,
            displayColor: lightScheme.onSurface,
          ),
      scaffoldBackgroundColor: lightScheme.surface,
      canvasColor: lightScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFEF8F1),
        foregroundColor: Colors.black,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: lightScheme.onSurface,
          textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightScheme.primaryContainer,
          foregroundColor: lightScheme.onPrimaryContainer,
          textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFEF6E6), // MaterialTheme.getLightFillColor()
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: lightScheme.outline, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: lightScheme.outline, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: lightScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: lightScheme.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: lightScheme.error, width: 2.0),
        ),
        labelStyle: TextStyle(
          color: lightScheme.onSurfaceVariant,
          fontSize: 18.0,
        ),
        hintStyle: TextStyle(
          color: lightScheme.onSurfaceVariant.withOpacity(0.6),
          fontSize: 18.0,
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            lightScheme.secondaryContainer,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: lightScheme.outline, width: 1.0),
            ),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            lightScheme.secondaryContainer,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: lightScheme.outline, width: 1.0),
            ),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          return Colors.white; // Always white background, even when checked
        }),
        checkColor: WidgetStateProperty.all(Colors.black), // Black checkmark
        side: BorderSide(color: Colors.black, width: 1.0),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  /// Dark theme with fixed pixel values (no .sp calculations)
  /// ColorScheme and all styling copied from MaterialTheme.darkTheme()
  static ThemeData get darkTheme {
    // ColorScheme copied directly from MaterialTheme.darkScheme()
    const darkScheme = ColorScheme(
      brightness: Brightness.dark,
      // Primary (warm, slightly lighter accent for dark surfaces)
      primary: Color(0xFFFFCFA3),
      surfaceTint: Color(0xFFFFB870),
      // Text/icon color that appears on primary (dark brown for contrast)
      onPrimary: Color(0xFF3A1F00),
      // Container used for stronger primary surfaces (darker warm brown)
      primaryContainer: Color(0xFF7A3F00),
      onPrimaryContainer: Color(0xFFFFFFFF),
      // Secondary (warm beige / peach accents)
      secondary: Color(0xFFFFD9B0),
      onSecondary: Color(0xFF3B2310),
      secondaryContainer: Color(0xFF6A3F1D),
      onSecondaryContainer: Color(0xFFFFF8F5),
      // Tertiary (muted olive/fresh accent tuned for dark)
      tertiary: Color(0xFFDDEB4E),
      onTertiary: Color(0xFF1A1E00),
      tertiaryContainer: Color(0xFF444B00),
      onTertiaryContainer: Color(0xFFFFF8F5),
      // Error
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      // Surfaces / background (pure black)
      surface: Color(0xFF000000),
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFFCCCCCC),
      // Outlines / variants
      outline: Color(0xFFA18C83),
      outlineVariant: Color(0xFF53433C),
      // Misc
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFEEE0DA),
      // Inverse / fixed colors
      inversePrimary: Color(0xFFFF8A33),
      primaryFixed: Color(0xFFFFDBCB),
      onPrimaryFixed: Color(0xFF341100),
      primaryFixedDim: Color(0xFFFFB691),
      onPrimaryFixedVariant: Color(0xFF733510),
      secondaryFixed: Color(0xFFFFDBCB),
      onSecondaryFixed: Color(0xFF2E1507),
      secondaryFixedDim: Color(0xFFECBCA5),
      onSecondaryFixedVariant: Color(0xFF603F2D),
      tertiaryFixed: Color(0xFFE7E887),
      onTertiaryFixed: Color(0xFF121200),
      tertiaryFixedDim: Color(0xFFCBD033),
      onTertiaryFixedVariant: Color(0xFF383800),
      // Subtle surface steps for depth on dark backgrounds
      surfaceDim: Color(0xFF000000),
      surfaceBright: Color(0xFF1A1A1A),
      surfaceContainerLowest: Color(0xFF000000),
      surfaceContainerLow: Color(0xFF0D0D0D),
      surfaceContainer: Color(0xFF1A1A1A),
      surfaceContainerHigh: Color(0xFF262626),
      surfaceContainerHighest: Color(0xFF333333),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkScheme,
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
        displayMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
        displaySmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
        headlineMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
        headlineSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
        titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
        titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      scaffoldBackgroundColor: darkScheme.surface,
      canvasColor: darkScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF000000), // Pure black for dark theme
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: darkScheme.onSurface,
          textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkScheme.inversePrimary,
          foregroundColor: Colors.black,
          textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900),
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111827),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: darkScheme.outline, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: darkScheme.outline, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: darkScheme.inversePrimary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        labelStyle: TextStyle(color: Colors.white, fontSize: 18.0),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 18.0,
        ),
        errorStyle: TextStyle(color: Colors.red, fontSize: 18.0),
        prefixIconColor: Colors.white,
        suffixIconColor: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(const Color(0xFF111827)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: darkScheme.inversePrimary, width: 1.0),
            ),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(const Color(0xFF111827)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: darkScheme.inversePrimary, width: 1.0),
            ),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return darkScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: Colors.white, width: 1.0),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
