import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/alert.dart';
import '../../providers/alerts_provider.dart';
import '../../data/awareness_tips.dart';

class AlertDetailScreen extends StatelessWidget {
  const AlertDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alert = ModalRoute.of(context)!.settings.arguments as Alert;
    final color = AppTheme.riskColor(alert.riskLevel);
    final bg = AppTheme.riskBg(alert.riskLevel);
    final fg = AppTheme.riskFg(alert.riskLevel);
    final fmt = DateFormat('HH:mm · dd/MM/yyyy');
    final generalCategory = _generalCategoryFor(alert.categories);
    final relatedTip = _relatedTipFor(generalCategory);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Orientação'),
        backgroundColor: AppTheme.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — Risco identificado
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13)),
                        child: Icon(AppTheme.riskIcon(alert.riskLevel), color: color, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
                              child: Text(AppTheme.riskLabel(alert.riskLevel), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              alert.appName != null
                                  ? '${AppTheme.riskLabel(alert.riskLevel)} em ${alert.appName}'
                                  : '${AppTheme.riskLabel(alert.riskLevel)} detectado',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.primaryDark),
                            ),
                            const SizedBox(height: 2),
                            Text(fmt.format(alert.timestamp), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bg.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.label_outline, size: 16, color: fg),
                        const SizedBox(width: 8),
                        const Text('Categoria geral:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(width: 8),
                        Text(generalCategory, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: fg)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Privacidade — explicação
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Por respeito à privacidade do seu filho, não mostramos o conteúdo exato. O Aura te avisa o tipo de risco e te orienta como conversar.',
                      style: TextStyle(fontSize: 12.5, color: AppTheme.primaryDark.withValues(alpha: 0.85), height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Por que isso importa
            _OrientationCard(
              icon: Icons.psychology_outlined,
              color: AppTheme.warning,
              title: 'Por que isso importa',
              body: _whyItMattersFor(generalCategory),
            ),
            const SizedBox(height: 12),

            // Como conversar
            _OrientationCard(
              icon: Icons.chat_bubble_outline,
              color: AppTheme.accent,
              title: 'Como conversar com seu filho',
              body: _howToTalkAbout(generalCategory),
              bullets: _talkingPointsFor(generalCategory),
            ),
            const SizedBox(height: 12),

            // Recurso relacionado
            if (relatedTip != null) ...[
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.pushNamed(context, Routes.awarenessDetail, arguments: relatedTip),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: relatedTip.color.withOpacity(0.3), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: relatedTip.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(relatedTip.icon, color: relatedTip.color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('LEITURA RELACIONADA',
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: relatedTip.color, letterSpacing: 1)),
                              const SizedBox(height: 3),
                              Text(relatedTip.title,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.primaryDark, height: 1.3)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward, color: relatedTip.color, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Dispensar alerta
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Marcar como visto e dispensar'),
                onPressed: () async {
                  final ok = await context.read<AlertsProvider>().dismiss(alert.id);
                  if (!context.mounted) return;
                  if (ok) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alerta dispensado'),
                        backgroundColor: AppTheme.safe,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao dispensar — tente novamente'),
                        backgroundColor: AppTheme.danger,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 14),

            // Privacidade reforçada
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nenhuma imagem é armazenada. A análise foi feita em RAM e destruída imediatamente.',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mapeia categorias específicas para uma palavra geral.
  String _generalCategoryFor(List<String> categories) {
    if (categories.isEmpty) return 'Conteúdo sensível';
    final all = categories.join(' ').toLowerCase();
    if (all.contains('grooming') || all.contains('alicia')) return 'Aliciamento';
    if (all.contains('nud') || all.contains('sex') || all.contains('adulto')) return 'Conteúdo adulto';
    if (all.contains('aposta') || all.contains('gambling') || all.contains('cassino')) return 'Apostas';
    if (all.contains('violência') || all.contains('arma') || all.contains('agressão')) return 'Violência';
    if (all.contains('bullying') || all.contains('assédio') || all.contains('humilha')) return 'Bullying';
    if (all.contains('drog') || all.contains('álcool')) return 'Substâncias';
    if (all.contains('microtran') || all.contains('compra')) return 'Microtransações';
    if (all.contains('extremis') || all.contains('ódio')) return 'Extremismo';
    return 'Conteúdo sensível';
  }

  String _whyItMattersFor(String category) {
    switch (category) {
      case 'Aliciamento':
        return 'O aliciamento online (grooming) é uma das formas mais perigosas de exploração infantil. Predadores constroem confiança gradualmente para depois manipular a criança. Identificar cedo pode evitar consequências graves.';
      case 'Conteúdo adulto':
        return 'A exposição precoce a conteúdo adulto pode distorcer a percepção da criança sobre relacionamentos, intimidade e respeito. O impacto é maior quando ela vê isso sozinha, sem contexto.';
      case 'Apostas':
        return 'Mecânicas de aposta em jogos exploram o sistema de recompensa cerebral — ainda em desenvolvimento em crianças. Isso pode formar padrões de comportamento compulsivo na vida adulta.';
      case 'Violência':
        return 'Crianças expostas a violência gráfica podem ter alteração na sensibilidade emocional, pesadelos e dificuldade de concentração. O contexto e a frequência importam mais que um único evento.';
      case 'Bullying':
        return 'O cyberbullying tem impacto comparável (ou maior) ao bullying presencial — porque não tem hora nem lugar para acabar. As marcas emocionais podem durar anos.';
      case 'Substâncias':
        return 'A normalização de álcool e drogas em conteúdo digital pode aumentar a curiosidade e diminuir a percepção de risco em adolescentes.';
      case 'Microtransações':
        return 'Gastos impulsivos em jogos podem virar problema financeiro e comportamental. Crianças ainda não têm o filtro racional totalmente desenvolvido para resistir.';
      case 'Extremismo':
        return 'Conteúdo extremista (ódio, radicalização) busca capturar jovens em momentos de vulnerabilidade. O algoritmo das plataformas frequentemente amplifica esse conteúdo.';
      default:
        return 'O Aura identificou algo que pode requerer sua atenção. Mesmo sem ver o conteúdo, você pode iniciar uma conversa acolhedora com seu filho.';
    }
  }

  String _howToTalkAbout(String category) {
    return 'Aborde com curiosidade, não com julgamento. Crianças se fecham quando sentem que vão ser punidas por se abrir.';
  }

  List<String> _talkingPointsFor(String category) {
    switch (category) {
      case 'Aliciamento':
        return [
          '"Você tem feito algum amigo novo nos jogos ultimamente?"',
          '"Já recebeu algum presente ou skin de alguém que não conhece pessoalmente?"',
          '"Sabe que pode me contar se alguém te pedir algo estranho?"',
          'Reforce: "Não é culpa sua se isso aconteceu — adultos manipulam crianças, e você fez o certo me contando."',
        ];
      case 'Conteúdo adulto':
        return [
          '"Já apareceu algum conteúdo que te deixou desconfortável?"',
          'Explique que sites/jogos têm muito conteúdo direcionado a adultos por motivos biológicos e emocionais',
          'Não puna nem demonize a curiosidade — é natural',
          'Ofereça canais saudáveis para tirar dúvidas (você, um responsável, profissional)',
        ];
      case 'Apostas':
        return [
          '"Você já comprou alguma caixinha surpresa nos jogos? Como você se sentiu?"',
          'Mostre matematicamente como funciona a probabilidade — "casa sempre ganha"',
          'Combinem um limite mensal — e respeite o que combinaram',
          'Conte de adultos próximos que tiveram problemas com aposta',
        ];
      case 'Violência':
        return [
          '"O que você acha quando vê coisas violentas nos vídeos/jogos?"',
          'Diferencie violência simbólica (jogos) de violência real (notícias, redes)',
          'Verifique se há padrões — assistir um vídeo violento é diferente de buscar repetidamente',
          'Limite conteúdo intenso antes de dormir',
        ];
      case 'Bullying':
        return [
          '"Tem alguém na escola ou nos jogos que te faz se sentir mal?"',
          'Se sim: "Como você reage? O que você gostaria que acontecesse?"',
          'Se for autor: "O que motivou? Como você acha que a outra pessoa se sentiu?"',
          'Não tire o celular — isso ensina que pedir ajuda tem custo',
        ];
      case 'Substâncias':
        return [
          '"Já viu colegas falando ou postando sobre bebida, cigarro, drogas?"',
          'Pergunte o que ele pensa antes de dar sua opinião',
          'Conte experiências reais (suas ou de pessoas próximas) sem dramatizar',
          'Forneça informação factual — efeitos, riscos, leis',
        ];
      case 'Microtransações':
        return [
          '"Quanto você acha que já gastou com skins esse mês?"',
          'Mostre o equivalente real — "esse dinheiro daria pra..."',
          'Estabeleça um orçamento mensal junto',
          'Recompense não-gastos — "se não gastar nada esse mês, ganha X"',
        ];
      case 'Extremismo':
        return [
          '"Tem algum criador ou comunidade nova que você está acompanhando?"',
          'Ensine a identificar conteúdo que apela para raiva ou medo',
          'Mostre como algoritmos amplificam polarização',
          'Caso preocupante: procure orientação profissional — radicalização tem padrões',
        ];
      default:
        return [
          '"Como foi seu dia online hoje?"',
          '"Tem alguma coisa que te deixou desconfortável recentemente?"',
          '"Sabe que pode me contar qualquer coisa, sem medo?"',
        ];
    }
  }

  /// Sugere um tip relacionado ao alerta.
  AwarenessTip? _relatedTipFor(String category) {
    switch (category) {
      case 'Aliciamento':
        return AwarenessTipsData.byId('grooming');
      case 'Bullying':
        return AwarenessTipsData.byId('cyberbullying');
      case 'Microtransações':
      case 'Apostas':
        return AwarenessTipsData.byId('microtransacoes');
      case 'Conteúdo adulto':
      case 'Violência':
      case 'Substâncias':
      case 'Extremismo':
        return AwarenessTipsData.byId('comunicacao');
      default:
        return AwarenessTipsData.byId('comunicacao');
    }
  }
}

class _OrientationCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final List<String>? bullets;

  const _OrientationCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 3, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.primaryDark)),
              ),
            ],
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(height: 1.5, fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
          if (bullets != null && bullets!.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final b in bullets!)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(top: 7, right: 10),
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    Expanded(
                      child: Text(b, style: const TextStyle(fontSize: 12.5, height: 1.5, color: AppTheme.textSecondary)),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
