import "package:flutter/material.dart";
import "package:sizer/sizer.dart";
import 'package:delivery_manager/core/theme/theme_constants.dart';
import 'package:delivery_manager/core/theme/theme_colors.dart';
import 'package:delivery_manager/core/theme/theme_data_builder.dart';

/// Main theme class that provides access to theme configuration
///
/// This class acts as a facade for the theme system, delegating to
/// specialized modules for colors, constants, and theme data.
class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  // Delegate to ThemeConstants for spacing and sizing
  static double getSpacing(String key) => ThemeConstants.getSpacing(key);
  static double getSize(String key) => ThemeConstants.getSize(key);

  // Common spacing getters
  static EdgeInsets getPaddingSmall() =>
      EdgeInsets.all(ThemeConstants.defaultSpacing['paddingSmall']!);
  static EdgeInsets getPaddingMedium() =>
      EdgeInsets.all(ThemeConstants.defaultSpacing['paddingMedium']!);
  static EdgeInsets getPaddingLarge() =>
      EdgeInsets.all(ThemeConstants.defaultSpacing['paddingLarge']!);
  static EdgeInsets getPaddingHorizontal({required double horizontal}) =>
      EdgeInsets.symmetric(horizontal: horizontal.w);
  static EdgeInsets getPaddingVertical({required double vertical}) =>
      EdgeInsets.symmetric(vertical: vertical.h);

  static SizedBox getSpacingSmall() =>
      SizedBox(height: ThemeConstants.defaultSpacing['spacingSmall']!.h);
  static SizedBox getSpacingMedium() =>
      SizedBox(height: ThemeConstants.defaultSpacing['spacingMedium']!.h);
  static SizedBox getSpacingLarge() =>
      SizedBox(height: ThemeConstants.defaultSpacing['spacingLarge']!.h);
  static SizedBox getSpacingHorizontal({required double horizontal}) =>
      SizedBox(width: horizontal.w);
  static SizedBox getSpacingVertical({required double vertical}) =>
      SizedBox(height: vertical.h);

  static BorderRadius getBorderRadiusSmall() =>
      BorderRadius.circular(ThemeConstants.defaultSpacing['radiusSmall']!);
  static BorderRadius getBorderRadiusMedium() =>
      BorderRadius.circular(ThemeConstants.defaultSpacing['radiusMedium']!);
  static BorderRadius getBorderRadiusLarge() =>
      BorderRadius.circular(ThemeConstants.defaultSpacing['radiusLarge']!);
  static BorderRadius getBorderRadiusButton() =>
      BorderRadius.circular(ThemeConstants.defaultSpacing['radiusButton']!.w);
  static BorderRadius getBorderRadiusInput() =>
      BorderRadius.circular(ThemeConstants.defaultSpacing['radiusInput']!);
  static BorderRadius getBorderRadiusCard() =>
      BorderRadius.circular(ThemeConstants.defaultSpacing['radiusCard']!);

  // Delegate to ThemeColors for color schemes
  static Color getLightFillColor() => ThemeColors.getLightFillColor();
  static ColorScheme lightScheme() => ThemeColors.lightScheme();
  static ColorScheme darkScheme() => ThemeColors.darkScheme();

  // Theme data methods
  ThemeData light() {
    return ThemeDataBuilder.buildTheme(lightScheme(), textTheme);
  }

  ThemeData dark() {
    return ThemeDataBuilder.buildTheme(darkScheme(), textTheme);
  }

  ThemeData theme(ColorScheme colorScheme) {
    return ThemeDataBuilder.buildTheme(colorScheme, textTheme);
  }

  // Static methods for easy use in main.dart
  static ThemeData lightTheme() {
    return ThemeDataBuilder.buildLightTheme();
  }

  static ThemeData darkTheme() {
    return ThemeDataBuilder.buildDarkTheme();
  }

  /// Get the standard gradient background decoration used across screens
  /// This ensures consistency and makes it easy to change the background gradient
  /// in one place throughout the app
  static BoxDecoration getGradientBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      // For dark theme, use pure black background
      return const BoxDecoration(color: Color(0xFF000000));
    }

    // For light theme, use warm cream background
    return const BoxDecoration(color: Color(0xFFFEF8F1));
  }

  /// Get the standard gradient background colors as a list
  /// Useful for custom implementations that need just the colors
  static List<Color> getGradientColors(BuildContext context) {
    return [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.primary.withOpacity(0.2),
    ];
  }

  /// Get a standardized CircularProgressIndicator widget
  /// This ensures consistent styling across the app
  /// Supports both dark and light modes
  static Widget getCircularProgressIndicator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        isDark ? Colors.white : Colors.white,
      ),
    );
  }

  /// Get a full-page loading overlay widget
  /// This provides a consistent loading overlay with semi-transparent background
  /// and centered CircularProgressIndicator
  /// Supports both dark and light modes
  static Widget getFullPageLoadingOverlay(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: Colors.black.withOpacity(isDark ? 0.6 : 0.5),
      child: Center(child: getCircularProgressIndicator(context)),
    );
  }

  /// Get the standard primary button style
  /// This provides a consistent orange button style across the app
  /// Uses Color(0xFFFF8A32) (the orange used in icons and AppBar)
  /// Text color is white in dark mode and black in light mode
  static ButtonStyle getPrimaryButtonStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF8A32),
      foregroundColor: isDark ? Colors.white : Colors.black,
    );
  }
}

/// Extended color class for future use
class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

/// Color family class for extended colors
class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
