// utils/logger.dart
import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error, critical }

class Logger {
  static final Logger _instance = Logger._internal();
  
  factory Logger() {
    return _instance;
  }
  
  Logger._internal();
  
  static bool enableConsoleLogging = true;
  
  void log(String message, {LogLevel level = LogLevel.info, String? tag}) {
    final String logTag = tag ?? 'SmsAiAssistant';
    final String formattedMessage = '${_getLevelPrefix(level)} $message';
    
    if (enableConsoleLogging) {
      developer.log(
        formattedMessage,
        name: logTag,
        level: _getLogPriority(level),
      );
    }
    
    // Here you could add file logging, crash reporting, etc.
  }

  String _getLevelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '[DEBUG]';
      case LogLevel.info:
        return '[INFO]';
      case LogLevel.warning:
        return '[WARN]';
      case LogLevel.error:
        return '[ERROR]';
      case LogLevel.critical:
        return '[CRITICAL]';
    }
  }
  
  int _getLogPriority(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1200;
    }
  }
}

// Extension methods for easy logging
extension LoggerExtension on Object {
  void logDebug(String message, {String? tag}) {
    Logger().log(message, level: LogLevel.debug, tag: tag);
  }
  
  void logInfo(String message, {String? tag}) {
    Logger().log(message, level: LogLevel.info, tag: tag);
  }
  
  void logWarning(String message, {String? tag}) {
    Logger().log(message, level: LogLevel.warning, tag: tag);
  }
  
  void logError(String message, {String? tag}) {
    Logger().log(message, level: LogLevel.error, tag: tag);
  }
  
  void logCritical(String message, {String? tag}) {
    Logger().log(message, level: LogLevel.critical, tag: tag);
  }
}