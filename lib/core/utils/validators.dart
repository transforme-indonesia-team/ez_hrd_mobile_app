class Validators {
  static String? username(String? value, {int? maxLength}) {
    if (value == null || value.isEmpty) {
      return 'Nama Pengguna tidak boleh kosong';
    }

    if (maxLength != null && value.length > maxLength) {
      return 'Nama Pengguna tidak boleh lebih dari $maxLength karakter';
    }

    return null;
  }

  static String? password(String? value, {int minLength = 8, int? maxLength}) {
    if (value == null || value.isEmpty) {
      return 'Kata Sandi tidak boleh kosong';
    }

    if (maxLength != null && value.length > maxLength) {
      return 'Kata Sandi tidak boleh lebih dari $maxLength karakter';
    }

    if (value.length < minLength) {
      return 'Kata Sandi minimal $minLength karakter';
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
