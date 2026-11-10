# Envio automático e acesso ao site — 2026-11-10

Versão do jogo: 0.3.6. Contrato da API continua 0.3.4, compatível com a API e a migração existentes; nenhuma nova migração SQL é necessária.

Atualização 0.3.7: ENVIAR AO GLOBAL removido por solicitação do usuário. O envio continua automático após REGISTRAR RECORDE; não há mais tentativa manual pelo resultado. Falhas preservam o registro local, sem fila persistente. Analógico Android e validação em TOUCH_ANALOG.md. Os metadados de download da seção abaixo são históricos da versão 0.3.6.

## Comportamento

Conforme esclarecido pelo responsável, “recorde” significa entrar no TOP 10 local e no TOP 100 global, não apenas superar o primeiro colocado.

1. Ao terminar a tentativa, o jogador informa três letras A–Z e escolhe REGISTRAR RECORDE.
2. O jogo confirma a elegibilidade local e salva no aparelho. Só após uma gravação bem-sucedida inicia a consulta global em segundo plano.
3. Com sessão online válida, consulta o ranking global de todos os tempos/todos os resultados, com parâmetro único para não reutilizar o cache da consulta anterior.
4. Com menos de 100 resultados, qualquer pontuação válida tem vaga. Com 100 resultados, deve superar o último colocado. Empate no corte não entra, pois os registros anteriores têm precedência no servidor.
5. Resultado elegível é enviado automaticamente com as mesmas três letras, cenouras, resultado e duração da tentativa. Resultado local fica salvo mesmo se consulta/envio falhar.

O menu do jogo mostra somente recordes locais. RANKING GLOBAL abre https://craftbunny-web.vercel.app/ no navegador do dispositivo. A consulta para decidir o envio é interna; nenhuma tabela global é exibida no jogo. O aviso de publicação aparece no resultado antes do registro. A partir da 0.3.7, não existe botão de envio manual.

Sem sessão iniciada online, a tentativa permanece local. Não criamos fila persistente, não enviamos resultados históricos retroativamente e não salvamos progresso de fase. Reiniciar invalida consultas pendentes da tentativa anterior. Envios simultâneos/repetidos são bloqueados no cliente; payload de retry e idempotência no banco foram preservados.

A qualificação global corresponde à tabela no momento da consulta. Outros jogadores podem alterar as posições depois. Isso não muda as regras de pontuação nem garante que um resultado permaneça no TOP 100.

## Implementação

- `game/scripts/global_ranking.gd`: fluxo de elegibilidade, validação da resposta, guarda de concorrência/geração e envio usando sessão existente.
- `game/scripts/main.gd`: aciona após salvar localmente; texto explicativo e botão de registro; botão global abre o site e remove tabela global embutida.
- `game/tools/test_auto_ranking.gd`: cenários isolados de corte, empate, indisponibilidade, duplicação, reinício, validade do nome e falha de gravação.
- `game/tools/test_global_ranking.gd`: integração HTTP/PostgreSQL agora exercita o fluxo automático e mantém um único resultado no banco temporário.
- `game/project.godot` e presets: versão 0.3.6, Android código 6, Windows 0.3.6.0. Builds antigos preservados.

## Validação

- 21 checks de envio automático aprovados com respostas simuladas.
- 15 checks de exclusão local e 16 de fluxo aprovados. O teste de fluxo continua emitindo o aviso de recursos no encerramento já documentado em WINDOWS_BUILD.md.
- Dez checks Godot/API/PostgreSQL aprovados; exatamente um resultado gravado somente no banco temporário. Nenhum recorde fictício enviado ao serviço público.
- Importação e smoke headless de 120 frames aprovados.
- Regressão da API/download: 33 testes aprovados. `git diff --check` sem erros.
- Windows 0.3.6: exportação release, propriedades 0.3.6.0 e smoke renderizado OpenGL de 120 frames fora do editor aprovados. ZIP com instruções/créditos/licenças preparado. EXE SHA256: `9948D65171ACDC6110568A0A428B088BA2345F65C4BF911750EB24055EE90065`.
- Android: APK código 6, versão 0.3.6-android-test, arm64-v8a/armeabi-v7a, INTERNET e assinaturas v2/v3 conferidos. Certificado igual ao APK 0.3.5; arquivo 79.741.400 bytes, SHA256 `1f6ed41ff230b8fa14169ffeacc8522782dcd1066f03b08f7d0faa64031af5da`.

## Download controlado do APK

Upload privado da versão 0.3.6 concluído e tamanho verificado. O servidor ainda seleciona o APK pelas variáveis da Vercel; fazer upload não muda essas variáveis automaticamente. Para ativar a nova versão no site, atualizar Production e fazer redeploy:

```dotenv
APK_BLOB_PATH=releases/0.3.6/1f6ed41ff230/CraftBunny-Android-0.3.6.apk
APK_DOWNLOAD_VERSION=0.3.6
APK_DOWNLOAD_SHA256=1f6ed41ff230b8fa14169ffeacc8522782dcd1066f03b08f7d0faa64031af5da
```

Manter o segredo do Authenticator, token privado Blob e variáveis Supabase existentes. Nenhuma nova migração. Builds locais e arquivos privados não são versionados. Link do site não declarado como atualizado para 0.3.6 antes de confirmar o redeploy dessas variáveis.

Consulta real de metadados em 2026-11-10: site ainda seleciona 0.3.5 (`available:true`). A versão 0.3.6 está no Blob privado e em arquivo local, mas a troca das variáveis/redeploy ainda é pendente.

Playtest físico de Android, abertura do navegador pelos botões e envio de uma tentativa real ainda devem ser confirmados pelo jogador. Não alteramos as regras de gameplay nem os arquivos de recordes existentes.
