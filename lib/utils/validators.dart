class Validators {
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final phoneRegex = RegExp(r'^[\d\s\+\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    if (double.tryParse(value) == null) {
      return 'Valeur numérique invalide';
    }
    return null;
  }

  static String? positiveNumber(String? value, {String? fieldName}) {
    final result = number(value, fieldName: fieldName);
    if (result != null) return result;
    if (double.parse(value!) < 0) {
      return '${fieldName ?? 'La valeur'} doit être positive';
    }
    return null;
  }
}
