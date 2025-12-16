import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  bool isAuthenticated = false;
  String userRole = '';

  Future<void> checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      // Aquí podrías validar token con backend si quieres
      isAuthenticated = true;
      userRole = 'admin'; // ejemplo
    } else {
      isAuthenticated = false;
      userRole = '';
    }

    notifyListeners();
  }

  Future<void> login(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    isAuthenticated = true;
    userRole = role;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    isAuthenticated = false;
    userRole = '';
    notifyListeners();
  }
}
