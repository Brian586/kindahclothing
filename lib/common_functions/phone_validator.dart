class PhoneValidator {
  static bool validatePhoneNumber(String phone) {
    if (phone.startsWith("+2547") || phone.startsWith("+2541")) {
      return true;
    } else {
      return false;
    }
  }

  static String correctPhoneNumber(String phone) {
    return phone.replaceFirst("+2540", "");
  }

  static String initialPhoneNumber(String phone) {
    return phone.replaceFirst("+254", "");
  }
}
