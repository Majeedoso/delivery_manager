import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_bloc.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_event.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_state.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  static const String route = '/language_selection';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.selectLanguage),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: BlocBuilder<LocalizationBloc, LocalizationState>(
        builder: (context, state) {
          return ListView.builder(
            // Optimize cache extent for better performance
            cacheExtent: 200, // Smaller cache for simple list items
            itemCount: state.supportedLanguages.length,
            itemBuilder: (context, index) {
              final language = state.supportedLanguages[index];
              final isSelected = state.currentLanguage.code == language.code;

              // Wrap in RepaintBoundary for better performance
              // Add key for better widget recycling
              return RepaintBoundary(
                key: ValueKey('language_${language.code}'),
                child: ListTile(
                  leading: Text(
                    language.flag,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  title: Text(
                    language.nativeName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(language.name),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.deepPurple)
                      : null,
                  onTap: () {
                    context.read<LocalizationBloc>().add(ChangeLanguageEvent(language));
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }
}

