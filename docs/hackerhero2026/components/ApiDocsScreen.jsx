// Aura — API Docs screen
// Clean list of endpoints with method badge, expandable params + dark code response

const AURA_ENDPOINTS = [
  {
    method: 'POST', path: '/api/auth/register/', auth: false,
    title: 'Cadastrar responsável legal',
    body: 'JSON', params: [
      { name: 'email',    type: 'string', req: true,  desc: 'E-mail do responsável (único)' },
      { name: 'password', type: 'string', req: true,  desc: 'Senha (mín. 8 caracteres)' },
      { name: 'eca_accept', type: 'bool', req: true,  desc: 'Aceite do termo ECA Digital (Art. 19 §1)' },
    ],
    response: `{
  "id": 42,
  "email": "maria.silva@aura.app",
  "access": "eyJhbGciOiJIUzI1NiIs...",
  "refresh": "eyJ0eXAiOiJKV1QiL...",
  "created_at": "2026-05-16T09:41:12Z"
}`,
  },
  {
    method: 'POST', path: '/api/auth/login/', auth: false,
    title: 'Login e geração de JWT', body: 'JSON',
    params: [
      { name: 'email', type: 'string', req: true, desc: 'E-mail cadastrado' },
      { name: 'password', type: 'string', req: true, desc: 'Senha' },
    ],
    response: `{
  "access": "eyJhbGciOi...",
  "refresh": "eyJ0eXAi...",
  "expires_in": 3600
}`,
  },
  {
    method: 'POST', path: '/api/analyze/', auth: false,
    title: 'Analisar captura de tela (IA Vision)',
    body: 'multipart/form-data',
    params: [
      { name: 'image', type: 'file', req: true, desc: 'Bytes da captura (destruídos após análise)' },
      { name: 'device_token', type: 'string', req: true, desc: 'Token do dispositivo da criança' },
      { name: 'app_package', type: 'string', req: true, desc: 'Pacote do jogo em foreground' },
    ],
    response: `{
  "risk_level": "high",
  "category": "Apostas detectadas",
  "summary": "Mecânica de roleta com tokens premium",
  "causes": [
    "Mecânicas de loot box com moeda paga",
    "Padrões visuais de cassino"
  ],
  "recommendations": [
    "Conversar sobre cassinos em jogos",
    "Revisar limites de compra"
  ],
  "image_destroyed": true,
  "model": "mistral-small-latest"
}`,
  },
  {
    method: 'GET', path: '/api/alerts/', auth: true,
    title: 'Histórico textual de alertas',
    params: [
      { name: 'device_token', type: 'query', req: false, desc: 'Filtrar por dispositivo' },
      { name: 'level', type: 'query', req: false, desc: 'high · medium · low' },
      { name: 'since', type: 'query', req: false, desc: 'ISO 8601' },
    ],
    response: `[
  {
    "id": 1284,
    "device_token": "DVC-7F4A...9C2B",
    "level": "high",
    "category": "Apostas detectadas",
    "summary": "Mecânica de roleta...",
    "created_at": "2026-05-16T14:32:08Z"
  }
]`,
  },
  {
    method: 'GET', path: '/api/devices/', auth: true,
    title: 'Listar dispositivos vinculados', params: [],
    response: `[
  { "token": "DVC-7F4A...9C2B", "kid_name": "Lucas", "apps_count": 12 },
  { "token": "DVC-A12C...8E91", "kid_name": "Sofia", "apps_count": 8 }
]`,
  },
  {
    method: 'POST', path: '/api/devices/{token}/apps/', auth: true,
    title: 'Sincronizar lista de apps monitorados',
    body: 'JSON',
    params: [
      { name: 'apps', type: 'array', req: true, desc: 'Lista de pacotes a monitorar' },
    ],
    response: `{
  "device_token": "DVC-7F4A...9C2B",
  "monitored_apps": ["com.roblox.client", "com.discord"],
  "synced_at": "2026-05-16T09:42:00Z"
}`,
  },
  {
    method: 'DELETE', path: '/api/devices/{token}/', auth: true,
    title: 'Desvincular dispositivo (LGPD Art. 18)',
    params: [],
    response: `{
  "deleted": true,
  "alerts_removed": 124,
  "device_token": "DVC-7F4A...9C2B"
}`,
  },
];

