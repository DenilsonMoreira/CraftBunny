# Download de versões de teste com Google Authenticator

2026-11-07. Um autenticador do responsável, sem cadastro dos testadores. Botão BAIXAR APK ao lado de O projeto, janela pixel art com seis dígitos e cancelamento.

O código funciona como acesso temporário por TOTP; sem login/senha anterior não constitui dois fatores completos. Cada código aceito só pode liberar uma autorização; o link resultante é válido por 60 segundos. Quem já baixou o arquivo pode copiá-lo, portanto este mecanismo controla a distribuição inicial e não revoga instalações.

## Ativação necessária

O código foi implementado/testado, mas falta configurar o ambiente online e fazer upload do APK. Sem isso a janela mostra download em preparação e nunca libera um arquivo público como alternativa.

### 1. Aplicar a migração adicional

No SQL Editor do mesmo Supabase do ranking, execute uma vez:

supabase/migrations/202611070002_private_download.sql

Ela adiciona apenas tabelas/RPCs de limite e uso de códigos. Não altera/apaga recordes. Requer a migração inicial já aplicada.

### 2. Criar armazenamento privado

No projeto Vercel: Storage → Create Storage → Blob → acesso Private. Conecte o store ao projeto. Não use armazenamento público.

O SDK reconhece BLOB_STORE_ID e OIDC da integração Vercel. Se sua integração fornecer BLOB_READ_WRITE_TOKEN, também é aceito, somente no servidor.

O APK atual tem 79.741.400 bytes, acima dos 50 MB por arquivo no Supabase Free. Vercel Blob suporta esse tamanho; Hobby tem franquias limitadas, não hospedagem ilimitada. Consulte o painel de uso.

### 3. Upload da versão controlada

Envie game/builds/CraftBunny-Android-0.3.5.apk ao store Private pelo painel Vercel. Copie o pathname do objeto, não o URL.

Alternativa para novas versões: em web/, configure BLOB_READ_WRITE_TOKEN no ambiente privado local e execute:

```text
npm run upload:apk -- ../game/builds/CraftBunny-Android-0.3.5.apk 0.3.5
```

O script calcula SHA256, usa pasta com versão/hash, impede sobrescrita e imprime apenas os metadados para cadastrar na Vercel. Nunca imprime o token.

### 4. Cadastrar o autenticador do responsável

Foi gerado localmente um QR em:

C:/Users/rleti/AppData/Local/CraftBunnyDownload/authenticator.html

Abra somente no computador do responsável. Google Authenticator → + → Ler QR code. Adicione Craft Bunny / Downloads de teste. A chave mostrada abaixo do QR é usada somente na variável DOWNLOAD_TOTP_SECRET da Vercel. Não envie QR/chave no chat, GitHub ou a testadores.

O segredo também está no arquivo privado .env.download.local dessa pasta, fora do repositório e OneDrive. Para gerar em outra máquina: npm run setup:download em web/. Rodar novamente preserva a chave existente, sem rotação silenciosa.

### 5. Variáveis da Vercel

Configure em Production:

| Variável | Valor |
|---|---|
| DOWNLOAD_TOTP_SECRET | Chave Base32 da página local privada |
| APK_BLOB_PATH | Pathname exato do APK no store Private |
| APK_DOWNLOAD_VERSION | 0.3.5 |
| APK_DOWNLOAD_SHA256 | A4582F7A33EA9DF76036E5C8A1FB903D52FAC30BFED046F18C1576531D785150 |

As variáveis Supabase e RATE_LIMIT_SECRET já existentes são reutilizadas. Mantenha ALLOWED_ORIGINS com a origem do site. BLOB_STORE_ID/OIDC ou BLOB_READ_WRITE_TOKEN vêm da conexão do store. Não use prefixo público nos segredos.

Faça Redeploy após configurar. GET /api/download retorna available:true e versão quando as variáveis estão presentes; isso por si só não prova que a migração e o upload foram concluídos. Teste um código atual e confirme o download privado.

## Como liberar uma nova versão

1. Exporte o novo APK.
2. Faça upload em outro pathname, sem sobrescrever a versão antiga.
3. Atualize APK_BLOB_PATH, APK_DOWNLOAD_VERSION e APK_DOWNLOAD_SHA256 e faça redeploy.
4. Informe aos testadores a versão disponível e compartilhe apenas o código de seis dígitos atual.

Nenhuma lista pública permite escolher versões antigas. Links já emitidos podem funcionar por até 60 segundos após a troca. O APK já instalado não é atualizado automaticamente.

## Proteção implementada

- OTPAuth TOTP SHA1, seis dígitos, período 30 s e tolerância de uma janela para relógio.
- Até cinco tentativas por minuto e 20 por hora por hash de rede, no PostgreSQL; erros de código também contam.
- Código consumido de forma atômica por hash do segredo + contador de tempo, sem guardar os seis dígitos ou o segredo nas tabelas.
- RPCs exclusivos da chave do servidor; RLS/tabelas privadas, sem acesso anon/authenticated.
- Código válido só libera o APK selecionado pelo servidor. Corpo do cliente não escolhe pathname/versão.
- SDK confirma store Private e assina somente GET desse objeto exato por 60 s. Material de assinatura e token read-write nunca chegam ao navegador.
- Link temporário pode ser reutilizado/compartilhado enquanto válido; não é uma URL de uso único. Reutilização do OTP para emitir outro link é bloqueada.
- Download sai direto do Blob, sem trafegar os ~80 MB pela função da API.
- Sem cache nas respostas de autorização, sem QR/seed público, sem código nos URLs ou logs.
- Falhas de banco/Blob não abrem acesso. Arquivo ausente ou store público não consome o código, permitindo tentar após correção.
- Dados de rate limit/códigos antigos são removidos após um dia na próxima tentativa.

## Verificações

31 testes aprovados (13 novos e 18 de regressão), incluindo vetor RFC 6238, expiração, formato, limites, corrida/reutilização, troca de versão com diálogo aberto, falha do storage, permissões, metadados, escopo exato do link e geração privada do QR sem imprimir a chave. Migrações executadas em PostgreSQL local via PGlite; Blob/assinatura simulados nos testes, sem upload público ou uso do autenticador real.

npm run build aprovado; npm audit e auditoria de produção: zero vulnerabilidades. Override pontual de zod em @vercel/cli-config para a versão corrigida 4.6.6.

Browser: posição do botão, abertura/cancelamento, estado não configurado e largura móvel de 390 px revisados. Captura docs/qa_download_otp.png não contém segredo. Download de 80 MB em produção, migração online adicional, store e validação do código real ainda dependem da ativação acima.

## Referências

[Vercel Blob privado](https://vercel.com/docs/vercel-blob/private-storage), [Signed URLs](https://vercel.com/docs/vercel-blob/vercel-signed-urls), [franquias Hobby](https://vercel.com/docs/vercel-blob/usage-and-pricing), [limite Supabase Free](https://supabase.com/docs/guides/storage/uploads/file-limits), [OTPAuth](https://github.com/hectorm/otpauth).
