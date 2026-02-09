import 'package:equatable/equatable.dart';

/// Parameters for GetLegalUrlsUseCase
/// 
/// Contains the language code to fetch URLs in the specified language.
class GetLegalUrlsParameters extends Equatable {
  final String? languageCode;

  const GetLegalUrlsParameters({this.languageCode});

  @override
  List<Object?> get props => [languageCode];
}

