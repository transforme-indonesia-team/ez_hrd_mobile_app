import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get imageBaseUrl => dotenv.env['IMAGE_BASE_URL'] ?? '';
  static String get staticToken => dotenv.env['STATIC_TOKEN'] ?? '';
  static String get encryptionKey => dotenv.env['CUSTOM_REQUEST_KEY'] ?? '';
  static String get encryptionIv => dotenv.env['CUSTOM_REQUEST_IV'] ?? '';

  static bool get isLoaded => dotenv.env.isNotEmpty;

  /// Validates that all critical environment variables are set.
  /// Throws [Exception] if any critical variable is missing.
  static void validateCritical() {
    final errors = <String>[];

    if (baseUrl.isEmpty) {
      errors.add('BASE_URL is not set');
    }
    if (encryptionKey.isEmpty) {
      errors.add('CUSTOM_REQUEST_KEY is not set');
    }
    if (encryptionIv.isEmpty) {
      errors.add('CUSTOM_REQUEST_IV is not set');
    }

    if (errors.isNotEmpty) {
      throw Exception('EnvConfig validation failed: ${errors.join(', ')}');
    }
  }

  /// Checks if critical variables are valid without throwing.
  static bool get isCriticalValid {
    return baseUrl.isNotEmpty &&
        encryptionKey.isNotEmpty &&
        encryptionIv.isNotEmpty;
  }
}
