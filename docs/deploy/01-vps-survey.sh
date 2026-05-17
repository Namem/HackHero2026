#!/usr/bin/env bash
# Survey do estado da VPS — não modifica nada.
# Rode com: bash 01-vps-survey.sh > vps-state.txt 2>&1
# Depois cole o conteúdo de vps-state.txt aqui no chat.

set +e  # continua mesmo se algum comando falhar

echo "==================================================================="
echo "  AURA — Survey da VPS Hostinger"
echo "  Data: $(date -Iseconds 2>/dev/null || date)"
echo "==================================================================="

echo ""
echo "=== 1. SISTEMA OPERACIONAL ==="
echo "--- /etc/os-release ---"
cat /etc/os-release 2>/dev/null
echo "--- uname ---"
uname -a
echo "--- arquitetura ---"
arch 2>/dev/null

echo ""
echo "=== 2. RECURSOS DISPONÍVEIS ==="
echo "--- RAM (free -h) ---"
free -h 2>/dev/null
echo "--- Disco (df -h /) ---"
df -h / 2>/dev/null
echo "--- CPU (nproc) ---"
nproc 2>/dev/null

echo ""
echo "=== 3. USUÁRIO ATUAL ==="
whoami
id
echo "Diretório home: $HOME"
echo "Sudo disponível?"
sudo -n true 2>/dev/null && echo "SIM (sem senha)" || echo "Precisa senha (ok se for root)"

echo ""
echo "=== 4. DOCKER ==="
echo "--- docker --version ---"
docker --version 2>/dev/null || echo "NÃO INSTALADO"
echo "--- docker compose version ---"
docker compose version 2>/dev/null || echo "NÃO INSTALADO"
echo "--- docker ps (containers rodando) ---"
docker ps 2>/dev/null || echo "Sem permissão ou Docker ausente"

echo ""
echo "=== 5. NGINX / APACHE / CADDY ==="
echo "--- nginx -v ---"
nginx -v 2>&1 | head -1 || echo "NÃO INSTALADO"
echo "--- apache2 / httpd ---"
apache2 -v 2>/dev/null | head -1 || httpd -v 2>/dev/null | head -1 || echo "NÃO INSTALADO"
echo "--- caddy version ---"
caddy version 2>/dev/null || echo "NÃO INSTALADO"
echo "--- Serviços web rodando (systemctl) ---"
systemctl is-active nginx 2>/dev/null && echo "nginx ATIVO"
systemctl is-active apache2 2>/dev/null && echo "apache2 ATIVO"
systemctl is-active caddy 2>/dev/null && echo "caddy ATIVO"

echo ""
echo "=== 6. PORTAS EM USO ==="
echo "--- Portas TCP escutando (ss -tlnp) ---"
sudo ss -tlnp 2>/dev/null || ss -tln 2>/dev/null
echo "--- Conflitos esperados pelo Aura: 80, 443, 5432, 8000 ---"

echo ""
echo "=== 7. FIREWALL ==="
echo "--- ufw status ---"
sudo ufw status 2>/dev/null || echo "ufw ausente"
echo "--- iptables (resumo) ---"
sudo iptables -L INPUT -n --line-numbers 2>/dev/null | head -10 || echo "sem acesso a iptables"

echo ""
echo "=== 8. SITE ATUAL EM numik.com.br ==="
echo "--- DNS público (dig) ---"
dig +short numik.com.br A 2>/dev/null || nslookup numik.com.br 2>/dev/null | head -10
echo "--- IP público da própria VPS ---"
curl -s --max-time 5 ifconfig.me 2>/dev/null
echo ""
echo "--- Resposta HTTP do site atual (curl head) ---"
curl -sI --max-time 5 http://numik.com.br 2>/dev/null | head -10
echo "--- HTTPS ---"
curl -sI --max-time 5 https://numik.com.br 2>/dev/null | head -10
echo ""
echo "--- Configs nginx (se houver) ---"
ls -la /etc/nginx/sites-enabled/ 2>/dev/null
ls -la /etc/nginx/conf.d/ 2>/dev/null
echo "--- Procurando arquivos do site atual ---"
ls -la /var/www/ 2>/dev/null
ls -la /usr/share/nginx/html/ 2>/dev/null | head -5

echo ""
echo "=== 9. GIT INSTALADO ==="
git --version 2>/dev/null || echo "NÃO INSTALADO"

echo ""
echo "=== 10. CHAVES SSH AUTHORIZED ==="
echo "Total de chaves em ~/.ssh/authorized_keys:"
wc -l ~/.ssh/authorized_keys 2>/dev/null || echo "sem authorized_keys"

echo ""
echo "==================================================================="
echo "  FIM DO SURVEY"
echo "==================================================================="
