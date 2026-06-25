class AppValidators {
  static String? Function(String?) required(String message) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال السعر';
    }
    if (double.tryParse(value) == null) {
      return 'يرجى إدخال رقم صحيح';
    }
    if (double.parse(value) < 0) {
      return 'السعر لا يمكن أن يكون سالباً';
    }
    return null;
  }
}
