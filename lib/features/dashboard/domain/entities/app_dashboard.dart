import 'package:equatable/equatable.dart';

class AppDashboard extends Equatable {
  final int id;
  final String key;
  final String value;
  final dynamic typedValue;
  final String description;
  final String type;
  final String category;
  final bool isPublic;

  const AppDashboard({
    required this.id,
    required this.key,
    required this.value,
    this.typedValue,
    required this.description,
    required this.type,
    required this.category,
    required this.isPublic,
  });

  AppDashboard copyWith({
    int? id,
    String? key,
    String? value,
    dynamic typedValue,
    String? description,
    String? type,
    String? category,
    bool? isPublic,
  }) {
    return AppDashboard(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      typedValue: typedValue ?? this.typedValue,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  @override
  List<Object?> get props => [id, key, value, typedValue, description, type, category, isPublic];
}
