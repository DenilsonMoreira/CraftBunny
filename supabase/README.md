# Banco do ranking

Migração: migrations/202611070001_global_ranking.sql.

No projeto correto do Supabase, abra SQL Editor e execute o arquivo inteiro uma única vez. A migração é transacional e aditiva: cria somente schema craftbunny_private, suas tabelas e funções cb_. Não apaga tabelas existentes.

Se adotar o Supabase CLI depois, sincronize o histórico da migração manual antes de executar db push.

## Estrutura

- run_sessions: tentativa, hash do token, hash de rede, versão, início e expiração.
- scores: uma linha por tentativa com apelido, cenouras, resultado, duração, versão e data do servidor.
- cb_start_run, cb_submit_score e cb_leaderboard: RPCs usados pela API.

RLS habilitada. Schema privado, tabelas e funções sem acesso de anon/authenticated. RPCs só executáveis pela chave secreta/service_role da API. Não exponha o schema privado na Data API nem libere INSERT público.

Migração testada localmente via PGlite e aplicada online pelo usuário. Consulta e criação de sessão reais confirmadas em 2026-11-07; nenhum resultado fictício publicado. Guia em ../docs/GLOBAL_RANKING.md.
