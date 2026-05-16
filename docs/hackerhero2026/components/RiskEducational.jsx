// Aura — Páginas de Risco V2 (versão educativa)
// Mudança de tom:
//  - "Alertas" → "Acompanhamento de hoje"
//  - "Recomendações" → "Como conversar com [nome]" (sugestões de diálogo)
//  - "Pode ser" → "Por que a Aura classifica assim" (explica o critério interno)
//  - Adiciona explainer de como o sistema define os 3 níveis
//  - Pais NÃO configuram — a Aura decide; pais leem e dialogam

const AURA_EVENTS = {
  high: [{
    id: 'h1', kid: 'Lucas', time: '14h32', date: 'hoje', game: 'Roblox · Aventuras',
    headline: 'Mecânica de aposta identificada',
    summary: 'A Aura encontrou padrões de cassino dentro do jogo.',
    perceived: 'Durante a sessão de Lucas no Roblox, a Aura identificou uma interface de roleta giratória, contagem regressiva e mensagens incentivando a "tentar de novo" após perdas. Esses padrões são associados a jogos de azar.',
    why: [
      'Roletas, jackpots e contagens regressivas',
      'Moeda comprada com dinheiro real',
      'Mensagens de "tente de novo" após perdas',
    ],
    talk: [
      'Pergunte como Lucas se sentiu quando "perdeu" no jogo',
      'Conte que jogos imitam cassinos de propósito — não é culpa dele querer continuar',
      'Combinem juntos um limite de gastos na loja',
    ],
  }, {
    id: 'h2', kid: 'Lucas', time: '12h08', date: 'hoje', game: 'Discord (no jogo)',
    headline: 'Contato com pessoa desconhecida',
    summary: 'Um adulto sem amizade prévia tentou iniciar conversa privada.',
    perceived: 'A Aura observou mensagens de um usuário que não está na lista de amigos do Lucas. O conteúdo pedia para mudar de canal e perguntava sobre escola e cidade.',
    why: [
      'Contato não solicitado de alguém fora da rede de amigos',
      'Pedido para ir a um canal privado',
      'Perguntas sobre dados pessoais (escola, cidade)',
    ],
    talk: [
      'Reforce que adultos não procuram crianças para amizade online',
      'Mostre como bloquear e reportar — peça para ele fazer junto',
      'Garanta que ele pode contar qualquer interação estranha sem ser repreendido',
    ],
  }],
  medium: [{
    id: 'm1', kid: 'Lucas', time: '09h21', date: 'hoje', game: 'Minecraft · Servidor público',
    headline: 'Linguagem ofensiva no chat',
    summary: 'Algumas palavras de baixo calão aparecem em chats de servidores públicos.',
    perceived: 'Em um servidor público do Minecraft, a Aura percebeu uso de palavras de baixo calão por outros jogadores nas mensagens recebidas pelo Lucas.',
    why: [
      'Servidor público sem moderação ativa',
      'Chat aberto com adultos e adolescentes',
    ],
    talk: [
      'Pergunte se ele já viu palavras assim — e o que achou',
      'Existe diferença entre servidores com moderação infantil',
      'Vocês podem buscar juntos servidores com classificação família',
    ],
  }],
  low: [{
    id: 'l1', kid: 'Sofia', time: '16h05', date: 'ontem', game: 'Candy Crush',
    headline: 'Sessão longa sem pausa',
    summary: 'Sofia passou cerca de 2 horas seguidas no jogo.',
    perceived: 'A sessão de Sofia ficou acima da média semanal sem nenhuma pausa registrada. Não foi observado conteúdo problemático.',
    why: [
      'Tempo contínuo elevado',
      'Sem pausas durante a sessão',
    ],
    talk: [
      'Combine com Sofia uma pausa visual a cada 30min',
      'Sem repreender — tempo de jogo é normal, só pausa ajuda a saúde',
    ],
  }],
};

const RISK_LEVELS_INFO = {
  low: {
    name: 'Risco Baixo',
    color: '#16a34a', soft: '#d1fae5', textSoft: '#065f46',
    one: 'Pode ser comum, vale uma conversa leve.',
    examples: 'Tempo de tela longo · anúncios fora do contexto · pausa sugerida',
  },
  medium: {
    name: 'Risco Médio',
    color: '#ea580c', soft: '#ffedd5', textSoft: '#9a3412',
    one: 'Merece atenção e uma conversa direta.',
    examples: 'Linguagem ofensiva · chat público com adultos · conteúdo limítrofe',
  },
  high: {
    name: 'Risco Alto',
    color: '#dc2626', soft: '#fee2e2', textSoft: '#991b1b',
    one: 'Precisa de conversa hoje, sem julgar a criança.',
    examples: 'Apostas · contato com desconhecidos · conteúdo adulto · aliciamento',
  },
};

