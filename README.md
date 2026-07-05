# ML Loyalty Project

Projeto de analytics e modelagem para dados de fidelidade, transacoes e educacao. O repositorio organiza bases locais em SQLite/CSV e consultas SQL para construir metricas, segmentacoes e features por cliente.

## Estrutura

```text
data/
  analytics/
    analytics.db
  education-platform/
    database.db
    *.csv
  loyalty_system/
    database.db
    *.csv

src/
  analytics/
    dau.sql
    mau.sql
    lifecycle.sql
    fs_transacional.sql
    fs_education.sql
    frequencia_valor.sql
    frequencia_valor.py
    exec_lifecycle.py
    report_ciclo_vida.sql
```

## Bases

`data/loyalty_system/database.db`

Base transacional do sistema de loyalty:

- `transacoes`: transacoes por cliente, data, pontos e origem.
- `transacao_produto`: produtos associados as transacoes.
- `clientes`: cadastro e flags de canais dos clientes.
- `produtos`: cadastro de produtos e categorias.

`data/education-platform/database.db`

Base da plataforma educacional:

- `cursos`
- `cursos_episodios`
- `cursos_episodios_completos`
- `habilidades`
- `habilidades_usuarios`
- `habilidades_cargos`
- `usuarios_tmw`
- `recompensas_usuarios`

`data/analytics/analytics.db`

Base de saida para tabelas analiticas geradas pelo projeto, como `lifecycle`.

## Consultas Principais

`src/analytics/dau.sql`

Calcula usuarios ativos diarios:

```sql
SELECT substr(DtCriacao, 1, 10) AS DtDia,
       COUNT(DISTINCT IdCliente) AS DAU
FROM transacoes
GROUP BY DtDia;
```

`src/analytics/mau.sql`

Calcula MAU usando janela movel de 28 dias.

`src/analytics/lifecycle.sql`

Classifica clientes por ciclo de vida usando recencia, idade da primeira transacao e penultima ativacao:

- `01 - CURIOSO`
- `02 - FIEL`
- `02 - RECONQUISTADO`
- `02 - REBORN`
- `03 - TURISTA`
- `04 - DESENCANTADO`
- `05 - ZUMBI`

Tambem junta informacoes de frequencia, valor e cluster transacional.

`src/analytics/fs_transacional.sql`

Cria features transacionais por cliente, incluindo:

- idade em dias
- quantidade de ativacoes por janelas D7, D14, D28 e D56
- quantidade de transacoes por janela
- saldo de pontos positivos e negativos
- percentual de transacoes por periodo do dia
- horas de atividade
- intervalo medio entre dias ativos
- participacao por produto/categoria

`src/analytics/fs_education.sql`

Cria features educacionais por cliente, incluindo:

- quantidade de cursos completos
- quantidade de cursos incompletos
- percentual de progresso por curso
- dias desde a ultima atividade educacional

`src/analytics/report_ciclo_vida.sql`

Gera um relatorio agregado por `dtRef`, `lifecycle` e `cluster`.

## Execucao Local

Use o ambiente conda do projeto:

```bash
conda activate loyalty-predict
```

Para executar uma query diretamente com SQLite:

```bash
sqlite3 data/loyalty_system/database.db < src/analytics/dau.sql
```

Para consultar a base educacional:

```bash
sqlite3 data/education-platform/database.db < src/analytics/fs_education.sql
```

Para rodar o ciclo de vida via Python:

```bash
cd src/analytics
python exec_lifecycle.py
```

O script `exec_lifecycle.py` le `lifecycle.sql`, executa a query para uma lista de datas e grava o resultado em `data/analytics/analytics.db`.

## Dependencias Python

Principais bibliotecas usadas:

- `pandas`
- `sqlalchemy`
- `matplotlib`
- `scikit-learn`
- `ipykernel`, para uso no VS Code/Jupyter

Instalacao no ambiente conda:

```bash
python -m pip install pandas sqlalchemy matplotlib scikit-learn ipykernel
```

Registrar o kernel no Jupyter/VS Code:

```bash
python -m ipykernel install --user --name loyalty-predict --display-name "Python (loyalty-predict)"
```

## VS Code

O diretorio `.vscode/` fica fora do Git:

```gitignore
.vscode/
```

Se arquivos `.sql` nao forem reconhecidos como SQL no editor, configure localmente o VS Code para associar `*.sql` ao modo SQL.

## Git

Branch principal de trabalho recente:

```bash
git checkout 4-feature-store---cursos
```

Enviar alteracoes para o remoto:

```bash
git push
```

Se a branch local ainda nao tiver upstream:

```bash
git push -u origin nome-da-branch
```

Se o push for rejeitado porque a branch esta atras do remoto:

```bash
git pull --rebase origin nome-da-branch
git push
```

## Observacoes

- As datas de referencia aparecem hardcoded em algumas queries, como `2025-10-01`.
- Algumas queries assumem nomes de colunas com maiusculas/minusculas do SQLite original, por exemplo `IdCliente`, `IdUsuario`, `DtCriacao` e `QtdePontos`.
- Antes de executar uma query pelo VS Code SQLite, confirme que a extensao esta conectada ao banco correto.
