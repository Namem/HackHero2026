// Aura — Transparência com a criança
// 3 telas:
//   ConsentScreen        — tela de ciência mostrada na 1ª vez (POV criança)
//   GameOverlayScreen    — POV criança jogando, com ícone Aura visível
//   PushNotificationScreen — lockscreen do pai com notificação educativa

// ─────────────────────────────────────────────────────────────────────
// 1. Tela de ciência do menor
// ─────────────────────────────────────────────────────────────────────
function ConsentScreen({ tweaks }) {
  const { theme } = useAura(tweaks);
  return (
    <Phone bg={theme.primary900} noSafeArea>
      <div style={{ position: 'absolute', inset: 0, background: theme.heroGrad }} />

      <StatusBar />

      <div style={{
        position: 'relative', zIndex: 1, flex: 1,
        display: 'flex', flexDirection: 'column',
        padding: '20px 24px 24px',
        color: '#fff',
      }}>
        {/* Big friendly logo */}
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', marginTop: 22 }}>
          <div style={{
            width: 84, height: 84, borderRadius: 22,
            background: theme.logoGrad,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 46, color: '#fff',
            boxShadow: '0 20px 50px rgba(0,0,0,0.45)',
            animation: 'pulse 3s ease-in-out infinite',
          }}>✦</div>
          <div style={{ fontSize: 22, fontWeight: 800, letterSpacing: -0.6, marginTop: 18 }}>
            Oi! Vamos conversar?
          </div>
          <div style={{
            fontSize: 13.5, color: 'rgba(255,255,255,0.78)', marginTop: 6,
            textAlign: 'center', lineHeight: 1.5,
          }}>
            Antes de você começar a jogar,<br/>quero te contar uma coisa importante.
          </div>
        </div>

        <div style={{
          marginTop: 26,
          background: 'rgba(255,255,255,0.07)',
          backdropFilter: 'blur(20px)',
          border: '1px solid rgba(255,255,255,0.13)',
          borderRadius: 18,
          padding: '18px 18px 20px',
        }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <ConsentItem
              n="1" theme={theme}
              title="Seu responsável instalou o Aura"
              body="Para te ajudar a ficar segura nos jogos."
            />
            <ConsentItem
              n="2" theme={theme}
              title="Você vai me ver o tempo todo"
              body={<>O ícone <strong style={{ color: theme.accent }}>✦ Aura</strong> aparece sempre que estiver jogando.</>}
            />
            <ConsentItem
              n="3" theme={theme}
              title="Seus segredos continuam seus"
              body="Suas mensagens, fotos e jogos não são gravados."
            />
            <ConsentItem
              n="4" theme={theme}
              title="Se aparecer algo estranho"
              body="Seu responsável é avisado para conversar com você — sem julgar."
            />
          </div>
        </div>

        <div style={{ flex: 1 }} />

        <Btn variant="primary" theme={theme} full style={{ marginTop: 16 }}>
          Eu entendi ✓
        </Btn>
        <div style={{
          textAlign: 'center', fontSize: 10.5, color: 'rgba(255,255,255,0.5)',
          marginTop: 12, letterSpacing: 0.3, lineHeight: 1.5,
        }}>
          ECA Digital · Lei 15.211/2025, Art. 19 §1º<br/>
          você tem o direito de saber que está sendo acompanhado
        </div>
      </div>

      <style>{`
        @keyframes pulse {
          0%, 100% { transform: scale(1); }
          50%      { transform: scale(1.04); }
        }
      `}</style>
    </Phone>
  );
}

function ConsentItem({ n, title, body, theme }) {
  return (
    <div style={{ display: 'flex', gap: 13, alignItems: 'flex-start' }}>
      <div style={{
        width: 26, height: 26, borderRadius: 8,
        background: theme.accentGrad,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        color: '#fff', fontSize: 12, fontWeight: 800,
        flexShrink: 0, boxShadow: '0 2px 8px rgba(0,0,0,0.25)',
      }}>{n}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 13.5, fontWeight: 800, color: '#fff', letterSpacing: -0.2 }}>{title}</div>
        <div style={{ fontSize: 12.5, color: 'rgba(255,255,255,0.7)', marginTop: 3, lineHeight: 1.45 }}>{body}</div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────
// 2. POV da criança jogando — com banner Aura persistente
// ─────────────────────────────────────────────────────────────────────
function GameOverlayScreen({ tweaks }) {
  const { theme } = useAura(tweaks);
  return (
    <Phone bg="#0b1220" noSafeArea>
      <StatusBarGame theme={theme} />

      {/* Fake game scene — purposefully abstract / placeholder */}
      <div style={{
        flex: 1, position: 'relative', overflow: 'hidden',
        background: '#0b1220',
      }}>
        {/* Sky gradient */}
        <div style={{
          position: 'absolute', top: 0, left: 0, right: 0, height: '45%',
          background: '#1e3a8a',
          opacity: 0.6,
        }} />
        {/* Stylized ground squares — Minecraft-y placeholder */}
        <div style={{
          position: 'absolute', bottom: 0, left: 0, right: 0, height: '38%',
          display: 'grid', gridTemplateColumns: 'repeat(8, 1fr)', gap: 1,
          opacity: 0.85,
        }}>
          {Array.from({ length: 40 }).map((_, i) => {
            const c = ['#15803d', '#16a34a', '#854d0e', '#a16207', '#365314'][i % 5];
            return <div key={i} style={{ background: c, opacity: 0.7 + (i % 3) * 0.1 }} />;
          })}
        </div>
        {/* "Player" character */}
        <div style={{
          position: 'absolute', left: '50%', top: '52%', transform: 'translate(-50%, -50%)',
          width: 38, height: 56, background: '#fbbf24', borderRadius: 4,
          border: '2px solid #92400e',
          boxShadow: '0 6px 12px rgba(0,0,0,0.4)',
        }}>
          <div style={{ position: 'absolute', top: 8, left: 8, width: 4, height: 4, background: '#000', borderRadius: 1 }} />
          <div style={{ position: 'absolute', top: 8, right: 8, width: 4, height: 4, background: '#000', borderRadius: 1 }} />
        </div>
        {/* Some clouds */}
        <div style={{ position: 'absolute', top: '12%', left: '15%', width: 50, height: 18, background: '#fff', borderRadius: 999, opacity: 0.65 }} />
        <div style={{ position: 'absolute', top: '18%', right: '12%', width: 38, height: 14, background: '#fff', borderRadius: 999, opacity: 0.6 }} />

        {/* Game UI — HUD */}
        <div style={{
          position: 'absolute', top: 50, left: 14,
          display: 'flex', flexDirection: 'column', gap: 6,
        }}>
          <GameHud icon="❤" label="20 / 20" />
          <GameHud icon="🍗" label="18 / 20" />
        </div>
        <div style={{
          position: 'absolute', top: 50, right: 14,
          padding: '5px 10px',
          background: 'rgba(0,0,0,0.5)', borderRadius: 8,
          color: '#fff', fontSize: 11, fontWeight: 700,
          fontFamily: 'ui-monospace, monospace',
        }}>SP: 047</div>

        {/* Bottom hotbar */}
        <div style={{
          position: 'absolute', bottom: 16, left: '50%', transform: 'translateX(-50%)',
          display: 'flex', gap: 4, padding: 4,
          background: 'rgba(0,0,0,0.55)', border: '2px solid #1f2937', borderRadius: 8,
        }}>
          {[1,2,3,4,5,6].map((i) => (
            <div key={i} style={{
              width: 32, height: 32, background: '#374151',
              border: i === 1 ? '2px solid #fff' : '1px solid #1f2937',
              borderRadius: 4,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: '#fff', fontSize: 12,
            }}>{i === 1 ? '⛏' : i === 2 ? '🪓' : ''}</div>
          ))}
        </div>

        {/* AURA persistent badge — top center, discreet but visible */}
        <div style={{
          position: 'absolute', top: 10, left: '50%', transform: 'translateX(-50%)',
          display: 'flex', alignItems: 'center', gap: 7,
          padding: '6px 12px 6px 8px',
          background: 'rgba(45, 0, 34, 0.85)',
          backdropFilter: 'blur(8px)',
          border: `1px solid ${theme.primary600}66`,
          borderRadius: 999,
          boxShadow: '0 6px 20px rgba(0,0,0,0.5)',
        }}>
          <div style={{
            width: 18, height: 18, borderRadius: 6,
            background: theme.logoGrad,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 10, color: '#fff',
          }}>✦</div>
          <div style={{ fontSize: 10.5, color: '#fff', fontWeight: 700, letterSpacing: 0.2 }}>
            Aura está acompanhando
          </div>
          <div style={{
            width: 5, height: 5, borderRadius: '50%', background: theme.accent,
            boxShadow: `0 0 8px ${theme.accent}`,
            animation: 'auraPulse 1.6s ease-in-out infinite',
          }} />
        </div>

        {/* Welcome toast — first session */}
        <div style={{
          position: 'absolute', top: 80, left: 14, right: 14,
          padding: '11px 12px',
          background: 'rgba(0,0,0,0.78)',
          backdropFilter: 'blur(10px)',
          border: `1px solid ${theme.primary600}55`,
          borderLeft: `3px solid ${theme.accent}`,
          borderRadius: 10,
          display: 'flex', alignItems: 'center', gap: 10,
        }}>
          <div style={{ fontSize: 18 }}>✦</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 11.5, fontWeight: 800, color: '#fff' }}>Sessão protegida</div>
            <div style={{ fontSize: 10.5, color: 'rgba(255,255,255,0.7)', marginTop: 1 }}>
              Você pode tocar em ✦ a qualquer momento para saber mais
            </div>
          </div>
          <span style={{ color: 'rgba(255,255,255,0.4)', fontSize: 14 }}>×</span>
        </div>
      </div>

      <style>{`
        @keyframes auraPulse {
          0%, 100% { opacity: 1; transform: scale(1); }
          50%      { opacity: 0.5; transform: scale(0.85); }
        }
      `}</style>
    </Phone>
  );
}

