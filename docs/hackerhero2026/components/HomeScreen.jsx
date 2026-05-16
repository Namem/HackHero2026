// Aura — Home / Devices screen
// Two variants:
// - HomeScreen (default): hero banner + cards for each kid
// - HomeScreenStats: hero with aggregate stats + smaller kid cards

const AURA_KIDS = [
  { name: 'Lucas', initial: 'L', token: 'DVC-7F4A...9C2B', alerts: 3, games: 12, lastSeen: 'há 2min', risk: 'high' },
  { name: 'Sofia', initial: 'S', token: 'DVC-A12C...8E91', alerts: 0, games: 8,  lastSeen: 'agora', risk: 'low' },
  { name: 'Théo',  initial: 'T', token: 'DVC-3B2F...77AD', alerts: 1, games: 15, lastSeen: 'há 14min', risk: 'medium' },
];

function HomeScreen({ tweaks }) {
  const { theme, density } = useAura(tweaks);
  const tight = density === 'compact';
  return (
    <Phone>
      <NavBar theme={theme} />
      <div style={{ flex: 1, overflowY: 'auto', padding: tight ? '14px 16px 24px' : '18px 18px 24px' }}>
        {/* Hero banner */}
        <div style={{
          background: theme.heroGrad,
          borderRadius: 16,
          padding: tight ? '18px 18px' : '22px 20px',
          color: '#fff',
          position: 'relative', overflow: 'hidden',
          marginBottom: tight ? 16 : 20,
          boxShadow: '0 12px 32px rgba(45,0,34,0.35)',
        }}>
          <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(255,255,255,0.7)' }}>
            Bem-vindo
          </div>
          <div style={{ fontSize: 22, fontWeight: 800, letterSpacing: -0.6, marginTop: 4, lineHeight: 1.15 }}>
            Aura está protegendo seus filhos
          </div>
          <div style={{ fontSize: 12.5, color: 'rgba(255,255,255,0.8)', marginTop: 8, lineHeight: 1.5 }}>
            Monitoramento inteligente · IA Vision analisando jogos em tempo real
          </div>
          <div style={{ display: 'flex', gap: 8, marginTop: 14 }}>
            <StatPill label="3 dispositivos" theme={theme} />
            <StatPill label="35 jogos" theme={theme} />
          </div>
        </div>

        {/* Section header */}
        <div style={{
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          marginBottom: 10,
        }}>
          <div style={{ fontSize: 14, fontWeight: 800, color: '#2d0022', letterSpacing: -0.2 }}>
            Seus filhos
          </div>
          <button style={{
            background: 'transparent', border: 'none',
            color: theme.primary600, fontSize: 12, fontWeight: 700, cursor: 'pointer',
            display: 'flex', alignItems: 'center', gap: 4,
          }}>
            + adicionar
          </button>
        </div>

        {/* Kid cards */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: tight ? 10 : 12 }}>
          {AURA_KIDS.map((k) => (
            <KidCard key={k.name} kid={k} theme={theme} tight={tight} />
          ))}
        </div>
      </div>
    </Phone>
  );
}

function StatPill({ label, theme }) {
  return (
    <div style={{
      padding: '5px 10px', borderRadius: 999,
      background: 'rgba(255,255,255,0.14)',
      border: '1px solid rgba(255,255,255,0.22)',
      fontSize: 11, fontWeight: 600, color: '#fff',
    }}>{label}</div>
  );
}

