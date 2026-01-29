# 📦 Estrutura de Versionamento - Servidor Garry's Mod

## 🎯 Objetivo

Manter o repositório Git **leve e eficiente** para trabalho em equipe, separando:
- ✅ **Código e configs** → Git (versionado)
- ❌ **Assets pesados** → Sincronização externa (Drive/Syncthing/OneDrive)

---

## 📁 Estrutura Recomendada

```
📂 servidor-gmod/
├── 📂 server-code/              ← VERSIONADO NO GIT
│   ├── garrysmod/
│   │   ├── gamemodes/           ← Seus gamemodes customizados
│   │   │   └── meu_gamemode/
│   │   │       ├── gamemode/
│   │   │       └── entities/
│   │   ├── lua/                 ← Scripts Lua globais
│   │   │   ├── autorun/
│   │   │   └── includes/
│   │   ├── addons/              ← Apenas addons LEVES (código)
│   │   │   └── meu_addon/
│   │   │       ├── lua/
│   │   │       └── addon.json
│   │   ├── cfg/                 ← Configs de exemplo
│   │   │   ├── server.cfg.example
│   │   │   └── autoexec.cfg.example
│   │   ├── data/                ← Configs de gamemode (excluir DBs)
│   │   └── html/                ← Menus HTML customizados
│   ├── .gitignore               ← Configuração do Git
│   ├── README.md                ← Documentação do servidor
│   ├── start.bat                ← Script de inicialização
│   └── INSTALL.md               ← Guia de instalação
│
└── 📂 server-assets/            ← NÃO VERSIONADO (sincronizar externamente)
    ├── garrysmod/
    │   ├── maps/                ← Mapas (.bsp, .nav)
    │   ├── materials/           ← Texturas
    │   ├── models/              ← Modelos 3D
    │   ├── sound/               ← Arquivos de áudio
    │   ├── particles/           ← Efeitos
    │   ├── addons/              ← Addons do Workshop com assets
    │   │   ├── ttt_content/
    │   │   ├── css_realistic/
    │   │   └── map_pack/
    │   └── cache/               ← Cache do jogo
    ├── sourceengine/            ← VPKs do Source
    ├── bin/                     ← Binários do servidor
    └── logs/                    ← Logs do servidor
```

---

## 🔧 O que vai para o Git?

### ✅ INCLUÍDO (versionado)

| Tipo | Pasta | Descrição |
|------|-------|-----------|
| **Código Lua** | `garrysmod/gamemodes/` | Seus gamemodes customizados |
| **Código Lua** | `garrysmod/lua/` | Scripts globais (autorun, includes) |
| **Addons Leves** | `garrysmod/addons/*/lua/` | Apenas a pasta `lua/` de addons |
| **Configs** | `garrysmod/cfg/*.example` | Configs de exemplo (não sensíveis) |
| **HTML/CSS/JS** | `garrysmod/html/` | Interfaces web customizadas |
| **Documentação** | `*.md`, `*.txt` | README, guias, licenças |
| **Scripts** | `*.bat`, `*.sh` | Scripts de inicialização |

### ❌ EXCLUÍDO (não versionado)

| Tipo | Pasta | Motivo |
|------|-------|--------|
| **Maps** | `garrysmod/maps/` | Arquivos grandes (50-500 MB cada) |
| **Materials** | `garrysmod/materials/` | Milhares de texturas |
| **Models** | `garrysmod/models/` | Modelos 3D pesados |
| **Sounds** | `garrysmod/sound/` | Arquivos de áudio grandes |
| **VPK** | `*.vpk` | Arquivos compactados do Source |
| **Cache** | `cache/`, `appcache/` | Dados temporários |
| **Logs** | `logs/`, `*.log` | Arquivos de log |
| **Binários** | `bin/`, `*.dll`, `*.exe` | Executáveis do servidor |
| **Addons Pesados** | `addons/*/models/`, etc. | Assets de addons do Workshop |

---

## 👥 Workflow para Desenvolvedores

### 1️⃣ Configuração Inicial

#### A. Clonar o repositório (código)
```bash
git clone https://github.com/seu-usuario/servidor-gmod.git server-code
cd server-code
```

#### B. Baixar os assets (escolha um método)

**Opção 1: Google Drive**
```
1. Entre na pasta compartilhada "Servidor GMOD - Assets"
2. Baixe a pasta "server-assets" completa
3. Coloque ao lado da pasta "server-code"
```

**Opção 2: Syncthing (recomendado para equipes)**
```
1. Instale o Syncthing: https://syncthing.net/
2. Adicione a pasta compartilhada "server-assets"
3. Configure para sincronizar automaticamente
```

**Opção 3: OneDrive / Dropbox**
```
1. Configure a pasta compartilhada no seu PC
2. Mantenha "server-assets" sempre sincronizado
```

#### C. Estrutura final no seu PC
```
📂 C:\servidor-gmod\
├── 📂 server-code\          ← Repositório Git
└── 📂 server-assets\        ← Sincronizado via Drive/Syncthing
```

---

### 2️⃣ Desenvolvimento Diário

#### 🔹 Trabalhando com CÓDIGO (Git)

```bash
# 1. Sempre puxe as últimas mudanças antes de começar
git pull origin main

# 2. Crie uma branch para sua feature
git checkout -b feature/novo-gamemode

# 3. Faça suas alterações no código
# Edite arquivos em garrysmod/lua/, gamemodes/, etc.

# 4. Adicione e commit
git add garrysmod/gamemodes/meu_gamemode/
git commit -m "feat: adiciona sistema de economia"

# 5. Envie para o repositório
git push origin feature/novo-gamemode

# 6. Abra um Pull Request no GitHub/GitLab
```

