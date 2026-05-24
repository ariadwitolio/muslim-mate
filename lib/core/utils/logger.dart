enum LogLevel { debug, info, warning, error }

class Logger {
  static const bool _enableLogging = true;
  static LogLevel _minimumLogLevel = LogLevel.debug;

  static void setMinimumLogLevel(LogLevel level) {
    _minimumLogLevel = level;
  }

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (!_enableLogging || level.index < _minimumLogLevel.index) {
      return;
    }

    final String timestamp = DateTime.now().toIso8601String();
    final String levelName = level.toString().split('.').last.toUpperCase();
    final String logMessage = '[$timestamp] [$levelName] $message';

    // ignore: avoid_print
    print(logMessage);

    if (error != null) {
      // ignore: avoid_print
      print('Error: $error');
    }

    if (stackTrace != null) {
      // ignore: avoid_print
      print('StackTrace: $stackTrace');
    }
  }
}
