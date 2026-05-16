import 'package:shared_preferences/shared_preferences.dart';
import '../models/installed_app.dart';
import 'api_service.dart';

class AppScanService {
  static Future<void> syncApps(List<Map<String, String>> apps) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('device_token') ?? '';
    await ApiService.post('/devices/$token/apps/', {'apps': apps});
  }

  static Future<List<Map<String, dynamic>>> getChildDevices() async {
    final result = await ApiService.getList('/devices/children/');
    return result.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<InstalledApp>> getAppsForDevice(String deviceToken) async {
    if (deviceToken.isEmpty) return getMockApps();
    try {
      final list = await ApiService.getList('/devices/$deviceToken/apps/');
      return list.map((e) => InstalledApp(
        id: e['id'] ?? 0,
        packageName: e['package_name'] ?? '',
        appName: e['app_name'] ?? e['package_name'] ?? '',
        isMonitored: e['is_active'] ?? true,
      )).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<InstalledApp>> getApps(int childId) async {
    // For parent: try to get child's device token from backend
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
    // Fallback: try local device_token (child device)
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('device_token') ?? '';
    if (token.isNotEmpty) return getAppsForDevice(token);
    return getMockApps();
  }

  // Apps realistas para a demo quando backend não tem dados
  static List<InstalledApp> getMockApps() => [
        const InstalledApp(id: 1, packageName: 'com.whatsapp', appName: 'WhatsApp', isMonitored: true),
        const InstalledApp(id: 2, packageName: 'com.google.android.youtube', appName: 'YouTube', isMonitored: false),
        const InstalledApp(id: 3, packageName: 'com.instagram.android', appName: 'Instagram', isMonitored: true),
        const InstalledApp(id: 4, packageName: 'com.android.chrome', appName: 'Chrome', isMonitored: false),
        const InstalledApp(id: 5, packageName: 'com.dts.freefireth', appName: 'Free Fire', isMonitored: true),
        const InstalledApp(id: 6, packageName: 'com.zhiliaoapp.musically', appName: 'TikTok', isMonitored: true),
        const InstalledApp(id: 7, packageName: 'com.spotify.music', appName: 'Spotify', isMonitored: false),
        const InstalledApp(id: 8, packageName: 'com.discord', appName: 'Discord', isMonitored: false),
        const InstalledApp(id: 9, packageName: 'com.supercell.brawlstars', appName: 'Brawl Stars', isMonitored: false),
        const InstalledApp(id: 10, packageName: 'com.roblox.client', appName: 'Roblox', isMonitored: true),
      ];
}
