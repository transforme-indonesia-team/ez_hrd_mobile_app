import 'package:hrd_app/core/config/env_config.dart';

extension ImageUrlExtension on String? {
  String? get asFullImageUrl {
    if (this == null || this!.isEmpty || this == '-') return null;
    final path = this!.trim();
    final base = EnvConfig.imageBaseUrl;
    // Pastikan ada slash antara base URL dan path
    if (path.startsWith('/')) {
      return '$base$path';
    }
    return '$base/$path';
  }
}
