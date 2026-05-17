# Aura — Proteção Digital Parental com IA

> App de monitoramento parental focado em jogos. A IA classifica capturas de tela em tempo real e o responsável recebe apenas um alerta textual. Nenhuma imagem é armazenada ou transmitida ao pai.

**Equipe Pitaia — Hacker Hero 2026**
Henrique Cunha · Namem Rachid · Beatriz Dutra

---

## Índice

- [Visão geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Stack](#stack)
- [Pré-requisitos](#pré-requisitos)
- [Como rodar — Backend](#como-rodar--backend-django--postgresql)
- [Como rodar — App Flutter](#como-rodar--app-flutter)
- [Como testar pai e filho em paralelo](#como-testar-pai-e-filho-em-paralelo)
- [Fluxo de teste end-to-end](#fluxo-de-teste-end-to-end)
- [Comandos úteis](#comandos-úteis)
- [Troubleshooting](#troubleshooting)
- [APIs](#apis)
- [Conformidade legal](#conformidade-legal)

---

## Visão geral

O Aura é um sistema de proteção digital parental voltado para **jogos mobile**. Quando a criança abre um jogo previamente escolhido pelo responsável, a tela é classificada por IA em três níveis de risco (Alto, Médio, Baixo). O responsável recebe um alerta textual com categoria, app, horário e orientações de como conversar com a criança. **Nenhuma imagem é armazenada nem chega ao celular dos pais.**

### O que está pronto no MVP

| | Status |
|---|---|
| Backend Django + DRF + JWT + PostgreSQL | ✅ |
| App Flutter (pai e filho no mesmo APK) | ✅ |
| Pareamento por código de 6 dígitos | ✅ |
| Notificação fixa do escudo na barra da criança | ✅ |
| Detecção de app em foreground via UsageStatsManager nativo | ✅ |
| Notificação adicional quando jogo monitorado é aberto | ✅ |
| Dashboard do pai com alertas | ✅ |
| Tela de orientação no detalhe do alerta (sem expor conteúdo) | ✅ |
| Conscientização: 6 artigos educacionais | ✅ |
| Política de Privacidade LGPD com aceite obrigatório | ✅ |
| Modo Beta: 3 botões para simular alertas (demo) | ✅ |
| Auto-refresh dos alertas no pai (polling 10s) | ✅ |
| Dispensar alerta (DELETE permanente) | ✅ |

### O que não foi implementado neste MVP

- ❌ Captura automática de tela via MediaProjection
- ❌ ForegroundService Android (app filho 24/7 mesmo com sistema matando)
- ❌ Firebase Cloud Messaging (substituído por polling)

> A captura automática é substituída no MVP pelo **Modo Beta** — botões na tela do filho que simulam alertas reais no backend, permitindo demonstrar o fluxo completo.

---

## Arquitetura

```
┌──────────────────────────────────────────────────────────────┐
│  App do Filho (Flutter / Android)                            │
│  • Notificação fixa "Aura está ativo" na barra de status     │
│  • UsageStatsManager detecta jogo em foreground              │
│  • Modo Beta: 3 botões simulam alertas                       │
│  • Tela de transparência ECA Digital                         │
└────────────────────────┬─────────────────────────────────────┘
                         │ HTTPS — JWT
                         ▼
┌──────────────────────────────────────────────────────────────┐
│  Backend (Django + DRF) em Docker                            │
│  • Auth JWT, pareamento por código                           │
│  • POST /api/simulate-alert/  → cria alerta sem imagem       │
│  • POST /api/analyze/         → upload de imagem + IA        │
│  • DELETE /api/alerts/<id>/   → dispensar permanente         │
│  • Persiste só: categoria, nível, app, hora                  │
└────────────────────────┬─────────────────────────────────────┘
                         │ Polling 10s
                         ▼
┌──────────────────────────────────────────────────────────────┐
│  App do Pai (Flutter / mesmo APK)                            │
│  • Dashboard com alertas + cards de conscientização          │
│  • Tela de orientação (não mostra o conteúdo)                │
│  • Seleção remota de apps a monitorar                        │
│  • Perfil com direito à exclusão LGPD                        │
└──────────────────────────────────────────────────────────────┘
```

---

## Stack

**Backend**
- Django 5.0 + DRF + simplejwt
- PostgreSQL 16
- Mistral / Gemini Vision (opcional — sem chave roda em modo mock)
- Docker Compose

**App**
- Flutter 3.x
- Provider (state management)
- `flutter_local_notifications` (notificação persistente)
- `flutter_svg` (logo escudo)
- MethodChannel nativo Kotlin → `UsageStatsManager`

---

## Pré-requisitos

Antes de começar, instale:

| Ferramenta | Versão mínima | Onde baixar |
|---|---|---|
| Docker Desktop | 4.20+ | https://www.docker.com/products/docker-desktop |
| Flutter SDK | 3.16+ | https://docs.flutter.dev/get-started/install |
| Android Studio | 2023.1+ (com Android SDK 34) | https://developer.android.com/studio |
| Git | 2.40+ | https://git-scm.com |

**Configure pelo menos 1 emulador Android** no Android Studio (Device Manager → Create Device → escolha Pixel 6 ou similar + System Image Android 14).

---

## Como rodar — Backend (Django + PostgreSQL)

### 1. Clone o repositório

```powershell
cd C:\dev
git clone https://github.com/Namem/HackHero2026.git aura
cd aura
```

> ⚠️ Use o caminho `C:\dev\aura` (ou outro sem acentos/espaços). O Gradle do Android quebra em paths com caracteres não-ASCII como "Área de Trabalho".

### 2. Inicie o Docker Desktop

Procure "Docker Desktop" no menu Iniciar do Windows e abra. Aguarde a baleia ficar estável na bandeja do sistema (canto inferior direito) — leva ~30 segundos.

Confirme que está rodando:

```powershell
docker ps
```

Se aparecer cabeçalho com colunas (mesmo sem containers listados), está OK.

### 3. (Opcional) Configure a chave da IA

Sem chave, o endpoint `/api/analyze/` retorna mock. Para a IA real, crie um arquivo `.env` na raiz do projeto:

```powershell
notepad .env
```

Conteúdo:
```
GEMINI_API_KEY=sua_chave_aqui
```

Salve e feche.

### 4. Suba os containers

```powershell
cd C:\dev\aura
docker compose up --build
```

A primeira vez demora 2-3 minutos (baixa imagens, instala dependências). Você verá logs do Postgres e do Django. Quando aparecer:

```
api-1  | Starting development server at http://0.0.0.0:8000/
```

está pronto.

> Para rodar em background (sem prender o terminal): `docker compose up -d --build`

### 5. Crie o superusuário do Django Admin

Em **outro terminal**, com os containers rodando:

```powershell
cd C:\dev\aura
docker compose exec api python manage.py createsuperuser
```

Preencha email, senha (mínimo 6 caracteres).

### 6. Acesse para verificar

| URL | O que é |
|---|---|
| http://localhost:8000/api/ | Página inicial da API (DRF) |
| http://localhost:8000/admin/ | Painel admin (logar com superuser) |

Se as duas abrirem, o backend está ok.

---

## Como rodar — App Flutter

### 1. Entre na pasta do app

```powershell
cd C:\dev\aura\aplicativo
```

### 2. Baixe as dependências

```powershell
flutter pub get
```

### 3. Inicie um emulador Android

Abra o Android Studio → Tools → Device Manager → ▶ ao lado do device.

Confirme que está visível:

```powershell
flutter devices
```

Deve aparecer algo como:
```
sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64 • Android 14 (API 34)
```

### 4. Rode o app

```powershell
flutter run -d emulator-5554
```

Build leva 30s a 2min na primeira vez. Quando aparecer:

```
Flutter run key commands.
r Hot reload. 🔥
R Hot restart.
```

o app está aberto no emulador.

### Teclas úteis enquanto roda

| Tecla | Ação |
|---|---|
| `r` | Hot reload (mudanças de UI) |
| `R` | Hot restart (rotas, providers, main) |
| `q` | Sair |
| `h` | Lista todos os atalhos |

---

## Como testar pai e filho em paralelo

Você precisa de **duas instâncias do app rodando ao mesmo tempo** (um logado como pai, outro como criança).

### Opção 1 — Dois emuladores via worktree (recomendado)

Cria uma cópia do projeto em outra pasta com pasta `build/` separada:

```powershell
cd C:\dev
git -C aura worktree add ../aura2
cd C:\dev\aura2\aplicativo
flutter pub get
```

**Inicie 2 emuladores no Android Studio:** Device Manager → ▶ em dois devices diferentes (ex: Pixel 6 e Pixel 7).

**Terminal 1 — pai:**
```powershell
cd C:\dev\aura\aplicativo
flutter run -d emulator-5554
```

**Terminal 2 — criança:**
```powershell
cd C:\dev\aura2\aplicativo
flutter run -d emulator-5556
```

Edições nos arquivos `.dart` aparecem nas duas pastas (mesmo working tree do git). Só a `build/` é separada.

### Opção 2 — Um emulador, alternando login

Roda um `flutter run` só. Loga como pai → faz o que precisa → logout → loga como criança → faz o que precisa. Mais simples, menos visualmente convincente.

---

## Fluxo de teste end-to-end

Com os dois emuladores rodando:

### 1. Criar conta do pai (Emulador 1)

1. Tela de Login → toca em "Criar conta"
2. Preenche nome, e-mail (ex: `pai@teste.com`), senha (mínimo 6 chars)
3. **Marca o checkbox de aceite da Política de Privacidade**
4. Toca "Cadastrar" → vai para Role Select
5. Toca **"Este é o MEU celular"**
6. Lê a tela de transparência → marca checkbox → "Entendi, vamos configurar"
7. Chega na tela de gerar código → **anote o código de 6 dígitos** mostrado

### 2. Criar conta da criança (Emulador 2)

1. Tela de Login → "Criar conta"
2. Outro e-mail (ex: `filho@teste.com`)
3. Aceita os termos → Cadastrar → Role Select
4. Toca **"Este é o celular do MEU FILHO"**
5. Aceita a tela de transparência da criança
6. Concede as permissões (especialmente **"Acesso ao uso de apps"** — abre Configurações do Android, encontra "vigilia" e ativa)
7. Tela "Inserir código de vinculação" → digita o código que o pai gerou
8. Toca em validar → vincula → chega na home da criança

### 3. Pai seleciona apps a monitorar (Emulador 1)

1. Tab "Apps" no menu inferior
2. Marca os jogos que quer monitorar (ex: Sudoku, qualquer outro app instalado)
3. Toca "Salvar seleção" → snackbar "Seleção salva!"

### 4. Criança simula alertas (Emulador 2)

1. Na home da criança → "Modo Demo (simulação)"
2. Tela do Modo Beta com 3 botões coloridos
3. Toca **"Risco Alto"** → snackbar verde "Risco Alto simulado"
4. Toca **"Risco Médio"** → idem
5. Repete quantas vezes quiser

### 5. Pai recebe os alertas (Emulador 1)

1. Volta pra tab "Início" do pai
2. Em até **10 segundos** os alertas aparecem no card "Alertas recentes"
3. Cada um mostra: nível de risco · horário · app · "Toque para ver orientação"
4. Toca em um → tela de detalhe com:
   - Categoria geral (sem expor conteúdo específico)
   - Por que isso importa
   - Como conversar com seu filho (frases prontas)
   - Card "Leitura relacionada" → abre artigo da conscientização

### 6. Dispensar alerta

1. Na tela de detalhe → "Marcar como visto e dispensar"
2. Volta pra home → o alerta sumiu permanentemente

---

## Comandos úteis

### Backend

```powershell
# Subir
docker compose up --build

# Subir em background
docker compose up -d --build

# Parar
docker compose down

# Parar e apagar volumes (reset banco)
docker compose down -v

# Ver logs em tempo real
docker compose logs -f api
docker compose logs -f db

# Entrar no shell do container Django
docker compose exec api bash

# Rodar migrations manualmente
docker compose exec api python manage.py migrate

# Criar superuser
docker compose exec api python manage.py createsuperuser

# Shell do Django
docker compose exec api python manage.py shell
```

### Flutter

```powershell
# Listar emuladores/devices
flutter devices

# Listar emuladores configurados (mesmo offline)
flutter emulators

# Iniciar emulador pela linha de comando
flutter emulators --launch Pixel_6_API_34

# Build APK release
flutter build apk --release

# Limpar cache de build
flutter clean
flutter pub get

# Atualizar pacotes
flutter pub upgrade

# Diagnóstico de instalação
flutter doctor
```

### Git

```powershell
# Ver status
git status

# Pull antes de começar o dia
git pull

# Branch para nova feature
git checkout -b feat/minha-feature

# Voltar pra main
git checkout main
```

---

## Troubleshooting

### "port is already allocated" ao subir Docker

Algum container antigo ainda está rodando na porta 8000.

```powershell
docker ps -a
# Identifica o container antigo (ex: hackhero2026-api-1)
docker stop hackhero2026-api-1 hackhero2026-db-1
docker rm hackhero2026-api-1 hackhero2026-db-1
docker compose up --build
```

### "Bind for 0.0.0.0:8000 failed" mesmo sem containers

Algo no Windows está segurando a porta. Descubra o PID:

```powershell
netstat -ano | findstr :8000
# Pega o PID e mata:
taskkill /F /PID <numero>
```

### Build do Flutter falha com erro de lock

Geralmente Gradle daemon segurando arquivos.

```powershell
taskkill /F /IM java.exe
cd C:\dev\aura\aplicativo
flutter clean
flutter pub get
flutter run
```

### "Unable to delete directory mergeDebugAssets"

Mesma família — lock do Windows. Solução acima resolve.

### App fica na splash do Flutter (azul) sem abrir

Significa que o app não conseguiu inicializar. Quase sempre é o `SharedPreferences` falhando na primeira execução. O código atual tem timeout de 5s → vai pro login automaticamente. Se não acontecer:

```powershell
# Desinstala e reinstala
adb uninstall com.vigilia.vigilia
flutter run
```

### Erro 401 em todos os endpoints do app

Token JWT expirado ou problema de auth. Faz logout e login de novo.

### Notificação não aparece para a criança

Android 13+ requer permissão de notificação concedida manualmente. Quando a criança chega na home pela primeira vez o sistema pede. Se você negou, vá em **Configurações > Apps > vigilia > Notificações** e ative.

### Filho não aparece como vinculado para o pai

1. Verifica se o código não expirou (10 minutos de validade)
2. Reseta gerando novo código no perfil do pai
3. Se persistir: `docker compose down -v && docker compose up --build` (reset do banco)

---

## APIs

### Auth
| Método | Endpoint | Auth | Descrição |
|---|---|---|---|
| POST | `/api/auth/register/` | Público | Cadastro |
| POST | `/api/auth/login/` | Público | Login → JWT |
| POST | `/api/auth/refresh/` | Público | Renova token |
| GET | `/api/auth/me/` | JWT | Dados do usuário |
| POST | `/api/auth/link/generate/` | JWT | Pai gera código de pareamento |
| POST | `/api/auth/link/pair/` | JWT | Filho usa código |
| GET | `/api/auth/link/status/` | JWT | Status do vínculo |

### Devices
| Método | Endpoint | Auth | Descrição |
|---|---|---|---|
| GET | `/api/devices/` | JWT | Devices do usuário |
| GET | `/api/devices/children/` | JWT | Devices dos filhos vinculados |
| GET | `/api/devices/<token>/apps/` | JWT | Lista apps monitorados |
| POST | `/api/devices/<token>/apps/` | JWT | Bulk: `{"app_ids": [1,2,3]}` (pai) ou `{"apps": [...]}` (filho sync) |

### Monitoramento
| Método | Endpoint | Auth | Descrição |
|---|---|---|---|
| POST | `/api/analyze/` | Público | Imagem → IA → alerta |
| POST | `/api/simulate-alert/` | Público | `{"risk_level": "high_risk|attention|safe", "device_token": "..."}` — Modo Beta |
| GET | `/api/alerts/` | JWT | Histórico (filtra por filhos vinculados) |
| DELETE | `/api/alerts/<id>/` | JWT | Dispensa o alerta permanentemente |

---

## Conformidade legal

| Decisão técnica | Lei | Artigo |
|---|---|---|
| Imagem destruída imediatamente | Lei 15.211/2025 + Decreto 12.880/2026 | Art. 19 + Art. 24 §3 |
| Imagem nunca transmitida aos pais | Lei 15.211/2025 | Art. 19 caput |
| Tela de ciência + notificação fixa para criança | Lei 15.211/2025 | Art. 19 §1 |
| Aceite obrigatório da Política de Privacidade no cadastro | LGPD | Art. 8º |
| Botão de exclusão de conta no perfil | LGPD | Art. 18 |
| Somente jogos selecionados pelo pai são monitorados | LGPD | Art. 6º III (minimização) |
| Consentimento documentado do responsável | LGPD | Art. 14 |

> Análise informativa. Consulte advogado especializado antes de publicar em produção.

---

## Estrutura do repositório

```
aura/
├── aplicativo/                # App Flutter (pai + criança no mesmo APK)
│   ├── lib/
│   │   ├── config/            # Tema, rotas, API config
│   │   ├── data/              # Conteúdo estático (artigos de conscientização)
│   │   ├── models/            # User, Alert, Device, etc.
│   │   ├── providers/         # Estado via Provider
│   │   ├── screens/
│   │   │   ├── auth/          # Login, registro, role select
│   │   │   ├── child/         # Telas da criança
│   │   │   ├── pairing/       # Pareamento por código
│   │   │   ├── parent/        # Telas do pai
│   │   │   └── shared/        # Tela de transparência, política privacidade
│   │   ├── services/          # API, notificação, foreground watcher
│   │   └── widgets/           # Componentes compartilhados
│   ├── android/
│   │   └── app/src/main/kotlin/com/vigilia/vigilia/
│   │       └── MainActivity.kt    # MethodChannels nativos
│   └── pubspec.yaml
├── backend/                   # Django backend
│   ├── accounts/              # User, ParentalLink, PairingCode
│   ├── devices/               # Device, MonitoredApp
│   ├── monitoring/            # Alert, AnalyzeView, SimulateAlertView
│   ├── services/
│   │   └── ai_agent.py        # Integração com IA Vision
│   ├── vigilia/
│   │   └── settings.py
│   ├── Dockerfile
│   └── requirements.txt
├── docs/
│   ├── deploy/                # Scripts de deploy (preparados, não usados no MVP)
│   ├── pipeline.svg
│   └── vigilia_analise_legal.pdf
├── docker-compose.yml         # Ambiente de desenvolvimento
├── docker-compose.prod.yml    # Preparado para produção
└── README.md
```

---

## Equipe Pitaia

- **Henrique Cunha**
- **Namem Rachid**
- **Beatriz Dutra**

Hackathon Hacker Hero 2026 — Trilha Detecção e Monitoramento Inteligente.

---

*Aura — Privacidade e segurança não são opostos.*
