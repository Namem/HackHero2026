import 'package:shared_preferences/shared_preferences.dart';
import '../models/trigger.dart';
import 'api_service.dart';

class TriggerService {
  static Future<String> _getDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('device_token') ?? '';
  }

  static Future<List<Trigger>> getTriggers() async {
    final token = await _getDeviceToken();
    if (token.isEmpty) return [];
    final json = await ApiService.get('/devices/$token/triggers/');
    final list = json['triggers'] as List? ?? json['results'] as List? ?? [];
    return list.map((e) => Trigger.fromJson(e)).toList();
  }

  static Future<Trigger> create(
      String category, List<String> keywords, int severity) async {
    final token = await _getDeviceToken();
    final json = await ApiService.post('/devices/$token/triggers/', {
      'category': category,
      'keywords': keywords,
      'severity': severity,
    });
    return Trigger.fromJson(json['trigger'] ?? json);
  }

  static Future<Trigger> update(
      int id, String category, List<String> keywords, int severity, bool active) async {
    final token = await _getDeviceToken();
    final json = await ApiService.put('/devices/$token/triggers/$id/', {
      'category': category,
      'keywords': keywords,
      'severity': severity,
      'active': active,
    });
    return Trigger.fromJson(json['trigger'] ?? json);
  }

  static Future<void> remove(int id) async {
    final token = await _getDeviceToken();
    await ApiService.delete('/devices/$token/triggers/$id/');
  }
}
