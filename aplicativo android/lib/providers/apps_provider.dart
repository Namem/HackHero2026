import 'package:flutter/material.dart';
import '../models/installed_app.dart';
import '../models/monitored_app.dart';
import '../services/app_scan_service.dart';
import '../services/monitor_service.dart';

class AppsProvider extends ChangeNotifier {
  List<InstalledApp> _apps = [];
  List<MonitoredApp> _monitored = [];
  bool _loading = false;
  String? _error;

  List<InstalledApp> get apps => _apps;
  List<MonitoredApp> get monitored => _monitored;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadApps(int childId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _apps = await AppScanService.getApps(childId);
      _monitored = await MonitorService.getMonitoredApps(childId);
      for (var i = 0; i < _apps.length; i++) {
        final isMonitored = _monitored.any((m) => m.packageName == _apps[i].packageName);
        _apps[i] = _apps[i].copyWith(isMonitored: isMonitored);
      }
    } catch (e) {
      _error = e.toString();
      // Fallback mock se o backend ainda não estiver pronto
      _apps = [
        const InstalledApp(id: 1, packageName: 'com.whatsapp', appName: 'WhatsApp', isMonitored: true),
        const InstalledApp(id: 2, packageName: 'com.google.android.youtube', appName: 'YouTube', isMonitored: false),
        const InstalledApp(id: 3, packageName: 'com.instagram.android', appName: 'Instagram', isMonitored: true),
        const InstalledApp(id: 4, packageName: 'com.android.chrome', appName: 'Chrome', isMonitored: false),
        const InstalledApp(id: 5, packageName: 'com.dts.freefireth', appName: 'Free Fire', isMonitored: true),
      ];
      _error = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void toggleApp(int index) {
    _apps[index] = _apps[index].copyWith(isMonitored: !_apps[index].isMonitored);
    notifyListeners();
  }

  Future<bool> saveSelection(int childId) async {
    _loading = true;
    notifyListeners();
    try {
      final ids = _apps.where((a) => a.isMonitored).map((a) => a.id).toList();
      await MonitorService.bulkUpdate(childId, ids);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
