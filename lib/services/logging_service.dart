import 'package:logger/logger.dart';

class LoggingService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void logInfo(String message) {
    logger.i(message);
  }

  static void logWarning(String message) {
    logger.w(message);
  }

  static void logError(String message, [error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }
}
