class ErrorMessageModel {
  final String message;
  final int statusCode;

  const ErrorMessageModel({
    required this.message,
    required this.statusCode,
  });

  factory ErrorMessageModel.fromJson(Map<String, dynamic> json) {
    return ErrorMessageModel(
      message: json['message'] ?? 'Unknown error',
      statusCode: json['status_code'] ?? 500,
    );
  }
}
