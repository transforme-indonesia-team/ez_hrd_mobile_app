class Validators {
  static String? email(String? value, {int? maxLength}) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }

    if (maxLength != null && value.length > maxLength) {
      return 'Email tidak boleh lebih dari $maxLength karakter';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email tidak valid';
    }

    return null;
  }

  static String? password(String? value, {int minLength = 2, int? maxLength}) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (maxLength != null && value.length > maxLength) {
      return 'Password tidak boleh lebih dari $maxLength karakter';
    }

    if (value.length < minLength) {
      return 'Password minimal $minLength karakter';
    }

    return null;
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Field'} tidak boleh kosong';
    }
    return null;
  }
}