// ─────────────────────────────────────────────────────────────────────
// LIST: tela principal — "Acompanhamento de hoje"
// ─────────────────────────────────────────────────────────────────────
function RiskEducationalList({ tweaks }) {
  const { theme } = useAura(tweaks);
  const totals = {
    high: AURA_EVENTS.high.length,
    medium: AURA_EVENTS.medium.length,
    low: AURA_EVENTS.low.length,
  };
  const all = ['high', 'medium', 'low']
    .flatMap((lvl) => AURA_EVENTS[lvl].map((e) => ({ ...e, level: lvl })));

  return (
    <Phone>
      <NavBar theme={theme} />
      <div style={{ flex: 1, overflowY: 'auto', padding: '18px 18px 28px' }}>
        {/* Header */}
        <div style={{ marginBottom: 16 }}>
          <a style={{ fontSize: 12, color: theme.primary600, fontWeight: 700, textDecoration: 'none' }}>← Voltar</a>
          <div style={{ fontSize: 22, fontWeight: 800, color: theme.primary900, letterSpacing: -0.6, marginTop: 6 }}>
            Acompanhamento
          </div>
          <div style={{ fontSize: 12.5, color: '#6b7280', marginTop: 3 }}>
            Lucas · sexta, 16 de maio
          </div>
        </div>

        {/* Educational intro card */}
        <div style={{
          background: '#fff',
          border: `1px solid ${theme.primary100}`,
          borderLeft: `3px solid ${theme.primary600}`,
          borderRadius: 12,
          padding: '12px 14px',
          marginBottom: 18,
          display: 'flex', gap: 11, alignItems: 'flex-start',
        }}>
          <div style={{
            width: 30, height: 30, borderRadius: 9,
            background: theme.primary600, color: '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 14, flexShrink: 0,
          }}>✦</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 12.5, fontWeight: 800, color: theme.primary900, marginBottom: 2 }}>
              A Aura decide os níveis para você
            </div>
            <div style={{ fontSize: 11.5, color: '#4b5563', lineHeight: 1.5 }}>
              Sem palavras-chave para configurar. A IA classifica cada interação em baixo, médio ou alto risco com base em literatura sobre segurança infantil.
            </div>
            <a style={{
              display: 'inline-block', marginTop: 6,
              fontSize: 11, fontWeight: 700, color: theme.primary600,
              textDecoration: 'none',
            }}>Entender os níveis →</a>
          </div>
        </div>

        {/* Totals — soft, not alarmist */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 8, marginBottom: 18 }}>
          {['high', 'medium', 'low'].map((lvl) => {
            const info = RISK_LEVELS_INFO[lvl];
            return (
              <div key={lvl} style={{
                background: '#fff',
                border: `1px solid ${info.color}22`,
                borderTop: `3px solid ${info.color}`,
                borderRadius: 12,
                padding: '11px 11px 10px',
                textAlign: 'center',
              }}>
                <div style={{ fontSize: 26, fontWeight: 800, color: info.color, letterSpacing: -1, lineHeight: 1 }}>
                  {totals[lvl]}
                </div>
                <div style={{ fontSize: 10.5, color: '#374151', fontWeight: 700, marginTop: 4, letterSpacing: 0.2 }}>
                  {info.name.split(' ')[1]}
                </div>
              </div>
            );
          })}
        </div>

        {/* Section title */}
        <div style={{
          fontSize: 12, fontWeight: 800, color: '#6b7280',
          letterSpacing: 0.6, textTransform: 'uppercase',
          marginBottom: 10,
        }}>
          O que aconteceu
        </div>

        {/* Event list — chronological, calm */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {all.map((e) => (
            <EventCard key={e.id} event={e} theme={theme} />
          ))}
        </div>

        {/* Footer note */}
        <div style={{
          marginTop: 22, padding: '14px 14px',
          background: theme.primary50, borderRadius: 12,
          fontSize: 11.5, color: theme.primary900, lineHeight: 1.55,
          border: `1px solid ${theme.primary100}`,
        }}>
          <strong style={{ fontWeight: 800 }}>✦ Sempre vísivel para a criança</strong><br/>
          Lucas vê o ícone <strong>✦</strong> na tela toda vez que está jogando — ele sabe que você está acompanhando.
        </div>
      </div>
    </Phone>
  );
}