function KidCard({ kid, theme, tight }) {
  return (
    <Card hover style={{ padding: tight ? '12px 14px' : '14px 16px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <Avatar initial={kid.initial} gradient={theme.accentGrad} size={tight ? 40 : 46} />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <span style={{ fontSize: 15, fontWeight: 800, color: '#111827' }}>{kid.name}</span>
            <span style={{
              fontSize: 10, color: '#9ca3af', fontWeight: 600,
              display: 'inline-flex', alignItems: 'center', gap: 4,
            }}>
              <span style={{ width: 5, height: 5, borderRadius: '50%', background: kid.risk === 'high' ? '#dc2626' : kid.risk === 'medium' ? '#ea580c' : '#16a34a' }} />
              {kid.lastSeen}
            </span>
          </div>
          <div style={{
            fontSize: 10.5, color: '#6b7280', marginTop: 3,
            fontFamily: 'ui-monospace, "SF Mono", monospace', letterSpacing: 0.2,
          }}>{kid.token}</div>
          <div style={{ display: 'flex', gap: 12, marginTop: 8, alignItems: 'center' }}>
            <Stat icon="🎮" label={`${kid.games} jogos`} />
            <span style={{ width: 1, height: 12, background: '#e5e7eb' }} />
            <Stat icon={kid.alerts > 0 ? '⚠' : '✓'} label={kid.alerts > 0 ? `${kid.alerts} alertas` : 'sem alertas'} color={kid.alerts > 0 ? '#dc2626' : '#16a34a'} />
          </div>
        </div>
      </div>
      <div style={{ marginTop: 12, display: 'flex', gap: 8 }}>
        <button style={{
          flex: 1,
          background: kid.alerts > 0 ? theme.accentGrad : '#f3f4f6',
          color: kid.alerts > 0 ? '#fff' : '#374151',
          border: 'none', borderRadius: 9,
          padding: '9px 12px', fontSize: 12.5, fontWeight: 700,
          cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
          boxShadow: kid.alerts > 0 ? '0 3px 10px rgba(233,30,140,0.28)' : 'none',
          fontFamily: 'inherit',
        }}>
          Ver Alertas {kid.alerts > 0 && <span style={{
            background: 'rgba(255,255,255,0.25)', padding: '2px 7px',
            borderRadius: 999, fontSize: 10.5, fontWeight: 800,
          }}>{kid.alerts}</span>}
        </button>
        <button style={{
          background: '#f9fafb', color: '#6b7280',
          border: '1px solid #e5e7eb', borderRadius: 9,
          width: 38, fontSize: 14, cursor: 'pointer',
          fontFamily: 'inherit',
        }}>⋯</button>
      </div>
    </Card>
  );
}

function Stat({ icon, label, color = '#374151' }) {
  return (
    <span style={{ fontSize: 11.5, color, fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: 4 }}>
      <span style={{ fontSize: 12 }}>{icon}</span>{label}
    </span>
  );
}

// ── Variant: Hero with aggregate stats ───────────────────────────────────
function HomeScreenStats({ tweaks }) {
  const { theme } = useAura(tweaks);
  return (
    <Phone>
      <NavBar theme={theme} />
      <div style={{ flex: 1, overflowY: 'auto', padding: '18px 18px 24px' }}>
        {/* Hero with stats */}
        <div style={{
          background: theme.heroGrad,
          borderRadius: 16,
          padding: '20px 20px 18px',
          color: '#fff',
          position: 'relative', overflow: 'hidden',
          marginBottom: 18,
          boxShadow: '0 12px 32px rgba(45,0,34,0.35)',
        }}>
          <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(255,255,255,0.7)' }}>
            Hoje, 16 mai · 9:41
          </div>
          <div style={{ fontSize: 21, fontWeight: 800, letterSpacing: -0.5, marginTop: 4, lineHeight: 1.2 }}>
            Bem-vinda, Maria
          </div>
          {/* Stats grid */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10, marginTop: 16 }}>
            <BigStat n="4" label="alertas" sub="hoje" theme={theme} highlight />
            <BigStat n="35" label="jogos" sub="monitorados" theme={theme} />
            <BigStat n="3" label="filhos" sub="protegidos" theme={theme} />
          </div>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
          <div style={{ fontSize: 14, fontWeight: 800, color: '#2d0022' }}>Atividade recente</div>
        </div>

        {/* Compact kid rows */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {AURA_KIDS.map((k) => (
            <CompactKidRow key={k.name} kid={k} theme={theme} />
          ))}
        </div>
      </div>
    </Phone>
  );
}

function BigStat({ n, label, sub, theme, highlight }) {
  return (
    <div style={{
      background: highlight ? `${theme.accent}22` : 'rgba(255,255,255,0.10)',
      border: `1px solid ${highlight ? theme.accent + '55' : 'rgba(255,255,255,0.14)'}`,
      borderRadius: 12, padding: '10px 8px',
    }}>
      <div style={{ fontSize: 28, fontWeight: 800, lineHeight: 1, color: highlight ? theme.accent : '#fff', letterSpacing: -1 }}>{n}</div>
      <div style={{ fontSize: 11, fontWeight: 700, marginTop: 4, color: '#fff' }}>{label}</div>
      <div style={{ fontSize: 10, color: 'rgba(255,255,255,0.6)', marginTop: 1 }}>{sub}</div>
    </div>
  );
}

function CompactKidRow({ kid, theme }) {
  return (
    <Card hover style={{ padding: '11px 14px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 11 }}>
        <Avatar initial={kid.initial} gradient={theme.accentGrad} size={36} />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 14, fontWeight: 700, color: '#111827' }}>{kid.name}</div>
          <div style={{ fontSize: 10.5, color: '#6b7280', marginTop: 1 }}>{kid.lastSeen} · {kid.games} jogos</div>
        </div>
        {kid.alerts > 0 ? (
          <div style={{
            background: kid.risk === 'high' ? '#fee2e2' : '#ffedd5',
            color:      kid.risk === 'high' ? '#991b1b' : '#9a3412',
            padding: '4px 9px', borderRadius: 999,
            fontSize: 11, fontWeight: 800,
          }}>{kid.alerts} alertas</div>
        ) : (
          <div style={{ color: '#16a34a', fontSize: 16 }}>✓</div>
        )}
        <span style={{ color: '#9ca3af', fontSize: 16 }}>›</span>
      </div>
    </Card>
  );
}

Object.assign(window, { HomeScreen, HomeScreenStats, AURA_KIDS });
