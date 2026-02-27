import 'package:delivery_manager/features/dashboard/domain/entities/app_dashboard.dart';

class AppDashboardModel extends AppDashboard {
  const AppDashboardModel({
    required super.id,
    required super.key,
    required super.value,
    super.typedValue,
    required super.description,
    required super.type,
    required super.category,
    required super.isPublic,
  });

  factory AppDashboardModel.fromJson(Map<String, dynamic> json) {
    return AppDashboardModel(
      id: json['id'] as int,
      key: json['key'] as String? ?? '',
      value: json['value']?.toString() ?? '',
      typedValue: json['typed_value'],
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'string',
      category: json['category'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? false,
    );
  }
}