function EventCard({ event, theme }) {
  const info = RISK_LEVELS_INFO[event.level];
  return (
    <div style={{
      background: '#fff',
      border: '1px solid #f3f4f6',
      borderLeft: `3px solid ${info.color}`,
      borderRadius: 12,
      padding: '13px 14px',
      cursor: 'pointer',
      transition: 'border-color .15s, box-shadow .15s',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginBottom: 6 }}>
        <span style={{
          display: 'inline-flex', alignItems: 'center', gap: 5,
          background: info.soft, color: info.textSoft,
          padding: '2px 8px', borderRadius: 999,
          fontSize: 10.5, fontWeight: 800,
          letterSpacing: 0.3,
        }}>
          <span style={{ width: 5, height: 5, borderRadius: '50%', background: info.color }} />
          {info.name}
        </span>
        <span style={{ fontSize: 11, color: '#9ca3af', fontWeight: 600 }}>
          {event.time} · {event.kid}
        </span>
      </div>
      <div style={{ fontSize: 14, fontWeight: 800, color: '#111827', letterSpacing: -0.2, marginBottom: 3 }}>
        {event.headline}
      </div>
      <div style={{ fontSize: 12, color: '#4b5563', lineHeight: 1.45, marginBottom: 8 }}>
        {event.summary}
      </div>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ fontSize: 11, color: '#9ca3af' }}>🎮 {event.game}</div>
        <a style={{
          fontSize: 11.5, fontWeight: 700, color: theme.primary600,
          display: 'inline-flex', alignItems: 'center', gap: 3,
        }}>
          Descubra o que significa →
        </a>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────
