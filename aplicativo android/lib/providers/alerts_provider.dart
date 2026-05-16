import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../services/alert_service.dart';

class AlertsProvider extends ChangeNotifier {
  List<Alert> _alerts = [];
  bool _loading = false;
  String? _error;

  List<Alert> get alerts => _alerts;
  bool get loading => _loading;
  String? get error => _error;
  int get unseenCount => _alerts.where((a) => !a.seen).length;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _alerts = await AlertService.getAlerts();
    } catch (e) {
      _error = e.toString();
      // Mock de fallback para demo
      _alerts = Alert.getMockAlerts();
      _error = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> markSeen(int id) async {
    try {
      final updated = await AlertService.markSeen(id);
      final idx = _alerts.indexWhere((a) => a.id == id);
      if (idx >= 0) {
        _alerts[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
