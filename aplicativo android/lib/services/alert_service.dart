import '../models/alert.dart';
import 'api_service.dart';

class AlertService {
  static Future<List<Alert>> getAlerts() async {
    final json = await ApiService.get('/alerts/');
    final list = json['alerts'] as List? ?? json['results'] as List? ?? [];
    return list.map((e) => Alert.fromJson(e)).toList();
  }

  static Future<Alert> getAlert(int id) async {
    final json = await ApiService.get('/alerts/$id/');
    return Alert.fromJson(json['alert'] ?? json);
  }

  static Future<Alert> markSeen(int id) async {
    final json = await ApiService.put('/alerts/$id/seen/', {});
    return Alert.fromJson(json['alert'] ?? json);
  }
}
