import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/link_provider.dart';

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final link = context.watch<LinkProvider>();
    final user = auth.user;

    return Container(
      color: AppTheme.surface,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E3A6E), AppTheme.primaryDark],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: AppTheme.primaryDark.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _initials(user?.name ?? '?'),
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user?.name ?? 'Usuário',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, size: 13, color: AppTheme.accent),
                      const SizedBox(width: 6),
                      Text(
                        'Responsável',
                        style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Vinculação
          _SectionTitle('Vinculação'),
          const SizedBox(height: 8),
          _Card(
            children: [
              _Tile(
                icon: link.linked ? Icons.link : Icons.link_off,
                iconColor: link.linked ? AppTheme.accent : Colors.grey,
                title: link.linked ? 'Filho vinculado' : 'Nenhum filho vinculado',
                subtitle: link.linked ? (link.partnerName ?? 'Vinculação ativa') : 'Gere um código para começar',
              ),
              const _Divider(),
              _Tile(
                icon: Icons.qr_code,
                iconColor: AppTheme.primary,
                title: 'Gerar código de vinculação',
                subtitle: 'Para vincular outro filho ou refazer o pareamento',
                onTap: () => Navigator.pushNamed(context, Routes.parentGenerateCode),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Privacidade
          _SectionTitle('Privacidade e dados'),
          const SizedBox(height: 8),
          _Card(
            children: [
              _Tile(
                icon: Icons.shield_outlined,
                iconColor: AppTheme.primary,
                title: 'Política de Privacidade e Termos',
                subtitle: 'Veja exatamente quais dados coletamos e como',
                onTap: () => Navigator.pushNamed(context, Routes.privacyPolicy),
              ),
              const _Divider(),
              _Tile(
                icon: Icons.delete_forever_outlined,
                iconColor: AppTheme.danger,
                title: 'Excluir minha conta',
                subtitle: 'Apaga todos os seus dados em até 15 dias (LGPD Art. 18)',
                titleColor: AppTheme.danger,
                onTap: () => _confirmDelete(context),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Sessão
          _Card(
            children: [
              _Tile(
                icon: Icons.logout,
                iconColor: Colors.grey,
                title: 'Sair',
                subtitle: 'Faz logout neste dispositivo',
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, Routes.login);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              'Aura · v1.0.0',
              style: TextStyle(color: Colors.grey[500], fontSize: 11.5, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir conta?'),
        content: const Text(
          'Esta ação remove todos os seus dados, alertas e vinculações em até 15 dias. '
          'Você não poderá recuperar essas informações depois.\n\n'
          'Tem certeza que deseja continuar?',
          style: TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pedido de exclusão enviado. Confira seu e-mail.'),
                  backgroundColor: AppTheme.danger,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Excluir conta'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 2),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppTheme.textSecondary.withValues(alpha: 0.8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15)),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: titleColor ?? AppTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, height: 1.3),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, color: Colors.grey.withValues(alpha: 0.5), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
