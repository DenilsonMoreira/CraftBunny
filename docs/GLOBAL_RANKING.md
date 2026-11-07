# Ranking global — implementação e ativação

2026-11-07. Cliente 0.3.4. TOP 10 local preservado e TOP 100 global por tentativa.

## Implementado

Site em web/public com artes e fonte pixeladas do jogo, filtros todos os tempos/últimos sete dias, todas as tentativas/vitórias, busca de três letras dentro do TOP 100, páginas de dez resultados e atualização manual. Estados de carregamento, vazio, apelido ausente e serviço não configurado/indisponível.

API em web/api, lógica em web/lib e migração em supabase/migrations. O navegador não fala diretamente com o banco e o jogo não contém chave Supabase.

Cliente game/scripts/global_ranking.gd abre sessão ao iniciar, congela resultado ao terminar e envia só quando o jogador clica ENVIAR AO GLOBAL. Falhas não impedem jogar ou salvar/consultar o TOP 10 local. Menu RECORDES dá acesso ao global; o painel mostra dez posições e o site até 100.

## Ativação online

1. No projeto Supabase destinado ao jogo, abra SQL Editor e execute supabase/migrations/202611070001_global_ranking.sql por inteiro uma única vez. Não apaga dados existentes. Ainda não aplicada online nesta sessão.
2. Na Vercel: Root Directory web, Framework Other, Node 22.x, Install npm ci, Build npm run build, Output public.
3. Em Environment Variables configure SUPABASE_URL e SUPABASE_SECRET_KEY. URL HTTPS do projeto e chave Secret do painel Supabase. A alternativa legada SUPABASE_SERVICE_ROLE_KEY também é aceita.
4. Gere RATE_LIMIT_SECRET aleatório privado de pelo menos 32 caracteres e configure na Vercel. Nunca o coloque no chat ou repositório. Ele serve ao hash de rede e não é enviado ao cliente.
5. Configure ALLOWED_ORIGINS com a origem HTTPS do site sem barra final. Para desenvolvimento, inclua http://localhost:3000. Hosts de produção/preview da própria Vercel são reconhecidos automaticamente.
6. Faça Deploy/Redeploy depois de configurar variáveis. GET https://SEU-SITE/api/leaderboard deve retornar 200 com entries e total; banco vazio retorna lista vazia e total zero.
7. No jogo, configure craft_bunny/ranking/api_url em project.godot com a URL raiz HTTPS do site, sem /api e sem chaves. CRAFT_BUNNY_API_URL em ambiente também é aceito para desktop/testes.
8. Exporte novo APK com essa URL. Preset 0.3.4 habilita internet; APK anterior 0.3.3 não contém o cliente global. Nenhum novo APK exportado nesta etapa.
9. Faça uma tentativa real, salve localmente se desejar e confirme ENVIAR AO GLOBAL. Confira no jogo/site. Sem sessão iniciada online, a tentativa fica local.

Variáveis alteradas depois de um deploy exigem redeploy. Não use prefixo público (NEXT_PUBLIC/VITE) para segredos. Não envie chaves por chat, GitHub ou capturas. Previews conectadas ao mesmo banco também podem receber resultados nele.

## Endpoints

POST /api/runs, Content-Type application/json:

```json
{"game_version":"0.3.4"}
```

Resposta 201: run_id, token e expires_at. Token aleatório de 32 bytes; somente SHA256 fica no banco. Sessão expira em seis horas.

POST /api/scores:

```json
{"run_id":"UUID-RECEBIDO","token":"TOKEN-RECEBIDO","initials":"ABC","carrots":24,"won":true,"duration_ms":60000,"game_version":"0.3.4"}
```

Use os valores reais da tentativa. Exemplo não é um envio válido pronto. Reenvio após resposta perdida deve repetir exatamente o mesmo corpo; outro resultado para o mesmo ID é rejeitado.

GET /api/leaderboard?period=all&outcome=all. period aceita all/week e outcome all/victory. Retorna entries, total, period e outcome. Entradas expõem somente position, initials, carrots, won, game_version e created_at.

Erros: 400 JSON, 401 token/sessão, 403 origem, 405 método, 410 expiração, 413 tamanho, 415 tipo, 422 validação, 429 limite e 503 configuração/indisponibilidade. Mensagens internas do banco não são expostas.

## Proteção e limites

- Uma linha por tentativa. Apelidos não são contas, podem repetir e não comprovam identidade.
- Ordem: mais cenouras, recebimento mais antigo e UUID para empate exato.
- Até 139 cenouras: 63 no mapa e 76 possíveis em drops. Teste Godot confere o total gerado; mudanças na fase exigem revisar versão/limites.
- Versão 0.3.4, apelido A-Z de três letras, inteiros positivos, resultado booleano e duração 1 s–6 h.
- Duração alegada não pode superar a observada pelo servidor em mais de 5 s. Vitória antes de 45 s é rejeitada como incompatível com deslocamento da fase atual.
- Até seis inícios/minuto e 30/hora por hash de rede, transacionalmente. Redes compartilhadas dividem a cota.
- IP não é persistido nas tabelas: HMAC-SHA256 com segredo privado. Hashes com mais de um dia são anonimizados na próxima criação. Sessões expiradas sem resultado são limpas após mais um dia, também na próxima criação.
- Schema privado, RLS, revogação de anon/authenticated e RPCs exclusivos da chave secreta da API. Não expor o schema na Data API.
- Token e corpo para repetição ficam somente em memória no jogo, sem save de progresso.
- CORS restringe origens de navegador. Clientes nativos não enviam Origin; CORS não é autenticação.

São validações básicas de plausibilidade e abuso. O servidor não reproduz a partida; um cliente modificado ainda pode inventar resultados dentro dos limites. Este protótipo não é um ranking verificado por replay.

## Validação executada

- npm test: 18 testes PostgreSQL via PGlite, usando a migração real e handlers HTTP. Cobrem permissões, hash, envio, duplicatas/repetições paralelas, adulteração, expiração, tipos, teto de pontuação, duração, rate limit, filtros, ordenação, retenção, JSON/tamanho/origem, indisponibilidade, chaves modernas e TOP 100.
- npm run build: estáticos e módulos Vercel validados.
- npm run test:game com GODOT_BIN: dez verificações Godot e ciclo cliente HTTP → API → PostgreSQL local; exatamente um resultado persistido.
- game/tools/test_flow.gd: 16 verificações do fluxo local aprovadas.
- Importação e smoke Godot executados. Harness de fluxo mantém aviso conhecido de recursos em uso ao encerrar.
- Navegador: paginação 1–10/11–14, busca FOX, ausência ZZZ, filtro semanal e vitórias, com 14 resultados fictícios em banco local isolado. Nenhum dado de QA enviado ao Supabase.
- Visual revisado em janela normal e largura móvel 390 px, sem transbordamento horizontal observado. Capturas qa_ranking_desktop.png (sem configuração online) e qa_ranking_mobile.png (faixa de dados fictícios).

Pendentes: aplicar migração online, variáveis/deploy Vercel, URL real no jogo, APK atualizado e teste em aparelho. Contas criadas não configuram esses itens automaticamente.

## Referências

[Vercel Node](https://vercel.com/docs/functions/runtimes/node-js), [configuração](https://vercel.com/docs/project-configuration/vercel-json), [cabeçalhos](https://vercel.com/docs/headers/request-headers), [funções Supabase](https://supabase.com/docs/guides/database/functions), [chaves Supabase](https://supabase.com/docs/guides/getting-started/api-keys), [PGlite](https://pglite.dev/docs/).
