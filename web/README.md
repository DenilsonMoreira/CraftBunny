# Craft Bunny — ranking global

Site responsivo em pixel art e três funções Node.js para Vercel. Artes e fonte reutilizadas do jogo; nenhuma credencial no navegador ou no jogo.

## Desenvolvimento

Execute npm ci, npm test, npm run build e npm run dev nesta pasta. Abra http://localhost:3000. Sem .env.local, o site mostra o estado real de preparação; não inventa recordes.

Copie .env.example para .env.local e configure os valores apenas localmente. Aplique a migração SQL no Supabase.

## Vercel

Root Directory: web. Framework: Other. Node: 22.x. Install: npm ci. Build: npm run build. Output: public. Não precisa acessar fontes fora da raiz.

Variáveis de servidor: SUPABASE_URL, SUPABASE_SECRET_KEY, RATE_LIMIT_SECRET (aleatório, mínimo 32 caracteres) e ALLOWED_ORIGINS (origens separadas por vírgula, sem barra final). A chave legada também é aceita como SUPABASE_SERVICE_ROLE_KEY. Não use prefixos NEXT_PUBLIC ou VITE.

Configure Production e Preview conforme o banco desejado. Previews conectadas ao mesmo banco também recebem resultados nesse banco.

Guia completo de ativação, endpoints, limitações e testes: ../docs/GLOBAL_RANKING.md.

## Testes locais adicionais

npm run test:game usa GODOT_BIN apontando à engine Godot 4.7.2 e executa cliente HTTP/API/PostgreSQL em memória, sem tocar no banco online.

node scripts/qa-site.mjs inicia uma prévia isolada na porta 3001 com faixa DADOS FICTÍCIOS DE TESTE. Esses resultados não pertencem à aplicação pública.
