# Craft Bunny — APK de teste

Build atualizado em 2026-11-13 com Godot 4.7.2.

- Arquivo: builds/CraftBunny-Android-0.5.0.apk (também disponível como CraftBunny-Android-Test.apk).
- Pacote: com.craftbunny.game
- Versão: 0.5.0-android-test (código 12), quatro ferramentas, árvores/rochas e círculos com ícones; fase de 24.000 px e teto 200 antes de gastar munição. Contrato global permanece 0.4.0, sem nova migração nesta atualização.
- Mínimo: Android API 24 (Android 7.0), aparelho com OpenGL ES 3 compatível com o renderer Compatibility.
- Target SDK: 36.
- Arquiteturas: arm64-v8a e armeabi-v7a.
- Orientação: paisagem, conteúdo 960x540 com proporção preservada.
- Tamanho: 83.212.930 bytes.
- SHA256: 3F46E9CB99EF8784768D27DAE006A4D31B4CFEB03D7F0515D1025539434AD37E
- Assinatura de depuração verificada: esquemas v2 e v3.

## Instalar

Atualização 0.5.0: mantido joystick esquerdo, ações em círculos com ícones e troca de ferramentas. Mira por segurar/soltar; ranking usa cenouras restantes. Artes novas são provisórias, com template para estados finais. Pacote, ARM32/64, INTERNET e mesmo certificado da 0.4.3 confirmados. Somente builds locais 0.5.0/0.4.3 mantidos; site não atualizado nesta etapa. Playtest físico pendente. Relatório: ../../docs/TOOLS_050.md. Notas abaixo são históricas.

Atualização 0.4.3: corrigidos enquadramento do martelo e escala do planar, mantendo os 12 quadros e regras. Manifesto e mesmo certificado da 0.4.2 confirmados. Somente APKs locais 0.4.3 e 0.4.2 mantidos; notas de versões anteriores são históricas e seus builds foram removidos. Site preservado. Relatório: ../../docs/SPRITE_LAYOUT_043.md.

Atualização 0.4.2: novo botão DASH e segundo toque/segurar PULO para planar. Duas artes de 12 quadros. Mesmo certificado da 0.4.1 confirmado; instalar por cima. Manifesto ARM32/64, código 10, INTERNET e assinatura conferidos. Playtest físico pendente. Arquivo local exportado; a versão selecionada para download no site não foi alterada nesta etapa. Guia: ../../docs/MOVEMENT_ABILITIES_042.md.

Atualização 0.4.1: extensão horizontal reduzida pela metade, mantendo itens, inimigos, alturas e caixas obrigatórias. Mesmo certificado da 0.4.0 confirmado. APK privado enviado; seleção do download na Vercel e testes em ../../docs/COMPACT_LEVEL_041.md. Notas seguintes são históricas.

Atualização 0.4.0: mapa editável com floresta/copa/subsolo, quatro caixas obrigatórias na escada, ave pousada por 0,5 s após atacar e casa pixel art. Mesma assinatura confirmada contra a 0.3.7, permitindo instalar por cima. Teto global 200 exige nova migração no Supabase; registro local continua independente. Guia e variáveis do download em ../../docs/WIDE_LEVEL_040.md. Notas seguintes são históricas.

Atualização 0.3.7: ESQ/DIR substituídos por analógico semitransparente, com zona morta e multitoque. Botão ENVIAR AO GLOBAL removido; REGISTRAR RECORDE mantém envio automático de pontuações elegíveis. Código 7 e mesmo certificado da 0.3.6 confirmados, permitindo atualização por cima. Captura, testes e variáveis para selecionar o novo download em ../../docs/TOUCH_ANALOG.md. As notas seguintes preservam o histórico de versões anteriores.

Atualização 0.3.5: no título aparece v0.3.5; RECORDES → ZERAR RANKING LOCAL abre CANCELAR/SIM, APAGAR OS RECORDES. Ranking global não é afetado. Contrato online permanece compatível com 0.3.4, sem alterar a fase nem exigir nova migração.

Pode atualizar por cima da versão anterior: mesmo pacote e certificado debug SHA256 confirmado contra o APK 0.3.5. No título aparece v0.3.6 | LOCAL + GLOBAL. Comece uma tentativa nova com internet; ao terminar com cenouras, preencha três letras e pressione REGISTRAR RECORDE. O resultado entra no ranking local e é enviado automaticamente se também entrar no TOP 100 global. Resultados antigos não são enviados retroativamente. O botão RANKING GLOBAL abre o site. Detalhes e testes em ../../docs/AUTO_GLOBAL_RANKING.md.

