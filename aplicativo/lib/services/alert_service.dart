import 'package:flutter/foundation.dart';
import '../models/alert.dart';
import 'api_service.dart';

class AlertService {
  static Future<List<Alert>> getAlerts() async {
    final list = await ApiService.getList('/alerts/');
    debugPrint('[AlertService] getAlerts received ${list.length} alerts');
    return list
        .map((e) => Alert.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<Alert> getAlert(int id) async {
    final json = await ApiService.get('/alerts/$id/');
    return Alert.fromJson(json['alert'] ?? json);
  }

  /// Dispensa/remove o alerta no backend. O alerta some da lista e
  /// não volta em refresh futuro.
  static Future<void> dismiss(int id) async {
    await ApiService.delete('/alerts/$id/');
    debugPrint('[AlertService] dismissed alert $id');
  }
}
