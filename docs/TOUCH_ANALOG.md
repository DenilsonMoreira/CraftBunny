# Analógico transparente e resultado sem envio manual — 2026-11-10

Versão 0.3.7. Solicitação: remover ENVIAR AO GLOBAL e substituir ESQ/DIR por um analógico transparente no APK.

## Implementado

- Removidos o botão de envio manual e seu callback no resultado. O campo de três letras aparece somente quando a pontuação qualifica para o TOP 10 local. REGISTRAR RECORDE continua salvando e enviando automaticamente quando também qualifica no TOP 100 global, conforme a versão 0.3.6.
- RANKING GLOBAL continua abrindo o site pelo menu de recordes. Nenhuma tabela global embutida.
- `game/scripts/touch_controls.gd`: base fixa semitransparente no canto esquerdo, desenho geométrico com contorno em passos de pixels e botão móvel. Centro (106,450), raio 74, botão raio 27 na resolução lógica 960x540; imagem visível por trás da base.
- Zona morta horizontal de 22% do deslocamento máximo. Fora dela, mantém a velocidade/direção existentes do jogador; o stick não muda a física, não adiciona movimento vertical nem substitui o pulo.
- Um dedo controla o stick até ser solto, inclusive quando sai da base. Outro dedo não rouba seu controle. Arrastar sobre botões de ação não dispara essas ações pelo dedo do stick.
- Ao soltar, pausar, perder foco, terminar a tentativa ou remover o controle, as ações são liberadas e o botão volta ao centro. Pulo, golpe, caixa e pausa mantidos e utilizáveis com outros dedos.
- Windows mantém teclado; a remoção do botão de envio manual também vale no PC.

## Validação

- Importação Godot 4.7.2 e smoke headless de 120 frames: aprovados.
- `tools/test_touch.gd`: 19 checks de centro, zona morta, direção, arraste além da base, segundo dedo, multitoque, pausa/foco, movimento real, segundo plano e Voltar Android aprovados. Execução OpenGL também aprovada, incluindo captura adicional.
- `tools/test_auto_ranking.gd`: 22 checks aprovados, incluindo ausência do botão manual e envio após registro local elegível.
- 15 checks de exclusão local e 16 de fluxo aprovados.
- Godot/API/PostgreSQL isolado: dez checks aprovados; somente um resultado no banco temporário, sem publicar score fictício.
- Windows 0.3.7: exportado release x86_64, propriedades 0.3.7.0, smoke OpenGL de 120 frames fora do editor aprovado; ZIP com avisos de licença preparado. SHA256 EXE: `ac429c3c4ad789379e2602cdf98b31351ca2286c4eb0e9304576c11903808b91`.
- Android 0.3.7: código 7, INTERNET, ARM32/64 e assinatura v2/v3 validados; mesmo certificado da 0.3.6. Scripts main/touch_controls dentro do APK comparados com a versão anterior: tamanhos e hashes diferentes, confirmando empacotamento atualizado. SHA256 APK: `29f3572782898a896fdc0fec16cec3b1e873c0941401b4ad360568986af5c575`.
- Avisos de encerramento nos testes headless de toque/fluxo (4 objetos/2 recursos e 2 objetos/1 recurso, respectivamente) registrados; execução OpenGL do teste de toque não apresentou esses avisos. Não equivalem a teste completo em aparelho físico.

Captura revisada: `docs/qa_touch_analog_037.png`, gerada pelo jogo com renderização OpenGL. Reproduzir com Godot console, `--path game --script res://tools/test_touch.gd -- --capture`, com `CRAFT_BUNNY_API_URL=disabled` para evitar sessões públicas de teste. Os testes usam arquivos isolados e não apagam os recordes reais.

Pendente: confirmar conforto, tamanho do polegar e abertura do navegador no Android físico. Sem alterações em gameplay, recordes existentes ou artes de referência.

## Distribuição

Arquivos locais: `game/builds/CraftBunny-Android-0.3.7.apk`, `game/builds/windows-0.3.7/CraftBunny-0.3.7.exe` e `game/builds/CraftBunny-Windows-0.3.7.zip`. Originais/builds anteriores preservados.

Upload do novo APK no Blob privado concluído e tamanho verificado. Para o botão BAIXAR APK selecionar essa versão, atualizar na Vercel Production e fazer redeploy:

```dotenv
APK_BLOB_PATH=releases/0.3.7/29f357278289/CraftBunny-Android-0.3.7.apk
APK_DOWNLOAD_VERSION=0.3.7
APK_DOWNLOAD_SHA256=29f3572782898a896fdc0fec16cec3b1e873c0941401b4ad360568986af5c575
```

O upload não troca automaticamente as variáveis do servidor. Segredo do Authenticator, credenciais e banco preservados; nenhuma nova migração SQL é necessária.
