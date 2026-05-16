import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _token != null;
  String get role => _user?.role ?? '';

  Future<bool> tryRestoreSession() async {
    final session = await AuthService.getStoredSession();
    if (session == null) return false;
    _token = session['token'];
    _user = User(
      id: session['user_id'],
      name: session['user_name'],
      email: session['user_email'],
      role: session['role'],
    );
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final json = await AuthService.login(email, password);
      _token = json['token'];
      _user = User.fromJson(json['user']);
      await AuthService.saveSession(_token!, _user!);
      return true;
    } catch (e) {
      _error = _parseError(e);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final json = await AuthService.register(name, email, password);
      _token = json['token'];
      _user = User.fromJson(json['user']);
      await AuthService.saveSession(_token!, _user!);
      return true;
    } catch (e) {
      _error = _parseError(e);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> setRole(String role) async {
    _loading = true;
    notifyListeners();
    try {
      // Role armazenado localmente — backend não tem esse campo
      await AuthService.saveRole(role);
      _user = User(
        id: _user!.id,
        name: _user!.name,
        email: _user!.email,
        role: role,
      );
      return true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _token = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    final s = e.toString();
    if (s.contains('No active account')) return 'E-mail ou senha incorretos';
    if (s.contains('already exists')) return 'E-mail já cadastrado';
    if (s.contains('Connection refused') || s.contains('SocketException')) {
      return 'Servidor indisponível';
    }
    return s.replaceFirst('ApiException', '').replaceAll(RegExp(r'^\(?\d+\)?:?\s*'), '').trim();
  }
}
