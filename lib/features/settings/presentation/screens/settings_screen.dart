import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_bloc.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_event.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_state.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/utils/version_helper.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_bloc.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_state.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_event.dart';
import 'package:delivery_manager/features/localization/domain/entities/language.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_bloc.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_event.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_state.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';
import 'package:delivery_manager/features/app_config/domain/usecases/get_legal_urls_usecase.dart';
import 'package:delivery_manager/features/app_config/domain/usecases/get_legal_urls_parameters.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  static const String route = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _privacyPolicyUrl;
  String? _termsOfServiceUrl;
  bool _isLoadingUrls = false;

  @override
  void initState() {
    super.initState();
    _loadLegalUrls();
  }

  Future<void> _loadLegalUrls() async {
    setState(() => _isLoadingUrls = true);
    try {
      final currentLanguage = context
          .read<LocalizationBloc>()
          .state
          .currentLanguage;
      final useCase = sl<GetLegalUrlsUseCase>();
      final result = await useCase(
        GetLegalUrlsParameters(languageCode: currentLanguage.code),
      );

      result.fold(
        (failure) {
          if (mounted) {
            final logger = sl<LoggingService>();
            logger.warning('Failed to load legal URLs: ${failure.message}');
          }
        },
        (legalUrls) {
          if (mounted) {
            setState(() {
              _privacyPolicyUrl = legalUrls.privacyPolicyUrl;
              _termsOfServiceUrl = legalUrls.termsOfServiceUrl;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        final logger = sl<LoggingService>();
        logger.warning('Error loading legal URLs: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingUrls = false);
      }
    }
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) {
      if (mounted) {
        ErrorSnackBar.show(
          context,
          AppLocalizations.of(context)!.urlNotAvailable,
        );
      }
      return;
    }

    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(
          context,
          AppLocalizations.of(context)!.errorOpeningUrl(e.toString()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocListener<LocalizationBloc, LocalizationState>(
        listenWhen: (previous, current) =>
            previous.currentLanguage.code != current.currentLanguage.code,
        listener: (context, state) => _loadLegalUrls(),
        child: BlocBuilder<LocalizationBloc, LocalizationState>(
          builder: (context, state) {
            final localizations = AppLocalizations.of(context)!;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsSectionHeader(title: localizations.appSettings),
                  _LanguageCard(
                    currentLanguage: state.currentLanguage,
                    supportedLanguages: state.supportedLanguages,
                    localizations: localizations,
                  ),
                  BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, themeState) {
                      return _ThemeCard(
                        currentTheme: themeState.currentTheme,
                        localizations: localizations,
                      );
                    },
                  ),
                  _SettingsSectionHeader(title: localizations.privacy),
                  _SettingsTile(
                    title: localizations.privacyPolicy,
                    icon: Icons.security_outlined,
                    onTap: _isLoadingUrls || _privacyPolicyUrl == null
                        ? null
                        : () => _openUrl(_privacyPolicyUrl),
                  ),
                  _SettingsTile(
                    title: localizations.termsOfService,
                    icon: Icons.description_outlined,
                    onTap: _isLoadingUrls || _termsOfServiceUrl == null
                        ? null
                        : () => _openUrl(_termsOfServiceUrl),
                  ),
                  _SettingsSectionHeader(title: localizations.appInformation),
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      final version = snapshot.hasData
                          ? snapshot.data!.version
                          : '1.0.0';
                      return _SettingsTile(
                        title: localizations.version,
                        subtitle: version,
                        icon: Icons.info_outline,
                      );
                    },
                  ),
                  _SettingsTile(
                    title: localizations.checkForUpdates,
                    icon: Icons.update_outlined,
                    onTap: () {
                      context.read<AppVersionBloc>().add(
                        const CheckAppVersionEvent(),
                      );
                      _showVersionCheckDialog(context);
                    },
                  ),
                  SizedBox(height: 4.h),
                  Center(
                    child: Text(
                      "© 2024. All rights reserved.",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.grey[500],
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showVersionCheckDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<AppVersionBloc>(),
          child: BlocBuilder<AppVersionBloc, AppVersionState>(
            builder: (context, state) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.w),
                ),
                title: Text(
                  localizations.checkForUpdates,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                content: _buildVersionDialogContent(
                  context,
                  state,
                  localizations,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      localizations.cancel,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                  ),
                  if (state.appVersion != null &&
                      state.userCurrentVersion != null)
                    Builder(
                      builder: (context) {
                        final updateStatus = _getUpdateStatus(
                          state,
                          localizations,
                        );
                        if (updateStatus['isRequired'] ||
                            updateStatus['isOptional']) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB824), Color(0xFFFF5000)],
                              ),
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () =>
                                  _openAppStore(context, state.appVersion!),
                              child: Text(
                                localizations.updateNow,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVersionDialogContent(
    BuildContext context,
    AppVersionState state,
    AppLocalizations localizations,
  ) {
    if (state.requestState == RequestState.loading) {
      return SizedBox(
        height: 100,
        child: Center(
          child: MaterialTheme.getCircularProgressIndicator(context),
        ),
      );
    }

    if (state.appVersion == null || state.userCurrentVersion == null) {
      return Text(
        state.message.isNotEmpty
            ? state.message
            : 'Unable to check for updates. Please try again later.',
        style: const TextStyle(color: Colors.red),
      );
    }

    final appVersion = state.appVersion!;
    final userVersion = state.userCurrentVersion!;
    final updateStatus = _getUpdateStatus(state, localizations);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildVersionRow(
          context,
          localizations.yourCurrentVersion,
          userVersion,
          Icons.phone_android,
        ),
        const Divider(),
        _buildVersionRow(
          context,
          localizations.latestAvailableVersion,
          appVersion.currentVersion,
          Icons.cloud_download,
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: updateStatus['isRequired']
                ? Colors.red.withOpacity(isDark ? 0.2 : 0.05)
                : updateStatus['isOptional']
                ? Colors.orange.withOpacity(isDark ? 0.2 : 0.05)
                : Colors.green.withOpacity(isDark ? 0.2 : 0.05),
            borderRadius: BorderRadius.circular(3.w),
          ),
          child: Row(
            children: [
              Icon(
                updateStatus['isRequired']
                    ? Icons.error_outline
                    : updateStatus['isOptional']
                    ? Icons.info_outline
                    : Icons.check_circle_outline,
                color: updateStatus['isRequired']
                    ? Colors.red
                    : updateStatus['isOptional']
                    ? Colors.orange
                    : Colors.green,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  updateStatus['message'],
                  style: TextStyle(
                    color: updateStatus['isRequired']
                        ? (isDark ? Colors.red[200] : Colors.red[900])
                        : updateStatus['isOptional']
                        ? (isDark ? Colors.orange[200] : Colors.orange[900])
                        : (isDark ? Colors.green[200] : Colors.green[900]),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVersionRow(
    BuildContext context,
    String label,
    String version,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey[600],
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  version,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getUpdateStatus(
    AppVersionState state,
    AppLocalizations localizations,
  ) {
    if (state.appVersion == null || state.userCurrentVersion == null) {
      return {
        'isRequired': false,
        'isOptional': false,
        'message': localizations.appUpToDate,
      };
    }
    final userVersion = state.userCurrentVersion!;
    final minimumVersion = state.appVersion!.minimumVersion;
    final latestVersion = state.appVersion!.currentVersion;
    final belowMinimum =
        VersionHelper.compareVersions(userVersion, minimumVersion) < 0;
    final belowLatest =
        VersionHelper.compareVersions(userVersion, latestVersion) < 0;
    if (belowMinimum) {
      return {
        'isRequired': true,
        'isOptional': false,
        'message': localizations.updateAvailable,
      };
    } else if (belowLatest) {
      return {
        'isRequired': false,
        'isOptional': true,
        'message': localizations.updateAvailableOptional,
      };
    } else {
      return {
        'isRequired': false,
        'isOptional': false,
        'message': localizations.appUpToDate,
      };
    }
  }

  Future<void> _openAppStore(
    BuildContext context,
    AppVersion appVersion,
  ) async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final updateUrl = isIOS
        ? appVersion.updateUrlIos
        : appVersion.updateUrlAndroid;
    String? urlToOpen = updateUrl;
    if (urlToOpen == null || urlToOpen.isEmpty) {
      final packageInfo = await PackageInfo.fromPlatform();
      final packageName = packageInfo.packageName;
      urlToOpen = isIOS
          ? null
          : 'https://play.google.com/store/apps/details?id=$packageName';
    }
    if (urlToOpen != null) {
      await launchUrl(
        Uri.parse(urlToOpen),
        mode: LaunchMode.externalApplication,
      );
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceBright : Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.1))
            : null,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
        leading: Container(
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFF892D).withOpacity(0.12),
            borderRadius: BorderRadius.circular(3.w),
          ),
          child: Icon(icon, color: const Color(0xFFFF892D), size: 20.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isDark ? Colors.white : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing:
            trailing ??
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: isDark ? Colors.white.withOpacity(0.4) : Colors.grey[400],
            ),
        onTap: onTap,
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  final String title;
  const _SettingsSectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.fromLTRB(1.w, 3.h, 1.w, 1.5.h),
      child: Row(
        children: [
          Container(
            width: 1.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: const Color(0xFFFF892D),
              borderRadius: BorderRadius.circular(1.w),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.grey[800],
                letterSpacing: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final Language currentLanguage;
  final List<Language> supportedLanguages;
  final AppLocalizations localizations;

  const _LanguageCard({
    required this.currentLanguage,
    required this.supportedLanguages,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceBright : Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.1))
            : null,
      ),
      child: DropdownButton2<String>(
        isExpanded: true,
        underline: const SizedBox.shrink(),
        buttonStyleData: const ButtonStyleData(
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
        ),
        customButton: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 0.3.h,
          ),
          leading: Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFF892D).withOpacity(0.12),
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Icon(
              Icons.language_outlined,
              color: const Color(0xFFFF892D),
              size: 20.sp,
            ),
          ),
          title: Text(
            localizations.language,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            '${currentLanguage.flag}  ${currentLanguage.nativeName}',
            style: TextStyle(
              fontSize: 16.sp,
              color: isDark ? Colors.white : Colors.grey[600],
            ),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_down,
            size: 22.sp,
            color: isDark ? Colors.white.withOpacity(0.4) : Colors.grey[400],
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          width: 90.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.w),
            color: isDark ? const Color(0xFF121212) : Colors.white,
          ),
          elevation: 8,
          offset: const Offset(0, -4),
        ),
        menuItemStyleData: MenuItemStyleData(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
        ),
        items: supportedLanguages.map((language) {
          return DropdownMenuItem<String>(
            value: language.code,
            child: Row(
              children: [
                Text(language.flag, style: TextStyle(fontSize: 18.sp)),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    language.nativeName,
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: language.code == currentLanguage.code
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (language.code == currentLanguage.code)
                  const Icon(Icons.check, color: Color(0xFFFF892D), size: 18),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? selectedCode) {
          if (selectedCode != null) {
            final selectedLanguage = supportedLanguages.firstWhere(
              (lang) => lang.code == selectedCode,
            );
            context.read<LocalizationBloc>().add(
              ChangeLanguageEvent(selectedLanguage),
            );
          }
        },
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final ThemeMode currentTheme;
  final AppLocalizations localizations;

  const _ThemeCard({required this.currentTheme, required this.localizations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final themeOptions = [
      {
        'value': 'light',
        'label': localizations.light,
        'icon': Icons.light_mode,
      },
      {'value': 'dark', 'label': localizations.dark, 'icon': Icons.dark_mode},
      {
        'value': 'system',
        'label': localizations.system,
        'icon': Icons.brightness_auto,
      },
    ];

    String themeLabel(ThemeMode mode) {
      if (mode == ThemeMode.light) return localizations.light;
      if (mode == ThemeMode.dark) return localizations.dark;
      return localizations.system;
    }

    IconData themeIcon(ThemeMode mode) {
      if (mode == ThemeMode.light) return Icons.light_mode_outlined;
      if (mode == ThemeMode.dark) return Icons.dark_mode_outlined;
      return Icons.brightness_auto_outlined;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceBright : Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.1))
            : null,
      ),
      child: DropdownButton2<String>(
        isExpanded: true,
        underline: const SizedBox.shrink(),
        buttonStyleData: const ButtonStyleData(
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
        ),
        customButton: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 0.3.h,
          ),
          leading: Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFF892D).withOpacity(0.12),
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Icon(
              themeIcon(currentTheme),
              color: const Color(0xFFFF892D),
              size: 20.sp,
            ),
          ),
          title: Text(
            localizations.theme,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            themeLabel(currentTheme),
            style: TextStyle(
              fontSize: 16.sp,
              color: isDark ? Colors.white : Colors.grey[600],
            ),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_down,
            size: 22.sp,
            color: isDark ? Colors.white.withOpacity(0.4) : Colors.grey[400],
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          width: 90.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.w),
            color: isDark ? const Color(0xFF121212) : Colors.white,
          ),
          elevation: 8,
          offset: const Offset(0, -4),
        ),
        menuItemStyleData: MenuItemStyleData(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
        ),
        items: themeOptions.map((option) {
          return DropdownMenuItem<String>(
            value: option['value'] as String,
            child: Row(
              children: [
                Icon(
                  option['icon'] as IconData,
                  color: const Color(0xFFFF892D),
                  size: 18.sp,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    option['label'] as String,
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight:
                          (option['value'] as String) == currentTheme.name
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if ((option['value'] as String) == currentTheme.name)
                  const Icon(Icons.check, color: Color(0xFFFF892D), size: 18),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? selectedValue) {
          if (selectedValue != null) {
            ThemeMode mode = ThemeMode.system;
            if (selectedValue == 'light') mode = ThemeMode.light;
            if (selectedValue == 'dark') mode = ThemeMode.dark;
            context.read<ThemeBloc>().add(ChangeThemeEvent(mode));
          }
        },
      ),
    );
  }
}
