import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';

class ChildConsentScreen extends StatefulWidget {
  const ChildConsentScreen({super.key});

  @override
  State<ChildConsentScreen> createState() => _ChildConsentScreenState();
}

class _ChildConsentScreenState extends State<ChildConsentScreen> {
  bool _accepted = false;

  Future<void> _continue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('consent_accepted', true);
    await prefs.setString('consent_date', DateTime.now().toIso8601String());
    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.childPermissions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aviso importante')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.family_restroom, size: 56, color: Colors.blue[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Olá!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Seu pai ou responsável está configurando este app para cuidar da sua segurança online.',
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text('O que este app faz:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _InfoTile(
                icon: Icons.visibility,
                title: 'Observa quais apps você usa',
                subtitle: 'Seu responsável escolhe quais apps serão observados',
              ),
              _InfoTile(
                icon: Icons.screenshot,
                title: 'Faz capturas de tela',
                subtitle: 'Apenas quando você está usando um app monitorado',
              ),
              _InfoTile(
                icon: Icons.smart_toy,
                title: 'Uma IA analisa o conteúdo',
                subtitle: 'Verifica se há algo que possa ser perigoso para você',
              ),
              _InfoTile(
                icon: Icons.delete_forever,
                title: 'A imagem é apagada imediatamente',
                subtitle: 'Ninguém vê a imagem — nem seus pais. Ela é destruída.',
              ),
              _InfoTile(
                icon: Icons.notifications,
                title: 'Seu responsável recebe um aviso em texto',
                subtitle: 'Apenas se algo perigoso for detectado, sem imagens.',
              ),
              _InfoTile(
                icon: Icons.badge,
                title: 'Um ícone fica visível',
                subtitle: 'Você sempre vai saber quando o app está ativo',
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gavel, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lei 15.211/2025, Art. 19 §1 — Você tem o direito de saber que está sendo monitorado.',
                        style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              CheckboxListTile(
                value: _accepted,
                onChanged: (v) => setState(() => _accepted = v ?? false),
                title: const Text('Eu entendi o que este app faz', style: TextStyle(fontWeight: FontWeight.w600)),
                activeColor: AppTheme.primary,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _accepted ? _continue : null,
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