// DETAIL: drawer educativo (3 seções)
// ─────────────────────────────────────────────────────────────────────
function RiskEducationalDetail({ tweaks }) {
  const { theme } = useAura(tweaks);
  const event = AURA_EVENTS.high[0];
  const info = RISK_LEVELS_INFO.high;

  return (
    <Phone>
      <NavBar theme={theme} />
      {/* Dimmed page behind */}
      <div style={{
        flex: 1, padding: '18px 18px 0',
        opacity: 0.25, filter: 'blur(0.5px)', overflow: 'hidden',
      }}>
        <div style={{ fontSize: 22, fontWeight: 800, color: theme.primary900 }}>Acompanhamento</div>
      </div>
      <div style={{ position: 'absolute', inset: '60px 0 0 0', background: 'rgba(45,0,34,0.5)' }} />

      {/* Drawer */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        background: '#fff',
        borderTopLeftRadius: 22, borderTopRightRadius: 22,
        boxShadow: '0 -8px 36px rgba(0,0,0,0.28)',
        maxHeight: '88%', display: 'flex', flexDirection: 'column',
      }}>
        {/* Drawer handle */}
        <div style={{ padding: '10px 0 0', display: 'flex', justifyContent: 'center' }}>
          <div style={{ width: 40, height: 4, background: '#e5e7eb', borderRadius: 999 }} />
        </div>

        {/* Header */}
        <div style={{ padding: '14px 18px 14px', borderBottom: '1px solid #f3f4f6' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
            <span style={{
              display: 'inline-flex', alignItems: 'center', gap: 5,
              background: info.soft, color: info.textSoft,
              padding: '3px 10px', borderRadius: 999,
              fontSize: 10.5, fontWeight: 800,
            }}>
              <span style={{ width: 5, height: 5, borderRadius: '50%', background: info.color }} />
              {info.name}
            </span>
            <span style={{ fontSize: 11, color: '#6b7280', fontWeight: 600 }}>
              {event.time} · {event.kid}
            </span>
          </div>
          <div style={{ fontSize: 17, fontWeight: 800, color: '#111827', letterSpacing: -0.4, lineHeight: 1.25 }}>
            {event.headline}
          </div>
          <div style={{ fontSize: 12, color: '#6b7280', marginTop: 4 }}>
            🎮 {event.game}
          </div>
        </div>

        <div style={{ flex: 1, overflowY: 'auto', padding: '16px 18px 18px' }}>
          {/* 1 — O que a Aura percebeu */}
          <EduSection
            n="01" title="O que a Aura percebeu" sub="Descrição neutra do que apareceu"
            theme={theme}
          >
            <div style={{ fontSize: 12.5, color: '#374151', lineHeight: 1.55 }}>
              {event.perceived}
            </div>
            <div style={{
              marginTop: 10, padding: '8px 10px',
              background: '#f9fafb', border: '1px solid #f3f4f6',
              borderRadius: 8, fontSize: 11, color: '#6b7280',
              display: 'flex', alignItems: 'center', gap: 6,
            }}>
              <span>✦</span>
              Mistral Vision · imagem destruída após análise
            </div>
          </EduSection>

          {/* 2 — Por que classificamos assim */}
          <EduSection
            n="02" title="Por que a Aura classificou assim" sub="O critério vem da literatura sobre segurança infantil — você não precisa configurar nada"
            theme={theme}
          >
            <div style={{ display: 'flex', flexDirection: 'column', gap: 9 }}>
              {event.why.map((w, i) => (
                <div key={i} style={{
                  display: 'flex', alignItems: 'flex-start', gap: 10,
                  padding: '10px 12px',
                  background: '#fafafa',
                  border: '1px solid #f3f4f6',
                  borderRadius: 9,
                }}>
                  <span style={{
                    width: 18, height: 18, borderRadius: 5,
                    background: info.color, color: '#fff',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontSize: 9.5, fontWeight: 800,
                    flexShrink: 0, marginTop: 1,
                  }}>{i + 1}</span>
                  <span style={{ fontSize: 12.5, color: '#374151', lineHeight: 1.5 }}>{w}</span>
                </div>
              ))}
            </div>
          </EduSection>

          {/* 3 — Como conversar com [nome] */}
          <div style={{
            background: theme.primary50,
            border: `1px solid ${theme.primary100}`,
            borderLeft: `4px solid ${theme.primary600}`,
            borderRadius: 12,
            padding: '14px 14px 16px 16px',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 9, marginBottom: 4 }}>
              <span style={{
                width: 22, height: 22, borderRadius: 6,
                background: theme.primary600, color: '#fff',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 10.5, fontWeight: 800,
              }}>03</span>
              <span style={{ fontSize: 13, fontWeight: 800, color: theme.primary900, letterSpacing: -0.2 }}>
                Como conversar com {event.kid}
              </span>
            </div>
            <div style={{ fontSize: 10.5, color: theme.primary700, marginBottom: 12, marginLeft: 31, fontStyle: 'italic' }}>
              Sugestões de diálogo · você decide se e como usar
            </div>
            <ol style={{ listStyle: 'none', padding: 0, margin: 0, display: 'flex', flexDirection: 'column', gap: 9 }}>
              {event.talk.map((t, i) => (
                <li key={i} style={{
                  display: 'flex', alignItems: 'flex-start', gap: 10,
                  fontSize: 12.5, color: theme.primary900, lineHeight: 1.5,
                }}>
                  <span style={{ color: theme.primary600, fontWeight: 800, flexShrink: 0 }}>{i + 1}.</span>
                  <span>{t}</span>
                </li>
              ))}
            </ol>
          </div>

          {/* Footer disclaimer */}
          <div style={{
            marginTop: 16, padding: '11px 12px',
            background: '#fafafa', borderRadius: 10,
            fontSize: 10.5, color: '#6b7280', lineHeight: 1.55,
            border: '1px solid #f3f4f6',
          }}>
            A Aura é uma ferramenta de apoio à conversa, não substitui acompanhamento profissional. Em situações graves, busque o Disque 100 ou SaferNet.
          </div>
        </div>
      </div>
    </Phone>
  );
}

function EduSection({ n, title, sub, theme, children }) {
  return (
    <div style={{ marginBottom: 16 }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10, marginBottom: 8 }}>
        <span style={{
          width: 22, height: 22, borderRadius: 6,
          background: '#f3f4f6', color: '#6b7280',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 10.5, fontWeight: 800, flexShrink: 0,
        }}>{n}</span>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 13, fontWeight: 800, color: '#111827', letterSpacing: -0.2 }}>{title}</div>
          {sub && <div style={{ fontSize: 10.5, color: '#6b7280', marginTop: 2, fontStyle: 'italic', lineHeight: 1.4 }}>{sub}</div>}
        </div>
      </div>
      <div style={{ paddingLeft: 32 }}>{children}</div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────
