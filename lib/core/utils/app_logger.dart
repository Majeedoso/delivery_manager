import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void debug(String message) {
    _logger.d(message);
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void success(String message) {
    _logger.i('✅ $message');
  }

  static void failure(String message) {
    _logger.e('❌ $message');
  }

  static void navigation(String message) {
    _logger.i('🧭 $message');
  }

  static void auth(String message) {
    _logger.i('🔐 $message');
  }

  static void api(String message) {
    _logger.i('🌐 $message');
  }

  static void user(String message) {
    _logger.i('👤 $message');
  }
}
