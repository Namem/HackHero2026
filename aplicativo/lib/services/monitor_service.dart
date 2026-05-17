import 'package:shared_preferences/shared_preferences.dart';
import '../models/monitored_app.dart';
import 'api_service.dart';
import 'app_scan_service.dart';

class MonitorService {
  static Future<String> _resolveToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Parent side: use child_device_token
    final childToken = prefs.getString('child_device_token');
    if (childToken != null && childToken.isNotEmpty) return childToken;
    // Child side: use own device_token
    return prefs.getString('device_token') ?? '';
  }

  static Future<List<MonitoredApp>> getMonitoredApps(int childId) async {
    var token = await _resolveToken();
    if (token.isEmpty) {
      // Try fetching from backend
      try {
        final devices = await AppScanService.getChildDevices();
        if (devices.isNotEmpty) {
          token = devices.first['device_token'] as String? ?? '';
          if (token.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('child_device_token', token);
          }
        }
      } catch (_) {}
    }
    if (token.isEmpty) return [];
    final list = await ApiService.getList('/devices/$token/apps/');
    return list.map((e) => MonitoredApp.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<void> bulkUpdate(int childId, List<int> appIds) async {
    var token = await _resolveToken();
    // Fallback: se ainda não temos o token do device da criança, busca no backend
    if (token.isEmpty) {
      try {
        final devices = await AppScanService.getChildDevices();
        if (devices.isNotEmpty) {
          token = devices.first['device_token'] as String? ?? '';
          if (token.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('child_device_token', token);
          }
        }
      } catch (_) {}
    }
    if (token.isEmpty) {
      throw Exception('Nenhum device da criança vinculado a esta conta');
    }
    // ignore: avoid_print
    print('[MonitorService] bulkUpdate token=$token appIds=$appIds');
    await ApiService.postRaw('/devices/$token/apps/', {
      'app_ids': appIds,
    });
  }

  static Future<void> remove(int id) async {
    final token = await _resolveToken();
    await ApiService.delete('/devices/$token/apps/$id/');
  }
}
