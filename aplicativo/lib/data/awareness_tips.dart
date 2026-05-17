import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Conteúdo educacional para os responsáveis.
/// Foco em orientação prática, não em descrição de conteúdo do filho.

class AwarenessTip {
  final String id;
  final IconData icon;
  final Color color;
  final String category;
  final String title;
  final String summary;
  final List<AwarenessSection> sections;
  final String source;
  final String? sourceUrl;

  const AwarenessTip({
    required this.id,
    required this.icon,
    required this.color,
    required this.category,
    required this.title,
    required this.summary,
    required this.sections,
    required this.source,
    this.sourceUrl,
  });
}

class AwarenessSection {
  final String title;
  final String body;
  final List<String>? bullets;
  const AwarenessSection({required this.title, required this.body, this.bullets});
}

class AwarenessTipsData {
  static const List<AwarenessTip> tips = [
    AwarenessTip(
      id: 'comunicacao',
      icon: Icons.chat_bubble_outline,
      color: AppTheme.primary,
      category: 'Comunicação',
      title: 'Conversando sobre internet com seu filho',
      summary: 'Como criar um ambiente de confiança para que ele venha até você antes de problemas acontecerem.',
      sections: [
        AwarenessSection(
          title: 'Por que isso importa',
          body: 'A maioria dos riscos online vira tragédia quando a criança tem vergonha ou medo de contar. Um ambiente de diálogo aberto é a melhor proteção — mais do que qualquer ferramenta.',
        ),
        AwarenessSection(
          title: 'Princípios para conversar',
          body: 'Não tente ter "a conversa". Crie pequenos momentos de diálogo no dia a dia. Pergunte sobre os jogos, os criadores que ele assiste, os amigos online. Demonstre curiosidade genuína, não inquisição.',
          bullets: [
            'Pergunte sobre o que ele gosta, não sobre o que você teme',
            'Ouça mais do que fala',
            'Compartilhe suas próprias experiências (boas e ruins) com tecnologia',
            'Não reaja com pânico — isso fecha a porta para conversas futuras',
            'Reforce que você está do lado dele, sempre',
          ],
        ),
        AwarenessSection(
          title: 'Frases que ajudam',
          body: 'Use perguntas abertas em vez de respostas prontas:',
          bullets: [
            '"O que você acha disso?"',
            '"Já viu alguma coisa estranha online?"',
            '"Como você reage quando algo te incomoda?"',
            '"Você sabe que pode me contar qualquer coisa, né?"',
          ],
        ),
      ],
      source: 'Adaptado de SaferNet Brasil — Guia de Pais',
      sourceUrl: 'https://new.safernet.org.br',
    ),

    AwarenessTip(
      id: 'grooming',
      icon: Icons.shield_outlined,
      color: AppTheme.danger,
      category: 'Proteção',
      title: 'Sinais de aliciamento online (grooming)',
      summary: 'Aprenda a reconhecer padrões de manipulação que predadores usam em jogos e redes sociais.',
      sections: [
        AwarenessSection(
          title: 'O que é grooming',
          body: 'Grooming é o processo gradual em que um adulto se aproxima de uma criança online com intenção de exploração. Costuma começar com amizade aparentemente inofensiva, presentes virtuais e elogios constantes.',
        ),
        AwarenessSection(
          title: 'Sinais de alerta no comportamento do seu filho',
          body: 'Mudanças sutis muitas vezes indicam que algo está acontecendo:',
          bullets: [
            'Esconde a tela quando você se aproxima',
            'Fica ansioso ou irritado se você pede para ver o celular',
            'Recebe presentes virtuais (skins, V-Bucks, Robux) sem explicar de onde vieram',
            'Fala de um "amigo" online que você nunca conheceu',
            'Passa cada vez mais tempo isolado conversando',
            'Usa linguagem ou termos novos, mais adultos',
          ],
        ),
        AwarenessSection(
          title: 'O que fazer se desconfiar',
          body: 'Não confronte com raiva. A criança pode se sentir culpada e fechar.',
          bullets: [
            'Mostre que você está preocupado, não com raiva dela',
            'Documente conversas (prints) sem deletar',
            'Procure a delegacia especializada (DECIPP) ou denuncie pelo SaferNet',
            'Considere apoio psicológico — grooming deixa marcas mesmo sem contato físico',
          ],
        ),
      ],
      source: 'SaferNet Brasil + Childhood Brasil',
      sourceUrl: 'https://new.safernet.org.br/canal-de-ajuda',
    ),

    AwarenessTip(
      id: 'microtransacoes',
      icon: Icons.attach_money,
      color: AppTheme.warning,
      category: 'Financeiro',
      title: 'Microtransações: ensinando o valor do dinheiro',
      summary: 'V-Bucks, Robux, skins... como evitar que jogos virem armadilhas financeiras.',
      sections: [
        AwarenessSection(
          title: 'O problema',
          body: 'Jogos free-to-play são desenhados por psicólogos para maximizar gastos impulsivos. Crianças e adolescentes têm o sistema de recompensa cerebral em desenvolvimento, o que os torna especialmente vulneráveis a essas mecânicas.',
        ),
        AwarenessSection(
          title: 'Mecânicas que pais devem conhecer',
          body: 'Entender as armadilhas ajuda a explicar para a criança:',
          bullets: [
            'Loot boxes / gachas — caixas surpresa com chance aleatória (semelhante a apostas)',
            'FOMO (Fear Of Missing Out) — itens "por tempo limitado"',
            'Battle Pass — pressão por jogar todo dia para "não desperdiçar"',
            'Moedas virtuais — desconectam a percepção do gasto real',
          ],
        ),
        AwarenessSection(
          title: 'Estratégias práticas',
          body: '',
          bullets: [
            'Configure senha obrigatória para qualquer compra na Google Play / App Store',
            'Use cartão pré-pago para limitar o teto',
            'Estabeleça um orçamento mensal para gastos em jogos',
            'Combine: para cada R\$ 10 gastos, ele guarda R\$ 5 numa "poupança"',
            'Mostre quanto custaria comprar algo real com o valor das skins',
          ],
        ),
      ],
      source: 'WHO + Common Sense Media',
      sourceUrl: 'https://www.commonsensemedia.org',
    ),

    AwarenessTip(
      id: 'cyberbullying',
      icon: Icons.sentiment_dissatisfied,
      color: AppTheme.danger,
      category: 'Bem-estar',
      title: 'Cyberbullying: como agir',
      summary: 'Quando seu filho é alvo — ou autor — de comportamento agressivo online.',
      sections: [
        AwarenessSection(
          title: 'Como identificar que seu filho é alvo',
          body: 'Sintomas comportamentais muitas vezes aparecem antes da criança contar:',
          bullets: [
            'Queda no rendimento escolar',
            'Evita o celular ou checa compulsivamente',
            'Mudanças de humor, irritabilidade, isolamento',
            'Problemas para dormir, perda de apetite',
            'Resistência em ir à escola ou eventos sociais',
          ],
        ),
        AwarenessSection(
          title: 'Se ele é alvo',
          body: 'Sua reação inicial define se a criança vai voltar a confiar em você no futuro.',
          bullets: [
            'Acolha primeiro, resolva depois — "Que coisa difícil, obrigado por contar"',
            'Não tire o celular como "solução" — isso só ensina que vir até você tem custo',
            'Documente (prints, screenshots) antes de bloquear o agressor',
            'Em casos graves, registre BO — cyberbullying é crime (Lei 13.185/2015)',
            'Considere apoio psicológico — sequelas podem durar anos',
          ],
        ),
        AwarenessSection(
          title: 'Se ele é o autor',
          body: 'Crianças que praticam bullying online geralmente também estão em sofrimento. Evite punir, busque entender.',
          bullets: [
            'Não negue — leia as evidências com calma antes de conversar',
            'Pergunte o que motivou (não justifica, mas explica)',
            'Mostre o impacto humano — a outra criança também tem família, sente medo',
            'Combine reparação: pedido de desculpa, deletar o post',
            'Acompanhamento profissional pode ser útil',
          ],
        ),
      ],
      source: 'Childhood Brasil + Lei 13.185/2015',
      sourceUrl: 'https://www.childhood.org.br',
    ),

    AwarenessTip(
      id: 'tempo-tela',
      icon: Icons.access_time,
      color: AppTheme.accent,
      category: 'Saúde',
      title: 'Tempo de tela saudável por idade',
      summary: 'Recomendações da Sociedade Brasileira de Pediatria para uso de telas.',
      sections: [
        AwarenessSection(
          title: 'Recomendações SBP 2024',
          body: 'A Sociedade Brasileira de Pediatria atualizou as diretrizes em 2024. Resumo por faixa etária:',
          bullets: [
            'Até 2 anos: evitar completamente, exceto videochamadas com família',
            '2 a 5 anos: máximo 1 hora/dia, sempre acompanhado',
            '6 a 10 anos: máximo 1-2 horas/dia, com pausas',
            '11 a 18 anos: máximo 2-3 horas/dia (excluindo escola)',
            'Nunca: telas durante refeições, 1 hora antes de dormir, ou no quarto à noite',
          ],
        ),
        AwarenessSection(
          title: 'Sinais de uso problemático',
          body: 'Não é só o tempo — é o impacto:',
          bullets: [
            'Irritação ou explosões quando precisa parar',
            'Perda de interesse por atividades que antes gostava',
            'Dificuldade em dormir ou pesadelos frequentes',
            'Mente sobre quanto tempo gastou',
            'Atrasos escolares ou queda de notas',
            'Dores físicas — cabeça, pescoço, vista',
          ],
        ),
        AwarenessSection(
          title: 'Estratégias práticas',
          body: '',
          bullets: [
            'Defina horários, não só limites totais (ex: nada antes de tarefa)',
            'Use a regra 20-20-20 — a cada 20min, olhe 20 segundos para 20m de distância',
            'Compense tela com atividades físicas — 1h fora para 1h de jogo',
            'Modele o comportamento — guarde seu celular também',
            'Crie zonas livres de tela na casa (mesa, quartos)',
          ],
        ),
      ],
      source: 'Sociedade Brasileira de Pediatria — Manual #MenosTelas2024',
      sourceUrl: 'https://www.sbp.com.br',
    ),

    AwarenessTip(
      id: 'apps-recomendados',
      icon: Icons.thumb_up_outlined,
      color: AppTheme.safe,
      category: 'Descoberta',
      title: 'Apps e jogos recomendados por faixa etária',
      summary: 'Em vez de só proibir, ofereça boas opções. Curadoria por idade.',
      sections: [
        AwarenessSection(
          title: 'A ideia',
          body: 'Crianças e adolescentes vão usar telas — a questão é o que vão consumir. Ter uma lista de opções aprovadas reduz a fricção das conversas e mostra que você se preocupa, não só restringe.',
        ),
        AwarenessSection(
          title: '4 a 7 anos',
          body: 'Foco em criatividade, motricidade e narrativas simples:',
          bullets: [
            'Toca Boca World — exploração criativa, sem competição',
            'Khan Academy Kids — alfabetização e matemática',
            'Sago Mini — brincadeiras educativas',
            'PlayKids — desenhos curados, sem ads',
          ],
        ),
        AwarenessSection(
          title: '8 a 12 anos',
          body: 'Jogos cooperativos, programação básica, descoberta:',
          bullets: [
            'Minecraft (modo criativo) — construção, lógica espacial',
            'Scratch / Scratch Jr — programação visual',
            'Stardew Valley — agricultura, cooperação, sem violência',
            'Animal Crossing — vida social positiva',
            'Duolingo — idiomas em formato lúdico',
          ],
        ),
        AwarenessSection(
          title: '13 anos +',
          body: 'Mais autonomia, mas continue acompanhando:',
          bullets: [
            'Minecraft (multiplayer privado com amigos da escola)',
            'Roblox — com configurações de privacidade rigorosas',
            'Discord — só em servidores conhecidos',
            'Cursos online — Coursera, edX, Khan Academy',
            'Ferramentas criativas — Canva, GarageBand, Procreate',
          ],
        ),
        AwarenessSection(
          title: 'O que evitar até pelo menos 16 anos',
          body: 'Mesmo que os amigos usem:',
          bullets: [
            'Apps de aposta disfarçados de jogos',
            'Redes sociais com DM aberto a desconhecidos',
            'Jogos com chat de voz com estranhos sem moderação',
            'Conteúdo de criadores que monetizam polêmica e raiva',
          ],
        ),
      ],
      source: 'Common Sense Media + Curadoria editorial',
      sourceUrl: 'https://www.commonsensemedia.org',
    ),
  ];

  static AwarenessTip? byId(String id) {
    try {
      return tips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
