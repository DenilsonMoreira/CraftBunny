# Fase de 24.000 px — 0.4.1 — 2026-11-13

Solicitação: reduzir a extensão horizontal de 48.000 para 24.000 px. A fase ativa agora é `game/scenes/level_wide/fase_compacta.tscn`; `fase_ampla.tscn` foi mantida como referência da geometria anterior, sem sobrescrever o arquivo. As edições locais do exemplo de aprendizado também foram preservadas.

## Ajustes

- Dois TileMapLayers passaram de 750 para 375 colunas de 64 px, terminando exatamente em X=24.000. Células e vãos foram reposicionados, mantendo os buracos com 64 px de largura.
- Galhos foram encurtados e aproximados, mantendo os vãos de 64 px e a espessura original.
- Escada deslocada para a nova extremidade direita, preservando degraus de 96 px de largura e os quatro desníveis que exigem caixas. Custo mínimo continua quatro caixas / 12 madeiras.
- Retornos do subsolo realinhados às novas aberturas. Dimensões de plataformas, alturas, caixas, personagens, velocidade e alcance de ataque mantidos.
- Itens e inimigos redistribuídos horizontalmente, com coletáveis sobre superfícies sólidas. Mantidos 140 cenouras no mapa, 80 madeiras, 24 inimigos e 60 cenouras em drops: máximo 200.
- Chegada reposicionada em X=23.600, no subsolo. Câmera termina em X=24.000; desenho de fundo e quantidade de árvores/nuvens adequados ao novo comprimento.

A densidade média de inimigos por distância aumentou aproximadamente duas vezes, sem adicionar inimigos. As conexões de acesso e retorno da 0.4.0 foram preservadas; a ilustração do percurso em S continua sendo uma proposta para outra etapa. O tempo de partida da fase compacta deve ser medido em playtest; não forçamos duração mínima de 15 minutos.

## Editar e testar

Importe o projeto atual `game/project.godot`, abra `res://scenes/level_wide/fase_compacta.tscn` e use a área 2D. Selecione InicioJogador e pressione F para enquadrar. Os nós de Terrenos, Plataformas, Itens, Inimigos e Chegada continuam editáveis. Ctrl+S salva; F5 abre o jogo e F6 pela cena encaminha ao menu para testar com NOVO JOGO.

`tools/compact_level.gd` foi usado uma vez para produzir a nova cena a partir da original e recusa sobrescrever uma cena compacta existente. Não é executado durante as partidas e não refaz suas pinturas ou posições.

Versão de build 0.4.1; contrato global permanece **0.4.0 / 200 cenouras**. Não há nova migração SQL nesta atualização. A migração `202611120003_wide_level_scores.sql` da versão anterior continua necessária somente se ainda não tiver sido aplicada.

## Validação

- 32 checks de mapa em `tools/test_wide_level.gd`: extensão nativa, suporte dos itens, vãos preservados, totais, retorno físico do subsolo, quatro caixas e saltos reais para os degraus, custo e chegada.
- Nove checks de construção, seis de pouso da ave, 14 de ave/martelo, 24 de pisão, 16 de fluxo, 22 de envio automático e 19 de toque aprovados. Avisos conhecidos de encerramento dos testes headless de pisão/toque continuam registrados.
- Dez checks de integração Godot/API/PostgreSQL aprovados, com um resultado somente em banco temporário e nenhuma publicação fictícia.
- Smoke headless e execução OpenGL do EXE exportado por 120 frames aprovados. Cinco capturas em `docs/qa_compact_*.png` geradas; copa inspecionada visualmente. Playtest humano completo e tempo real ainda pendentes.

## Builds e download

- Windows: `game/builds/windows-0.4.1/CraftBunny-0.4.1.exe`, 137.114.664 bytes, SHA256 `2af94ab2e483867224ec2bc6b82e52aef502856f1e93fa8bd93de442b466ce35`. ZIP com licenças: `game/builds/CraftBunny-Windows-0.4.1.zip`.
- Android: `game/builds/CraftBunny-Android-0.4.1.apk`, 81.064.303 bytes, código 9, SHA256 `3bbd3a9b0e1a529796024eb65b6777069d53859330d698b4a7449396fb89221e`. Assinatura v2/v3 e mesmo certificado da 0.4.0 confirmados; atualização por cima preserva os dados.
- Upload privado confirmado pelo tamanho e caminho do objeto. Para selecionar este APK no site, atualizar na Vercel e fazer redeploy:

```text
APK_DOWNLOAD_VERSION=0.4.1
APK_BLOB_PATH=releases/0.4.1/3bbd3a9b0e1a/CraftBunny-Android-0.4.1.apk
APK_DOWNLOAD_SHA256=3bbd3a9b0e1a529796024eb65b6777069d53859330d698b4a7449396fb89221e
```

O upload não altera automaticamente a versão selecionada na Vercel.

Sem alterações nos recordes existentes, segredos ou artes originais. Builds anteriores preservados.