Confirmados no APK: permissão INTERNET e URL real dentro de assets/project.binary. Cliente desktop abriu sessão real e consultou o ranking; nenhum score fictício foi publicado. Envio completo validado em banco local de teste. Playtest Android físico e envio de resultado real ainda pendentes.

tools/build_android.ps1 agora restaura o preset sanitizado ao terminar, inclusive se ocorrer falha, para não deixar caminhos/credenciais locais no arquivo versionado. A configuração headless do editor reportou RIDs em uso ao sair; exportação/assinatura concluíram e importação normal/smoke passaram.

Copie o APK para o celular e abra pelo gerenciador de arquivos. Se solicitado, permita que esse gerenciador instale apps dessa origem. É uma versão de teste para instalação direta; não é uma publicação na Play Store.

Controles na tela: ESQ/DIR, PULO, GOLPE, CAIXA e II (pausa). Aceita dois dedos para andar e agir ao mesmo tempo. A pausa libera os comandos pressionados. Voltar do Android abre/fecha pausa; ao perder foco, a partida e a música pausam. Menu de opções oferece ajuda dos controles de toque e volumes. Ranking usa teclado virtual do campo de iniciais.

## Implementação

scripts/touch_controls.gd implementa os botões multitoque. scripts/main.gd habilita-os no Android, em dispositivos com touchscreen e no modo de prévia --touch; oculta a legenda de teclas e aumenta os botões dos menus. scripts/pixel_hud.gd usa TOQUE na indicação de construção. scripts/sprite_atlas.gd mantém cache de limites alpha, evitando recalcular a mesma folha para cada inimigo.

Preset Android acrescentado a export_presets.cfg; preset Web preservado. Fontes/referências, capturas de QA, ferramentas, arquivos antigos e chave não entram no APK. A inspeção do pacote encontrou zero ocorrências desses arquivos de desenvolvimento.

Ícone novo: assets/production/v2/android_icon.png, gerado com a ferramenta integrada de imagens. Prompt: ícone quadrado pixel art, rosto do coelho creme com orelhas rosadas, lenço vermelho gasto, fundo verde e borda dourada, sem texto, composição legível em escala pequena.

## Ferramentas locais e reprodução

Cache: %LOCALAPPDATA%/CraftBunnyAndroid. Contém JDK 17 portátil, Android SDK, templates Android e chave debug. O Java global do Windows não foi substituído; os caminhos de JDK/SDK da Godot foram ajustados para esse cache.

Downloads oficiais: Adoptium JDK 17 (checksum SHA256 conferido), Android Command-line Tools, Platform Tools, Build Tools 35.0.1, Platform 35 e templates 4.7.2 da Godot. A exportação usa o APK template pronto e não exige Gradle/NDK nesta modalidade. A Godot usa Build Tools 35.0.1 com aviso de diferença para target 36; exportação e verificação de assinatura concluíram.

```powershell
# Ferramentas já configuradas nesta máquina:
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_android.ps1

# Testes:
& .\Godot_v4.7.2-stable_win64_console.exe --headless --path (Get-Location).Path --script res://tools/test_touch.gd

# Prévia de controles no computador:
& .\Godot_v4.7.2-stable_win64_console.exe --path (Get-Location).Path -- --touch
```

tools/setup_android.ps1 baixa os pacotes base. Em outra máquina, instalar os componentes do SDK e configurar a chave debug antes de usar tools/configure_android.gd. Este script ajusta os caminhos da Godot e do preset para o cache local.

Referência de configuração: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html

## Validação e limitações

Dez verificações passaram em tools/test_touch.gd, incluindo ações simultâneas, liberação individual, pausa/retomada, deslocamento e salto reais do personagem, segundo plano e botão Voltar. O harness reporta recursos em uso ao encerrar; smoke test normal concluiu sem erros.

Prévia renderizada em OpenGL revisada em docs/qa_android_controls.png. Manifesto conferido com aapt; assinatura com apksigner. ADB não encontrou aparelhos conectados. APK NÃO foi instalado/executado em Android físico ou emulador nesta sessão. Testar desempenho, áudio, recortes de tela, teclado virtual, reinstalação e percurso completo em aparelho é a próxima etapa.

A chave utilizada é somente de teste; a versão é debuggable. Distribuição final exige uma assinatura de produção própria e a revisão de licenças dos áudios/assets.