function MethodBadge({ method }) {
  const c = {
    GET:    { bg: '#dbeafe', fg: '#1e40af' },
    POST:   { bg: '#dcfce7', fg: '#166534' },
    DELETE: { bg: '#fee2e2', fg: '#991b1b' },
    PUT:    { bg: '#fef3c7', fg: '#92400e' },
  }[method];
  return (
    <span style={{
      background: c.bg, color: c.fg,
      padding: '3px 8px', borderRadius: 6,
      fontSize: 10.5, fontWeight: 800, letterSpacing: 0.4,
      fontFamily: 'ui-monospace, "SF Mono", monospace',
    }}>{method}</span>
  );
}

function EndpointRow({ ep, open, onToggle, theme }) {
  return (
    <div style={{
      background: '#fff',
      border: `1px solid ${open ? theme.primary100 : '#f3f4f6'}`,
      borderRadius: 10, marginBottom: 8,
      overflow: 'hidden',
      boxShadow: open ? '0 4px 14px rgba(233,30,140,0.10)' : 'none',
      transition: 'border-color .15s, box-shadow .15s',
    }}>
      <button onClick={onToggle} style={{
        width: '100%', background: 'transparent', border: 'none', cursor: 'pointer',
        padding: '11px 12px', display: 'flex', alignItems: 'center', gap: 10,
        textAlign: 'left', fontFamily: 'inherit',
      }}>
        <MethodBadge method={ep.method} />
        <span style={{
          flex: 1, minWidth: 0,
          fontFamily: 'ui-monospace, "SF Mono", monospace',
          fontSize: 12, color: '#111827', fontWeight: 600,
          overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
        }}>{ep.path}</span>
        {ep.auth && (
          <span title="Requer auth" style={{ fontSize: 10, color: '#9ca3af' }}>🔒</span>
        )}
        <span style={{
          fontSize: 10, color: '#9ca3af',
          transform: open ? 'rotate(180deg)' : 'rotate(0)', transition: 'transform .2s',
        }}>▾</span>
      </button>
      {open && (
        <div style={{ padding: '4px 14px 14px', borderTop: '1px solid #f9fafb' }}>
          <div style={{ fontSize: 12.5, color: '#374151', marginTop: 8, fontWeight: 600 }}>{ep.title}</div>
          {ep.body && (
            <div style={{ fontSize: 10.5, color: '#9ca3af', marginTop: 2, fontFamily: 'ui-monospace, monospace' }}>
              Content-Type: {ep.body}
            </div>
          )}

          {ep.params.length > 0 && (
            <>
              <div style={{ fontSize: 10, fontWeight: 800, letterSpacing: 0.6, textTransform: 'uppercase', color: '#6b7280', marginTop: 14, marginBottom: 6 }}>
                Parâmetros
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
                {ep.params.map((p) => (
                  <div key={p.name} style={{
                    display: 'flex', alignItems: 'flex-start', gap: 8,
                    fontSize: 11.5, lineHeight: 1.4,
                  }}>
                    <code style={{
                      fontFamily: 'ui-monospace, monospace',
                      background: '#f9fafb', padding: '2px 6px', borderRadius: 4,
                      color: theme.primary700, fontWeight: 700, fontSize: 11,
                      flexShrink: 0,
                    }}>{p.name}</code>
                    <span style={{ fontSize: 10, color: '#9ca3af', flexShrink: 0, marginTop: 2 }}>{p.type}{p.req && ' · req'}</span>
                    <span style={{ color: '#4b5563', flex: 1 }}>{p.desc}</span>
                  </div>
                ))}
              </div>
            </>
          )}

          <div style={{ fontSize: 10, fontWeight: 800, letterSpacing: 0.6, textTransform: 'uppercase', color: '#6b7280', marginTop: 14, marginBottom: 6 }}>
            Response
          </div>
          <pre style={{
            background: '#0f0a14',
            color: '#f9a8d4',
            padding: '12px 14px',
            borderRadius: 8,
            fontSize: 10.5,
            fontFamily: 'ui-monospace, "SF Mono", "Cascadia Mono", monospace',
            overflow: 'auto',
            lineHeight: 1.55,
            margin: 0,
            border: `1px solid ${theme.primary900}`,
          }}>
            <CodeColor text={ep.response} theme={theme} />
          </pre>
        </div>
      )}
    </div>
  );
}

