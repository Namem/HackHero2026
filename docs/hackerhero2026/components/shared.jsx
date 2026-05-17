// Aura — tokens, logo, shared chrome
// Mobile artboard: 420 × 900

// 5 paletas — todas inspiradas em variedades reais de pitaya
const AURA_THEMES = {
  // Pitaya vermelha — casca rosa-magenta + polpa branca com sementes pretas + sementes verdes
  pitaya: {
    label: 'Pitaya Vermelha',
    swatch: ['#e91e8c', '#84cc16', '#2d0022'],
    primary900: '#2d0022', primary800: '#4a0035', primary700: '#c2185b',
    primary600: '#e91e8c', primary400: '#f472b6', primary100: '#fce7f3', primary50: '#fdf2f8',
    accent: '#84cc16', accentLight: '#ecfccb',
    navBg: '#2d0022', navText: '#f9a8d4',
    heroGrad:   '#2d0022',
    accentGrad: '#e91e8c',
    logoGrad:   '#e91e8c',
  },
  // Pitaya amarela — casca dourada + polpa branca, contraste com verde profundo
  amarela: {
    label: 'Pitaya Amarela',
    swatch: ['#f59e0b', '#10b981', '#3a2410'],
    primary900: '#3a2410', primary800: '#5c3a18', primary700: '#b45309',
    primary600: '#f59e0b', primary400: '#fbbf24', primary100: '#fef3c7', primary50: '#fffbeb',
    accent: '#10b981', accentLight: '#d1fae5',
    navBg: '#3a2410', navText: '#fcd34d',
    heroGrad:   '#3a2410',
    accentGrad: '#f59e0b',
    logoGrad:   '#f59e0b',
  },
  // Pitaya branca — rosa suave da casca + verde-água, tom mais delicado
  branca: {
    label: 'Pitaya Branca',
    swatch: ['#ec4899', '#06b6d4', '#3b0e3d'],
    primary900: '#3b0e3d', primary800: '#581c63', primary700: '#a855f7',
    primary600: '#ec4899', primary400: '#f9a8d4', primary100: '#fce7f3', primary50: '#fdf2f8',
    accent: '#06b6d4', accentLight: '#cffafe',
    navBg: '#3b0e3d', navText: '#fbcfe8',
    heroGrad:   '#3b0e3d',
    accentGrad: '#ec4899',
    logoGrad:   '#ec4899',
  },
  // Pitaya noturna — magenta profundo + lime brilhante, tom premium escuro
  noturna: {
    label: 'Pitaya Noturna',
    swatch: ['#be185d', '#a3e635', '#0e0008'],
    primary900: '#0e0008', primary800: '#1f0014', primary700: '#9d174d',
    primary600: '#be185d', primary400: '#ec4899', primary100: '#fbcfe8', primary50: '#fdf2f8',
    accent: '#a3e635', accentLight: '#ecfccb',
    navBg: '#0e0008', navText: '#f9a8d4',
    heroGrad:   '#0e0008',
    accentGrad: '#be185d',
    logoGrad:   '#be185d',
  },
  // Aura violeta — tema do base.html mantido como alternativa
  violeta: {
    label: 'Aura Violeta',
    swatch: ['#7c3aed', '#0ea5e9', '#2e1065'],
    primary900: '#2e1065', primary800: '#4c1d95', primary700: '#6d28d9',
    primary600: '#7c3aed', primary400: '#a78bfa', primary100: '#ede9fe', primary50: '#f5f3ff',
    accent: '#0ea5e9', accentLight: '#e0f2fe',
    navBg: '#2e1065', navText: '#c4b5fd',
    heroGrad:   '#2e1065',
    accentGrad: '#7c3aed',
    logoGrad:   '#7c3aed',
  },
};

const GRADIENT_INTENSITY = {
  subtle:    { hero: 0.55, accent: 0.75 },
  medium:    { hero: 0.85, accent: 0.95 },
  dramatic:  { hero: 1.0,  accent: 1.0  },
};

function useAura(tweaks) {
  const theme = AURA_THEMES[tweaks?.theme || 'pitaya'];
  const intensity = GRADIENT_INTENSITY[tweaks?.gradient || 'medium'];
  return { theme, intensity, density: tweaks?.density || 'comfortable' };
}

// Artboard shell — fixed 420×900 mobile portrait. Inside is column flex.
function Phone({ children, bg = '#f3f4f6', noSafeArea = false }) {
  return (
    <div style={{
      width: '100%', height: '100%', background: bg,
      display: 'flex', flexDirection: 'column',
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
      color: '#111827',
      overflow: 'hidden',
      position: 'relative',
    }}>
      {!noSafeArea && <StatusBar />}
      {children}
    </div>
  );
}