#### 🔹 Trabalhando com ASSETS (Drive/Syncthing)

```
1. Adicione novos maps/models/materials em "server-assets/"
2. A sincronização acontece automaticamente
3. Avise a equipe no Discord/Slack quando adicionar assets grandes
4. NÃO tente commitar assets no Git!
```

---

### 3️⃣ Sincronização de Assets

#### 🔄 Syncthing (Recomendado)

**Vantagens:**
- ✅ Sincronização automática P2P
- ✅ Sem limites de tamanho
- ✅ Rápido e eficiente
- ✅ Controle de versão de arquivos

**Configuração:**
```
1. Instale: https://syncthing.net/downloads/
2. Abra a interface web (http://127.0.0.1:8384)
3. Adicione o dispositivo do líder da equipe
4. Compartilhe a pasta "server-assets"
5. Configure para sincronizar automaticamente
```

#### ☁️ Google Drive

**Vantagens:**
- ✅ Fácil de usar
- ✅ 15 GB grátis
- ✅ Backup automático

**Limitações:**
- ⚠️ Limite de 15 GB (pode ser pouco)
- ⚠️ Sincronização pode ser lenta

**Uso:**
```
1. Crie uma pasta "Servidor GMOD - Assets" no Drive
2. Compartilhe com a equipe (permissão de edição)
3. Configure o Google Drive Desktop
4. Mantenha a pasta "server-assets" sempre sincronizada
```

#### 📁 OneDrive / Dropbox

Similar ao Google Drive, mas com:
- OneDrive: 5 GB grátis (pode integrar com Office 365)
- Dropbox: 2 GB grátis

---

### 4️⃣ Boas Práticas

#### ✅ DO (Faça)

- ✅ Sempre `git pull` antes de começar a trabalhar
- ✅ Use branches para novas features
- ✅ Escreva mensagens de commit descritivas
- ✅ Mantenha os assets sincronizados via Drive/Syncthing
- ✅ Teste localmente antes de dar push
- ✅ Documente mudanças importantes no README

#### ❌ DON'T (Não Faça)

- ❌ **NUNCA** commite assets (maps, models, materials, sounds)
- ❌ Não commite configs sensíveis (senhas, IPs, chaves)
- ❌ Não faça push direto para `main` (use branches)
- ❌ Não faça commits gigantes (quebre em partes menores)
- ❌ Não ignore o `.gitignore` (ele está lá por um motivo!)

---

## 🚀 Iniciar o Servidor

### Desenvolvimento Local

```bash
# Windows
cd server-code
start.bat

# Linux
cd server-code
./start.sh
```

### Produção (VPS/Dedicado)

```bash
# 1. Clone o código
git clone https://github.com/seu-usuario/servidor-gmod.git /home/gmod/server-code

# 2. Sincronize os assets (rsync, scp, ou Syncthing)
rsync -avz user@assets-server:/server-assets/ /home/gmod/server-assets/

# 3. Configure os links simbólicos (se necessário)
ln -s /home/gmod/server-assets/garrysmod/maps /home/gmod/server-code/garrysmod/maps

# 4. Inicie o servidor
cd /home/gmod/server-code
./start.sh
```

---

## 🔐 Configs Sensíveis

### Exemplo: `server.cfg.example`

```lua
// ==============================================
// Configuração do Servidor Garry's Mod
// ==============================================
// RENOMEIE PARA server.cfg E EDITE OS VALORES

hostname "Meu Servidor GMOD"
sv_password ""
rcon_password "SUA_SENHA_AQUI"

sv_region "3"  // South America
sv_lan 0
sv_allow_lobby_connect_only 0

// Network
sv_maxrate 0
sv_minrate 75000
sv_maxupdaterate 66
sv_minupdaterate 10

// Game Settings
mp_friendlyfire 0
sbox_godmode 0

// Workshop Collection
host_workshop_collection "123456789"
```

**IMPORTANTE:** 
- O arquivo `server.cfg.example` vai para o Git
- O arquivo `server.cfg` (com senhas reais) NÃO vai para o Git (está no `.gitignore`)

---

## 📊 Tamanho Esperado

| Componente | Tamanho | Versionado? |
|-----------|---------|-------------|
| **server-code** (Git) | ~50-200 MB | ✅ Sim |
| **server-assets** (Drive) | ~5-50 GB | ❌ Não |
| **Total** | ~5-50 GB | - |

---

## 🆘 Problemas Comuns

### "Git push dá timeout"
**Causa:** Você tentou commitar assets pesados.
**Solução:**
```bash
# Remova os arquivos grandes do histórico
git rm --cached garrysmod/maps/*.bsp
git commit -m "fix: remove mapas do Git"
git push
```

### "Assets não aparecem no servidor"
**Causa:** Falta sincronizar a pasta `server-assets`.
**Solução:** Verifique se o Drive/Syncthing está sincronizado.

### "Conflitos no Git ao dar pull"
**Causa:** Você e outro dev editaram o mesmo arquivo.
**Solução:**
```bash
# Salve suas mudanças
git stash

# Puxe as mudanças
git pull origin main

# Reaplique suas mudanças
git stash pop

# Resolva conflitos manualmente e commit
```

---

## 📚 Recursos Úteis

- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [Syncthing Docs](https://docs.syncthing.net/)
- [Garry's Mod Wiki](https://wiki.facepunch.com/gmod/)
- [GLua Reference](https://wiki.facepunch.com/gmod/~)

---

## 📞 Suporte

Dúvidas? Entre em contato:
- 💬 Discord: `#dev-suporte`
- 📧 Email: `admin@servidor.com`
- 🐛 Issues: [GitHub Issues](https://github.com/seu-usuario/servidor-gmod/issues)

---

**Última atualização:** Janeiro 2026
