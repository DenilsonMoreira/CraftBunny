# Dash e planar — 0.4.2 — 2026-11-13

Implementados diretamente no CharacterBody2D existente. Parâmetros, controles e regras detalhados no `game/README.md`. Não foram alterados gravidade, impulso de pulo, coyote time/jump buffer (0,12 s), dimensões de colisão, dano, vida, inventário, pontuação ou protocolo global (0.4.0). A fase permanece com 24.000 px e teto de 200 cenouras.

## Controle de estados

Dash e planar usam temporizadores/flags explícitos no controlador. O Dash fixa velocidade horizontal em 600 px/s por 0,16 s, preservando gravidade e `move_and_slide()`. Cooldown de 0,8 s contado desde o início; uma carga aérea por aterrissagem real sobre terreno/plataforma/caixa. Sair de uma borda durante Dash gasta a mesma carga; pisão em inimigos não recarrega. Parede encerra a arrancada. O pulo pode acontecer no mesmo tick e durante Dash no chão. Aceleração/atrito existentes suavizam a saída.

Ataques existentes precisam terminar antes de iniciar Dash. Ataque/construção ficam bloqueados durante Dash; o ataque possui buffer com validade de até 0,12 s, construção não fica enfileirada. Dash não executa pisão nem ganha imunidade. Dano cancela habilidades e mantém o knockback normal; morte as encerra. Pausa congela os temporizadores e descarta entradas pendentes.

O segundo evento de pulo, dentro de 0,35 s do salto, registra a solicitação de planar. Repetição automática de tecla não conta como toque. A solicitação feita na subida espera a velocidade vertical se tornar descendente, sem aplicar impulso. Segurar o segundo toque limita a queda a 70 px/s; soltar cancela. O saldo de 1 s só é gasto enquanto planando, não pode ser renovado em pleno ar e é suspenso durante Dash. O pouso recarrega as habilidades, mantendo o cooldown geral do Dash. Remapeamento usa a ação `jump`; funciona com Espaço, W, seta para cima ou tecla personalizada.

Touch mantém o analógico, martelo e caixa e adiciona DASH. O adaptador entrega eventos InputEventAction explícitos ao mesmo controlador de movimento, com estado imediato e sem confundir o primeiro toque. Dois dedos no mesmo botão não geram uma segunda pressão artificial; pausa/foco liberam as entradas.

## Arquivos

- `game/scripts/player.gd`: estados, parâmetros exportados, reconhecimento de eventos, física e animações de habilidade.
- `game/scripts/movement_fx.gd`: até três imagens residuais, poeira no chão, sem colisões/dano.
- `game/scripts/main.gd`: binding I, remapeamento/persistência e instruções de controles.
- `game/scripts/touch_controls.gd`: botão DASH e entrega explícita de eventos.
- `game/project.godot`, `game/export_presets.cfg`: Input Map e versão 0.4.2.
- `game/assets/production/v3/bunny_dash_12.png`, `bunny_glide_12.png`: duas spritesheets RGBA de 12 quadros, grade 4×3. Prompts/origem em `movement_animations.md` na mesma pasta.
- `game/assets/audio/sfx/dash_placeholder.wav`: sopro sintético original, curto e substituível; créditos atualizados em `game/assets/CREDITS.md`.
- `game/tools/test_mobility.gd`, `test_mobility_visual.gd`: novos testes físicos e visuais.
- `game/tools/test_touch.gd`: regressão ampliada com planar e Dash multitoque; `test_death.gd`: fixture de queda adaptada ao kill plane da fase atual.
- Documentação: `README.md`, `game/README.md`, `game/AGENTS.md`, `game/ROADMAP.md`, `game/docs/TEST_PLAN.md`, guias de build e este relatório. Metadados `.uid`/`.import` acompanham os novos recursos.
- Capturas: `docs/qa_mobility_dash.png` e `docs/qa_mobility_glide.png`.

