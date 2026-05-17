import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/link_provider.dart';
import '../../services/app_scan_service.dart';
import '../../services/foreground_watcher_service.dart';
import '../../services/monitor_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/aura_logo.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LinkProvider>().checkStatus();
      _syncApps();
      _startMonitoringNotification();
      _startForegroundWatcher();
      // Atualiza lista de apps monitorados a cada 30s (caso o pai mude)
      _refreshTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _refreshMonitoredApps(),
      );
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    ForegroundWatcherService.stop();
    super.dispose();
  }

  Future<void> _syncApps() async {
    try {
      final appsData = await AppScanService.scanRealApps();
      await AppScanService.syncApps(appsData);
    } catch (_) {}
  }

  Future<void> _startMonitoringNotification() async {
    await NotificationService.requestPermission();
    await NotificationService.showOngoing();
  }

  Future<void> _startForegroundWatcher() async {
    final hasAccess = await ForegroundWatcherService.hasUsageAccess();
    if (!hasAccess) {
      debugPrint('[ChildHome] sem permissão PACKAGE_USAGE_STATS — watcher não iniciado');
      return;
    }
    await _refreshMonitoredApps(start: true);
  }

  Future<void> _refreshMonitoredApps({bool start = false}) async {
    try {
      // Pega apps monitorados (is_active=true) do backend usando o token desta criança
      final link = context.read<LinkProvider>();
      final childId = link.linkedChildId ?? 0;
      final apps = await MonitorService.getMonitoredApps(childId);
      final activeApps = <String, String>{
        for (final a in apps.where((a) => a.isActive))
          a.packageName: a.appName,
      };
      if (start || !ForegroundWatcherService.isRunning) {
        ForegroundWatcherService.start(activeApps);
      } else {
        ForegroundWatcherService.updateMonitoredApps(activeApps);
      }
    } catch (e) {
      debugPrint('[ChildHome] refreshMonitoredApps error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final link = context.watch<LinkProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // Nav
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const AuraLogo(size: 30, showLabel: true),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.white.withValues(alpha: 0.7), size: 20),
                    onPressed: () async {
                      ForegroundWatcherService.stop();
                      await NotificationService.cancel();
                      await auth.logout();
                      if (mounted) Navigator.pushReplacementNamed(context, Routes.login);
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        children: [
                          const AuraLogo(size: 72),
                          const SizedBox(height: 16),
                          const Text('Aura está ativo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text('Seus pais estão cuidando de você online', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: link.linked ? AppTheme.accent.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: link.linked ? AppTheme.accent.withValues(alpha: 0.4) : Colors.orange.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 6, height: 6, decoration: BoxDecoration(color: link.linked ? AppTheme.accent : Colors.orange, shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text(link.linked ? 'Conectado' : 'Aguardando vinculação', style: TextStyle(color: link.linked ? AppTheme.accent : Colors.orange, fontWeight: FontWeight.w600, fontSize: 12)),
                              ],
                            ),
                          ),
                          if (link.partnerName != null) ...[
                            const SizedBox(height: 10),
                            Text('Responsável: ${link.partnerName}', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.5)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildButton(icon: Icons.apps, label: 'Ver apps monitorados', onTap: () => Navigator.pushNamed(context, Routes.childAppsList)),
                    const SizedBox(height: 10),
                    _buildButton(icon: Icons.science_outlined, label: 'Modo Demo (simulação)', onTap: () => Navigator.pushNamed(context, Routes.childSimulate), secondary: true),
                    if (!link.linked) ...[
                      const SizedBox(height: 10),
                      _buildButton(icon: Icons.link, label: 'Inserir código de vinculação', onTap: () => Navigator.pushNamed(context, Routes.childEnterCode), secondary: true),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text('Aura · Proteção ativa', style: TextStyle(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 0.4), textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required String label, required VoidCallback onTap, bool secondary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: secondary ? Colors.white.withValues(alpha: 0.06) : AppTheme.primary,
          borderRadius: BorderRadius.circular(14),
          border: secondary ? Border.all(color: Colors.white.withValues(alpha: 0.14)) : null,
          boxShadow: secondary ? null : [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
