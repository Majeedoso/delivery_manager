import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/theme/theme_constants.dart';
import 'package:delivery_manager/core/theme/theme_colors.dart';

/// ThemeData builder for creating light and dark themes
///
/// This file contains the ThemeData creation logic separated from
/// the main MaterialTheme class for better organization.
class ThemeDataBuilder {
  /// Create text theme with default sizes
  static TextTheme _createTextTheme() {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: ThemeConstants.defaultSizes['displayLarge']!.sp,
        fontWeight: FontWeight.w400,
      ),
      displayMedium: TextStyle(
        fontSize: ThemeConstants.defaultSizes['displayMedium']!.sp,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        fontSize: ThemeConstants.defaultSizes['displaySmall']!.sp,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        fontSize: ThemeConstants.defaultSizes['headlineLarge']!.sp,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: TextStyle(
        fontSize: ThemeConstants.defaultSizes['headlineMedium']!.sp,
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: TextStyle(
        fontSize: ThemeConstants.defaultSizes['headlineSmall']!.sp,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: TextStyle(
        fontSize: ThemeConstants.defaultSizes['titleLarge']!.sp,
        fontWeight: FontWeight.w400,
      ),
      titleMedium: TextStyle(
        fontSize: ThemeConstants.defaultSizes['titleMedium']!.sp,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontSize: ThemeConstants.defaultSizes['titleSmall']!.sp,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontSize: ThemeConstants.defaultSizes['bodyLarge']!.sp,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        fontSize: ThemeConstants.defaultSizes['bodyMedium']!.sp,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        fontSize: ThemeConstants.defaultSizes['bodySmall']!.sp,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        fontSize: ThemeConstants.defaultSizes['labelLarge']!.sp,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        fontSize: ThemeConstants.defaultSizes['labelMedium']!.sp,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        fontSize: ThemeConstants.defaultSizes['labelSmall']!.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Build light theme
  static ThemeData buildLightTheme() {
    final colorScheme = ThemeColors.lightScheme();
    final textTheme = _createTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFEF8F1),
        foregroundColor: Colors.black,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: ThemeConstants.defaultSizes['appBarTitle']!.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.onSurface,
          textStyle: TextStyle(
            fontSize: ThemeConstants.defaultSizes['textButton']!.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          textStyle: TextStyle(
            fontSize: ThemeConstants.defaultSizes['elevatedButton']!.sp,
            fontWeight: FontWeight.w600,
          ),
          padding: EdgeInsets.symmetric(
            horizontal:
                ThemeConstants.defaultSpacing['buttonPaddingHorizontal']!,
            vertical: ThemeConstants.defaultSpacing['buttonPaddingVertical']!,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ThemeConstants.defaultSpacing['radiusMedium']!,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeColors.getLightFillColor(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ThemeConstants.defaultSpacing['inputPaddingHorizontal']!,
          vertical: ThemeConstants.defaultSpacing['inputPaddingVertical']!,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ThemeConstants.defaultSpacing['radiusInput']!,
          ),
          borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ThemeConstants.defaultSpacing['radiusInput']!,
          ),
          borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ThemeConstants.defaultSpacing['radiusInput']!,
          ),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ThemeConstants.defaultSpacing['radiusInput']!,
          ),
          borderSide: BorderSide(color: colorScheme.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ThemeConstants.defaultSpacing['radiusInput']!,
          ),
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: ThemeConstants.defaultSizes['inputLabel']!.sp,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          fontSize: ThemeConstants.defaultSizes['inputText']!.sp,
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            colorScheme.secondaryContainer,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ThemeConstants.defaultSpacing['radiusInput']!,
              ),
              side: BorderSide(color: colorScheme.outline, width: 1.0),
            ),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            colorScheme.secondaryContainer,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ThemeConstants.defaultSpacing['radiusInput']!,
              ),
              side: BorderSide(color: colorScheme.outline, width: 1.0),
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
        side: const BorderSide(color: Colors.black, width: 1.0),
        overlayColor: WidgetStateProperty.all(
          Colors.transparent,
        ), // Prevent overlay from hiding border
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  /// Build dark theme
  static ThemeData buildDarkTheme() {
    final colorScheme = ThemeColors.darkScheme();
    final textTheme = _createTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF000000), // Pure black for dark theme
        foregroundColor: Colors.white, // White text and icons
        elevation: 0, // Remove shadow
        titleTextStyle: TextStyle(
          fontSize: ThemeConstants.defaultSizes['appBarTitle']!.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.onSurface,
          textStyle: TextStyle(
            fontSize: ThemeConstants.defaultSizes['textButton']!.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.inversePrimary,
          foregroundColor: Colors.black,
          textStyle: TextStyle(
            fontSize: ThemeConstants.defaultSizes['elevatedButton']!.sp,
            fontWeight: FontWeight.w900,
          ),
          padding: EdgeInsets.symmetric(
            horizontal:
                ThemeConstants.defaultSpacing['buttonPaddingHorizontal']!,
            vertical: ThemeConstants.defaultSpacing['buttonPaddingVertical']!,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ThemeConstants.defaultSpacing['radiusMedium']!,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111827),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ThemeConstants.defaultSpacing['inputPaddingHorizontal']!,
          vertical: ThemeConstants.defaultSpacing['inputPaddingVertical']!,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ThemeConstants.defaultSpacing['radiusInput']!,
          ),
          borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ThemeConstants.defaultSpacing['radiusInput']!,
          ),
          borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ThemeConstants.defaultSpacing['radiusInput']!,
          ),
          borderSide: BorderSide(color: colorScheme.inversePrimary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ThemeConstants.defaultSpacing['radiusInput']!,
          ),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ThemeConstants.defaultSpacing['radiusInput']!,
          ),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        labelStyle: TextStyle(
          color: Colors.white,
          fontSize: ThemeConstants.defaultSizes['inputLabel']!.sp,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: ThemeConstants.defaultSizes['inputText']!.sp,
        ),
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: ThemeConstants.defaultSizes['inputErrorText']!.sp,
        ),
        prefixIconColor: Colors.white,
        suffixIconColor: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(const Color(0xFF111827)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ThemeConstants.defaultSpacing['radiusInput']!,
              ),
              side: BorderSide(color: colorScheme.inversePrimary, width: 1.0),
            ),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(const Color(0xFF111827)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ThemeConstants.defaultSpacing['radiusInput']!,
              ),
              side: BorderSide(color: colorScheme.inversePrimary, width: 1.0),
            ),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary; // Use primary color when checked
          }
          return Colors.transparent; // Transparent when unchecked
        }),
        checkColor: WidgetStateProperty.all(
          Colors.white,
        ), // White checkmark for dark theme
        side: const BorderSide(color: Colors.white, width: 1.0),
        overlayColor: WidgetStateProperty.all(
          Colors.transparent,
        ), // Prevent overlay from hiding border
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  /// Build theme from color scheme (for MaterialTheme class)
  static ThemeData buildTheme(ColorScheme colorScheme, TextTheme textTheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      // AppBar theme - black for dark theme, orange for light theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.brightness == Brightness.dark
            ? const Color(0xFF000000) // Pure black for dark theme
            : const Color(0xFFFEF8F1), // Warm cream for light theme
        foregroundColor: Colors.white, // White text/icons
        elevation: 0, // Remove shadow
      ),
    );
  }
}
