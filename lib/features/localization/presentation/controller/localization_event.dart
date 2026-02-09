import 'package:equatable/equatable.dart';
import 'package:delivery_manager/features/localization/domain/entities/language.dart';

abstract class LocalizationEvent extends Equatable {
  const LocalizationEvent();

  @override
  List<Object?> get props => [];
}

class GetCurrentLanguageEvent extends LocalizationEvent {}

class ChangeLanguageEvent extends LocalizationEvent {
  final Language language;

  const ChangeLanguageEvent(this.language);

  @override
  List<Object?> get props => [language];
}

class GetSupportedLanguagesEvent extends LocalizationEvent {}

/// Event to check if this is the first time the app is run
class CheckFirstRunEvent extends LocalizationEvent {}