function StatusBarGame({ theme }) {
  return (
    <div style={{
      height: 32, flexShrink: 0,
      background: '#000',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 18px',
      fontSize: 12, fontWeight: 600, color: '#fff',
      borderBottom: `1px solid #1f2937`,
      position: 'relative', zIndex: 2,
    }}>
      <span>9:41</span>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 7,
      }}>
        {/* Aura icon discreet in status bar */}
        <div title="Aura monitorando" style={{
          width: 16, height: 16, borderRadius: 5,
          background: theme.logoGrad,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 9, color: '#fff', fontWeight: 700,
        }}>✦</div>
        <span style={{ fontSize: 11 }}>5G</span>
        <span style={{
          display: 'inline-block', width: 22, height: 10,
          border: '1.4px solid #fff', borderRadius: 2, position: 'relative',
        }}>
          <span style={{ position: 'absolute', inset: 1, width: 14, background: '#fff', borderRadius: 0.5 }} />
        </span>
      </div>
    </div>
  );
}

function GameHud({ icon, label }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 6,
      padding: '4px 9px',
      background: 'rgba(0,0,0,0.5)', borderRadius: 6,
      color: '#fff', fontSize: 11, fontWeight: 700,
      fontFamily: 'ui-monospace, monospace',
    }}>
      <span>{icon}</span>
      <span>{label}</span>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────