function StatusBar() {
  return (
    <div style={{
      height: 28, flexShrink: 0,
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 18px',
      fontSize: 12, fontWeight: 600, color: '#111827',
      letterSpacing: 0.2,
    }}>
      <span>9:41</span>
      <span style={{ display: 'flex', gap: 5, alignItems: 'center', fontSize: 11 }}>
        <span>●●●●</span>
        <span>􀙇</span>
        <span style={{
          display: 'inline-block', width: 22, height: 10,
          border: '1.4px solid #111827', borderRadius: 2, position: 'relative',
        }}>
          <span style={{ position: 'absolute', inset: 1, width: 14, background: '#111827', borderRadius: 0.5 }} />
        </span>
      </span>
    </div>
  );
}

function LogoMark({ size = 36, gradient }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.28,
      background: gradient,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      color: '#fff', fontSize: size * 0.55, fontWeight: 700,
      boxShadow: '0 4px 14px rgba(233,30,140,0.35)',
      flexShrink: 0,
    }}>
      ✦
    </div>
  );
}

function NavBar({ theme, email = 'maria.silva@aura.app' }) {
  return (
    <div style={{
      background: theme.navBg, color: '#fff',
      padding: '10px 16px',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      borderBottom: `1px solid rgba(255,255,255,0.06)`,
      flexShrink: 0,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 9 }}>
        <LogoMark size={28} gradient={theme.logoGrad} />
        <span style={{ fontSize: 17, fontWeight: 800, letterSpacing: -0.4 }}>Aura</span>
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, fontSize: 11.5, color: theme.navText }}>
        <span style={{ maxWidth: 130, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{email}</span>
        <a style={{ color: '#fff', textDecoration: 'none', fontWeight: 600 }}>Sair</a>
      </div>
    </div>
  );
}

function Card({ children, style, hover = false, onClick }) {
  const [h, setH] = React.useState(false);
  return (
    <div
      onMouseEnter={() => setH(true)}
      onMouseLeave={() => setH(false)}
      onClick={onClick}
      style={{
        background: '#fff',
        borderRadius: 14,
        boxShadow: hover && h
          ? '0 8px 24px rgba(233,30,140,0.18), 0 0 0 1.5px #e91e8c'
          : '0 1px 3px rgba(0,0,0,.08), 0 1px 2px rgba(0,0,0,.04)',
        transition: 'box-shadow .18s, transform .18s',
        transform: hover && h ? 'translateY(-2px)' : 'none',
        cursor: onClick ? 'pointer' : 'default',
        ...style,
      }}
    >
      {children}
    </div>
  );
}

function Btn({ children, variant = 'primary', theme, full = false, onClick, style }) {
  const base = {
    border: 'none', cursor: 'pointer',
    fontWeight: 700, fontSize: 14,
    padding: full ? '14px 18px' : '10px 18px',
    borderRadius: 10,
    width: full ? '100%' : 'auto',
    display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
    transition: 'transform .1s, box-shadow .15s, opacity .15s',
    letterSpacing: 0.1,
    fontFamily: 'inherit',
  };
  if (variant === 'primary') {
    return <button style={{ ...base, background: theme.accentGrad, color: '#fff', boxShadow: '0 4px 14px rgba(233,30,140,0.32)', ...style }} onClick={onClick}>{children}</button>;
  }
  if (variant === 'dark') {
    return <button style={{ ...base, background: theme.heroGrad, color: '#fff', ...style }} onClick={onClick}>{children}</button>;
  }
  if (variant === 'ghost') {
    return <button style={{ ...base, background: 'rgba(255,255,255,0.08)', color: '#fff', border: '1px solid rgba(255,255,255,0.18)', ...style }} onClick={onClick}>{children}</button>;
  }
  return <button style={{ ...base, background: '#f3f4f6', color: '#111827', ...style }} onClick={onClick}>{children}</button>;
}

function Avatar({ initial, gradient, size = 44 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%',
      background: gradient,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      color: '#fff', fontWeight: 800, fontSize: size * 0.42,
      flexShrink: 0,
      boxShadow: '0 2px 8px rgba(233,30,140,0.25)',
    }}>
      {initial}
    </div>
  );
}

// Risk pills
function RiskPill({ level }) {
  const map = {
    high:   { bg: '#fee2e2', fg: '#991b1b', label: 'Risco Alto', dot: '#dc2626' },
    medium: { bg: '#ffedd5', fg: '#9a3412', label: 'Risco Médio', dot: '#ea580c' },
    low:    { bg: '#d1fae5', fg: '#065f46', label: 'Risco Baixo', dot: '#16a34a' },
  };
  const s = map[level];
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: '4px 10px', borderRadius: 999,
      background: s.bg, color: s.fg,
      fontSize: 11, fontWeight: 700,
    }}>
      <span style={{ width: 6, height: 6, borderRadius: '50%', background: s.dot }} />
      {s.label}
    </span>
  );
}

Object.assign(window, { AURA_THEMES, GRADIENT_INTENSITY, useAura, Phone, StatusBar, LogoMark, NavBar, Card, Btn, Avatar, RiskPill });
