import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../widgets/aura_logo.dart';

enum TransparencyAudience { child, parent }

class TransparencyScreen extends StatefulWidget {
  final TransparencyAudience audience;
  const TransparencyScreen({super.key, required this.audience});

  @override
  State<TransparencyScreen> createState() => _TransparencyScreenState();
}

class _TransparencyScreenState extends State<TransparencyScreen> {
  bool _accepted = false;

  bool get _isChild => widget.audience == TransparencyAudience.child;

  Future<void> _continue() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isChild) {
      await prefs.setBool('consent_accepted', true);
      await prefs.setString('consent_date', DateTime.now().toIso8601String());
    } else {
      await prefs.setBool('parent_transparency_accepted', true);
      await prefs.setString('parent_transparency_date', DateTime.now().toIso8601String());
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      _isChild ? Routes.childPermissions : Routes.parentGenerateCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _isChild ? _childItems : _parentItems;
    final headerIcon = _isChild ? Icons.family_restroom : Icons.shield_outlined;
    final headerTitle = _isChild ? 'Olá!' : 'Como o Aura funciona';
    final headerSubtitle = _isChild
        ? 'Seu pai ou responsável está configurando este app para cuidar da sua segurança online.'
        : 'Antes de configurar, entenda exatamente o que o app faz no celular do seu filho.';
    final sectionTitle = _isChild ? 'O que este app faz:' : 'O que o Aura faz no celular do seu filho:';
    final legalNotice = _isChild
        ? 'Lei 15.211/2025, Art. 19 §1 — Você tem o direito de saber que está sendo monitorado.'
        : 'Lei 15.211/2025, Art. 19 §1 — A criança tem o direito de saber que está sendo monitorada. O Aura cumpre isso automaticamente.';
    final acceptLabel = _isChild
        ? 'Eu entendi o que este app faz'
        : 'Eu entendi e vou informar meu filho';
    final buttonLabel = _isChild ? 'Continuar →' : 'Entendi, vamos configurar →';

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const AuraLogo(size: 30, showLabel: true),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(headerIcon, color: AppTheme.accent, size: 28),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            headerTitle,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            headerSubtitle,
                            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.75), height: 1.4),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      sectionTitle,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 12),

                    for (int i = 0; i < items.length; i++)
                      _NumberedItem(n: i + 1, item: items[i]),

                    const SizedBox(height: 16),

                    // Legal notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.accent.withOpacity(0.25)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.gavel, color: AppTheme.accent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              legalNotice,
                              style: TextStyle(fontSize: 11.5, color: Colors.white.withOpacity(0.75), height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Accept checkbox
                    GestureDetector(
                      onTap: () => setState(() => _accepted = !_accepted),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _accepted ? AppTheme.accent.withOpacity(0.5) : Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _accepted ? AppTheme.accent : Colors.transparent,
                                border: Border.all(
                                  color: _accepted ? AppTheme.accent : Colors.white.withOpacity(0.4),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: _accepted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                acceptLabel,
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _accepted ? _continue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accepted ? AppTheme.primary : Colors.white.withOpacity(0.1),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.white.withOpacity(0.1),
                          disabledForegroundColor: Colors.white.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _childItems = <_Item>[
    _Item(icon: Icons.visibility, title: 'Aura roda em segundo plano', sub: 'Só vê qual app você está abrindo, nada mais'),
    _Item(icon: Icons.screenshot, title: 'Captura a tela quando você abre um jogo monitorado', sub: 'Apenas em jogos que seu responsável escolheu'),
    _Item(icon: Icons.smart_toy, title: 'Uma IA analisa o conteúdo', sub: 'Verifica se há algo que possa ser perigoso para você'),
    _Item(icon: Icons.delete_forever, title: 'A imagem é apagada imediatamente', sub: 'Ninguém vê a imagem — nem seus pais'),
    _Item(icon: Icons.notifications, title: 'Seu responsável recebe um aviso em texto', sub: 'Apenas se algo perigoso for detectado, sem imagens'),
    _Item(icon: Icons.shield, title: 'O escudo do Aura fica fixo na barra de notificações', sub: 'Sempre que o app está ativo. Em jogos monitorados, aparece um aviso adicional'),
  ];

  static const _parentItems = <_Item>[
    _Item(icon: Icons.visibility, title: 'Aura roda em segundo plano no celular do seu filho', sub: 'Só vê qual app está aberto, nada mais'),
    _Item(icon: Icons.screenshot, title: 'Captura a tela quando seu filho abre um jogo monitorado', sub: 'Apenas em jogos que você escolher'),
    _Item(icon: Icons.smart_toy, title: 'Uma IA analisa o conteúdo', sub: 'Classifica em risco alto, médio ou baixo'),
    _Item(icon: Icons.delete_forever, title: 'A imagem é apagada imediatamente', sub: 'Você nunca verá a tela do seu filho — só o alerta'),
    _Item(icon: Icons.notifications, title: 'Você recebe um aviso em texto', sub: 'Categoria, nível e horário — sem imagens'),
    _Item(icon: Icons.shield, title: 'O escudo do Aura fica fixo na barra do celular do seu filho', sub: 'Ele sempre sabe quando o app está ativo (Art. 19 §1 do ECA Digital)'),
  ];
}

class _Item {
  final IconData icon;
  final String title;
  final String sub;
  const _Item({required this.icon, required this.title, required this.sub});
}

class _NumberedItem extends StatelessWidget {
  final int n;
  final _Item item;
  const _NumberedItem({required this.n, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Center(
                child: Text('$n',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(item.sub, style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
