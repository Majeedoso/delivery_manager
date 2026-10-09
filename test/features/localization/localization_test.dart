import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/localization/data/datasource/localization_local_data_source.dart';
import 'package:delivery_manager/features/localization/data/repository/localization_repository.dart';
import 'package:delivery_manager/features/localization/domain/entities/language.dart';
import 'package:delivery_manager/features/localization/domain/repository/base_localization_repository.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_bloc.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_event.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSource extends Mock implements BaseLocalizationLocalDataSource {}

/// The app's language: Arabic, French or English, first guessed from the
/// phone (Arabic when the phone speaks something else), then the manager's
/// choice, kept on the phone. Nothing chosen yet means a first run.
void main() {
  final arabic = Language.supportedLanguages[0];
  final english = Language.supportedLanguages[1];
  final french = Language.supportedLanguages[2];

  Future<LocalizationLocalDataSource> source({
    Map<String, Object> saved = const {},
    String phone = 'en',
  }) async {
    SharedPreferences.setMockInitialValues(saved);
    return LocalizationLocalDataSource(
      sharedPreferences: await SharedPreferences.getInstance(),
      deviceLanguageCode: () => phone,
    );
  }

  group('the language on the phone', () {
    test('nothing chosen: the phone\'s language, not saved', () async {
      final local = await source(phone: 'FR');

      expect(await local.getCurrentLanguage(), french);
      expect(await local.isFirstRun(), isTrue, reason: 'still to choose');
    });

    test('a phone in another language gets Arabic', () async {
      final local = await source(phone: 'de');

      expect(await local.getCurrentLanguage(), arabic);
    });

    test('a choice is kept and ends the first run', () async {
      final local = await source(phone: 'ar');

      await local.setLanguage(english);

      expect(await local.getCurrentLanguage(), english);
      expect(await local.isFirstRun(), isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('selected_language'),
        'en',
        reason: 'the API sends it as Accept-Language',
      );
    });

    test('an unknown saved code falls back to the first language', () async {
      final local = await source(saved: {'selected_language': 'kab'});

      expect(await local.getCurrentLanguage(), arabic);
    });

    test('the three languages are offered', () async {
      final local = await source();

      expect((await local.getSupportedLanguages()).map((l) => l.code), [
        'ar',
        'en',
        'fr',
      ]);
    });
  });

  group('the repository', () {
    late _MockSource local;
    late LocalizationRepository repository;

    setUp(() {
      local = _MockSource();
      repository = LocalizationRepository(
        baseLocalizationLocalDataSource: local,
      );
    });

    test('hands the answers over', () async {
      when(() => local.getCurrentLanguage()).thenAnswer((_) async => french);
      when(() => local.isFirstRun()).thenAnswer((_) async => false);
      when(() => local.setLanguage(french)).thenAnswer((_) async {});

      expect(
        await repository.getCurrentLanguage(),
        Right<Failure, Language>(french),
      );
      expect(await repository.isFirstRun(), const Right<Failure, bool>(false));
      expect((await repository.setLanguage(french)).isRight(), isTrue);
    });

    test('storage trouble is a cache failure', () async {
      registerFallbackValue(english);
      when(() => local.getCurrentLanguage()).thenThrow(const CacheException());
      when(() => local.isFirstRun()).thenThrow(const CacheException());
      when(() => local.setLanguage(any())).thenThrow(const CacheException());
      when(
        () => local.getSupportedLanguages(),
      ).thenThrow(const CacheException());

      expect((await repository.getCurrentLanguage()).isLeft(), isTrue);
      expect((await repository.isFirstRun()).isLeft(), isTrue);
      expect((await repository.setLanguage(english)).isLeft(), isTrue);
      expect((await repository.getSupportedLanguages()).isLeft(), isTrue);
    });
  });

  group('the bloc', () {
    Future<LocalizationBloc> build({
      Map<String, Object> saved = const {},
      String phone = 'fr',
    }) async => LocalizationBloc(
      LocalizationRepository(
        baseLocalizationLocalDataSource: await source(
          saved: saved,
          phone: phone,
        ),
      ),
    );

    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 10));

    test('does nothing until asked', () async {
      final bloc = await build();
      final states = <LocalizationState>[];
      bloc.stream.listen(states.add);

      await settle();

      expect(states, isEmpty, reason: 'it used to load the language twice');
      await bloc.close();
    });

    test('a first run shows the phone\'s language, still to choose', () async {
      final bloc = await build(phone: 'fr');

      bloc.add(GetCurrentLanguageEvent());
      await settle();

      expect(bloc.state.currentLanguage, french);
      expect(bloc.state.isFirstRun, isTrue);
      expect(bloc.state.firstRunCheckCompleted, isTrue);
      expect(bloc.state.requestState, RequestState.loaded);
      await bloc.close();
    });

    test('later runs use the choice', () async {
      final bloc = await build(saved: {'selected_language': 'ar'}, phone: 'fr');

      bloc.add(GetCurrentLanguageEvent());
      await settle();

      expect(bloc.state.currentLanguage, arabic);
      expect(bloc.state.isFirstRun, isFalse);
      await bloc.close();
    });

    test('choosing a language switches and ends the first run', () async {
      final bloc = await build();
      bloc.add(GetCurrentLanguageEvent());
      await settle();

      bloc.add(ChangeLanguageEvent(arabic));
      await settle();

      expect(bloc.state.currentLanguage, arabic);
      expect(bloc.state.isFirstRun, isFalse);
      await bloc.close();
    });

    test('a first-run check can be asked on its own', () async {
      final bloc = await build(saved: {'selected_language': 'en'});

      bloc.add(CheckFirstRunEvent());
      await settle();

      expect(bloc.state.isFirstRun, isFalse);
      expect(bloc.state.firstRunCheckCompleted, isTrue);
      await bloc.close();
    });

    test(
      'a storage failure is shown, the first run check still ends',
      () async {
        final repository = _FailingRepository();
        final bloc = LocalizationBloc(repository);

        bloc.add(GetCurrentLanguageEvent());
        await settle();

        expect(bloc.state.requestState, RequestState.error);
        expect(bloc.state.firstRunCheckCompleted, isTrue);
        await bloc.close();
      },
    );
  });
}

class _FailingRepository implements BaseLocalizationRepository {
  @override
  Future<Either<Failure, Language>> getCurrentLanguage() async =>
      const Left(CacheFailure());

  @override
  Future<Either<Failure, List<Language>>> getSupportedLanguages() async =>
      const Left(CacheFailure());

  @override
  Future<Either<Failure, bool>> isFirstRun() async =>
      const Left(CacheFailure());

  @override
  Future<Either<Failure, void>> setLanguage(Language language) async =>
      const Left(CacheFailure());
}
