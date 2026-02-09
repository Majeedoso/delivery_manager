/// Theme constants for spacing, sizing, and other design tokens
/// 
/// This file contains all the default values used throughout the app
/// for consistent spacing, sizing, and styling.
class ThemeConstants {
  // Default font sizes for text themes (values will be used with .sp)
  static const Map<String, double> defaultSizes = {
    'displayLarge': 18,
    'displayMedium': 18,
    'displaySmall': 18,
    'headlineLarge': 18,
    'headlineMedium': 18,
    'headlineSmall': 18,
    'titleLarge': 18,
    'titleMedium': 18,
    'titleSmall': 18,
    'bodyLarge': 18,
    'bodyMedium': 20,
    'bodySmall': 18,
    'labelLarge': 18,
    'labelMedium': 18,
    'labelSmall': 18,
    'appBarTitle': 20,
    'dialogTitle': 18,
    'dialogContent': 18,
    'listTileTitle': 18,
    'listTileSubtitle': 18,
    'cardTitle': 18,
    'cardContent': 18,
    'chipLabel': 18,
    'tooltip': 18,
    'bottomNavLabel': 18,
    'navigationRailLabel': 18,
    'dataTableHeader': 18,
    'dataTableContent': 18,
    'dropdownMenuItem': 18,
    'snackBarContent': 18,
    'elevatedButton': 18,
    'textButton': 18,
    'inputLabel': 18,
    'inputText': 18,
    'inputErrorText': 18,
    'scrollbarThickness': 18,
  };

  // Default spacing and sizing values (values will be used with .w, .h, or direct)
  static const Map<String, double> defaultSpacing = {
    // Padding
    'paddingSmall': 8.0,
    'paddingMedium': 16.0,
    'paddingLarge': 24.0,
    'paddingXLarge': 32.0,
    'paddingHorizontalSmall': 2.5,
    'paddingHorizontalMedium': 3.0,
    'paddingHorizontalLarge': 16.0,
    'paddingVerticalSmall': 12.0,
    'paddingVerticalMedium': 16.0,
    'paddingVerticalLarge': 24.0,
    'inputPaddingHorizontal': 16.0,
    'inputPaddingVertical': 16.0,
    'cardPaddingHorizontal': 2.0,
    'cardPaddingVertical': 0.0,
    'listTilePaddingHorizontal': 2.0,
    'listTilePaddingVertical': 0.0,
    'buttonPaddingHorizontal': 24.0,
    'buttonPaddingVertical': 12.0,
    
    // Margin
    'marginSmall': 8.0,
    'marginMedium': 12.0,
    'marginLarge': 16.0,
    'marginXLarge': 24.0,
    'cardMarginBottom': 12.0,
    
    // Spacing (SizedBox)
    'spacingSmall': 2.0,
    'spacingMedium': 16.0,
    'spacingLarge': 24.0,
    'spacingXLarge': 32.0,
    'spacingHorizontalSmall': 4.0,
    'spacingHorizontalMedium': 8.0,
    'spacingHorizontalLarge': 12.0,
    'spacingVerticalSmall': 2.0,
    'spacingVerticalMedium': 16.0,
    'spacingVerticalLarge': 24.0,
    
    // Icon sizes (will be used with .sp)
    'iconSmall': 16,
    'iconMedium': 18,
    'iconLarge': 24,
    'iconXLarge': 32,
    'iconXXLarge': 64,
    'iconLeading': 18,
    'iconTrailing': 26,
    'iconTrailingSmall': 18,
    'iconAppBar': 20,
    'iconButton': 20,
    
    // Border radius
    'radiusSmall': 4.0,
    'radiusMedium': 8.0,
    'radiusLarge': 12.0,
    'radiusXLarge': 16.0,
    'radiusButton': 3.0,
    'radiusInput': 12.0,
    'radiusCard': 12.0,
    'radiusChip': 20.0,
    'radiusDatePicker': 8.0,
    'radiusCheckbox': 4.0,
    
    // Button sizes (will be used with .h)
    'buttonHeight': 7.5,
    'buttonHeightSmall': 5.0,
    'buttonMinWidth': 0.0,
    
    // Container sizes (will be used with .w)
    'containerWidthSmall': 10.0,
    'containerWidthMedium': 32.0,
    'containerWidthLarge': 42.0,
    'containerWidthXLarge': 45.0,
    'containerHeightSmall': 5.0,
    'containerHeightMedium': 32.0,
    'containerHeightLarge': 45.0,
    'cardHeight': 9.0, // Card height for settings and info cards (will be used with .h)
    'profileCardHeight': 10.0, // Card height for profile page cards (will be used with .h)
    'checkboxSize': 4.5,
    'pinInputSize': 56.0,
    
    // Border widths
    'borderWidthSmall': 1.0,
    'borderWidthMedium': 2.0,
    'borderWidthLarge': 3.0,
    
    // Elevation
    'elevationSmall': 2.0,
    'elevationMedium': 4.0,
    'elevationLarge': 8.0,
    
    // Other
    'checkboxScale': 1.5,
    'spacingGrid': 2.5,
  };

  // Helper methods to get spacing values
  static double getSpacing(String key) => defaultSpacing[key] ?? 0.0;
  static double getSize(String key) => defaultSizes[key] ?? 18.0;
}

