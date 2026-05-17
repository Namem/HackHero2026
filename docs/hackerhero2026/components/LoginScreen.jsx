// Aura — Login screen
// Layout: full-bleed dark hero with logo, form card centered, ECA legal notice in highlight box

function LoginScreen({ tweaks }) {
  const { theme } = useAura(tweaks);
  const [email, setEmail] = React.useState('maria.silva@aura.app');
  const [pass, setPass] = React.useState('••••••••');
  const [accepted, setAccepted] = React.useState(true);
  const [focus, setFocus] = React.useState(null);

  return (
    <Phone bg={theme.primary900} noSafeArea>
      {/* Full-bleed gradient backdrop */}
      <div style={{
        position: 'absolute', inset: 0,
        background: theme.heroGrad,
      }} />

      <StatusBar />

      <div style={{
        position: 'relative', zIndex: 1,
        flex: 1, padding: '32px 24px 24px',
        display: 'flex', flexDirection: 'column',
        color: '#fff',
      }}>
        {/* Brand */}
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', marginTop: 36 }}>
          <LogoMark size={68} gradient={theme.logoGrad} />
          <div style={{ fontSize: 34, fontWeight: 800, letterSpacing: -1.2, marginTop: 16 }}>Aura</div>
          <div style={{ fontSize: 13, color: 'rgba(255,255,255,0.7)', marginTop: 4, fontWeight: 500 }}>
            Proteção digital com inteligência
          </div>
        </div>

        {/* Form card */}
        <div style={{
          marginTop: 36,
          background: 'rgba(255,255,255,0.06)',
          backdropFilter: 'blur(20px)',
          border: '1px solid rgba(255,255,255,0.12)',
          borderRadius: 18,
          padding: '22px 20px',
        }}>
          <Field
            label="E-mail"
            value={email} onChange={setEmail}
            focused={focus === 'email'}
            onFocus={() => setFocus('email')} onBlur={() => setFocus(null)}
            theme={theme}
            icon="✉"
          />
          <div style={{ height: 14 }} />
          <Field
            label="Senha"
            value={pass} onChange={setPass}
            focused={focus === 'pass'}
            onFocus={() => setFocus('pass')} onBlur={() => setFocus(null)}
            theme={theme}
            icon="🔒"
            type="password"
          />

          {/* ECA notice */}
          <div style={{
            marginTop: 18,
            background: 'rgba(132,204,22,0.10)',
            border: '1px solid rgba(132,204,22,0.32)',
            borderRadius: 12,
            padding: '12px 12px 12px 14px',
            display: 'flex', gap: 10, alignItems: 'flex-start',
            position: 'relative',
          }}>
            <div style={{
              position: 'absolute', left: 0, top: 12, bottom: 12, width: 3,
              background: theme.accent, borderRadius: 2,
            }} />
            <button
              onClick={() => setAccepted(!accepted)}
              style={{
                width: 18, height: 18, borderRadius: 5, flexShrink: 0, marginTop: 1,
                border: `1.5px solid ${accepted ? theme.accent : 'rgba(255,255,255,0.4)'}`,
                background: accepted ? theme.accent : 'transparent',
                color: '#2d0022', fontSize: 12, fontWeight: 900,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                cursor: 'pointer', padding: 0,
              }}
            >{accepted ? '✓' : ''}</button>
            <div style={{ fontSize: 11.5, lineHeight: 1.5, color: 'rgba(255,255,255,0.92)' }}>
              <strong style={{ color: theme.accent, fontWeight: 700 }}>Aviso legal · ECA Digital</strong><br/>
              Você se compromete a <strong>informar a criança</strong> sobre o monitoramento. Ela também verá o ícone <strong>✦</strong> sempre que estiver jogando.
              <span style={{ color: 'rgba(255,255,255,0.55)', fontSize: 10.5, display: 'block', marginTop: 3 }}>
                Lei 15.211/2025, Art. 19 §1º — transparência total com o menor
              </span>
            </div>
          </div>

          <div style={{ marginTop: 18 }}>
            <Btn variant="primary" theme={theme} full>
              Entrar →
            </Btn>
          </div>

          <div style={{
            marginTop: 14, textAlign: 'center',
            fontSize: 12, color: 'rgba(255,255,255,0.6)',
          }}>
            Não tem conta? <span style={{ color: '#fff', fontWeight: 600, textDecoration: 'underline', textUnderlineOffset: 3 }}>Cadastrar responsável</span>
          </div>
        </div>

        <div style={{ flex: 1 }} />

        {/* Footer */}
        <div style={{
          textAlign: 'center', fontSize: 10.5, color: 'rgba(255,255,255,0.45)',
          letterSpacing: 0.4, textTransform: 'uppercase',
        }}>
          ✦ Aura · Hackathon HackerHero 2026
        </div>
      </div>
    </Phone>
  );
}

function Field({ label, value, onChange, focused, onFocus, onBlur, icon, type = 'text', theme }) {
  return (
    <label style={{ display: 'block' }}>
      <div style={{
        fontSize: 11, fontWeight: 700, letterSpacing: 0.5,
        textTransform: 'uppercase', color: 'rgba(255,255,255,0.55)',
        marginBottom: 6,
      }}>{label}</div>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 10,
        background: 'rgba(0,0,0,0.25)',
        border: `1.5px solid ${focused ? theme.primary600 : 'rgba(255,255,255,0.12)'}`,
        borderRadius: 10,
        padding: '11px 14px',
        transition: 'border-color .15s, box-shadow .15s',
        boxShadow: focused ? `0 0 0 4px ${theme.primary600}22` : 'none',
      }}>
        <span style={{ fontSize: 14, opacity: 0.7 }}>{icon}</span>
        <input
          type={type}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          onFocus={onFocus}
          onBlur={onBlur}
          style={{
            flex: 1, background: 'transparent', border: 'none', outline: 'none',
            color: '#fff', fontSize: 14, fontWeight: 500,
            fontFamily: 'inherit',
          }}
        />
      </div>
    </label>
  );
}

Object.assign(window, { LoginScreen });
