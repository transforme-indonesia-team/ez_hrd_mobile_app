import 'package:hrd_app/core/config/env_config.dart';

/// Extension untuk konversi relative image path ke full URL
extension ImageUrlExtension on String? {
  /// Converts a relative image path to full URL using EnvConfig.imageBaseUrl
  /// Returns null if the original string is null, empty, or '-'
  String? get asFullImageUrl {
    if (this == null || this!.isEmpty || this == '-') return null;
    return '${EnvConfig.imageBaseUrl}$this';
  }
}
