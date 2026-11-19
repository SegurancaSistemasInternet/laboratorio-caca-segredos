#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Cria, na pasta ./portalagenda, uma cópia FICTÍCIA do repositório do
# PortalAgenda (Cais Azul, empresa fictícia), com histórico de commits e
# segredos FALSOS esquecidos ao longo do caminho.
#
# Uso:  bash preparar.sh
#
# Tudo aqui é inventado para a aula: nenhuma senha, chave ou token deste
# repositório dá acesso a qualquer sistema real. Mesmo assim, NÃO envie a
# pasta portalagenda para o GitHub (ela está no .gitignore).
# ---------------------------------------------------------------------------
set -euo pipefail
cd "$(dirname "$0")"
DEST=portalagenda

if [ -e "$DEST" ]; then
  echo "A pasta $DEST já existe."
  echo "Para recomeçar do zero:  rm -rf $DEST && bash preparar.sh"
  exit 1
fi

mkdir -p "$DEST"
cd "$DEST"
git init -q
git symbolic-ref HEAD refs/heads/main
git config commit.gpgsign false
git config user.name "Lucas Amaral"
git config user.email "lucas.amaral@caisazul.test"

PKG=src/main/java/br/test/caisazul/portalagenda

# commit "<autor>" "<email>" "<data>" "<mensagem>"
commit() {
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" \
  GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" \
    git commit -q -m "$4"
}
LUCAS=("Lucas Amaral" "lucas.amaral@caisazul.test")
BIANCA=("Bianca Rocha" "bianca.rocha@caisazul.test")

# ---------------------------------------------------------------- commit 1
mkdir -p "$PKG/agenda"
cat > README.md <<'EOF'
# PortalAgenda

Agendamento de janelas de atendimento no gate da Cais Azul.

> Repositório **fictício**, criado para a disciplina Segurança de Sistemas.
EOF
cat > pom.xml <<'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0">
  <modelVersion>4.0.0</modelVersion>
  <groupId>br.test.caisazul</groupId>
  <artifactId>portalagenda</artifactId>
  <version>1.4.0</version>
  <packaging>jar</packaging>
</project>
EOF
cat > "$PKG/PortalAgendaApplication.java" <<'EOF'
package br.test.caisazul.portalagenda;

public class PortalAgendaApplication {
    public static void main(String[] args) {
        System.out.println("PortalAgenda iniciado");
    }
}
EOF
cat > "$PKG/agenda/AgendaService.java" <<'EOF'
package br.test.caisazul.portalagenda.agenda;

import java.time.LocalTime;

public class AgendaService {
    private static final int JANELA_MINUTOS = 30;

    public LocalTime fimDaJanela(LocalTime inicio) {
        return inicio.plusMinutes(JANELA_MINUTOS);
    }
}
EOF
commit "${LUCAS[@]}" "2026-03-02T09:14:00-03:00" "Estrutura inicial do PortalAgenda"

# ---------------------------------------------------------------- commit 2
mkdir -p src/main/resources "$PKG/banco"
cat > src/main/resources/application.properties <<'EOF'
# Banco de motoristas (rede interna)
spring.datasource.url=jdbc:postgresql://db-motoristas.caisazul.test:5432/portalagenda
spring.datasource.username=portalagenda
spring.datasource.password=Pg7xQm2vLr9KtW4nZb8s
EOF
cat > "$PKG/banco/BancoConfig.java" <<'EOF'
package br.test.caisazul.portalagenda.banco;

public class BancoConfig {
    // Usado só nos testes de homologação. TODO: tirar daqui depois.
    private static final String SENHA_BANCO_HOMOLOG = "Homolog@CaisAzul2026";

    public String senhaHomologacao() {
        return SENHA_BANCO_HOMOLOG;
    }
}
EOF
commit "${LUCAS[@]}" "2026-03-09T16:40:00-03:00" "Configuração do banco de dados"

# ---------------------------------------------------------------- commit 3
mkdir -p "$PKG/integracao"
cat > "$PKG/integracao/MapasClient.java" <<'EOF'
package br.test.caisazul.portalagenda.integracao;

