import 'package:equatable/equatable.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/localization/domain/entities/language.dart';

class LocalizationState extends Equatable {
  final Language currentLanguage;
  final List<Language> supportedLanguages;
  final RequestState requestState;
  final String message;

  /// True if this is the first time the app is run (no language has been selected yet)
  final bool isFirstRun;

  /// True if the first run check has completed
  final bool firstRunCheckCompleted;

  const LocalizationState({
    this.currentLanguage = const Language(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    this.supportedLanguages = Language.supportedLanguages,
    this.requestState = RequestState.loading,
    this.message = '',
    this.isFirstRun = false,
    this.firstRunCheckCompleted = false,
  });

  LocalizationState copyWith({
    Language? currentLanguage,
    List<Language>? supportedLanguages,
    RequestState? requestState,
    String? message,
    bool? isFirstRun,
    bool? firstRunCheckCompleted,
  }) {
    return LocalizationState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
      isFirstRun: isFirstRun ?? this.isFirstRun,
      firstRunCheckCompleted:
          firstRunCheckCompleted ?? this.firstRunCheckCompleted,
    );
  }

  @override
  List<Object?> get props => [
    currentLanguage,
    supportedLanguages,
    requestState,
    message,
    isFirstRun,
    firstRunCheckCompleted,
  ];
}
