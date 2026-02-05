# 🚀 Guia Rápido - Git para Garry's Mod

## ⚡ Setup Inicial (fazer 1 vez)

```bash
# 1. Inicializar Git
git init

# 2. Adicionar origem remota (substitua pela sua URL)
git remote add origin https://github.com/seu-usuario/servidor-gmod.git

# 3. Fazer primeiro commit
git add .
git commit -m "initial: estrutura inicial do servidor"

# 4. Enviar para o GitHub
git branch -M main
git push -u origin main
```

---

## 📝 Comandos do Dia-a-Dia

### Antes de começar a trabalhar
```bash
git pull origin main
```

### Criar nova feature
```bash
git checkout -b feature/nome-da-feature
```

### Ver o que mudou
```bash
git status
git diff
```

### Salvar mudanças
```bash
# Adicionar arquivos específicos
git add garrysmod/lua/autorun/meu_script.lua

# Ou adicionar tudo
git add .

# Commit
git commit -m "feat: adiciona sistema de X"

# Push
git push origin feature/nome-da-feature
```

### Voltar para a branch principal
```bash
git checkout main
```

---

## 🛠️ Comandos Úteis

### Ver histórico
```bash
git log --oneline
```

### Desfazer mudanças locais
```bash
# Desfazer mudanças em um arquivo
git checkout -- garrysmod/lua/autorun/meu_script.lua

# Desfazer TODAS as mudanças
git reset --hard HEAD
```

### Atualizar do remoto
```bash
git fetch origin
git merge origin/main
```

---

## ❌ O que NÃO fazer

- ❌ `git add garrysmod/maps/` (mapas são muito grandes!)
- ❌ `git add garrysmod/materials/` (texturas são pesadas!)
- ❌ `git add garrysmod/models/` (modelos 3D não vão no Git!)
- ❌ Commitar senhas ou tokens no código

---

## ✅ O que PODE fazer

- ✅ `git add garrysmod/lua/`
- ✅ `git add garrysmod/gamemodes/`
- ✅ `git add garrysmod/addons/meu_addon/lua/`
- ✅ `git add garrysmod/cfg/*.example`
---

## 🆘 Problemas Comuns

### "Accidentally committed large files"
```bash
# Remover do Git (mantém no disco)
git rm --cached garrysmod/maps/*.bsp
git commit -m "fix: remove mapas do Git"
git push --force
```

### "Conflicts ao fazer pull"
```bash
git stash           # Salva suas mudanças
git pull            # Atualiza
git stash pop       # Reaplica suas mudanças
# Resolva conflitos manualmente
```

### "Esqueci de criar uma branch"
```bash
git stash
git checkout -b minha-feature
git stash pop
```

---

## 📊 Estrutura de Commits

Use prefixos para organizar:

- `feat:` - Nova funcionalidade
- `fix:` - Correção de bug
- `refactor:` - Refatoração de código
- `docs:` - Documentação
- `style:` - Formatação
- `test:` - Testes
- `chore:` - Manutenção

**Exemplos:**
```bash
git commit -m "feat: adiciona sistema de economia"
git commit -m "fix: corrige bug no spawn de NPCs"
git commit -m "docs: atualiza README com novas instruções"
```

---

## 🔗 Links Úteis

- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [GitHub Desktop](https://desktop.github.com/) (interface gráfica)
- [GitKraken](https://www.gitkraken.com/) (interface avançada)
