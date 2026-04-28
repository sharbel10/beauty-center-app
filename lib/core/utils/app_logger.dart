import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger();

  static void d(dynamic message) {
    if (kDebugMode) {
      _logger.d(message);
    }
  }

  static void i(dynamic message) {
    if (kDebugMode) {
      _logger.i(message);
    }
  }

  static void w(dynamic message) {
    if (kDebugMode) {
      _logger.w(message);
    }
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }
}
