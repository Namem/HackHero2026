import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/aura_logo.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  Future<void> _select(BuildContext context, String role) async {
    final auth = context.read<AuthProvider>();
    await auth.setRole(role);
    if (!context.mounted) return;
    if (role == 'parent') {
      Navigator.pushReplacementNamed(context, Routes.parentTransparency);
    } else {
      Navigator.pushReplacementNamed(context, Routes.childConsent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: AuraLogo(size: 64)),
              const SizedBox(height: 28),
              const Text(
                'Este dispositivo\né de quem?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5, height: 1.2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Você pode usar a mesma conta nos dois celulares.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (auth.loading)
                const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              else ...[
                _RoleCard(
                  icon: Icons.shield,
                  title: 'Este é o MEU celular',
                  subtitle: 'Vou monitorar o celular do meu filho daqui',
                  color: AppTheme.primary,
                  onTap: () => _select(context, 'parent'),
                ),
                const SizedBox(height: 14),
                _RoleCard(
                  icon: Icons.child_care,
                  title: 'Este é o celular do MEU FILHO',
                  subtitle: 'Vou configurar o monitoramento neste aparelho',
                  color: AppTheme.accent,
                  onTap: () => _select(context, 'child'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 3),
              Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.5)),
            ])),
            Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}
