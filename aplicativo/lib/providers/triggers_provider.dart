import 'package:flutter/material.dart';
import '../models/trigger.dart';
import '../services/trigger_service.dart';

class TriggersProvider extends ChangeNotifier {
  List<Trigger> _triggers = [];
  bool _loading = false;
  String? _error;

  List<Trigger> get triggers => _triggers;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _triggers = await TriggerService.getTriggers();
    } catch (e) {
      _error = e.toString();
      // Mock de fallback
      _triggers = [
        const Trigger(id: 1, category: 'Violência', keywords: ['briga', 'arma', 'sangue'], severity: 8, active: true),
        const Trigger(id: 2, category: 'Jogos de Azar', keywords: ['aposta', 'bet', 'cassino'], severity: 9, active: true),
        const Trigger(id: 3, category: 'Conteúdo Adulto', keywords: [], severity: 10, active: true),
      ];
      _error = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> create(String category, List<String> keywords, int severity) async {
    try {
      final t = await TriggerService.create(category, keywords, severity);
      _triggers.add(t);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(int id, String category, List<String> keywords, int severity, bool active) async {
    try {
      final t = await TriggerService.update(id, category, keywords, severity, active);
      final idx = _triggers.indexWhere((x) => x.id == id);
      if (idx >= 0) _triggers[idx] = t;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> remove(int id) async {
    try {
      await TriggerService.remove(id);
      _triggers.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