// Tiny syntax highlight for the response JSON
function CodeColor({ text, theme }) {
  // Color: strings #84cc16 (accent), keys #f472b6 (primary400), bool/numbers #fbbf24
  const out = [];
  let i = 0, n = text.length;
  let key = 0;
  while (i < n) {
    const ch = text[i];
    if (ch === '"') {
      let j = i + 1;
      while (j < n && text[j] !== '"') { if (text[j] === '\\') j++; j++; }
      const str = text.slice(i, j + 1);
      // Decide if key (followed by ':') or string value
      let k = j + 1;
      while (k < n && /\s/.test(text[k])) k++;
      const isKey = text[k] === ':';
      out.push(<span key={key++} style={{ color: isKey ? '#f472b6' : '#84cc16' }}>{str}</span>);
      i = j + 1;
    } else if (/[0-9]/.test(ch) || (ch === '-' && /[0-9]/.test(text[i + 1] || ''))) {
      let j = i;
      while (j < n && /[0-9.\-]/.test(text[j])) j++;
      out.push(<span key={key++} style={{ color: '#fbbf24' }}>{text.slice(i, j)}</span>);
      i = j;
    } else if (text.startsWith('true', i) || text.startsWith('false', i) || text.startsWith('null', i)) {
      const tok = text.startsWith('null', i) ? 'null' : text.startsWith('true', i) ? 'true' : 'false';
      out.push(<span key={key++} style={{ color: '#fbbf24', fontStyle: 'italic' }}>{tok}</span>);
      i += tok.length;
    } else {
      out.push(<span key={key++} style={{ color: '#e9d5ff' }}>{ch}</span>);
      i++;
    }
  }
  return <>{out}</>;
}

function ApiDocsScreen({ tweaks }) {
  const { theme } = useAura(tweaks);
  const [open, setOpen] = React.useState(2); // default open: /api/analyze/
  return (
    <Phone>
      <NavBar theme={theme} />
      <div style={{ flex: 1, overflowY: 'auto', padding: '18px 18px 24px' }}>
        <div style={{ marginBottom: 18 }}>
          <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1, textTransform: 'uppercase', color: theme.primary600 }}>
            Documentação
          </div>
          <div style={{ fontSize: 22, fontWeight: 800, color: theme.primary900, letterSpacing: -0.6, marginTop: 2 }}>
            API Aura · v1
          </div>
          <div style={{ fontSize: 12.5, color: '#6b7280', marginTop: 4, lineHeight: 1.5 }}>
            Backend Django + DRF · JWT auth · base URL <code style={{ background: '#f3f4f6', padding: '1px 6px', borderRadius: 4, fontSize: 11, fontFamily: 'ui-monospace, monospace' }}>https://api.aura.app</code>
          </div>
        </div>

        {/* Quick stats */}
        <div style={{
          display: 'flex', gap: 8, marginBottom: 16,
          fontSize: 11, color: '#374151', fontWeight: 600,
        }}>
          <Pill bg="#dbeafe" fg="#1e40af">4 GET</Pill>
          <Pill bg="#dcfce7" fg="#166534">3 POST</Pill>
          <Pill bg="#fee2e2" fg="#991b1b">1 DELETE</Pill>
        </div>

        {AURA_ENDPOINTS.map((ep, idx) => (
          <EndpointRow key={ep.path + ep.method} ep={ep} open={open === idx} onToggle={() => setOpen(open === idx ? -1 : idx)} theme={theme} />
        ))}

        <div style={{
          marginTop: 20, padding: '12px 14px',
          background: theme.primary50, border: `1px solid ${theme.primary100}`,
          borderRadius: 10, fontSize: 11, color: theme.primary900, lineHeight: 1.5,
        }}>
          <strong style={{ fontWeight: 800 }}>✦ Importante:</strong> Imagens enviadas a <code style={{ fontFamily: 'ui-monospace, monospace' }}>/api/analyze/</code> nunca são persistidas — são destruídas imediatamente após a análise (ECA Digital · Decreto 12.880/2026, Art. 24 §3).
        </div>
      </div>
    </Phone>
  );
}

function Pill({ children, bg, fg }) {
  return <span style={{ background: bg, color: fg, padding: '4px 9px', borderRadius: 999, fontSize: 10.5, fontWeight: 800, letterSpacing: 0.3 }}>{children}</span>;
}

Object.assign(window, { ApiDocsScreen, AURA_ENDPOINTS });