As duas modificações prévias do usuário em `game/scenes/editor_example/` foram preservadas, sem incluí-las nesta atualização.

## Testes executados

Godot 4.7.2, Windows, API pública desativada nos processos de teste. Nenhum resultado fictício enviado ao ranking público.

| Suíte | Resultado |
|---|---|
| `test_mobility.gd` | 40 checks aprovados: chão/ar, cooldown, repetição aérea, recarga, paredes, primeiro/segundo toque, subida/descida, soltura, duração, combinações, buffer, dano, morte, coyote e jump buffer |
| `test_touch.gd` | 23 checks aprovados, incluindo segundo toque, planar segurado, Dash combinado e liberação de entradas |
| `test_build.gd` | 9 checks aprovados |
| `test_bird_hammer.gd` | 14 checks aprovados |
| `test_stomp.gd` | 24 checks aprovados |
| `test_wide_level.gd` | 32 checks aprovados, inclusive saltos obrigatórios com caixas e retorno do subsolo |
| `test_flow.gd` | 16 checks aprovados |
| `test_auto_ranking.gd` | 22 checks aprovados |
| `test_attack.gd` | PASS |
| `test_death.gd` | 10 checks aprovados, inclusive grito antes do som de morte |
| `test_mobility_visual.gd` | OpenGL: 12 quadros de Dash e 12 de planar observados, duas capturas revisadas em câmera lenta (0,25×) |

Alguns testes antigos continuam emitindo avisos de ObjectDB/resources em uso ao encerrar o processo (fluxo, pisão, ataque e morte); seus checks passaram. Não declarar esses avisos como corrigidos. A nova suíte de habilidades encerrou sem avisos desse tipo.

Reprodução na raiz do repositório, com `godot` apontando ao executável instalado:

```text
godot --headless --path game --editor --quit
godot --headless --path game --script res://tools/test_mobility.gd
godot --headless --path game --script res://tools/test_touch.gd
godot --path game --rendering-method gl_compatibility --script res://tools/test_mobility_visual.gd
godot --headless --path game --quit-after 120
```

## Validação manual pendente

No editor, F5 → NOVO JOGO: correr e pressionar I, combinar Espaço+I, colidir lateralmente com parede/caixa, confirmar cooldown e novo Dash após pousar. Apertar Espaço, soltar e apertar novamente dentro de 0,35 s; segurar até a descida, soltar, repetir após pousar. Confirmar retorno do planar após Dash e ausência de recarga no ar. Martelar e construir antes/depois; receber dano e morrer durante as habilidades. Verificar lenço/pivôs e fluidez em velocidade normal, ouvir o sopro e os volumes. Testar as mesmas combinações em Android físico com múltiplos dedos. Percurso completo e impacto das habilidades sobre o balanceamento ainda precisam de playtest; não foram declarados aprovados.

## Exportações verificadas

- Importação headless e smoke headless de 120 frames aprovados, sem erros de parser/runtime.
- Windows `game/builds/windows-0.4.2/CraftBunny-0.4.2.exe`: 139.160.528 bytes, versão 0.4.2.0, SHA256 `8fb03fc5a777ed04877072596ec48cc2658276c43583748384b8869615f28292`. Inicialização OpenGL de 120 frames fora do editor aprovada, saída 0 e log sem erros. ZIP com licenças `game/builds/CraftBunny-Windows-0.4.2.zip` (68.365.998 bytes).
- Android `game/builds/CraftBunny-Android-0.4.2.apk`: 83.096.748 bytes, SHA256 `6a645e2388778c5f7172a04c4bb0ae11a696f53122df64e85ba24616702cea5c`, código 10 / 0.4.2-android-test, ARM32/64, permissão INTERNET, assinatura v2/v3. Mesmo certificado da 0.4.1 confirmado. Execução em aparelho não realizada.
- Builds anteriores preservados. Não houve upload do novo APK nem troca da versão selecionada no site nesta etapa.
