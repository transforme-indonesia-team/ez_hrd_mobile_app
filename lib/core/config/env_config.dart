import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get staticToken => dotenv.env['STATIC_TOKEN'] ?? '';
  static String get encryptionKey => dotenv.env['CUSTOM_REQUEST_KEY'] ?? '';
  static String get encryptionIv => dotenv.env['CUSTOM_REQUEST_IV'] ?? '';

  static bool get isLoaded => dotenv.env.isNotEmpty;
}
