class StringUtils {
  StringUtils._();

  static String getInitials(String? name, {int maxLength = 2}) {
    if (name == null || name.isEmpty) return '';

    final words = name.trim().split(' ');
    final initials = words
        .where((word) => word.isNotEmpty)
        .take(maxLength)
        .map((word) => word[0].toUpperCase());
    return initials.join();
  }
}
