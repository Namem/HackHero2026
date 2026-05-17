// Aura — Alertas screen
// Variants:
//   AlertsScreen          — colapsáveis (alto aberto), drawer fechado
//   AlertsScreenDrawer    — mesmo + drawer de detalhe aberto sobre um card
//   AlertsScreenInline    — spec original, detalhe expandido inline no card
//   AlertsScreenTimeline  — variação: timeline vertical (sem colapso)
//   AlertsScreenEmpty     — estado vazio

const AURA_ALERTS = {
  high: [
    {
      id: 'a1',
      kid: 'Lucas',
      time: '14h32',
      date: 'hoje',
      game: 'Roblox · Aventuras',
      category: 'Apostas detectadas',
      summary: 'Mecânica de roleta com tokens premium identificada na sessão.',
      detection: 'A IA Vision detectou uma interface de roleta giratória oferecendo recompensas baseadas em "tokens premium" comprados com dinheiro real. O sistema mostra cores piscantes, contagem regressiva e mensagens incentivando recargas após perdas consecutivas.',
      causes: [
        'Mecânicas de loot box com moeda paga',
        'Padrões visuais de cassino (roletas, jackpots)',
        'Pressão por recarga após sequência de derrotas',
      ],
      recs: [
        'Conversar com Lucas sobre como jogos imitam cassinos para gerar gasto compulsivo',
        'Revisar limites de compra na loja do dispositivo',
        'Considerar pausar este jogo por 7 dias',
      ],
    },
    {
      id: 'a2',
      kid: 'Lucas',
      time: '12h08',
      date: 'hoje',
      game: 'Discord (em jogo)',
      category: 'Contato com desconhecido',
      summary: 'Usuário adulto tentou marcar encontro privado.',
      detection: 'Mensagens recebidas de um usuário sem amizade prévia solicitando vídeo-chamada privada e informações da escola. Linguagem aliciante identificada.',
      causes: [
        'Contato não solicitado por adulto',
        'Solicitação de dados pessoais (escola, endereço)',
        'Tentativa de mover conversa para canal privado',
      ],
      recs: [
        'Bloquear o usuário imediatamente no Discord',
        'Salvar capturas para denúncia ao SaferNet (cuidado: o Aura não armazena imagens)',
        'Conversar sem julgamento sobre aliciamento online',
      ],
    },
    {
      id: 'a3',
      kid: 'Théo',
      time: '11h45',
      date: 'hoje',
      game: 'GTA Online',
      category: 'Violência gráfica',
      summary: 'Conteúdo com sangue intenso e armas de fogo durante 14min.',
      detection: 'Sessão extensa em modo livre com armas. Categorizado como inadequado para faixa etária declarada (10 anos).',
      causes: [
        'Faixa etária declarada incompatível com PEGI 18',
        'Exposição prolongada (>10min) a violência',
      ],
      recs: [
        'Conferir classificação indicativa antes de instalar',
        'Aplicar restrição de idade na loja',
      ],
    },
  ],
  medium: [
    {
      id: 'm1', kid: 'Lucas', time: '09h21', date: 'hoje',
      game: 'Minecraft · Servidor público',
      category: 'Linguagem ofensiva no chat',
      summary: 'Palavras de baixo calão em chat público (3 ocorrências).',
      detection: 'Mensagens com xingamentos identificadas em chat de servidor público frequentado por adultos.',
      causes: ['Servidor sem moderação ativa', 'Chat público com adultos'],
      recs: ['Sugerir servidores com classificação infantil', 'Ativar filtro de chat do Minecraft'],
    },
    {
      id: 'm2', kid: 'Théo', time: '08h12', date: 'hoje',
      game: 'YouTube Kids (em jogo)',
      category: 'Anúncio fora do contexto',
      summary: 'Propaganda de produto adulto exibida durante sessão.',
      detection: 'Banner publicitário com temática adulta exibido em app marcado como infantil.',
      causes: ['Falha do filtro de anúncios', 'Conteúdo segmentado incorretamente'],
      recs: ['Reportar à plataforma', 'Verificar se YouTube Kids está atualizado'],
    },
  ],
  low: [
    {
      id: 'l1', kid: 'Sofia', time: '16h05', date: 'ontem',
      game: 'Candy Crush',
      category: 'Tempo de tela elevado',
      summary: 'Sessão de 2h sem pausa.',
      detection: 'Tempo contínuo acima da média semanal sem interrupção.',
      causes: ['Sem pausas durante a sessão'],
      recs: ['Configurar lembretes de pausa de 20min'],
    },
  ],
};

