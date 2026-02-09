import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/features/localization/domain/entities/language.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_bloc.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_event.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_state.dart';

/// First-run language selection screen
///
/// This screen is shown when the app is launched for the first time
/// and no language has been saved yet. The prompt is displayed in the
/// device's system language initially, then updates to the selected language.
class FirstRunLanguageScreen extends StatelessWidget {
  const FirstRunLanguageScreen({super.key});

  static const String route = '/first_run_language';

  /// Get localized strings based on a language code
  /// These are hardcoded because we can't use AppLocalizations before
  /// the user selects their language preference
  Map<String, String> _getStringsForLanguage(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return {
          'title': 'اختر لغتك',
          'subtitle': 'اختر اللغة التي تفضلها لاستخدام التطبيق',
          'confirm': 'تأكيد',
        };
      case 'fr':
        return {
          'title': 'Choisissez votre langue',
          'subtitle': 'Sélectionnez la langue que vous préférez utiliser',
          'confirm': 'Confirmer',
        };
      default: // English and others
        return {
          'title': 'Choose your language',
          'subtitle': 'Select the language you prefer to use',
          'confirm': 'Confirm',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Background color matching other screens
    const lightBackgroundColor = Color(0xFFFEF8F1);

    return Scaffold(
      backgroundColor: isDark ? null : lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? null : lightBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: Icon(
              Icons.settings,
              size: 24.sp,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isDark
            ? MaterialTheme.getGradientBackground(context)
            : null,
        child: SafeArea(
          top: false, // AppBar already handles top safe area
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: BlocBuilder<LocalizationBloc, LocalizationState>(
              builder: (context, state) {
                // Get strings based on currently selected language
                final strings = _getStringsForLanguage(
                  state.currentLanguage.code,
                );

                return Column(
                  children: [
                    SizedBox(height: 2.h),
                    // App logo
                    SizedBox(
                      width: 35.w,
                      height: 35.w,
                      child: Image.asset(
                        isDark
                            ? 'assets/images/splash_screen_dark_mode.png'
                            : 'assets/images/splash_screen_light_mode.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Title - updates based on selected language
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        strings['title']!,
                        key: ValueKey('title_${state.currentLanguage.code}'),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Subtitle - updates based on selected language
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        strings['subtitle']!,
                        key: ValueKey('subtitle_${state.currentLanguage.code}'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Language options
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.supportedLanguages.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 1.5.h),
                        itemBuilder: (context, index) {
                          final language = state.supportedLanguages[index];
                          final isSelected =
                              state.currentLanguage.code == language.code;

                          return _LanguageCard(
                            language: language,
                            isSelected: isSelected,
                            onTap: () {
                              context.read<LocalizationBloc>().add(
                                ChangeLanguageEvent(language),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // Confirm button - text updates based on selected language
                    SizedBox(
                      width: double.infinity,
                      height: 7.h,
                      child: ElevatedButton(
                        onPressed: () {
                          // Ensure the current language is saved even if the user didn't tap a card
                          // (e.g. they accepted the default selection)
                          context.read<LocalizationBloc>().add(
                            ChangeLanguageEvent(state.currentLanguage),
                          );
                          Navigator.of(context).pushReplacementNamed('/splash');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.orange[700]
                              : Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.w),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          strings['confirm']!,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual language card widget with selection animation
class _LanguageCard extends StatelessWidget {
  final Language language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? Colors.orange[700] : Colors.orange)
            : (isDark ? Colors.grey[800] : Colors.white),
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: isSelected
              ? (isDark ? Colors.orange[400]! : Colors.orange[300]!)
              : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.orange.withAlpha(50),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4.w),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
            child: Row(
              children: [
                // Flag emoji
                Text(language.flag, style: TextStyle(fontSize: 22.sp)),
                SizedBox(width: 4.w),
                // Language names
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.nativeName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        language.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Colors.white70
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
                // Check icon for selected language
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelected ? 1.0 : 0.0,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
