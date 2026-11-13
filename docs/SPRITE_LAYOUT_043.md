# Enquadramento do martelo e escala do planar — 0.4.3 — 2026-11-13

Analisado o vídeo `20261113-1316-37.5110756.mp4` fornecido pelo usuário (16,07 s, 30 fps), com amostras do ataque e do planar. O ataque recortava parte do martelo e a abertura do lenço aumentava o corpo do coelho. Não foi necessário recriar os PNGs: ambos os defeitos estavam na montagem e escala do sprite em tempo de execução.

## Correções

- `game/scripts/sprite_atlas.gd`: quando existem pivôs de pés por quadro, calcula uma tela transparente comum que acomoda todo o conteúdo acima/abaixo e dos dois lados do pivô. A tela é simétrica horizontalmente e tem 2 px de respiro; offsets e posição do sprite mantêm o mesmo pivô. A escala do ataque não foi alterada.
- Antes, os quadros 7, 8 e 9 excediam a margem direita em 22, 34 e 12 px da textura; os quadros 9 e 10 também excediam o limite inferior em 21 e 25 px. O tamanho lógico fixo da célula cortava esses trechos após deslocar o pivô. Agora todos os 12 quadros cabem completamente na tela virtual, inclusive espelhados.
- `game/scripts/player.gd`: calibra a primeira pose do planar pela altura alpha da pose normal, em vez de preencher uma caixa de 82×76. Altura de referência ~53,17 px de mundo; abertura do planar igual à pose normal, demais poses variam com a postura, sem crescimento de escala. Animação continua com 12 quadros, mesmo tempo e transições.
- Nenhuma mudança em hitbox do martelo (32×26), dano, colisão do corpo, velocidade, física de Dash/planar, inventário ou pontuação. PNGs de produção e artes originais preservados.

## Testes realizados

- `test_sprite_layout.gd`: 40 verificações geométricas/escala e duas capturas OpenGL aprovadas (42 checks na execução com `--capture`). Canvas comum, margens completas do ataque, escala de ataque preservada, referência do planar e 12 quadros em ambas as sequências.
- Capturas inspecionadas: `docs/qa_attack_layout_043.png` (12 quadros para cada lado) e `docs/qa_glide_scale_043.png` (normal e 12 poses de planar).
- Regressões headless aprovadas: habilidades 40, toque 23, fluxo 16, ave/martelo 14, pisão 24; `test_attack.gd` PASS com 12 quadros e um único evento de golpe.
- Alguns testes antigos ainda reportam recursos/ObjectDB em uso no encerramento, sem falha dos checks; não foram declarados corrigidos nesta etapa.

Na raiz do repositório:

```text
godot --path game --rendering-method gl_compatibility --script res://tools/test_sprite_layout.gd -- --capture
godot --headless --path game --script res://tools/test_mobility.gd
godot --headless --path game --script res://tools/test_attack.gd
```

Pendente: confirmar visualmente em partida real/Android físico as transições, especialmente ataque em movimento junto de paredes. A revisão quadro a quadro e os testes automatizados não substituem esse playtest.

## Retenção de builds

Autorização do usuário: manter somente as duas últimas versões. A limpeza se restringe a `game/builds/`: executáveis/distribuições Windows, ZIPs, APKs versionados e logs de exportação/smoke das versões removidas. Histórico Git, fontes, capturas/documentação, artes de referência e as duas edições prévias do exemplo visual são preservados. Armazenamento remoto e versão selecionada no site não são alterados.

`game/tools/prune_builds.ps1` lista os alvos por padrão. `-Apply` remove somente filhos diretos reconhecidos da pasta de builds, após validar os caminhos absolutos, rejeitar links e confirmar que as duas versões retidas têm EXE, ZIP e APK. Aliases `CraftBunny-Android-Test.apk`/assinatura continuam correspondendo à versão atual.

Executado após exportação e validação: mantidas **0.4.3 e 0.4.2**; removidas 23 entradas das versões 0.3.5, 0.3.6, 0.3.7, 0.4.0 e 0.4.1, liberando **2.092.890.687 bytes** (~2,09 GB). Segunda execução em modo de listagem confirmou zero remoções pendentes. Log local: `game/builds/prune-0.4.3.log`.

```powershell
./game/tools/prune_builds.ps1 -Keep 2
./game/tools/prune_builds.ps1 -Keep 2 -Apply
```

## Builds verificados

- Windows: `game/builds/windows-0.4.3/CraftBunny-0.4.3.exe`, versão 0.4.3.0, 139.165.504 bytes, SHA256 `294009ca200fd3af7111438b79aa19382dab70369d798872bb876ba3597029ae`. Importação/exportação e smoke OpenGL de 120 frames fora do editor aprovados, saída 0 sem erros no log. ZIP com licenças: `game/builds/CraftBunny-Windows-0.4.3.zip` (68.370.515 bytes).
- Android: `game/builds/CraftBunny-Android-0.4.3.apk`, código 11 / 0.4.3-android-test, 83.096.748 bytes, SHA256 `64aa204d1c092e1374852a4431bb24274b5d48589c03cbdd5fedf938bf54e45c`. ARM32/64 e assinatura v2/v3 conferidos; mesmo certificado da 0.4.2 confirmado, permitindo atualização por cima. Execução em aparelho físico pendente.
- APK novo não enviado ao armazenamento remoto; seleção do download no site preservada.