// ── Section header ─────────────────────────────────────────────────────────
function RiskSection({ level, count, open, onToggle, children }) {
  const styles = {
    high:   { grad: '#dc2626', emoji: '🔴', label: 'Risco Alto' },
    medium: { grad: '#ea580c', emoji: '🟡', label: 'Risco Médio' },
    low:    { grad: '#16a34a', emoji: '🟢', label: 'Risco Baixo' },
  }[level];
  return (
    <div style={{ marginBottom: 12, borderRadius: 14, overflow: 'hidden', boxShadow: '0 1px 3px rgba(0,0,0,.08)' }}>
      <button
        onClick={onToggle}
        style={{
          background: styles.grad, color: '#fff',
          padding: '13px 16px',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          width: '100%', border: 'none', cursor: 'pointer',
          fontFamily: 'inherit',
        }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <span style={{ fontSize: 14 }}>{styles.emoji}</span>
          <span style={{ fontSize: 14.5, fontWeight: 800, letterSpacing: -0.2 }}>{styles.label}</span>
          <span style={{
            background: 'rgba(255,255,255,0.22)',
            border: '1px solid rgba(255,255,255,0.30)',
            padding: '2px 9px', borderRadius: 999,
            fontSize: 11.5, fontWeight: 800,
          }}>{count}</span>
        </div>
        <span style={{
          fontSize: 11, transform: open ? 'rotate(180deg)' : 'rotate(0)',
          transition: 'transform .2s',
        }}>▾</span>
      </button>
      {open && (
        <div style={{ background: '#fff', padding: 10, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {children}
        </div>
      )}
    </div>
  );
}

// ── Alert card (collapsed) ─────────────────────────────────────────────────
function AlertCard({ alert, theme, level, onClick, expanded }) {
  const accent = level === 'high' ? '#dc2626' : level === 'medium' ? '#ea580c' : '#16a34a';
  return (
    <div
      onClick={onClick}
      style={{
        background: '#fff',
        border: `1.5px solid ${expanded ? theme.primary600 : '#f3f4f6'}`,
        borderLeft: `4px solid ${accent}`,
        borderRadius: 10,
        padding: '12px 14px',
        cursor: 'pointer',
        transition: 'border-color .15s, box-shadow .15s',
        boxShadow: expanded ? '0 6px 18px rgba(233,30,140,0.15)' : 'none',
      }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 10 }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
            <span style={{ fontSize: 11, color: '#6b7280', fontWeight: 600 }}>{alert.time} · {alert.date}</span>
            <span style={{ width: 3, height: 3, borderRadius: '50%', background: '#d1d5db' }} />
            <span style={{ fontSize: 11, color: '#6b7280', fontWeight: 600 }}>{alert.kid}</span>
          </div>
          <div style={{ fontSize: 14, fontWeight: 800, color: '#111827', letterSpacing: -0.2 }}>
            {alert.category}
          </div>
          <div style={{ fontSize: 12, color: '#4b5563', marginTop: 3, lineHeight: 1.4 }}>
            {alert.game}
          </div>
        </div>
        <span style={{ fontSize: 16, color: '#9ca3af' }}>›</span>
      </div>
    </div>
  );
}

// ── Detail body (used in drawer + inline) ──────────────────────────────────
function AlertDetailBody({ alert, theme, level }) {
  const accent = level === 'high' ? '#dc2626' : level === 'medium' ? '#ea580c' : '#16a34a';
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      {/* Section 1 — Detected */}
      <Sec
        icon="🔍" title="O que foi detectado"
        accent={accent}
      >
        <div style={{ fontSize: 12.5, color: '#374151', lineHeight: 1.55 }}>
          {alert.detection}
        </div>
        <div style={{
          marginTop: 10, padding: '8px 10px',
          background: '#f9fafb', border: '1px solid #f3f4f6',
          borderRadius: 8,
          fontSize: 11, color: '#6b7280',
          display: 'flex', alignItems: 'center', gap: 6,
        }}>
          <span style={{ fontSize: 12 }}>✦</span>
          Análise gerada por <strong style={{ color: '#374151' }}>Mistral Vision</strong> · imagem destruída após análise
        </div>
      </Sec>

      {/* Section 2 — Pode ser */}
      <Sec icon="💭" title="Pode ser" accent={accent}>
        <ul style={{ listStyle: 'none', padding: 0, margin: 0, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {alert.causes.map((c, i) => (
            <li key={i} style={{
              display: 'flex', alignItems: 'flex-start', gap: 9,
              fontSize: 12.5, color: '#374151', lineHeight: 1.5,
            }}>
              <span style={{
                width: 6, height: 6, borderRadius: '50%', background: accent,
                marginTop: 7, flexShrink: 0,
              }} />
              <span>{c}</span>
            </li>
          ))}
        </ul>
      </Sec>

      {/* Section 3 — Recomendações */}
      <div style={{
        background: theme.primary50,
        border: `1px solid ${theme.primary100}`,
        borderLeft: `4px solid ${theme.primary600}`,
        borderRadius: 10,
        padding: '14px 14px 14px 16px',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
          <span style={{ fontSize: 14 }}>✦</span>
          <span style={{ fontSize: 13, fontWeight: 800, color: theme.primary900 }}>Entenda e converse</span>
        </div>
        <div style={{ fontSize: 11, color: theme.primary700, marginBottom: 12, fontStyle: 'italic' }}>
          A Aura não decide por você — oferece informação para apoiar diálogo.
        </div>
        <ol style={{ listStyle: 'none', padding: 0, margin: 0, display: 'flex', flexDirection: 'column', gap: 10 }}>
          {alert.recs.map((r, i) => (
            <li key={i} style={{
              display: 'flex', alignItems: 'flex-start', gap: 10,
              fontSize: 12.5, color: theme.primary900, lineHeight: 1.5,
            }}>
              <span style={{
                width: 18, height: 18, borderRadius: '50%',
                background: theme.primary600, color: '#fff',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 10.5, fontWeight: 800, flexShrink: 0,
                marginTop: 1,
              }}>{i + 1}</span>
              <span>{r}</span>
            </li>
          ))}
        </ol>
      </div>
    </div>
  );
}

function Sec({ icon, title, accent, children }) {
  return (
    <div>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8,
      }}>
        <span style={{ fontSize: 13 }}>{icon}</span>
        <span style={{ fontSize: 12, fontWeight: 800, color: '#111827', letterSpacing: 0.2, textTransform: 'uppercase' }}>{title}</span>
      </div>
      {children}
    </div>
  );
}

// ── Page chrome shared by variants ─────────────────────────────────────────
function AlertsHeader({ theme, count }) {
  return (
    <div style={{ padding: '18px 18px 14px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
        <a style={{ fontSize: 12, color: theme.primary600, fontWeight: 700, textDecoration: 'none' }}>← Voltar</a>
      </div>
      <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between' }}>
        <div>
          <div style={{ fontSize: 22, fontWeight: 800, color: theme.primary900, letterSpacing: -0.6 }}>Alertas</div>
          <div style={{ fontSize: 12.5, color: '#6b7280', marginTop: 2 }}>
            Lucas · DVC-7F4A...9C2B · <span style={{ color: '#16a34a', fontWeight: 700 }}>● ativo</span>
          </div>
        </div>
        <div style={{
          background: '#fff', padding: '6px 12px', borderRadius: 999,
          border: '1px solid #f3f4f6', fontSize: 12, fontWeight: 700, color: '#111827',
        }}>{count} hoje</div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────
// VARIANT 1 — Default (colapsáveis, drawer fechado)
// ─────────────────────────────────────────────────────────────────────
function AlertsScreen({ tweaks }) {
  const { theme } = useAura(tweaks);
  const dataset = (tweaks?.alertsState === 'few')
    ? { high: AURA_ALERTS.high.slice(0, 1), medium: [], low: AURA_ALERTS.low }
    : (tweaks?.alertsState === 'empty')
      ? { high: [], medium: [], low: [] }
      : AURA_ALERTS;

  const [open, setOpen] = React.useState({ high: true, medium: false, low: false });
  if (tweaks?.alertsState === 'empty') return <AlertsScreenEmpty tweaks={tweaks} />;

  return (
    <Phone>
      <NavBar theme={theme} />
      <AlertsHeader theme={theme} count={dataset.high.length + dataset.medium.length + dataset.low.length} />
      <div style={{ flex: 1, overflowY: 'auto', padding: '0 16px 24px' }}>
        {['high', 'medium', 'low'].map((lvl) => (
          <RiskSection
            key={lvl} level={lvl} count={dataset[lvl].length}
            open={open[lvl]} onToggle={() => setOpen({ ...open, [lvl]: !open[lvl] })}
          >
            {dataset[lvl].length === 0 ? (
              <div style={{ fontSize: 12, color: '#9ca3af', padding: '10px 6px', textAlign: 'center' }}>
                Nenhum alerta neste nível
              </div>
            ) : dataset[lvl].map((a) => (
              <AlertCard key={a.id} alert={a} theme={theme} level={lvl} />
            ))}
          </RiskSection>
        ))}
      </div>
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────────────
// VARIANT 2 — Drawer aberto sobre a tela
// ─────────────────────────────────────────────────────────────────────
function AlertsScreenDrawer({ tweaks }) {
  const { theme } = useAura(tweaks);
  const alert = AURA_ALERTS.high[0];
  return (
    <Phone>
      <NavBar theme={theme} />
      <AlertsHeader theme={theme} count={6} />
      {/* Dimmed background list */}
      <div style={{ flex: 1, overflowY: 'hidden', padding: '0 16px 24px', filter: 'blur(0.5px)', opacity: 0.4 }}>
        <RiskSection level="high" count={3} open onToggle={() => {}}>
          {AURA_ALERTS.high.map((a) => <AlertCard key={a.id} alert={a} theme={theme} level="high" expanded={a.id === alert.id} />)}
        </RiskSection>
        <RiskSection level="medium" count={2} open={false} onToggle={() => {}} />
      </div>
      {/* Dim overlay */}
      <div style={{ position: 'absolute', inset: 0, background: 'rgba(45,0,34,0.45)', pointerEvents: 'none' }} />
      {/* Drawer */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        background: '#fff', borderTopLeftRadius: 22, borderTopRightRadius: 22,
        boxShadow: '0 -8px 36px rgba(0,0,0,0.25)',
        maxHeight: '78%', overflow: 'hidden',
        display: 'flex', flexDirection: 'column',
      }}>
        {/* Drawer header */}
        <div style={{ padding: '10px 0 0', display: 'flex', justifyContent: 'center' }}>
          <div style={{ width: 40, height: 4, background: '#e5e7eb', borderRadius: 999 }} />
        </div>
        <div style={{ padding: '14px 18px 12px', borderBottom: '1px solid #f3f4f6' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
            <RiskPill level="high" />
            <span style={{ fontSize: 11, color: '#6b7280', fontWeight: 600 }}>{alert.time} · {alert.kid}</span>
          </div>
          <div style={{ fontSize: 17, fontWeight: 800, color: '#111827', letterSpacing: -0.4 }}>
            {alert.category}
          </div>
          <div style={{ fontSize: 12.5, color: '#6b7280', marginTop: 3 }}>{alert.game}</div>
        </div>
        <div style={{ flex: 1, overflowY: 'auto', padding: '16px 18px 18px' }}>
          <AlertDetailBody alert={alert} theme={theme} level="high" />
          <div style={{ marginTop: 18, display: 'flex', gap: 8 }}>
            <Btn variant="primary" theme={theme} full>Marcar como resolvido</Btn>
            <button style={{
              padding: '12px 14px', borderRadius: 10,
              background: '#f3f4f6', color: '#374151', border: 'none',
              fontSize: 13, fontWeight: 700, cursor: 'pointer',
              fontFamily: 'inherit',
            }}>Compartilhar</button>
          </div>
        </div>
      </div>
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────────────
// VARIANT 3 — Inline (spec original): detalhe expandido dentro do card
// ─────────────────────────────────────────────────────────────────────
function AlertsScreenInline({ tweaks }) {
  const { theme } = useAura(tweaks);
  const expanded = AURA_ALERTS.high[0];
  return (
    <Phone>
      <NavBar theme={theme} />
      <AlertsHeader theme={theme} count={6} />
      <div style={{ flex: 1, overflowY: 'auto', padding: '0 16px 24px' }}>
        <RiskSection level="high" count={3} open onToggle={() => {}}>
          {/* Expanded card */}
          <div style={{
            background: '#fff',
            border: `1.5px solid ${theme.primary600}`,
            borderLeft: `4px solid #dc2626`,
            borderRadius: 12,
            padding: '14px 14px 16px',
            boxShadow: '0 6px 20px rgba(233,30,140,0.18)',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
              <span style={{ fontSize: 11, color: '#6b7280', fontWeight: 600 }}>{expanded.time} · {expanded.kid}</span>
              <RiskPill level="high" />
            </div>
            <div style={{ fontSize: 15, fontWeight: 800, color: '#111827', letterSpacing: -0.3 }}>
              {expanded.category}
            </div>
            <div style={{ fontSize: 12, color: '#4b5563', marginTop: 3, marginBottom: 14 }}>
              {expanded.game}
            </div>
            <AlertDetailBody alert={expanded} theme={theme} level="high" />
          </div>
          {/* Other cards collapsed */}
          {AURA_ALERTS.high.slice(1).map((a) => (
            <AlertCard key={a.id} alert={a} theme={theme} level="high" />
          ))}
        </RiskSection>
        <RiskSection level="medium" count={2} open={false} onToggle={() => {}} />
        <RiskSection level="low" count={1} open={false} onToggle={() => {}} />
      </div>
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────────────
// VARIANT 4 — Timeline vertical
// ─────────────────────────────────────────────────────────────────────
function AlertsScreenTimeline({ tweaks }) {
  const { theme } = useAura(tweaks);
  const all = [
    ...AURA_ALERTS.high.map((a) => ({ ...a, level: 'high' })),
    ...AURA_ALERTS.medium.map((a) => ({ ...a, level: 'medium' })),
    ...AURA_ALERTS.low.map((a) => ({ ...a, level: 'low' })),
  ];
  return (
    <Phone>
      <NavBar theme={theme} />
      <AlertsHeader theme={theme} count={all.length} />
      <div style={{ flex: 1, overflowY: 'auto', padding: '0 16px 24px' }}>
        {/* Filter chips */}
        <div style={{ display: 'flex', gap: 6, marginBottom: 14, overflowX: 'auto' }}>
          {[
            { k: 'all', label: 'Todos', count: 6, active: true },
            { k: 'high', label: '🔴 Alto', count: 3 },
            { k: 'medium', label: '🟡 Médio', count: 2 },
            { k: 'low', label: '🟢 Baixo', count: 1 },
          ].map((c) => (
            <button key={c.k} style={{
              padding: '7px 12px', borderRadius: 999,
              background: c.active ? theme.primary900 : '#fff',
              color: c.active ? '#fff' : '#374151',
              border: `1px solid ${c.active ? theme.primary900 : '#e5e7eb'}`,
              fontSize: 11.5, fontWeight: 700, cursor: 'pointer',
              whiteSpace: 'nowrap', flexShrink: 0,
              fontFamily: 'inherit',
            }}>{c.label} · {c.count}</button>
          ))}
        </div>

        {/* Timeline */}
        <div style={{ position: 'relative', paddingLeft: 28 }}>
          {/* Vertical line */}
          <div style={{
            position: 'absolute', left: 9, top: 8, bottom: 8,
            width: 2, background: '#e5e7eb',
            borderRadius: 1, opacity: 0.4,
          }} />
          {all.map((a, idx) => {
            const c = a.level === 'high' ? '#dc2626' : a.level === 'medium' ? '#ea580c' : '#16a34a';
            return (
              <div key={a.id} style={{ position: 'relative', marginBottom: 12 }}>
                {/* Dot */}
                <div style={{
                  position: 'absolute', left: -24, top: 14,
                  width: 18, height: 18, borderRadius: '50%',
                  background: '#fff', border: `3px solid ${c}`,
                  boxShadow: `0 0 0 3px ${c}22`,
                }} />
                <Card hover style={{ padding: '12px 14px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 10 }}>
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 3 }}>
                        <span style={{ fontSize: 11, fontWeight: 700, color: c }}>{a.time}</span>
                        <span style={{ fontSize: 10.5, color: '#9ca3af' }}>·</span>
                        <span style={{ fontSize: 11, color: '#6b7280', fontWeight: 600 }}>{a.kid}</span>
                      </div>
                      <div style={{ fontSize: 13.5, fontWeight: 800, color: '#111827', letterSpacing: -0.2 }}>
                        {a.category}
                      </div>
                      <div style={{ fontSize: 11.5, color: '#6b7280', marginTop: 2, lineHeight: 1.4 }}>
                        {a.summary}
                      </div>
                    </div>
                  </div>
                </Card>
              </div>
            );
          })}
        </div>
      </div>
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────────────
// VARIANT 5 — Empty state
// ─────────────────────────────────────────────────────────────────────
function AlertsScreenEmpty({ tweaks }) {
  const { theme } = useAura(tweaks);
  return (
    <Phone>
      <NavBar theme={theme} />
      <AlertsHeader theme={theme} count={0} />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 32px 24px', textAlign: 'center' }}>
        <div style={{
          width: 96, height: 96, borderRadius: '50%',
          background: theme.accentGrad,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 44, color: '#fff', marginBottom: 22,
          boxShadow: '0 16px 40px rgba(233,30,140,0.30)',
        }}>✦</div>
        <div style={{ fontSize: 20, fontWeight: 800, color: theme.primary900, letterSpacing: -0.5, marginBottom: 8 }}>
          Tudo sob proteção
        </div>
        <div style={{ fontSize: 13, color: '#6b7280', lineHeight: 1.6, maxWidth: 290 }}>
          Nenhuma interacão de risco nas últimas 24 horas. A Aura está acompanhando <strong style={{ color: theme.primary900 }}>3 dispositivos</strong> em <strong style={{ color: theme.primary900 }}>35 jogos</strong> — e a criança vê o ícone <strong style={{ color: theme.primary600 }}>✦</strong> sempre que está jogando.
        </div>

        <div style={{
          marginTop: 28, padding: '14px 16px',
          background: '#fff', border: `1px solid ${theme.primary100}`,
          borderRadius: 12, width: '100%', maxWidth: 320,
          display: 'flex', alignItems: 'center', gap: 12,
          textAlign: 'left',
        }}>
          <div style={{
            width: 36, height: 36, borderRadius: 10,
            background: theme.accentLight, color: theme.accent,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 16, fontWeight: 800, flexShrink: 0,
          }}>✓</div>
          <div>
            <div style={{ fontSize: 12.5, fontWeight: 800, color: '#111827' }}>Última verificação</div>
            <div style={{ fontSize: 11, color: '#6b7280', marginTop: 1 }}>há 12 segundos · Mistral Vision</div>
          </div>
        </div>

        <div style={{ marginTop: 22, fontSize: 11, color: '#9ca3af' }}>
          Continue tranquila — avisaremos se algo precisar de atenção.
        </div>
      </div>
    </Phone>
  );
}

Object.assign(window, {
  AlertsScreen, AlertsScreenDrawer, AlertsScreenInline, AlertsScreenTimeline, AlertsScreenEmpty,
  AURA_ALERTS,
});
