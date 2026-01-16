import 'package:hrd_app/core/config/env_config.dart';

extension ImageUrlExtension on String? {
  String? get asFullImageUrl {
    if (this == null || this!.isEmpty || this == '-') return null;
    return '${EnvConfig.imageBaseUrl}$this';
  }
}
