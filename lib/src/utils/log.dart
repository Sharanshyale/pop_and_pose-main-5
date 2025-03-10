import 'package:logger/logger.dart';

class Log {
  static final Log _instance = Log._internal();

  late Logger _logger;

  // Singleton pattern
  factory Log({required PrettyPrinter printer, required Level level}) {
    return _instance;
  }
  Log._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // Number of method calls to be displayed
        errorMethodCount: 8, // Number of method calls if stacktrace is provided
        lineLength: 120, // Width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
      ),
      // Customize log levels
      level: Level.debug,
    );
  }

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _instance._logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _instance._logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _instance._logger.e(message, error: error, stackTrace: stackTrace);
  }
}
