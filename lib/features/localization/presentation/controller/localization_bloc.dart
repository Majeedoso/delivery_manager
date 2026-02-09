import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/localization/domain/repository/base_localization_repository.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_event.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_state.dart';

class LocalizationBloc extends Bloc<LocalizationEvent, LocalizationState> {
  final BaseLocalizationRepository baseLocalizationRepository;

  LocalizationBloc(this.baseLocalizationRepository)
    : super(const LocalizationState()) {
    on<GetCurrentLanguageEvent>(_getCurrentLanguage);
    on<ChangeLanguageEvent>(_changeLanguage);
    on<GetSupportedLanguagesEvent>(_getSupportedLanguages);
    on<CheckFirstRunEvent>(_checkFirstRun);

    // Load current language on initialization
    add(GetCurrentLanguageEvent());
  }

  Future<void> _getCurrentLanguage(
    GetCurrentLanguageEvent event,
    Emitter<LocalizationState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    // First check if this is the first run
    final firstRunResult = await baseLocalizationRepository.isFirstRun();
    bool isFirstRun = false;

    firstRunResult.fold(
      (failure) => isFirstRun = false,
      (result) => isFirstRun = result,
    );

    final result = await baseLocalizationRepository.getCurrentLanguage();

    result.fold(
      (failure) => emit(
        state.copyWith(
          requestState: RequestState.error,
          message: failure.message,
          isFirstRun: isFirstRun,
          firstRunCheckCompleted: true,
        ),
      ),
      (language) => emit(
        state.copyWith(
          currentLanguage: language,
          requestState: RequestState.loaded,
          isFirstRun: isFirstRun,
          firstRunCheckCompleted: true,
        ),
      ),
    );
  }

  Future<void> _changeLanguage(
    ChangeLanguageEvent event,
    Emitter<LocalizationState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await baseLocalizationRepository.setLanguage(event.language);

    result.fold(
      (failure) => emit(
        state.copyWith(
          requestState: RequestState.error,
          message: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          currentLanguage: event.language,
          requestState: RequestState.loaded,
          isFirstRun:
              false, // After selecting a language, it's no longer first run
        ),
      ),
    );
  }

  Future<void> _getSupportedLanguages(
    GetSupportedLanguagesEvent event,
    Emitter<LocalizationState> emit,
  ) async {
    final result = await baseLocalizationRepository.getSupportedLanguages();

    result.fold(
      (failure) => emit(
        state.copyWith(
          requestState: RequestState.error,
          message: failure.message,
        ),
      ),
      (languages) => emit(
        state.copyWith(
          supportedLanguages: languages,
          requestState: RequestState.loaded,
        ),
      ),
    );
  }

  Future<void> _checkFirstRun(
    CheckFirstRunEvent event,
    Emitter<LocalizationState> emit,
  ) async {
    final result = await baseLocalizationRepository.isFirstRun();

    result.fold(
      (failure) => emit(
        state.copyWith(
          requestState: RequestState.error,
          message: failure.message,
          firstRunCheckCompleted: true,
        ),
      ),
      (isFirstRun) => emit(
        state.copyWith(
          isFirstRun: isFirstRun,
          firstRunCheckCompleted: true,
          requestState: RequestState.loaded,
        ),
      ),
    );
  }
}
