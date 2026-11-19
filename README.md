# Laboratório: caça aos segredos no Git

> Disciplina **Segurança de Sistemas** · Bloco 3 (gestão de chaves e segredos) · ⏱️ cerca de 50 minutos

A equipe de desenvolvimento da Cais Azul, empresa fictícia de logística portuária usada nas aulas, nunca fez varredura de segredos no repositório do **PortalAgenda**. Neste laboratório você faz o papel da **Marina**, a analista de segurança: vai procurar senhas, chaves e tokens esquecidos no código **e no histórico do Git** e decidir o que cada achado exige.

> **Hipótese desta atividade:** o repositório que você vai analisar é uma cópia fictícia do PortalAgenda, criada para a aula com segredos **falsos**. Nenhuma senha, chave ou token deste laboratório dá acesso a qualquer sistema real.

Tudo roda no **GitHub Codespaces**, uma máquina Linux na nuvem acessada pelo navegador: **não é preciso instalar nada nem ter acesso de administrador** no computador do laboratório. Você vai trabalhar numa **cópia deste repositório na sua própria conta do GitHub**, com um Codespace seu.

---

## Antes de tudo: o que você vai entregar

Você vai preencher um **documento Word** durante a atividade e enviá-lo na **tarefa do Teams**.

1. O modelo é o arquivo [`entrega/Modelo-Entrega-Caca-Segredos.docx`](entrega/Modelo-Entrega-Caca-Segredos.docx), que vem junto com a **sua cópia** do repositório. Você vai baixá-lo na **Etapa 0**, logo depois de criar a cópia.
2. Abra o arquivo no Word e deixe-o aberto ao lado do navegador.
3. Ao longo do roteiro, sempre que aparecer **📸 EVIDÊNCIA**, tire um print e cole no quadro correspondente do documento.
4. Na **Etapa 6**, preencha a **tabela de classificação dos achados**.
5. No fim, salve como `Entrega-Segredos-SeuNome.docx` e envie na tarefa do Teams.

> 📷 **Como tirar print:** no Windows, **Windows + Shift + S**, selecione a área e cole no Word com **Ctrl + V**. No Mac, **Cmd + Ctrl + Shift + 4** e **Cmd + V**.

**Os símbolos deste roteiro**

