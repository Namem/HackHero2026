import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'notification_service.dart';

/// Serviço que monitora qual app está em foreground via UsageStatsManager (Android).
/// Quando detecta que a criança abriu um app monitorado pelo pai,
/// mostra uma notificação avisando sobre o monitoramento (ECA Digital Art. 19 §1).
class ForegroundWatcherService {
  static const _channel = MethodChannel('com.vigilia/foreground');
  static const _ownPackage = 'com.vigilia.vigilia';

  static Timer? _timer;
  static String? _lastForeground;
  static Map<String, String> _monitoredApps = {}; // package -> app_name
  static bool _running = false;

  static bool get isRunning => _running;

  /// Verifica se o app tem a permissão PACKAGE_USAGE_STATS.
  static Future<bool> hasUsageAccess() async {
    try {
      return await _channel.invokeMethod<bool>('hasUsageAccess') ?? false;
    } catch (e) {
      debugPrint('[ForegroundWatcher] hasUsageAccess error: $e');
      return false;
    }
  }

  /// Retorna o package_name do app em foreground (null se não conseguir).
  static Future<String?> getForegroundApp() async {
    try {
      return await _channel.invokeMethod<String>('getForegroundApp');
    } catch (e) {
      debugPrint('[ForegroundWatcher] getForegroundApp error: $e');
      return null;
    }
  }

  /// Inicia o polling. `monitoredApps` é package_name -> app_name.
  /// Polling a cada 4s.
  static void start(Map<String, String> monitoredApps) {
    _monitoredApps = Map.from(monitoredApps);
    _running = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _tick());
    debugPrint('[ForegroundWatcher] started with ${_monitoredApps.length} apps monitorados');
  }

  /// Para o polling e remove notificação ativa.
  static void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
    _lastForeground = null;
    NotificationService.removeAppMonitoringAlert();
    debugPrint('[ForegroundWatcher] stopped');
  }

  /// Atualiza a lista de apps monitorados sem reiniciar o timer.
  static void updateMonitoredApps(Map<String, String> monitoredApps) {
    _monitoredApps = Map.from(monitoredApps);
  }

  static Future<void> _tick() async {
    final fg = await getForegroundApp();
    if (fg == null) return;

    // Ignora o próprio app Aura
    if (fg == _ownPackage) {
      if (_lastForeground != null && _monitoredApps.containsKey(_lastForeground)) {
        // saiu do app monitorado para o Aura
        await NotificationService.removeAppMonitoringAlert();
      }
      _lastForeground = fg;
      return;
    }

    final isMonitored = _monitoredApps.containsKey(fg);

    if (fg != _lastForeground) {
      debugPrint('[ForegroundWatcher] foreground changed: $_lastForeground -> $fg (monitored=$isMonitored)');

      if (isMonitored) {
        // Entrou em um app monitorado → mostra notificação
        final appName = _monitoredApps[fg] ?? fg;
        await NotificationService.showAppMonitoringAlert(appName);
      } else if (_lastForeground != null && _monitoredApps.containsKey(_lastForeground)) {
        // Saiu de um app monitorado para outro não monitorado → remove
        await NotificationService.removeAppMonitoringAlert();
      }

      _lastForeground = fg;
    }
  }
}
