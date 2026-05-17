import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../widgets/aura_logo.dart';

class ChildPermissionsScreen extends StatefulWidget {
  const ChildPermissionsScreen({super.key});

  @override
  State<ChildPermissionsScreen> createState() => _ChildPermissionsScreenState();
}

class _ChildPermissionsScreenState extends State<ChildPermissionsScreen> {
  bool _usageStats = false;
  bool _overlay = false;
  bool _notifications = false;

  void _openUsageStatsSettings() async {
    try {
      const channel = MethodChannel('com.vigilia/settings');
      await channel.invokeMethod('openUsageAccessSettings');
    } catch (_) {
      try {
        const channel = MethodChannel('com.vigilia/settings');
        await channel.invokeMethod('openSettings');
      } catch (_) {}
    }
    setState(() => _usageStats = true);
  }

  void _openOverlaySettings() async {
    try {
      const channel = MethodChannel('com.vigilia/settings');
      await channel.invokeMethod('openOverlaySettings');
    } catch (_) {}
    setState(() => _overlay = true);
  }

  void _continue() {
    Navigator.pushReplacementNamed(context, Routes.childEnterCode);
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _usageStats && _overlay;
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
                  const AuraLogo(size: 30, showLabel: true, labelColor: Colors.white),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.security, size: 26, color: AppTheme.primary),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Para funcionar corretamente, o app precisa de algumas permissões:',
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    _PermissionCard(
                      icon: Icons.bar_chart,
                      title: 'Acesso ao uso de apps',
                      subtitle: 'Para saber qual app está aberto',
                      granted: _usageStats,
                      onTap: _openUsageStatsSettings,
                    ),
                    const SizedBox(height: 10),
                    _PermissionCard(
                      icon: Icons.layers,
                      title: 'Sobreposição de tela',
                      subtitle: 'Para exibir o escudo do Aura na barra de notificações',
                      granted: _overlay,
                      onTap: _openOverlaySettings,
                    ),
                    const SizedBox(height: 10),
                    _PermissionCard(
                      icon: Icons.notifications,
                      title: 'Notificações',
                      subtitle: 'Para manter o serviço ativo',
                      granted: _notifications,
                      onTap: () => setState(() => _notifications = true),
                    ),

                    const Spacer(),

                    if (!allGranted)
                      Text(
                        'Ative as permissões acima para continuar',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: allGranted ? AppTheme.primary : Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(allGranted ? 'Tudo pronto!' : 'Continuar mesmo assim'),
                    ),
                    if (!allGranted) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Algumas funcionalidades podem não funcionar sem as permissões.',
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool granted;
  final VoidCallback onTap;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: granted ? AppTheme.safe.withOpacity(0.4) : Colors.white.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: granted ? AppTheme.safe.withOpacity(0.15) : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: granted ? AppTheme.safe : Colors.white.withOpacity(0.6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.55))),
              ],
            ),
          ),
          granted
              ? const Icon(Icons.check_circle, color: AppTheme.safe, size: 22)
              : GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Ativar', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ),
        ],
      ),
    );
  }
}
