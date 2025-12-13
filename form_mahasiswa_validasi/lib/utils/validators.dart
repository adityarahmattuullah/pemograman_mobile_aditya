class Validators {
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'Wajib diisi';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || !value.contains('@')) {
      return 'Email tidak valid';
    }
    return null;
  }
}
