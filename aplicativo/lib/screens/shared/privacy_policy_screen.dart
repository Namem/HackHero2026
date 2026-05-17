import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Tela de Termos de Uso e Política de Privacidade — conformidade LGPD.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        title: const Text('Privacidade e Termos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            const _Header(
              icon: Icons.shield_outlined,
              title: 'Sua privacidade é prioridade',
              subtitle: 'O Aura foi desenhado para coletar o mínimo possível e armazenar nada que possa expor seu filho.',
            ),
            const SizedBox(height: 20),

            _Section(
              number: '1',
              title: 'Quem somos',
              body: const [
                'O Aura é um aplicativo de monitoramento parental que ajuda você a proteger seu filho em ambientes digitais.',
                'Para fins da LGPD (Lei 13.709/2018), atuamos como controlador dos dados de cadastro e operador dos dados gerados pelo monitoramento, conforme a finalidade definida por você ao configurar o serviço.',
              ],
            ),

            _Section(
              number: '2',
              title: 'Quais dados coletamos',
              body: const [
                '• Conta: nome, e-mail e senha (armazenada com hash criptográfico).',
                '• Vinculação: código único de pareamento entre o seu celular e o do seu filho.',
                '• Dispositivo do filho: identificador anônimo (token) gerado no app, sem relação com IMEI/MAC.',
                '• Apps instalados no celular do filho: nome e identificador do app (package name). Não coletamos histórico de uso, mensagens ou conteúdos.',
                '• Capturas de tela em jogos monitorados: processadas exclusivamente em memória RAM para análise pela IA.',
                '• Alertas: categoria de risco, nível (alto / médio / baixo), horário e nome do app. Sempre em formato textual.',
              ],
            ),

            _Section(
              number: '3',
              title: 'O que NÃO coletamos',
              highlight: AppTheme.safe,
              body: const [
                '• Não armazenamos imagens, vídeos ou capturas de tela em disco ou banco de dados.',
                '• Não enviamos imagens para você (pai/responsável) — você só vê texto.',
                '• Não acessamos mensagens, contatos, localização, fotos pessoais ou arquivos.',
                '• Não vendemos, alugamos ou compartilhamos seus dados com terceiros para marketing.',
              ],
            ),

            _Section(
              number: '4',
              title: 'Como tratamos imagens',
              highlight: AppTheme.accent,
              body: const [
                'Quando seu filho abre um jogo monitorado, o app captura a tela em memória RAM.',
                'A imagem é enviada por HTTPS para o nosso servidor, processada pela IA de visão (Mistral AI) e destruída imediatamente após a análise.',
                'A imagem NUNCA é gravada em disco, banco de dados ou enviada a terceiros além do provedor da IA, que opera sob acordo de não-retenção de dados.',
                'O único registro que persiste é o alerta textual: categoria, nível e timestamp.',
              ],
            ),

            _Section(
              number: '5',
              title: 'Onde os dados ficam armazenados',
              body: const [
                'Dados de conta e alertas: banco PostgreSQL em servidor próprio, criptografado em repouso.',
                'Comunicação: 100% via HTTPS (TLS 1.3).',
                'Tokens de sessão: JWT armazenado no celular do usuário (não trafegam em URLs).',
                'Capturas de tela: NUNCA persistidas — RAM apenas.',
              ],
            ),

            _Section(
              number: '6',
              title: 'Quem tem acesso',
              body: const [
                'Você (pai/responsável): vê apenas os alertas textuais do seu filho vinculado.',
                'A IA (Mistral AI): processa a imagem em memória durante a análise e a descarta.',
                'Equipe técnica do Aura: pode acessar dados anonimizados para manutenção, sob termo de sigilo.',
                'Ninguém mais. Não compartilhamos com publicitários, governos (sem ordem judicial) ou parceiros comerciais.',
              ],
            ),

            _Section(
              number: '7',
              title: 'Transparência com a criança',
              body: const [
                'Conforme exigido pelo Art. 19 §1 da Lei 15.211/2025 (ECA Digital):',
                '• A criança recebe uma tela explicativa no primeiro uso, em linguagem apropriada.',
                '• Uma notificação fixa fica visível na barra de status enquanto o Aura está ativo.',
                '• Quando um jogo monitorado é aberto, uma notificação adicional avisa a criança.',
              ],
            ),

            _Section(
              number: '8',
              title: 'Seus direitos (LGPD Art. 18)',
              highlight: AppTheme.primaryLight,
              body: const [
                '• Acesso: você pode pedir uma cópia de todos os dados que temos sobre você.',
                '• Correção: pode atualizar nome, e-mail ou senha a qualquer momento.',
                '• Exclusão: pode apagar sua conta e todos os dados associados (botão "Excluir conta" no Perfil).',
                '• Portabilidade: pode solicitar seus dados em formato JSON estruturado.',
                '• Revogar consentimento: pode desativar o monitoramento a qualquer momento, sem prejuízo.',
                '• Reclamação: pode acionar a ANPD (Autoridade Nacional de Proteção de Dados) se discordar do tratamento.',
              ],
            ),

            _Section(
              number: '9',
              title: 'Tempo de retenção',
              body: const [
                'Alertas: 90 dias por padrão, podem ser excluídos a qualquer momento.',
                'Dados de conta: enquanto você mantiver a conta ativa.',
                'Logs técnicos: 30 dias para fins de segurança.',
                'Tudo é excluído permanentemente em até 15 dias após o pedido de exclusão da conta.',
              ],
            ),

            _Section(
              number: '10',
              title: 'Base legal',
              body: const [
                'Tratamos seus dados com base em:',
                '• Consentimento (LGPD Art. 7º I) — você concorda ao se cadastrar.',
                '• Proteção do menor (LGPD Art. 14) — interesse superior da criança e do adolescente.',
                '• Cumprimento de obrigação legal (LGPD Art. 7º II) — Lei 15.211/2025 (ECA Digital).',
              ],
            ),

            _Section(
              number: '11',
              title: 'Encarregado de dados (DPO)',
              body: const [
                'Em caso de dúvidas, exercício de direitos ou denúncias relacionadas à privacidade:',
                'E-mail: dpo@aura.app',
                'Resposta em até 15 dias úteis.',
              ],
            ),

            _Section(
              number: '12',
              title: 'Mudanças nesta política',
              body: const [
                'Podemos atualizar este texto. Mudanças relevantes serão notificadas dentro do app e por e-mail.',
                'A versão atual foi publicada em ${'17 de maio de 2026'}.',
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: AppTheme.primaryLight, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Conformidade: LGPD (Lei 13.709/2018), ECA Digital (Lei 15.211/2025) e Decreto 12.880/2026.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11.5, height: 1.4),
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
}

class _Header extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Header({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryLight, size: 28),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12.5, height: 1.4), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String number;
  final String title;
  final List<String> body;
  final Color? highlight;
  const _Section({required this.number, required this.title, required this.body, this.highlight});

  @override
  Widget build(BuildContext context) {
    final color = highlight ?? AppTheme.primaryLight;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(number, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final paragraph in body)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  paragraph,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12.5, height: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
