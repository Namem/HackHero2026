# ✦ Aura — Proteção Digital Parental com IA

> App de monitoramento parental focado em jogos. A IA analisa capturas de tela em tempo real, destrói a imagem imediatamente e envia apenas um alerta textual ao responsável. Nenhuma imagem é armazenada ou transmitida.

---

## Índice

- [O que é o Aura](#o-que-é-o-aura)
- [Arquitetura](#arquitetura)
- [Fluxo Principal](#fluxo-principal)
- [Stack Tecnológica](#stack-tecnológica)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Categorias de Risco](#categorias-de-risco)
- [APIs](#apis)
- [Dashboard Web](#dashboard-web)
- [Como rodar localmente](#como-rodar-localmente)
- [Conformidade Legal](#conformidade-legal)

---

## O que é o Aura

O **Aura** é um sistema de proteção digital parental voltado exclusivamente para **jogos mobile**. Quando a criança abre um jogo monitorado, o app captura a tela em memória RAM, envia ao servidor, a IA classifica o risco e **destrói a imagem imediatamente**. Os pais recebem apenas um alerta textual — nunca uma imagem.

### Diferenciais

| | Aura | Soluções comuns |
|---|---|---|
| Imagem armazenada | ❌ Nunca | ✅ Sim |
| Imagem transmitida aos pais | ❌ Nunca | ✅ Sim |
| Criança informada | ✅ Obrigatório | ⚠️ Opcional |
| Escopo limitado | ✅ Só jogos | ❌ Todo o device |
| Análise por IA | ✅ Gemini 2.5 Flash | ❌ Palavras-chave |
| Conforme ECA Digital | ✅ | ⚠️ Incerto |

---

## Arquitetura

```
┌─────────────────────────────────────────────────────────┐
│  App do Filho (Flutter / Android)                       │
│  - ForegroundService em background                      │
│  - UsageStatsManager detecta jogo em foreground         │
│  - Captura tela em RAM — nunca em disco                 │
│  - Popup de ciência ao abrir jogo monitorado            │
│  - Envia imagem via HTTPS → descarta imediatamente      │
└────────────────────────┬────────────────────────────────┘
                         │ HTTPS — bytes em memória
                         ▼
┌─────────────────────────────────────────────────────────┐
│  Backend (Django + DRF) — rodando em Docker             │
│  - Recebe imagem em memória                             │
│  - Gemini 2.5 Flash Vision analisa o conteúdo           │
│  - DESTRÓI a imagem imediatamente após análise          │
│  - Persiste apenas: categoria, nível, descrição, hora   │
│  - Dispara push FCM ao responsável                      │
└────────────────────────┬────────────────────────────────┘
                         │ Push (texto apenas)
                         ▼
┌─────────────────────────────────────────────────────────┐
│  App dos Pais (Flutter) + Dashboard Web (Django)        │
│  - Alertas agrupados: Alto / Médio / Baixo              │
│  - Clica no alerta → "Pode ser" + Recomendações         │
│  - Gerencia jogos monitorados remotamente               │
│  - Vinculação via código de 6 dígitos (10 min)          │
└─────────────────────────────────────────────────────────┘
```

---

## Fluxo Principal

```
1. PAI instala o app no próprio celular → cria conta → gera código de 6 dígitos

2. PAI pega o celular do filho → instala o app Aura → loga com conta do filho
   → digita o código de 6 dígitos gerado pelo pai
   → ParentalLink criado + Device registrado automaticamente

3. PAI configura remotamente os jogos a monitorar
   (app filho busca a lista em GET /api/devices/<token>/config/)

4. FILHO abre jogo monitorado
   → popup de ciência aparece na tela ("Este jogo está sendo monitorado")
   → ForegroundService captura tela em RAM

5. App filho envia imagem → POST /api/analyze/
   → Gemini 2.5 Flash analisa
   → imagem DESTRUÍDA
   → se risco detectado: alerta salvo + FCM enviado ao pai

6. PAI recebe push → abre app → vê alerta com nível, categoria,
   "pode ser" e recomendações de como agir
```

---

## Stack Tecnológica

### Backend
| Tecnologia | Versão | Uso |
|---|---|---|
| Django | 5.0.4 | Framework principal |
| Django REST Framework | 3.15.1 | APIs REST |
| djangorestframework-simplejwt | 5.3.1 | Autenticação JWT |
| PostgreSQL | 16 | Banco de dados |
| google-genai | 2.3.0 | Gemini 2.5 Flash Vision |
| Pillow | 10.3.0 | Manipulação de imagem em memória |
| Gunicorn | 22.0.0 | Servidor WSGI produção |
| Docker + Docker Compose | — | Ambiente local e produção |

### Apps (Flutter)
| Pacote | Uso |
|---|---|
| flutter_foreground_task | ForegroundService Android |
| usage_stats | UsageStatsManager — app em foreground |
| firebase_messaging | Push notifications FCM |
| dio | HTTP client async |
| flutter_secure_storage | Token JWT seguro |
| riverpod | Gerenciamento de estado |

---

## Estrutura do Projeto

```
HACKAHERO/
├── backend/
│   ├── accounts/          # Auth, usuários, vinculação pai-filho
│   │   ├── models.py      # User, PairingCode, ParentalLink
│   │   ├── views.py       # Register, Login, GenerateCode, Pair, LinkStatus
│   │   └── urls.py
│   ├── devices/           # Devices e apps monitorados
│   │   ├── models.py      # Device, MonitoredApp
│   │   ├── views.py       # CRUD devices + config + ChildDevices
│   │   └── urls.py
│   ├── monitoring/        # Análise, alertas, recomendações
│   │   ├── models.py      # Alert, Trigger
│   │   ├── views.py       # Analyze, Alerts, Recommendations
│   │   └── urls.py
│   ├── dashboard/         # Dashboard web dos pais
│   │   ├── views.py       # Login, Home, Alerts, API Docs
│   │   └── urls.py
│   ├── services/
│   │   └── ai_agent.py    # Gemini 2.5 Flash + categorias de risco
│   ├── templates/         # HTML/CSS puro — temas Aura e Pitaya
│   ├── Dockerfile
│   └── requirements.txt
├── docs/
│   ├── vigilia_analise_legal.pdf   # Análise jurídica completa
│   └── gerar_pdf_legal.py
├── docker-compose.yml
└── README.md
```

---

## Categorias de Risco

Baseadas em **PEGI 2026, ESRB, WHO ICD-11, ECA Digital Lei 15.211/2025 e SaferNet Brasil**:

| Categoria | Nível Padrão | Descrição |
|---|---|---|
| `violencia` | 🟡 Médio | Armas, sangue, morte, combate gráfico |
| `gambling` | 🟡 Médio | Loot boxes, apostas, recompensas aleatórias pagas |
| `grooming` | 🔴 Alto | Adulto pedindo contato externo, dados pessoais |
| `bullying` | 🟡 Médio | Insultos, assédio, mensagens de ódio |
| `conteudo_adulto` | 🔴 Alto | Imagens sexuais, linguagem adulta |
| `microtransacao` | 🟢 Baixo | Timers de urgência, pressão de compra |
| `fomo` | 🟢 Baixo | Recompensas diárias obrigatórias, ansiedade |
| `extremismo` | 🔴 Alto | Símbolos de ódio, conteúdo radical |
| `privacidade` | 🟡 Médio | Pedido de dados pessoais, localização |
| `vicio` | 🟡 Médio | Padrões de uso compulsivo |
| `seguro` | 🟢 Baixo | Nenhum risco detectado |

Cada categoria inclui lista de **"pode ser"** e **recomendações** para os pais.

---

## APIs

### Autenticação
| Método | Endpoint | Auth | Descrição |
|---|---|---|---|
| POST | `/api/auth/register/` | Público | Cadastro do responsável |
| POST | `/api/auth/login/` | Público | Login → JWT |
| POST | `/api/auth/refresh/` | Público | Renova token |
| GET | `/api/auth/me/` | JWT | Dados do usuário |
| POST | `/api/auth/link/generate/` | JWT | Gera código de 6 dígitos para vincular filho |
| POST | `/api/auth/link/pair/` | JWT | Filho usa código → cria vínculo + device |
| GET | `/api/auth/link/status/` | JWT | Verifica se está vinculado e qual papel (pai/filho) |

### Devices
| Método | Endpoint | Auth | Descrição |
|---|---|---|---|
| GET | `/api/devices/` | JWT | Lista devices do usuário |
| POST | `/api/devices/` | JWT | Cria device manualmente |
| GET | `/api/devices/children/` | JWT | Lista devices de todos os filhos vinculados |
| GET | `/api/devices/<token>/config/` | Público | Config do device — usado pelo app filho |
| GET | `/api/devices/<token>/apps/` | JWT | Lista jogos monitorados |
| POST | `/api/devices/<token>/apps/` | JWT | Adiciona jogo(s) — aceita bulk `{"apps": [...]}` |
| DELETE | `/api/devices/<token>/apps/<id>/` | JWT | Remove jogo |

### Monitoramento
| Método | Endpoint | Auth | Descrição |
|---|---|---|---|
| POST | `/api/analyze/` | Público | Imagem → IA → alerta (usado pelo app filho) |
| GET | `/api/alerts/` | JWT | Histórico de alertas |
| GET | `/api/devices/<token>/recommendations/` | JWT | Recomendações geradas pela IA |

### Dashboard Web
| URL | Descrição |
|---|---|
| `/login/` | Login web |
| `/` | Home — dispositivos |
| `/<token>/alerts/` | Alertas agrupados por nível |
| `/api-docs/` | Documentação das APIs |

---

## Dashboard Web

O dashboard é acessível em `http://localhost:8000` e oferece:

- **Login** com aviso legal sobre ciência do menor (ECA Digital)
- **Home** com cards dos devices monitorados
- **Alertas** agrupados em Alto / Médio / Baixo — ao clicar: "pode ser" + recomendações
- **API Docs** com todos os endpoints documentados
- **Dois temas visuais**: Aura (violeta) e Pitaya (magenta + verde limão) — switcher no navbar

---

## Como rodar localmente

### Pré-requisitos
- Docker + Docker Compose
- (Opcional) Chave da API Gemini para análise real

### 1. Clone e configure
```bash
git clone https://github.com/Namem/HackHero2026
cd HackHero2026
```

Crie o arquivo `.env` na raiz (opcional — sem ele roda em modo mock):
```
GEMINI_API_KEY=sua_chave_aqui
```

### 2. Suba os containers
```bash
docker compose up --build -d
```

### 3. Crie o superusuário
```bash
docker compose exec -it api python manage.py createsuperuser
```

### 4. Acesse
| URL | Descrição |
|---|---|
| `http://localhost:8000` | Dashboard web |
| `http://localhost:8000/admin/` | Django Admin |
| `http://localhost:8000/api-docs/` | Documentação das APIs |

### 5. Testar o analyze (PowerShell)
```powershell
curl.exe -X POST http://localhost:8000/api/analyze/ `
  -F "device_token=SEU_TOKEN" `
  -F "app_package=com.roblox.client" `
  -F "image=@C:/caminho/para/imagem.jpg"
```

---

## Conformidade Legal

Análise jurídica completa disponível em [`docs/vigilia_analise_legal.pdf`](docs/vigilia_analise_legal.pdf).

| Decisão técnica | Lei | Artigo | Status |
|---|---|---|---|
| Imagem destruída imediatamente | Lei 15.211/2025 + Decreto 12.880/2026 | Art. 19 + Art. 24 §3 | ✅ Supera o exigido |
| Imagem nunca transmitida aos pais | Lei 15.211/2025 | Art. 19 caput | ✅ Supera o exigido |
| Popup de ciência ao abrir jogo | Lei 15.211/2025 | Art. 19 §1 | ✅ Conforme |
| Aviso legal no cadastro do pai | Lei 15.211/2025 | Art. 19 §1 | ✅ Conforme |
| Somente jogos monitorados | LGPD | Art. 6 III (minimização) | ✅ Conforme |
| Consentimento do responsável | LGPD | Art. 14 | ✅ Conforme |
| Imagem passa pela API Gemini | LGPD | Art. 26 (operador terceiro) | ⚠️ Requer DPA |

> ⚠️ Esta análise é preliminar e informativa. Consulte um advogado especializado em LGPD e ECA antes de publicar o aplicativo.

---

## Time

Hackathon HackHero 2026 — 48h

---

*Aura — Proteção digital com IA · 2026*
