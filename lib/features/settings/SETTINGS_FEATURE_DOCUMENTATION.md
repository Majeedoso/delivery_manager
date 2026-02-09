# Settings Feature Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Components](#components)
4. [Features](#features)
5. [State Management](#state-management)
6. [Localization](#localization)
7. [Theme Management](#theme-management)
8. [Performance Optimizations](#performance-optimizations)
9. [Code Structure](#code-structure)
10. [Usage Guide](#usage-guide)
11. [Future Enhancements](#future-enhancements)

---

## Overview

The Settings feature provides a centralized configuration interface for the Delivery Operator app. It allows users to customize their app experience through language selection, theme preferences, and access to app information and privacy policies.

### Key Capabilities
- **Language Selection**: Switch between Arabic, English, and French
- **Theme Management**: Choose between Light, Dark, and System theme modes
- **Privacy & Terms**: Access to privacy policy and terms of service
- **App Information**: View app version and check for updates

### Technical Stack
- **Framework**: Flutter
- **State Management**: BLoC Pattern (flutter_bloc)
- **Localization**: flutter_localizations
- **Persistence**: SharedPreferences
- **Dependency Injection**: GetIt

---

## Architecture

The Settings feature follows **Clean Architecture** principles with clear separation of concerns:

```
settings/
├── presentation/
│   └── screens/
│       ├── settings_screen.dart      # Main settings screen
│       └── about_screen.dart        # About screen (future)
```

### Dependencies
- **Localization Feature**: Uses `LocalizationBloc` for language management
- **Theme Service**: Uses `ThemeService` for theme persistence and management
- **Widget Decorations**: Reusable UI components from `core/theme/widget_decorations.dart`

---

## Components

### 1. SettingsScreen

The main settings screen widget that displays all configuration options.

**Location**: `lib/features/settings/presentation/screens/settings_screen.dart`

**Key Properties**:
- `route`: Static route constant `/settings`
- `StatelessWidget`: Stateless implementation for better performance

**Structure**:
```dart
SettingsScreen
├── AppBar (with localized title)
└── Body
    ├── BlocBuilder<LocalizationBloc> (for language changes)
    └── SingleChildScrollView
        ├── App Settings Section
        │   ├── Language Card
        │   └── Theme Card (_ThemeCard widget)
        ├── Privacy Settings Section
        │   ├── Privacy Policy Card
        │   └── Terms of Service Card
        └── App Information Section
            ├── Version Card
            └── Check for Updates Card
```

### 2. _ThemeCard

A private widget that isolates theme-related rebuilds for better performance.

**Purpose**: Prevents unnecessary rebuilds of the entire settings screen when only the theme changes.

**Key Features**:
- Uses `StreamBuilder` to listen to theme changes
- Implements `PopupMenuButton` for theme selection
- Displays localized theme names
- Shows visual indicators (icons) for current theme

---

## Features

### 1. Language Selection

**Implementation**:
- Uses `LocalizationBloc` to manage language state
- Displays current language using `nativeName` (e.g., "العربية", "English", "Français")
- Navigates to `LanguageSelectionScreen` on tap
- Updates immediately when language changes

**User Flow**:
1. User taps on Language card
2. Navigates to `LanguageSelectionScreen`
3. User selects a language
4. `LocalizationBloc` updates the state
5. `MaterialApp` locale updates
6. Settings screen rebuilds with new language

### 2. Theme Management

**Implementation**:
- Uses `ThemeService` singleton for theme persistence
- Supports three modes: Light, Dark, System
- Persists theme preference in SharedPreferences
- Updates app theme immediately via `StreamBuilder`

**Theme Modes**:
- **Light**: Uses light color scheme
- **Dark**: Uses dark color scheme
- **System**: Follows device system theme

**User Flow**:
1. User taps on Theme card
2. Popup menu appears with three options
3. User selects a theme
4. `ThemeService.setTheme()` is called
5. Theme is saved to SharedPreferences
6. `themeStream` emits new theme
7. App theme updates immediately

### 3. Privacy & Terms

**Implementation**:
- Placeholder cards for Privacy Policy and Terms of Service
- Ready for future navigation implementation
- Uses consistent styling with `WidgetDecorations.getInfoCard()`

### 4. App Information

**Implementation**:
- Displays app version (currently hardcoded as "1.0.0")
- Placeholder for "Check for Updates" functionality
- Ready for future implementation with app version checking

---

## State Management

### LocalizationBloc

**Purpose**: Manages language selection and state.

**Key Events**:
- `GetCurrentLanguageEvent`: Loads saved language from SharedPreferences
- `ChangeLanguageEvent`: Updates language and saves to SharedPreferences

**State Updates**:
- When language changes, `LocalizationState.currentLanguage` updates
- `BlocBuilder` in `SettingsScreen` rebuilds only when language code changes (via `buildWhen`)

**Integration**:
```dart
BlocBuilder<LocalizationBloc, LocalizationState>(
  buildWhen: (previous, current) => 
      previous.currentLanguage.code != current.currentLanguage.code,
  builder: (context, state) {
    // Rebuilds only when language code changes
  },
)
```

### ThemeService

**Purpose**: Manages theme preference and persistence.

**Key Methods**:
- `init()`: Loads saved theme from SharedPreferences on app start
- `setTheme(ThemeMode)`: Updates theme and saves to SharedPreferences
- `toggleTheme()`: Toggles between light and dark themes
- `getThemeDisplayNameLocalized()`: Returns localized theme name
- `getThemeIcon()`: Returns icon for theme mode

**Stream Management**:
- Uses `StreamController<ThemeMode>.broadcast()` for multiple listeners
- Emits theme changes via `themeStream`

---

## Localization

The Settings screen is fully localized for three languages:

### Supported Languages
1. **Arabic (ar)**: العربية
2. **English (en)**: English
3. **French (fr)**: Français

### Localized Strings

All text in the settings screen uses `AppLocalizations`:

```dart
final localizations = AppLocalizations.of(context)!;

// Section titles
localizations.appSettings      // "App Settings"
localizations.privacy          // "Privacy"
localizations.appInformation   // "App Information"

// Language settings
localizations.language         // "Language" / "اللغة" / "Langue"
localizations.arabic           // "Arabic" / "العربية" / "Arabe"
localizations.english         // "English" / "الإنجليزية" / "Anglais"
localizations.french          // "French" / "الفرنسية" / "Français"

// Theme settings
localizations.theme           // "Theme" / "المظهر" / "Thème"
localizations.light           // "Light" / "فاتح" / "Clair"
localizations.dark            // "Dark" / "داكن" / "Sombre"
localizations.system          // "System" / "النظام" / "Système"

// Privacy
localizations.privacyPolicy    // "Privacy Policy"
localizations.termsOfService   // "Terms of Service"

// App info
localizations.version         // "Version"
localizations.checkForUpdates // "Check for Updates"
```

### Language Display

The current language is displayed using `nativeName` from the `Language` entity:
- Arabic: "العربية"
- English: "English"
- French: "Français"

This ensures the language name is always displayed in its native script, regardless of the current app language.

---

## Theme Management

### ThemeService Architecture

**Singleton Pattern**: Uses factory constructor for single instance

**Persistence**: 
- Stores theme preference in SharedPreferences with key `'theme_mode'`
- Loads theme on app initialization
- Saves theme immediately when changed

**Stream-based Updates**:
- Uses `StreamController<ThemeMode>.broadcast()` for real-time updates
- Multiple widgets can listen to theme changes simultaneously
- Updates are emitted immediately when theme changes

### Theme Integration with MaterialApp

The theme is applied at the app level in `main.dart`:

```dart
StreamBuilder<ThemeMode>(
  stream: sl<ThemeService>().themeStream,
  initialData: sl<ThemeService>().currentTheme,
  builder: (context, themeSnapshot) {
    return MaterialApp(
      theme: MaterialTheme.lightTheme(),
      darkTheme: MaterialTheme.darkTheme(),
      themeMode: themeSnapshot.data ?? ThemeMode.system,
      // ...
    );
  },
)
```

### Theme Card UI

The theme selection uses a `PopupMenuButton` with three options:
1. **Light Mode**: `Icons.light_mode` + localized "Light" text
2. **Dark Mode**: `Icons.dark_mode` + localized "Dark" text
3. **System Mode**: `Icons.brightness_auto` + localized "System" text

Each option shows a checkmark (✓) when selected.

---

## Performance Optimizations

The Settings screen implements several performance optimizations:

### 1. Cached Service Access
```dart
// ThemeService is cached once at the top level
final themeService = sl<ThemeService>();
```
**Benefit**: Avoids multiple service locator calls

### 2. Selective Rebuilds with `buildWhen`
```dart
BlocBuilder<LocalizationBloc, LocalizationState>(
  buildWhen: (previous, current) => 
      previous.currentLanguage.code != current.currentLanguage.code,
  // Only rebuilds when language code actually changes
)
```
**Benefit**: Prevents unnecessary rebuilds when other state properties change

### 3. Cached Values
```dart
// Localizations and fillColor are cached once per build
final localizations = AppLocalizations.of(context)!;
final fillColor = Theme.of(context).inputDecorationTheme.fillColor ?? 
                 Theme.of(context).colorScheme.secondaryContainer;
```
**Benefit**: Reduces repeated context lookups

### 4. Isolated Widget for Theme
```dart
class _ThemeCard extends StatelessWidget {
  // Extracted widget isolates theme rebuilds
}
```
**Benefit**: Theme changes only rebuild the `_ThemeCard` widget, not the entire settings screen

### 5. Removed Redundant BlocBuilder
```dart
// AppBar uses simple Builder instead of BlocBuilder
title: Builder(
  builder: (context) => Text(AppLocalizations.of(context)!.settings),
),
```
**Benefit**: AppBar title updates automatically when locale changes, without separate BlocBuilder overhead

### 6. StreamBuilder with Initial Data
```dart
StreamBuilder<ThemeMode>(
  stream: themeService.themeStream,
  initialData: themeService.currentTheme,
  // Provides immediate data without waiting for first stream emission
)
```
**Benefit**: Prevents blank/loading state on initial render

---

## Code Structure

### File Organization

```
delivery_operator/lib/features/settings/
└── presentation/
    └── screens/
        ├── settings_screen.dart    # Main settings screen
        └── about_screen.dart      # About screen (future)

dependencies/
├── core/
│   ├── services/
│   │   └── theme_service.dart     # Theme management service
│   └── theme/
│       └── widget_decorations.dart # Reusable UI components
└── features/
    └── localization/
        └── presentation/
            └── controller/
                └── localization_bloc.dart # Language management
```

### Key Classes

#### SettingsScreen
```dart
class SettingsScreen extends StatelessWidget {
  static const String route = '/settings';
  
  @override
  Widget build(BuildContext context) {
    // Main settings screen implementation
  }
}
```

#### _ThemeCard
```dart
class _ThemeCard extends StatelessWidget {
  final Color fillColor;
  final ThemeMode currentTheme;
  final ThemeService themeService;
  final AppLocalizations localizations;
  
  // Isolated theme selection widget
}
```

#### ThemeService
```dart
class ThemeService {
  // Singleton pattern
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  
  // Stream-based theme updates
  Stream<ThemeMode> get themeStream;
  
  // Theme management methods
  Future<void> setTheme(ThemeMode theme);
  String getThemeDisplayNameLocalized(...);
  IconData getThemeIcon(ThemeMode theme);
}
```

---

## Usage Guide

### Navigating to Settings

```dart
Navigator.of(context).pushNamed(SettingsScreen.route);
```

### Accessing Settings Programmatically

```dart
// Get current theme
final themeService = sl<ThemeService>();
final currentTheme = themeService.currentTheme;

// Listen to theme changes
themeService.themeStream.listen((theme) {
  print('Theme changed to: $theme');
});

// Change theme programmatically
await themeService.setTheme(ThemeMode.dark);
```

### Adding New Settings

To add a new setting:

1. **Add localized strings** to `.arb` files:
```json
{
  "newSetting": "New Setting",
  "@newSetting": {
    "description": "Label for new setting"
  }
}
```

2. **Add setting card** in `SettingsScreen`:
```dart
WidgetDecorations.getInfoCard(
  context: context,
  label: localizations.newSetting,
  value: 'Setting Value',
  icon: Icons.settings,
  labelColor: Colors.black,
  valueColor: Colors.black,
  onTap: () {
    // Handle setting action
  },
),
```

### Customizing Theme Card

The `_ThemeCard` widget can be customized by modifying:
- Theme options (add/remove theme modes)
- Icons for each theme
- Display format
- Menu style

---

## Future Enhancements

### Planned Features
1. **App Version Display**: 
   - Display actual app version from `package_info_plus`
   - Show build number and version code

2. **Update Checking**:
   - Implement app version checking
   - Navigate to app store for updates
   - Show update notifications

3. **Privacy & Terms Navigation**:
   - Implement navigation to privacy policy screen
   - Implement navigation to terms of service screen
   - Add web view for displaying documents

4. **Additional Settings**:
   - Notification preferences
   - Data usage settings
   - Cache management
   - Account deletion

5. **Settings Persistence**:
   - Save user preferences
   - Sync settings across devices (if multi-device support is added)

### Performance Improvements
1. **Lazy Loading**: Load settings sections on demand
2. **Caching**: Cache settings values to reduce SharedPreferences calls
3. **Animation**: Add smooth transitions for theme changes

### UX Improvements
1. **Search**: Add search functionality for settings
2. **Categories**: Better organization with collapsible sections
3. **Shortcuts**: Quick actions for common settings
4. **Feedback**: Visual feedback for setting changes

---

## Troubleshooting

### Common Issues

#### Language Not Updating
**Problem**: Language name doesn't update when language changes.

**Solution**: 
- Ensure `LocalizationBloc` is provided at the app level
- Check that `buildWhen` is correctly implemented
- Verify `MaterialApp` locale is updated

#### Theme Not Persisting
**Problem**: Theme resets to default on app restart.

**Solution**:
- Ensure `ThemeService.init()` is called in `main.dart`
- Check SharedPreferences permissions
- Verify theme key is correct

#### Performance Issues
**Problem**: Settings screen is slow or laggy.

**Solution**:
- Verify all performance optimizations are in place
- Check for unnecessary rebuilds using Flutter DevTools
- Ensure `buildWhen` is used correctly

---

## Related Documentation

- [Localization Feature Documentation](../localization/README.md)
- [Theme Service Documentation](../../core/services/THEME_SERVICE.md)
- [Widget Decorations Documentation](../../core/theme/widget_decorations.dart)
- [Clean Architecture Guide](../../ARCHITECTURE.md)

---

## Version History

- **v1.0.0** (Current)
  - Initial implementation
  - Language selection
  - Theme management
  - Privacy & Terms placeholders
  - App information display
  - Performance optimizations

---

## Contributors

- Initial implementation and architecture
- Performance optimizations
- Localization support

---

## License

This feature is part of the Delivery Operator app and follows the project's license.