public class MapasClient {
    // Chave do serviço de mapas (a mesma que vai no App Motorista)
    private static final String MAPS_API_KEY = "mpk_9fK2xQ7LmT4vB8nR1sW6yZ3cD5hJ0gE";

    public String urlRota(String origem, String destino) {
        return "https://mapas.exemplo.test/rota?o=" + origem + "&d=" + destino + "&k=" + MAPS_API_KEY;
    }
}
EOF
commit "${BIANCA[@]}" "2026-04-14T11:05:00-03:00" "Integração com o serviço de mapas do App Motorista"

# ---------------------------------------------------------------- commit 4
cat > .env <<'EOF'
# Ambiente de desenvolvimento
PAGAPORTO_WEBHOOK_SECRET=whsec_4Rt8Yp2Kq6Vn9Xb3Lm7Zc1Fd5Gh0Js
SMS_API_TOKEN=smst_7Hc2Np9Qx4Rv8Lk3Wm6Zb1Td5Ys0Fg
EOF
commit "${BIANCA[@]}" "2026-05-20T18:22:00-03:00" "Variáveis de ambiente do PagaPorto e do serviço de SMS"

# ---------------------------------------------------------------- commit 5
mkdir -p deploy
if command -v ssh-keygen >/dev/null 2>&1; then
  ssh-keygen -q -t ed25519 -N "" -C "deploy@portalagenda" -f deploy/chave-deploy
else
  openssl genpkey -algorithm ed25519 -out deploy/chave-deploy 2>/dev/null
  openssl pkey -in deploy/chave-deploy -pubout -out deploy/chave-deploy.pub 2>/dev/null
fi
cat > deploy/LEIAME.md <<'EOF'
# Publicação

Chave usada para publicar o PortalAgenda nos servidores da DMZ via SSH.
Assim qualquer pessoa da equipe consegue publicar quando o Lucas estiver de férias.
EOF
commit "${LUCAS[@]}" "2026-06-03T22:47:00-03:00" "Chave de deploy para publicar sem depender do Lucas"

# ---------------------------------------------------------------- commit 6
mkdir -p docs
cat > docs/api.md <<'EOF'
# API do App Motorista

Toda chamada leva o token de acesso no cabeçalho `Authorization`.
Exemplo (token de exemplo da documentação do padrão JWT, não é de nenhum usuário):

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

| Método | Caminho | Uso |
|---|---|---|
| POST | /api/v1/login | entrar |
| GET | /api/v1/agendamentos | listar agendamentos |
| POST | /api/v1/checkin | registrar chegada ao gate |
EOF
commit "${BIANCA[@]}" "2026-07-08T10:31:00-03:00" "Documentação da API"

# ---------------------------------------------------------------- commit 7
git rm -q .env deploy/chave-deploy
cat > .gitignore <<'EOF'
.env
deploy/chave-*
EOF
cat > src/main/resources/application.properties <<'EOF'
# Banco de motoristas (rede interna)
spring.datasource.url=jdbc:postgresql://db-motoristas.caisazul.test:5432/portalagenda
spring.datasource.username=portalagenda
spring.datasource.password=${DB_PASSWORD}
EOF
cat > "$PKG/integracao/MapasClient.java" <<'EOF'
package br.test.caisazul.portalagenda.integracao;

public class MapasClient {
    private static final String MAPS_API_KEY = System.getenv("MAPS_API_KEY");

    public String urlRota(String origem, String destino) {
        return "https://mapas.exemplo.test/rota?o=" + origem + "&d=" + destino + "&k=" + MAPS_API_KEY;
    }
}
EOF
commit "${BIANCA[@]}" "2026-08-11T09:02:00-03:00" "Remove segredos do repositório"

# ---------------------------------------------------------------- commit 8
sed -i 's/JANELA_MINUTOS = 30/JANELA_MINUTOS = 40/' "$PKG/agenda/AgendaService.java"
commit "${LUCAS[@]}" "2026-09-15T14:20:00-03:00" "Aumenta a janela de atendimento para 40 minutos"

echo
echo "Repositório fictício criado em ./$DEST com $(git rev-list --count HEAD) commits."
echo "Próximo passo: siga a Etapa 1 do README."
