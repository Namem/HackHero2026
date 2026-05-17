import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Serviço de notificação persistente do Aura.
/// Mostra uma notificação "ongoing" (não pode ser deslizada) enquanto
/// o app está ativo no celular da criança — atende ECA Digital Art. 19 §1.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'aura_ongoing';
  static const String _channelName = 'Monitoramento Aura';
  static const String _channelDesc =
      'Notificação fixa indicando que o Aura está ativo';
  static const int _ongoingId = 1001;

  static const String _alertChannelId = 'aura_app_alert';
  static const String _alertChannelName = 'App monitorado em uso';
  static const String _alertChannelDesc =
      'Aviso quando um app monitorado pelo Aura é aberto';
  static const int _alertId = 1002;

  static bool _initialized = false;

  /// Inicializa o plugin. Chame uma vez no main().
  static Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@drawable/ic_aura_notification');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);

    // Cria o canal (Android 8+)
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.low, // sem som / vibração
        showBadge: false,
      ),
    );

    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _alertChannelId,
        _alertChannelName,
        description: _alertChannelDesc,
        importance: Importance.high,
        showBadge: true,
      ),
    );

    _initialized = true;
  }

  /// Pede permissão de notificação (necessário no Android 13+).
  static Future<bool> requestPermission() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidImpl?.requestNotificationsPermission();
    return granted ?? false;
  }

  /// Mostra a notificação fixa do Aura.
  static Future<void> showOngoing({
    String title = 'Aura está ativo',
    String body = 'Seu uso está sendo acompanhado pelo seu responsável',
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true, // não pode ser deslizada
        autoCancel: false,
        showWhen: false,
        onlyAlertOnce: true,
        icon: '@drawable/ic_aura_notification',
        category: AndroidNotificationCategory.service,
        visibility: NotificationVisibility.public,
      );

      const details = NotificationDetails(android: androidDetails);

      await _plugin.show(_ongoingId, title, body, details);
    } catch (e) {
      debugPrint('[NotificationService] showOngoing error: $e');
    }
  }

  /// Remove a notificação fixa.
  static Future<void> cancel() async {
    try {
      await _plugin.cancel(_ongoingId);
    } catch (e) {
      debugPrint('[NotificationService] cancel error: $e');
    }
  }

  /// Notificação visível quando um app monitorado é aberto pela criança.
  /// Não é "ongoing" porque o objetivo é alertar — mas tem som para chamar atenção.
  static Future<void> showAppMonitoringAlert(String appName) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _alertChannelId,
        _alertChannelName,
        channelDescription: _alertChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        ongoing: true, // permanece enquanto o app monitorado estiver aberto
        autoCancel: false,
        icon: '@drawable/ic_aura_notification',
        category: AndroidNotificationCategory.status,
        visibility: NotificationVisibility.public,
        ticker: 'App monitorado em uso',
      );
      const details = NotificationDetails(android: androidDetails);
      await _plugin.show(
        _alertId,
        'Aura está observando $appName',
        'Seu uso deste app está sendo acompanhado pelo seu responsável',
        details,
      );
    } catch (e) {
      debugPrint('[NotificationService] showAppMonitoringAlert error: $e');
    }
  }

  /// Remove a notificação de app monitorado.
  static Future<void> removeAppMonitoringAlert() async {
    try {
      await _plugin.cancel(_alertId);
    } catch (e) {
      debugPrint('[NotificationService] removeAppMonitoringAlert error: $e');
    }
  }
}
