import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class LinkService {
  static Future<Map<String, dynamic>> generateCode() async {
    return ApiService.post('/auth/link/generate/', {});
  }

  static Future<Map<String, dynamic>> pairWithCode(String code) async {
    return ApiService.post('/auth/link/pair/', {'code': code});
  }

  static Future<Map<String, dynamic>> status() async {
    return ApiService.get('/auth/link/status/');
  }

  static Future<void> saveDeviceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_token', token);
  }

  static Future<String?> getDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('device_token');
  }
}