// 3. Notificações push educativas (lockscreen do pai)
// ─────────────────────────────────────────────────────────────────────
function PushNotificationScreen({ tweaks }) {
  const { theme } = useAura(tweaks);
  const notifications = [
    {
      level: 'low', time: 'agora',
      title: 'Lucas teve uma interação de risco baixo.',
      body: 'Toque para descobrir o que isso significa.',
    },
    {
      level: 'medium', time: 'há 12min',
      title: 'Théo encontrou linguagem inadequada no Minecraft.',
      body: 'Veja como conversar sobre isso.',
    },
    {
      level: 'high', time: 'há 1h',
      title: 'Lucas pode ter encontrado mecânicas de aposta.',
      body: 'Material de apoio disponível no Aura.',
    },
  ];

  return (
    <Phone bg="#000" noSafeArea>
      {/* Lockscreen background — abstract gradient */}
      <div style={{
        position: 'absolute', inset: 0,
        background: '#1a0011',
      }} />

      <StatusBarDark />

      <div style={{
        position: 'relative', zIndex: 1, flex: 1,
        display: 'flex', flexDirection: 'column',
        padding: '14px 14px 24px',
        color: '#fff',
      }}>
        {/* Clock */}
        <div style={{ textAlign: 'center', marginTop: 20 }}>
          <div style={{ fontSize: 13, fontWeight: 600, color: 'rgba(255,255,255,0.75)', letterSpacing: 0.4 }}>
            sexta-feira, 16 de maio
          </div>
          <div style={{ fontSize: 76, fontWeight: 200, letterSpacing: -3, marginTop: -4, lineHeight: 1 }}>9:41</div>
        </div>

        {/* Notifications stack */}
        <div style={{ marginTop: 30, display: 'flex', flexDirection: 'column', gap: 8 }}>
          <div style={{
            fontSize: 10.5, fontWeight: 800, letterSpacing: 1, textTransform: 'uppercase',
            color: 'rgba(255,255,255,0.55)', padding: '0 4px 6px',
          }}>
            Aura · {notifications.length} notificações
          </div>
          {notifications.map((n, i) => (
            <PushCard key={i} notif={n} theme={theme} stacked={i > 0} />
          ))}
        </div>

        <div style={{ flex: 1 }} />

        {/* Bottom hint */}
        <div style={{
          textAlign: 'center', fontSize: 10.5, color: 'rgba(255,255,255,0.5)',
          marginBottom: 8, letterSpacing: 0.3,
        }}>
          ✦ Apenas texto — nenhuma imagem é enviada ao seu celular
        </div>
        <div style={{
          height: 4, width: 110, background: '#fff', borderRadius: 999,
          margin: '12px auto 0', opacity: 0.5,
        }} />
      </div>
    </Phone>
  );
}

