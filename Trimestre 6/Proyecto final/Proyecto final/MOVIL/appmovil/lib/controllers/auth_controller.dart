// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String correo, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.login(correo, password);
      _user = user;

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', user.token);
      await prefs.setString('nombre', user.nombre);

      // Rol por nombre (de la BD) o por ID como fallback
      String rolName;
      if (user.rolNombre.isNotEmpty) {
        rolName = user.rolNombre;
      } else {
        switch (user.rolId) {
          case 1:
            rolName = 'Administrador';
            break;
          case 2:
            rolName = 'Empleado';
            break;
          case 3:
            rolName = 'Superadmin';
            break;
          default:
            rolName = 'Sin rol';
        }
      }

      await prefs.setString('rol', rolName);

      _isLoading = false;
      notifyListeners();
      return true; // ✅ login OK
    } on AuthException catch (e) {
      _isLoading = false;
      _error = e.message; // mensaje amigable del backend
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Ocurrió un error inesperado. Inténtalo de nuevo.';
      notifyListeners();
      return false;
    }
  }
}