| Símbolo | Significado |
|---|---|
| ✅ **CHECKPOINT** | Confira se está tudo certo antes de seguir. Se não estiver, veja [Problemas comuns](#problemas-comuns). |
| 📸 **EVIDÊNCIA** | Tire o print indicado e cole no documento de entrega. |

**Resumo da entrega**

| Item | Onde acontece |
|---|---|
| 📸 Evidência 1 — o repositório da Cais Azul | Etapa 1 |
| 📸 Evidência 2 — a varredura da versão atual | Etapa 2 |
| 📸 Evidência 3 — a varredura do histórico | Etapa 3 |
| 📸 Evidência 4 — o segredo "apagado" | Etapa 4 |
| 📸 Evidência 5 — o que a ferramenta não viu | Etapa 5 |
| 📝 Tabela de classificação dos achados | Etapa 6 |

**Quanto tempo leva**

| Parte    | O que você faz | Tempo esperado | Tempo acumulado |
|---|---|---|---|
| Parte&nbsp;1 | Ler o essencial da teoria | 5 min | 5 min |
| Etapa&nbsp;0 | Criar a cópia do repositório, baixar o modelo e abrir o Codespace | 7 min | 12 min |
| Etapa&nbsp;1 | Gerar e conhecer o repositório da Cais Azul · 📸 Evidência 1 | 4 min | 16 min |
| Etapa&nbsp;2 | Varrer a versão atual · 📸 Evidência 2 | 4 min | 20 min |
| Etapa&nbsp;3 | Varrer o histórico · 📸 Evidência 3 | 6 min | 26 min |
| Etapa&nbsp;4 | Confirmar no Git que "apagar" não apagou · 📸 Evidência 4 | 5 min | 31 min |
| Etapa&nbsp;5 | Encontrar o que a ferramenta não viu · 📸 Evidência 5 | 6 min | 37 min |
| Etapa&nbsp;6 | Classificar os achados (tabela) | 8 min | 45 min |
| Etapa&nbsp;7 | Encerrar o Codespace e enviar no Teams | 4 min | 49 min |
| **Total** | | **cerca de 50 min** | |

> ⏱️ Se uma etapa passar muito do tempo esperado, consulte [Problemas comuns](#problemas-comuns) ou chame o professor.

---

## Parte 1 — O essencial em 5 minutos

**Segredo.** É tudo o que, nas mãos erradas, permite ler, alterar, assinar ou entrar no lugar de alguém: senhas de banco de dados, chaves de API, tokens, chaves privadas. Um segredo escrito no código vai junto para todo lugar aonde o código vai.

**O Git guarda tudo.** Cada **commit** é uma "foto" completa do projeto naquele momento, e o **histórico** guarda todas as fotos. Apagar um segredo num commit novo tira o segredo da foto **atual**, mas as fotos antigas continuam lá — em todas as cópias do repositório, em todos os computadores que já o baixaram.

**Varredura de segredos.** Ferramentas como o **gitleaks** procuram segredos com **regras**: formatos conhecidos (uma chave privada sempre começa com `-----BEGIN … PRIVATE KEY-----`) e combinações de palavra-chave com um valor "aleatório demais" para ser texto comum. Essa aleatoriedade é medida pela **entropia**: quanto mais imprevisível a sequência de caracteres, maior a entropia. O gitleaks tem dois modos principais:

| Modo | O que examina |
|---|---|
| `gitleaks dir` | só os arquivos como estão **agora** |
| `gitleaks git` | **todos os commits** do histórico |

**Nenhuma ferramenta é perfeita.**

- **Falso positivo:** a ferramenta aponta algo que não é segredo de verdade, como um exemplo público de documentação.
- **Falso negativo:** um segredo de verdade que a ferramenta **não** encontra, por exemplo porque a regra não conhece o nome da variável.

**Achou um segredo de verdade? A ordem importa.**

1. **Revogar ou trocar** o segredo no sistema de origem: só isso tira o acesso de quem já copiou.
2. Tirar o segredo do código e guardá-lo num **cofre de segredos** ou numa **variável de ambiente**.
3. Avisar quem precisa saber e verificar se o segredo foi usado indevidamente.
4. Opcionalmente, reescrever o histórico do Git — o que **não substitui** o passo 1.

**No cenário.** O PortalAgenda é mantido por **Lucas Amaral** e **Bianca Rocha**; a publicação é feita pelo Lucas via SSH nos servidores da DMZ; e a equipe **não faz varredura de segredos**. Hoje você vai fazer a primeira.

---

## Parte 2 — Roteiro

**Como trabalhar**

- Use o **terminal** do Codespace, na parte de baixo do editor. Se não estiver aberto: menu **☰ → Terminal → New Terminal**.
- A partir da Etapa 1, os comandos rodam **dentro da pasta `portalagenda`**. O caminho aparece antes do `$` no terminal.
- Para copiar um comando, use o botão de copiar que aparece no canto do bloco de código.
- Os comandos do gitleaks mostram um aviso de "leaks found" e terminam com código de erro quando encontram algo: **isso é o esperado** neste laboratório.

### Etapa 0 — Preparar o ambiente (7 min)

1. Entre no GitHub com a **sua conta**.
2. **Crie a sua cópia deste repositório:** acima da lista de arquivos desta página, ao lado do botão **Code**, clique no botão verde **Use this template → Create a new repository**. Em *Owner*, escolha a **sua conta**; dê um nome (por exemplo, `laboratorio-caca-segredos`) e clique em **Create repository**.
3. **Baixe o modelo de entrega da sua cópia:** na página da sua cópia (o endereço no navegador começa com `github.com/SEU-USUARIO/`), abra a pasta **`entrega`**, clique em **`Modelo-Entrega-Caca-Segredos.docx`** e use o botão **⬇ Download raw file**, à direita, acima da área do arquivo. Abra o arquivo no Word e preencha nome, RA, turma e data.
4. **Ainda na sua cópia**, volte à página inicial dela e clique no botão verde **Code → aba Codespaces → Create codespace on main**. Assim o Codespace fica na sua conta e usa a sua cota.
5. Aguarde: na primeira vez, a criação e a instalação do gitleaks levam de 2 a 3 minutos. O editor abre no navegador. Para acompanhar este roteiro enquanto trabalha, coloque o README no modo de pré-visualização: clique no arquivo `README.md` no painel de arquivos e pressione **Ctrl + Shift + V**. A pré-visualização abre ao lado do editor; deixe-a visível e abra o terminal em **☰ → Terminal → New Terminal**.
6. Quando a instalação terminar, confira:

```bash
gitleaks version
jq --version
```

> ✅ **CHECKPOINT 0** — O modelo de entrega está aberto no Word, com a sua identificação. O Codespace está aberto a partir da **sua cópia** do repositório. O terminal mostrou a mensagem **"Ambiente pronto"**, o `gitleaks version` mostrou um número que começa com **8** e o `jq --version` respondeu.

### Etapa 1 — Gerar e conhecer o repositório da Cais Azul (4 min)

O script `preparar.sh` cria, na pasta `portalagenda`, a cópia fictícia do repositório do PortalAgenda, com 8 commits feitos pelo Lucas e pela Bianca entre março e setembro de 2026.

```bash
bash preparar.sh
cd portalagenda
```

Veja o histórico e os arquivos da versão atual:

```bash
git log --format='%h  %ad  %an  %s' --date=short
ls -a
ls deploy
```

Repare no penúltimo commit: **"Remove segredos do repositório"**. Na versão atual não há arquivo `.env` nem chave privada na pasta `deploy` — só a chave **pública** (`chave-deploy.pub`), que não é segredo.

> ✅ **CHECKPOINT 1** — O `git log` mostrou **8 commits**, o mais antigo "Estrutura inicial do PortalAgenda" e o mais recente "Aumenta a janela de atendimento para 40 minutos". O caminho antes do `$` termina em **`/portalagenda`**.

> 📸 **EVIDÊNCIA 1 — O repositório da Cais Azul.** Print do terminal com os 8 commits do `git log` e a listagem dos arquivos (`ls -a` e `ls deploy`).

### Etapa 2 — Varrer a versão atual (4 min)

Primeiro, a varredura que muita equipe faz: só nos arquivos como estão **agora**.

```bash
gitleaks dir . -v --no-banner
```

Para cada achado, o gitleaks mostra a regra (`RuleID`), o arquivo (`File`), a linha e o trecho encontrado. No fim, ele diz quantos achados houve.

> ✅ **CHECKPOINT 2** — A última linha diz **`leaks found: 1`**. O único achado é da regra **`jwt`**, no arquivo **`docs/api.md`**.

> 📸 **EVIDÊNCIA 2 — A varredura da versão atual.** Print com o achado (`RuleID`, `File`) e a linha `leaks found: 1`.

### Etapa 3 — Varrer o histórico (7 min)

Agora a varredura de **todos os commits**:

```bash
gitleaks git . -v --no-banner
```

A saída é longa: role o terminal para cima para ver todos os achados. Para cada um, além da regra e do arquivo, aparecem o **commit**, o **autor** e a **data**.

Gere também um relatório em JSON e veja um resumo, um achado por linha:

```bash
gitleaks git . --no-banner --report-path ../relatorio.json
jq -r '.[] | [.RuleID, .File, .Commit[0:7], .Author] | @tsv' ../relatorio.json
```

> ✅ **CHECKPOINT 3** — A varredura terminou com **`leaks found: 6`** e o resumo do `jq` mostra **6 linhas**: 4 da regra `generic-api-key` (em `application.properties`, `MapasClient.java` e duas no `.env`), 1 da regra `private-key` (em `deploy/chave-deploy`) e 1 da regra `jwt` (em `docs/api.md`).

> 📸 **EVIDÊNCIA 3 — A varredura do histórico.** Print com a linha `leaks found: 6` e as 6 linhas do resumo do `jq`. Se não couber num print só, cole dois.

### Etapa 4 — Confirmar no Git que "apagar" não apagou (5 min)

Pegue no relatório o commit que criou o arquivo `.env` e peça ao Git o conteúdo do arquivo **naquele commit**:

```bash
C=$(jq -r '[.[] | select(.File==".env")][0].Commit' ../relatorio.json)
echo "Commit que criou o .env: $C"
git show "$C:.env"
```

Agora tente o mesmo na versão atual:

```bash
git show HEAD:.env
```

E veja a vida inteira do arquivo da chave privada — o commit que a criou e o que a "apagou":

```bash
git log --format='%h  %ad  %an  %s' --date=short -- deploy/chave-deploy
```

> ✅ **CHECKPOINT 4** — O `git show "$C:.env"` mostrou as linhas **`PAGAPORTO_WEBHOOK_SECRET=…`** e **`SMS_API_TOKEN=…`**. O `git show HEAD:.env` deu **erro**, porque o arquivo não existe na versão atual. O último comando mostrou **2 commits**: o que criou a chave e o "Remove segredos do repositório".

> 📸 **EVIDÊNCIA 4 — O segredo "apagado".** Print com o conteúdo do `.env` recuperado do commit antigo e o erro do `git show HEAD:.env`.

### Etapa 5 — Encontrar o que a ferramenta não viu (6 min)

O código da Cais Azul é escrito em português. Procure a palavra **senha** na versão atual:

```bash
git grep -n -i "senha" HEAD
```

Repare na constante `SENHA_BANCO_HOMOLOG` em `BancoConfig.java`: uma senha escrita no código, **na versão atual**, que o gitleaks não apontou. As regras padrão procuram palavras como *password*, *secret* e *token* — não *senha*.

Rode de novo a varredura do histórico, agora com uma **regra extra** para senhas em português. Abra o arquivo [`regras/gitleaks-senha.toml`](regras/gitleaks-senha.toml) no editor e leia os comentários antes:

```bash
gitleaks git . --no-banner --config ../regras/gitleaks-senha.toml --report-path ../relatorio-pt.json
jq -r '.[] | [.RuleID, .File, .Commit[0:7], .Author] | @tsv' ../relatorio-pt.json
```

> ✅ **CHECKPOINT 5** — O `git grep` mostrou a linha com **`SENHA_BANCO_HOMOLOG = "Homolog@CaisAzul2026"`**. A varredura com a regra extra terminou com **`leaks found: 7`**, e o resumo tem uma linha nova da regra **`senha-em-portugues`**, em `BancoConfig.java`.

> 📸 **EVIDÊNCIA 5 — O que a ferramenta não viu.** Print com o resultado do `git grep` e o resumo do `jq` com as 7 linhas, incluindo `senha-em-portugues`.

### Etapa 6 — Classificar os achados (8 min)

Agora é a decisão da Marina. No documento de entrega, a **tabela de classificação** já traz os 7 achados (regra e arquivo). Para cada um, preencha:

- **O que é:** que segredo é aquele, em poucas palavras (ex.: "senha do banco de motoristas em produção").
- **É segredo de verdade?** Sim, ou não (falso positivo).
- **O que fazer:** por exemplo, revogar/trocar no sistema de origem e mover para o cofre; ou nada, se for falso positivo.
- **Quem precisa agir ou saber:** pessoas do cenário (Lucas, Bianca, Tiago, Marina, Paula) e, quando for o caso, empresas de fora (como o PagaPorto ou o serviço de SMS).

Para entender cada achado, abra o conteúdo do commit em que ele apareceu (`git show <commit>`, com o commit do resumo do `jq`) e releia a Parte 1. Dois detalhes ajudam:

- o achado da regra `jwt` está num texto de documentação: leia o que a frase acima dele diz;
- a chave do serviço de mapas é **a mesma que vai dentro do App Motorista**, mantido pela CódigoSul.

> ✅ **CHECKPOINT 6** — As 7 linhas da tabela estão preenchidas. Pelo menos um achado foi marcado como **falso positivo**, com a justificativa.

### Etapa 7 — Encerrar e entregar (4 min)

1. **Não envie a pasta `portalagenda` para o GitHub.** Ela está no `.gitignore` da sua cópia, então nem aparece no `git status` da raiz. Você não precisa fazer nenhum commit neste laboratório.
2. **Pare o Codespace** para não gastar a sua cota mensal: na **sua cópia** do repositório no GitHub, **Code → Codespaces → ⋯ → Stop codespace**. Depois de receber a nota, você pode excluí-lo.
3. Confira o documento de entrega:

> ✅ **CHECKPOINT FINAL**
> - [ ] As **5 evidências** estão coladas e legíveis.
> - [ ] A **tabela de classificação** tem as 7 linhas preenchidas.
> - [ ] Nome, RA, turma e data estão preenchidos.

4. Salve como **`Entrega-Segredos-SeuNome.docx`** e envie na **tarefa do Teams**.

---

## Problemas comuns

| Sintoma | O que fazer |
|---|---|
| Não encontro o botão **Use this template** | Ele fica na página do repositório da disciplina, acima da lista de arquivos, ao lado do botão **Code**. É preciso estar logado no GitHub. |
| Criei o Codespace no repositório da disciplina, e não na minha cópia | Pare e exclua esse Codespace (**Code → Codespaces → ⋯ → Delete**), volte ao passo 4 da Etapa 0 e crie o Codespace a partir da sua cópia. |
| Não consegui baixar o modelo pelo GitHub | Baixe pelo próprio Codespace: no painel de arquivos à esquerda, abra a pasta `entrega`, clique com o botão direito em `Modelo-Entrega-Caca-Segredos.docx` e escolha **Download**. |
| `gitleaks: command not found` | A instalação ainda não terminou ou falhou. Na raiz do repositório, rode `bash .devcontainer/pos-criacao.sh`. |
| `A pasta portalagenda já existe` | O `preparar.sh` já foi executado. Para recomeçar do zero, na raiz do repositório: `rm -rf portalagenda && bash preparar.sh`. |
| O número de achados é diferente do checkpoint | Confira com `pwd` se você está dentro de `portalagenda`. Se você alterou arquivos ou fez commits a mais, recrie o repositório (linha acima) e refaça a partir da Etapa 1. |
| `jq: error: Could not open file ../relatorio.json` | O relatório ainda não foi gerado ou você está em outra pasta. Refaça o comando `gitleaks git … --report-path ../relatorio.json` dentro de `portalagenda`. |
| `git show "$C:.env"` deu erro `invalid object name` | A variável `C` ficou vazia: o relatório não existe neste terminal. Gere o relatório da Etapa 3 e rode de novo. |

---

## Arquivos do repositório

| Arquivo | Para que serve |
|---|---|
| `README.md` | Este roteiro |
| `entrega/Modelo-Entrega-Caca-Segredos.docx` | Modelo do documento de entrega (evidências e tabela de classificação) |
| `preparar.sh` | Cria o repositório fictício do PortalAgenda, com os segredos falsos no histórico |
| `regras/gitleaks-senha.toml` | Configuração do gitleaks com a regra extra para senhas em português (Etapa 5) |
| `.devcontainer/` | Prepara o Codespace e instala o gitleaks e o jq |

> ⚠️ **Somente laboratório:** os segredos do repositório fictício são falsos e foram criados para a aula. Nunca use repositórios de verdade, de nenhuma empresa, para praticar.
