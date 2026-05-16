import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    // Backend espera first_name, não name
    final result = await ApiService.post('/auth/register/', {
      'email': email,
      'password': password,
      'first_name': name,
    }, auth: false);

    // Backend retorna { access, refresh } — salva token e busca user
    final token = result['access'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);

    // Busca dados do user
    final userJson = await ApiService.get('/auth/me/');
    return {
      'token': token,
      'refresh': result['refresh'],
      'user': userJson,
    };
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    // simplejwt com USERNAME_FIELD=email aceita { email, password }
    final result = await ApiService.post('/auth/login/', {
      'email': email,
      'password': password,
    }, auth: false);

    final token = result['access'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);

    // Busca dados do user
    final userJson = await ApiService.get('/auth/me/');
    return {
      'token': token,
      'refresh': result['refresh'],
      'user': userJson,
    };
  }

  static Future<User> me() async {
    final json = await ApiService.get('/auth/me/');
    return User.fromJson(json);
  }

  static Future<void> saveSession(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('user_role', user.role);
    await prefs.setInt('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  static Future<void> saveDeviceToken(String deviceToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_token', deviceToken);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, dynamic>?> getStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return null;
    return {
      'token': token,
      'role': prefs.getString('user_role') ?? '',
      'user_id': prefs.getInt('user_id') ?? 0,
      'user_name': prefs.getString('user_name') ?? '',
      'user_email': prefs.getString('user_email') ?? '',
      'device_token': prefs.getString('device_token'),
    };
  }
}