function StatusBarDark() {
  return (
    <div style={{
      height: 28, flexShrink: 0, position: 'relative', zIndex: 2,
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 18px',
      fontSize: 12, fontWeight: 600, color: '#fff',
    }}>
      <span>9:41</span>
      <span style={{ display: 'flex', gap: 5, alignItems: 'center', fontSize: 11 }}>
        <span>5G</span>
        <span style={{
          display: 'inline-block', width: 22, height: 10,
          border: '1.4px solid #fff', borderRadius: 2, position: 'relative',
        }}>
          <span style={{ position: 'absolute', inset: 1, width: 14, background: '#fff', borderRadius: 0.5 }} />
        </span>
      </span>
    </div>
  );
}

function PushCard({ notif, theme }) {
  const levelMap = {
    low:    { color: '#84cc16', label: 'risco baixo' },
    medium: { color: '#f59e0b', label: 'risco médio' },
    high:   { color: '#ef4444', label: 'risco alto' },
  };
  const m = levelMap[notif.level];
  return (
    <div style={{
      background: 'rgba(255,255,255,0.14)',
      backdropFilter: 'blur(24px) saturate(160%)',
      border: '1px solid rgba(255,255,255,0.15)',
      borderRadius: 14,
      padding: '11px 13px',
      display: 'flex', gap: 11, alignItems: 'flex-start',
    }}>
      <div style={{
        width: 32, height: 32, borderRadius: 8,
        background: theme.logoGrad,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: 16, color: '#fff', fontWeight: 700,
        flexShrink: 0,
      }}>✦</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 2 }}>
          <span style={{ fontSize: 11.5, fontWeight: 800, color: '#fff' }}>Aura</span>
          <span style={{
            display: 'inline-flex', alignItems: 'center', gap: 4,
            padding: '1px 6px', borderRadius: 999,
            background: `${m.color}30`,
            fontSize: 9.5, fontWeight: 800, color: m.color,
            letterSpacing: 0.3, textTransform: 'uppercase',
          }}>
            <span style={{ width: 4, height: 4, borderRadius: '50%', background: m.color }} />
            {m.label}
          </span>
          <span style={{ flex: 1 }} />
          <span style={{ fontSize: 10.5, color: 'rgba(255,255,255,0.55)' }}>{notif.time}</span>
        </div>
        <div style={{ fontSize: 12.5, color: '#fff', fontWeight: 600, lineHeight: 1.35 }}>
          {notif.title}
        </div>
        <div style={{ fontSize: 11.5, color: 'rgba(255,255,255,0.7)', marginTop: 2, lineHeight: 1.4 }}>
          {notif.body}
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { ConsentScreen, GameOverlayScreen, PushNotificationScreen });
