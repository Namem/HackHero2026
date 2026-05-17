import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/installed_app.dart';
import 'api_service.dart';

class AppScanService {
  static const _channel = MethodChannel('com.vigilia/apps');

  static Future<List<Map<String, dynamic>>> scanRealApps() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getInstalledApps');
      return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> syncApps(List<Map<String, dynamic>> apps) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('device_token') ?? '';
    if (token.isEmpty) return;
    await ApiService.post('/devices/$token/apps/', {'apps': apps});
  }

  static Future<List<Map<String, dynamic>>> getChildDevices() async {
    final result = await ApiService.getList('/devices/children/');
    return result.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<InstalledApp>> getAppsForDevice(String deviceToken) async {
    if (deviceToken.isEmpty) return [];
    try {
      final list = await ApiService.getList('/devices/$deviceToken/apps/');
      return list.map((e) => InstalledApp(
        id: e['id'] ?? 0,
        packageName: e['package_name'] ?? '',
        appName: e['app_name'] ?? e['package_name'] ?? '',
        iconBase64: e['icon_base64'],
        isMonitored: e['is_active'] ?? true,
      )).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<InstalledApp>> getApps(int childId) async {
    try {
      final devices = await getChildDevices();
      if (devices.isNotEmpty) {
        final token = devices.first['device_token'] as String? ?? '';
        if (token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('child_device_token', token);
          return getAppsForDevice(token);
        }
      }
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('device_token') ?? '';
    if (token.isNotEmpty) return getAppsForDevice(token);
    return [];
  }
}