// EXPLAINER: como a Aura define os 3 níveis (só leitura, sem configurar)
// ─────────────────────────────────────────────────────────────────────
function RiskLevelsExplainer({ tweaks }) {
  const { theme } = useAura(tweaks);
  return (
    <Phone>
      <NavBar theme={theme} />
      <div style={{ flex: 1, overflowY: 'auto', padding: '18px 18px 28px' }}>
        <a style={{ fontSize: 12, color: theme.primary600, fontWeight: 700, textDecoration: 'none' }}>← Voltar</a>
        <div style={{ fontSize: 22, fontWeight: 800, color: theme.primary900, letterSpacing: -0.6, marginTop: 6 }}>
          Como funcionam os níveis
        </div>
        <div style={{ fontSize: 12.5, color: '#6b7280', marginTop: 6, lineHeight: 1.55 }}>
          Você <strong style={{ color: theme.primary900 }}>não precisa configurar nada</strong>. A Aura classifica cada interação em um dos três níveis com base em literatura sobre segurança infantil online.
        </div>

        <div style={{ marginTop: 22, display: 'flex', flexDirection: 'column', gap: 12 }}>
          {['high', 'medium', 'low'].map((lvl) => {
            const info = RISK_LEVELS_INFO[lvl];
            return (
              <div key={lvl} style={{
                background: '#fff',
                border: `1px solid ${info.color}22`,
                borderTop: `4px solid ${info.color}`,
                borderRadius: 14,
                padding: '16px 16px 14px',
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 9, marginBottom: 6 }}>
                  <span style={{
                    width: 26, height: 26, borderRadius: '50%',
                    background: info.color, color: '#fff',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontSize: 13, fontWeight: 800, fontFamily: 'ui-monospace, monospace',
                  }}>{lvl === 'high' ? 'A' : lvl === 'medium' ? 'M' : 'B'}</span>
                  <span style={{ fontSize: 15.5, fontWeight: 800, color: info.color }}>{info.name}</span>
                </div>
                <div style={{ fontSize: 13, fontWeight: 700, color: '#111827', marginBottom: 6 }}>
                  {info.one}
                </div>
                <div style={{
                  fontSize: 11.5, color: '#4b5563', lineHeight: 1.5,
                  paddingTop: 8, borderTop: '1px solid #f3f4f6',
                  marginTop: 4,
                }}>
                  <span style={{ fontWeight: 700, color: '#6b7280', fontSize: 10.5, textTransform: 'uppercase', letterSpacing: 0.4 }}>
                    Exemplos
                  </span>
                  <div style={{ marginTop: 4 }}>{info.examples}</div>
                </div>
              </div>
            );
          })}
        </div>

        {/* Notification preview */}
        <div style={{
          marginTop: 22, padding: '14px 14px',
          background: theme.primary50,
          border: `1px solid ${theme.primary100}`,
          borderRadius: 12,
        }}>
          <div style={{ fontSize: 11, fontWeight: 800, color: theme.primary700, letterSpacing: 0.6, textTransform: 'uppercase', marginBottom: 8 }}>
            ✦ Você receberá algo assim
          </div>
          <div style={{
            background: '#fff',
            border: '1px solid #f3f4f6',
            borderRadius: 10,
            padding: '11px 12px',
            display: 'flex', gap: 10,
          }}>
            <div style={{
              width: 30, height: 30, borderRadius: 8,
              background: theme.primary600, color: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 14, fontWeight: 700, flexShrink: 0,
            }}>✦</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 11, fontWeight: 700, color: '#374151' }}>
                Aura · agora
              </div>
              <div style={{ fontSize: 12.5, color: '#111827', fontWeight: 600, marginTop: 1, lineHeight: 1.4 }}>
                Seu filho teve uma interação de risco baixo. Descubra o que isso significa.
              </div>
            </div>
          </div>
          <div style={{ fontSize: 10.5, color: '#6b7280', marginTop: 8, fontStyle: 'italic', lineHeight: 1.4 }}>
            Tom educativo, nunca alarmista. Apenas texto — nenhuma imagem é enviada.
          </div>
        </div>

        {/* Transparency footer */}
        <div style={{
          marginTop: 18, padding: '14px 14px',
          background: '#fafafa', borderRadius: 12,
          fontSize: 11.5, color: '#4b5563', lineHeight: 1.55,
          border: '1px solid #f3f4f6',
        }}>
          <strong style={{ color: '#111827', fontWeight: 800 }}>Transparência com a criança</strong><br/>
          Toda vez que seu filho joga, ele vê o ícone <strong style={{ color: theme.primary600 }}>✦ Aura</strong> na tela. Ele sabe que você está acompanhando — sem segredos.
        </div>
      </div>
    </Phone>
  );
}

Object.assign(window, {
  RiskEducationalList, RiskEducationalDetail, RiskLevelsExplainer,
  AURA_EVENTS, RISK_LEVELS_INFO,
});
