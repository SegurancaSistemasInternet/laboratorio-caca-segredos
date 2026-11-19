#!/usr/bin/env bash
# Executado uma única vez, quando o Codespace é criado.
# Instala o gitleaks (versão fixa, do GitHub oficial do projeto) e o jq.
set -e
VERSAO=8.30.1
sudo apt-get update -y
sudo apt-get install -y jq curl
curl -sSL -o /tmp/gitleaks.tar.gz \
  "https://github.com/gitleaks/gitleaks/releases/download/v${VERSAO}/gitleaks_${VERSAO}_linux_x64.tar.gz"
sudo tar -xzf /tmp/gitleaks.tar.gz -C /usr/local/bin gitleaks
rm -f /tmp/gitleaks.tar.gz
chmod +x preparar.sh
echo
echo "============================================================"
echo " Ambiente pronto: gitleaks $(gitleaks version) · $(jq --version)"
echo " Siga o README.md (Etapa 0, Checkpoint 0)"
echo "============================================================"
