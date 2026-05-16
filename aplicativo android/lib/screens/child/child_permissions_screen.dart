import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';

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
      // Fallback: abre configurações gerais
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
      appBar: AppBar(title: const Text('Permissões necessárias')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.security, size: 48, color: AppTheme.primary),
              const SizedBox(height: 16),
              const Text(
                'Para funcionar corretamente, o app precisa de algumas permissões:',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              _PermissionCard(
                icon: Icons.bar_chart,
                title: 'Acesso ao uso de apps',
                subtitle: 'Para saber qual app está aberto no momento',
                granted: _usageStats,
                onTap: _openUsageStatsSettings,
              ),
              const SizedBox(height: 12),
              _PermissionCard(
                icon: Icons.layers,
                title: 'Sobreposição de tela',
                subtitle: 'Para exibir o ícone de monitoramento ativo',
                granted: _overlay,
                onTap: _openOverlaySettings,
              ),
              const SizedBox(height: 12),
              _PermissionCard(
                icon: Icons.notifications,
                title: 'Notificações',
                subtitle: 'Para manter o serviço ativo em segundo plano',
                granted: _notifications,
                onTap: () => setState(() => _notifications = true),
              ),

              const Spacer(),

              if (!allGranted)
                Text(
                  'Ative as permissões acima para continuar',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _continue,
                child: Text(allGranted ? 'Tudo pronto!' : 'Continuar mesmo assim'),
              ),
              if (!allGranted) ...[
                const SizedBox(height: 8),
                Text(
                  'Algumas funcionalidades podem não funcionar sem as permissões.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
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
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: granted ? AppTheme.primary.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
          child: Icon(icon, color: granted ? AppTheme.primary : Colors.grey),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: granted
            ? const Icon(Icons.check_circle, color: AppTheme.primary)
            : OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('Ativar', style: TextStyle(fontSize: 12)),
              ),
      ),
    );
  }
}
