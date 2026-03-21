import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized logger instance for the application.
///
/// Usage:
/// ```dart
/// logger.d('Debug message');
/// logger.i('Info message');
/// logger.w('Warning message');
/// logger.e('Error message', error: e, stackTrace: s);
/// ```
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // Number of method calls to be displayed
    errorMethodCount: 8, // Number of method calls if stacktrace is provided
    lineLength: 120, // Width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print an emoji for each log message
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Should each log print contain a timestamp
  ),
  filter: kReleaseMode ? _ReleaseFilter() : null, // Custom filter for release builds
);

/// A custom filter that suppresses all logs in release mode.
class _ReleaseFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // In release mode, we generally don't want to log anything.
    // However, you could allow Error level logs if you send them to a crash reporting service.
    return false;
  }
}
