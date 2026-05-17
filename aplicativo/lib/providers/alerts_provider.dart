import 'package:flutter/foundation.dart';
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
      debugPrint('[AlertsProvider] loaded ${_alerts.length} real alerts from backend');
    } catch (e) {
      _error = e.toString();
      debugPrint('[AlertsProvider] load error: $e');
      // Mantém os alertas anteriores se houver erro de rede
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> dismiss(int id) async {
    try {
      await AlertService.dismiss(id);
      _alerts.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[AlertsProvider] dismiss error: $e');
      // Se o backend já retornou 404 (alerta já foi deletado), ainda assim remove da lista local
      final msg = e.toString();
      if (msg.contains('404') || msg.contains('não encontrado')) {
        _alerts.removeWhere((a) => a.id == id);
        notifyListeners();
        return true;
      }
      return false;
    }
  }
}
