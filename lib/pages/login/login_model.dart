import 'package:flutter/material.dart';

class LoginModel extends ChangeNotifier {
  bool isLoading = false;
  bool obscurePassword = true;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
