# Craft Bunny 🐰🔨 — Godot 4

> **Status:** protótipo v0.5.1 com quatro ferramentas, projétil/mira, árvores-ponte, rochas quebráveis e botões touch circulares. Artes de ferramentas/personagem e obstáculos integradas em production/v4; percurso completo e Android físico pendentes de playtest. **Objetivo:** concluir uma versão 1.0 jogável de **uma única fase**. **Engine validada:** Godot 4.7.2 / GDScript / 2D.

## O jogo

**Craft Bunny** é um jogo de plataforma 2D de correr, saltar, enfrentar inimigos e improvisar caixas de madeira com o martelinho. O coelho explora floresta, copa e subsolo conectados no mesmo mapa, até chegar à **casa do coelhinho**, que marca o final da tentativa. A competição é pelo maior número de cenouras coletadas, não pelo tempo de chegada.

**Escopo da v1.0:** uma fase de 24.000 px em três alturas, revisável por playtest; sem checkpoints; sem lojas; sem áreas secretas; sem segunda fase; sem sistema de progressão persistente. **Somente os recordes e preferências/controles ficam salvos localmente.** Uma segunda fase será avaliada **após** validar a primeira.

## Iniciar e testar

**Fase atual 0.5.1:** `scenes/level_wide/fase_ferramentas.tscn`, editável na área 2D, com floresta, copa e subsolo. 140 cenouras no mapa + 60 de inimigos = 200 antes de gastar munição. Dois buracos exigem árvores derrubadas com machado; duas passagens com cenouras visíveis exigem picareta. Quatro desníveis da escada continuam exigindo caixas; aves pousam por 0,5 s após atacar. Guia em `../docs/TOOLS_050.md`. Cenas anteriores e exemplo inicial preservados.

**Aprender a editar a fase visualmente:** abra `scenes/editor_example/fase_exemplo.tscn` e pressione **F6**. Contém terra pintável com colisão, início do coelho e uma cobra arrastáveis. F5 continua no jogo principal. Guia passo a passo em `docs/EDITABLE_EXAMPLE.md`.

Windows atual: `builds/windows-0.5.1/CraftBunny-0.5.1.exe`. Abrir a pasta antiga não atualiza o jogo de PC. Histórico em `docs/WINDOWS_BUILD.md`; atualização em `../docs/TOOLS_050.md`.

RECORDES → ZERAR RANKING LOCAL pede confirmação antes de apagar os recordes deste aparelho. Cancelar preserva os dados; a ação não afeta o ranking global. Detalhes em ../docs/LOCAL_RESET_AND_RANKING_LAYOUT.md.

Ao terminar, informe três letras e use REGISTRAR RECORDE: se entrar no TOP 10 local e no TOP 100 global, o envio ocorre automaticamente após salvar localmente. Falhas de internet preservam o recorde no aparelho. RANKING GLOBAL abre o site; não há tabela global dentro do jogo. Contrato novo 0.4.0/teto 200; antigos 0.3.4/teto 139 preservados. Aplicar a migração indicada em ../docs/WIDE_LEVEL_040.md.

Título, opções e controles com tema pixel art; inimigos exibem balão de detecção e feedback de dano. Arte, fonte, testes e limitações em assets/production/v2/pixel_menus_feedback.md.

Atualização visual: mundo ampliado em 25% pela câmera, com colisões preservadas. Ataque exclusivo do coelho em 12 quadros, martelo maior e alcance frontal de 32 unidades. Detalhes e testes em assets/production/v2/bunny_attack_12.md.

Versão Android atual em builds/CraftBunny-Android-0.5.0.apk, com analógico semitransparente à esquerda e círculos com ícones para pulo, ação, caixa, troca, Dash e pausa. Duplo toque/segurar no pulo plana; segurar/soltar a ação mira/dispara estilingue. Paisagem e mínimo API 24. APKs não são versionados. Playtest físico pendente.

Retenção local: manter apenas os dois builds completos mais recentes. Após exportar EXE, ZIP e APK, `./tools/prune_builds.ps1 -Keep 2` lista as versões antigas; `-Apply` realiza a limpeza. Atualmente mantidas **0.5.0 e 0.4.3**. A limpeza anterior da 0.4.3 liberou ~2,09 GB; a atualização 0.5.0 removeu a 0.4.2, liberando mais ~430 MB. Documentos históricos podem citar builds removidos; fontes, artes e histórico Git permanecem.

1. Instale **Godot 4.3 ou superior**.
2. Abra o gerenciador de projetos da Godot, clique em **Importar** e escolha `project.godot` nesta pasta.
3. Abra o projeto e pressione **F5**. Cena inicial: `main.tscn`.
4. Se ocorrer erro de parser, carregamento ou física, **corrija antes** de desenvolver novas funcionalidades. Veja os registros de validação no ROADMAP.md.
5. Para teste automatizado de importação, se `godot` estiver instalado no PATH: `godot --headless --path . --editor --quit` (importação), depois `godot --headless --path . --quit-after 120` (smoke test). A CLI não substitui teste visual/manual.

### Controles iniciais

| Ação | Teclas |
|---|---|
| Andar | A/D ou setas esquerda/direita |
| Saltar | Espaço/W/seta cima |
| Alternar ferramenta | I |
| Dash | L |
| Planar | Segundo toque no pulo em até 0,35 s; segurar durante a descida |
| Ação principal / segurar para mirar e soltar para disparar | J |
| Construir caixa com martelo | K |
| Pausar | Esc/P |
| Reiniciar tentativa | R |

As teclas devem ser remapeáveis nas opções. Reiniciar começa sempre do início.

### Ferramentas — 0.5.0

I alterna **martelo → machado → picareta → estilingue → martelo**. O HUD mostra ícone/nome, destaca a troca e usa `music/item-switch.mp3`. A troca leva 0,24 s sem parar movimento/pulo; pedidos feitos durante ataque/Dash aguardam o fim da ação. Trocar, receber dano, pausar ou iniciar Dash cancela a mira sem gastar munição. Preferências antigas com Dash em I migram para L; demais teclas personalizadas são preservadas.

| Ferramenta | Dano | Tempo | Utilidade |
|---|---|---|---|
| Martelo | 1 HP | 0,35 s; janela ativa 0,12 s | Combate, construir por 3 tábuas e destruir caixas de 2 HP |
| Machado | 2 HP | 0,55 s; preparação 0,10 s, ativa 0,12 s | Combate e árvores marcadas |
| Picareta | 3 HP | 1,00 s: preparação 0,30 / ativa 0,20 / recuperação 0,50 | Rochas marcadas e interceptar ave frontal/de cima durante a janela ativa |
| Estilingue | 3 HP | Recuperação 0,35 s após disparo válido | Gasta 1 cenoura por disparo; não dispara sem saldo |

Estilingue: segure J para ver a parábola e continuar andando; solte para disparar. Velocidade inicial `(±390, -230)` px/s, gravidade 900 px/s², colisão contínua com inimigos/cenário e duração máxima 4 s. Munição é descontada uma vez ao criar o projétil; ranking local e envio global usam **somente cenouras restantes**, sem alterar dados de recordes antigos. Interceptação da picareta aplica 3 HP/knockback e cancela aquele mergulho; preparação, recuperação e ataques laterais continuam vulneráveis.

A fase contém árvores em X≈2.008 e 14.296, criando pontes sobre vãos de 1.024 px; três golpes de machado e queda previsível para a direita (0,65 s). Passagens baixas com rochas em X=6.144 e 18.432 guardam 12 cenouras existentes; três golpes de picareta abrem cada passagem. Há rachaduras, fragmentos e som provisório. Sem áreas secretas nem novos recursos consumidos pelos obstáculos. F6 pela cena encaminha ao menu; F5 abre o jogo.

Animações: martelo conserva os sprites existentes, incluindo ataque/Dash de 12 quadros. Machado, picareta, estilingue e switch usam **poses modulares provisórias em 12 passos**, sem afirmar 12 artes finais distintas. `assets/production/tools/tool_frames_template.tres` oferece 32 slots nomeados `ferramenta/estado`; `final_tool_frames` no jogador recebe SpriteFrames finais e substitui apenas estados preenchidos. Padrão e instruções em `assets/production/tools/README.md`.

Configuração central em `scripts/tool_catalog.gd`; obstáculos têm propriedades exportadas no editor. Testes: `godot --headless --path . --script res://tools/test_tools.gd` e `... --script res://tools/test_tool_level.gd`. Relatório completo em `../docs/TOOLS_050.md`.

### Dash e planar — 0.4.2

Dash: 600 px/s, duração 0,16 s, cooldown 0,8 s, na direção do olhar. Disponível no chão e uma vez por salto; a carga aérea volta ao pousar sobre terreno, plataforma ou caixa. Mantém colisões, não atravessa obstáculos, não causa dano e não dá invulnerabilidade. Ataque e construção ficam bloqueados durante a arrancada; uma martelada solicitada nos últimos 0,12 s é executada ao terminar. Dash aguarda o término da animação de um ataque já iniciado. Aceleração/atrito normais suavizam o retorno. Pulo continua disponível durante Dash no chão.

Planar: o primeiro evento de pulo salta normalmente. Um segundo toque dentro de 0,35 s solicita abrir o lenço, sem impulso vertical; se ocorrer na subida, aguarda a descida. Segure o segundo toque para reduzir a queda a no máximo 70 px/s, por até 1 s acumulado por salto. Soltar cancela a solicitação e volta à queda normal; novos toques não recarregam o tempo. Dash suspende o planar sem consumir nem repor seu saldo e permite retomá-lo se o pulo continuar segurado. Dano cancela as habilidades e mantém knockback/invulnerabilidade existentes. O pulo base não foi alterado.

Valores ajustáveis exportados em `scripts/player.gd`: `dash_speed`, `dash_duration`, `dash_cooldown`, `dash_attack_buffer_time`, `glide_double_tap_window`, `glide_duration`, `glide_fall_speed` e `dash_sound`. O som padrão substituível é `assets/audio/sfx/dash_placeholder.wav`. Artes RGBA de 12 quadros cada: `assets/production/v3/bunny_dash_12.png` e `bunny_glide_12.png`, com abertura, ciclo e recolhimento do lenço. Dash possui mais 0,08 s de animação de frenagem, sem prolongar sua velocidade.

Testes reproduzíveis: `godot --headless --path . --script res://tools/test_mobility.gd` e `godot --path . --rendering-method gl_compatibility --script res://tools/test_mobility_visual.gd`. O segundo usa câmera lenta para inspeção e capturas. Relatório e testes manuais pendentes em `../docs/MOVEMENT_ABILITIES_042.md`.

Construção: equipe martelo, aproxime-se de um apoio e pressione K. Caixas podem ser empilhadas ao mirar outra caixa; para níveis altos, suba ou salte e deixe livre o novo espaço. Cada construção custa três tábuas; cenouras são pontuação e munição do estilingue.

## Regras definitivas v1.0

| Elemento | Regra |
|---|---|
| Vida inicial do coelho | **3 HP = 3 corações** |
| Coração coletável | +1 HP, máximo 3 |
| Invulnerabilidade após dano | **0,5 segundo** |
| Martelada | **1 dano** por golpe validado |
| Pisão | **1 dano** ao cair por cima do inimigo; impulso de retorno e um quique no chão |
| Cobra | **2 HP**, **1 dano**, derruba **1 cenoura** |
| Guaxinim | **5 HP**, **2 danos**, derruba **3 cenouras** |
| Ave de rapina | **7 HP**, **3 danos**, derruba **5 cenouras** |
| Tábuas | sem limite de quantidade carregada |
| Caixa | custa **3 tábuas**, possui **2 HP** e **só o coelho pode destruí-la** |
| Cenouras | +1 ponto ao coletar; estilingue consome 1 por disparo; ranking considera o saldo |
| Coletáveis | flutuam pouco acima do chão; coletados por contato |
| Fim da fase | tocar/entrar na área da **casa do coelhinho** |
| Derrota | HP = 0 ou queda fora da fase, sem checkpoint |
| Recordes | TOP 10, **exatamente três letras A–Z**; entra após vitória **ou** derrota, se qualificar |
| Salvamento | **somente ranking, áudio e controles**; nunca salvar posição, HP, madeira ou cenouras da tentativa |

**Empates no ranking:** comportamento atual usa ordenação por cenouras e exige superar o 10º lugar quando cheio; não introduzir novo critério de desempate sem registrar a decisão. Nunca registrar uma pontuação duas vezes na mesma tentativa.

### Física e combate — valores iniciais para teste (não balanceamento final)

- `SPEED = 230 px/s`, `ACCELERATION = 1250 px/s²`, `FRICTION = 1600 px/s²`.
- Gravidade `1150 px/s²`; impulso vertical preservado em `-340 px/s` (altura ideal ~50 px, próxima à altura visual do coelho). Não houve ajuste do pulo nesta versão.
- **Coyote time = 0,12 s** e **jump buffer = 0,12 s**.
- Hitbox ativa do martelo **0,12 s**; intervalo entre marteladas **0,35 s**; um acerto por alvo por golpe.
- Knockback no coelho ao receber dano: ~**215 px/s horizontal**, **-190 px/s vertical**.
- Recuperação após martelada em inimigo: **0,28 s**; recuperação pós-ataque: ~**0,35 s**.
- IA com **patrulha → detecção → perseguição → aviso/ataque → recuperação**; cobra detecta 185 px, guaxinim 275 px, ave 315 px. A ave anuncia o mergulho para o jogador poder reagir.
- Dano da ave (3 HP) pode eliminar o coelho com a barra cheia; preservar a regra até avaliação do playtest.

## Estrutura da fase única

| Trecho | Percurso | Mecânica dominante |
|---|---|---|
| 1. Pradaria inicial | 0–15% | Aprender movimento, coletar cenouras, cobras |
| 2. Floresta | 15–35% | Introduzir madeira, construção e inimigos |
| 3. Rochas e barrancos | 35–55% | Guaxinins, buracos, plataformas |
| 4. Copas das árvores | 55–80% | Aves, elevação, risco/recompensa |
| 5. Última travessia | 80–100% | Misturar ameaças, aumentar densidade, chegar à casa |

**Regra de design:** saltos comuns devem respeitar pulo/caixas disponíveis. Os dois grandes vãos sinalizados são desafios de árvore/machado, com ferramenta sempre disponível e ponte permanente durante a tentativa. Não consumir mais tábuas do que o jogador pode obter nem depender de um único item perdido. Sem checkpoints significa que justiça, legibilidade e aviso de ataques são essenciais.

## Arquivos existentes

- `project.godot`: configuração do projeto.
- `main.tscn`: cena inicial.
- `scripts/main.gd`: geração do mapa, HUD, menus, ranking e economia, **atualmente concentrados em um arquivo grande**.
- `scripts/player.gd`: jogador, física, martelo, câmera, HP.
- `scripts/enemy.gd`: comportamentos de inimigos, dano e drops.
- `scripts/box.gd`: caixas de 2 HP.
- `scripts/pickup.gd`: itens coletáveis.
- `scripts/parallax.gd`: fundo provisório.

**Arte atual:** sprites de produção v2/v3 já integrados ao jogo; novas ferramentas, suas poses e alguns obstáculos usam placeholders técnicos organizados. Referências com títulos/quadros continuam sendo concept sheets, não atlas prontos. A estrutura de substituição por arte final está em `assets/production/tools/README.md`; consultar também `docs/ASSETS.md`.

## Como trabalhar com Codex

1. Leia **`AGENTS.md`** (instruções permanentes) e **`ROADMAP.md`** (etapas e critérios de pronto).
2. Execute **somente a primeira etapa incompleta**, em commits pequenos; não começar arte/polimento antes do projeto rodar.
3. Antes de editar, inspecione a implementação real e preserve as regras acima.
4. Depois de cada etapa: execute validações disponíveis, documente testes manuais, liste erros conhecidos e atualize os checkboxes de `ROADMAP.md` **apenas quando verificados**.
5. Nunca declarar “funcional” ou “testado na Godot” sem ter realmente executado os testes correspondentes.

### Primeiro comando para colar no Codex

```text
Leia AGENTS.md, README.md, ROADMAP.md e docs/TEST_PLAN.md. Faça uma auditoria do projeto Godot existente, identifique problemas de parser/runtime e execute a etapa M0 (estabilização) sem implementar fases extras ou modificar as regras de gameplay. Se a Godot estiver disponível, rode importação headless e smoke test; se não, documente claramente a limitação. Corrija os problemas encontrados, apresente o diff, os testes e a atualização de ROADMAP.md. Só avance para M1 quando M0 estiver verificada.
```

## Critério de conclusão da v1.0

Um jogador consegue iniciar no título, percorrer toda a fase, controlar o coelho com pulo consistente, construir/destruir caixas, enfrentar e derrotar os três inimigos, coletar cenouras, chegar à casa **ou morrer**, registrar três letras quando elegível, consultar o TOP 10 após reabrir o jogo e ajustar áudio/teclas. Nenhuma tentativa pode ser retomada a partir do meio da fase. O projeto precisa abrir sem erros e exportar para Windows. Confira os casos detalhados em `docs/TEST_PLAN.md`.

**Referência sonora:** https://pixabay.com/pt/sound-effects/ — importar arquivos selecionados pelo usuário, conferir licença e condições de cada download antes de distribuir.

## Arte incluída no pacote

As referências de sprites do coelho, inimigos, coletáveis, HUD, tela de título, terreno e folhagens estão em `assets/references/`. Leia `assets/references/README.md` antes de convertê-las em spritesheets técnicos; as folhas atuais não são atlas prontos para importação automática.

## Artes 0.5.1

Onze folhas de 12 quadros, quatro ferramentas, kit de árvore e quatro estados de rocha. Corpo modular em idle/run/jump/fall/dash/glide/switch; ataques próprios de machado/picareta/estilingue e mira. Martelo, morte e pisão anteriores preservados. Parâmetros de movimento, danos, hitboxes, inventário e ranking preservados. Fontes e prompts: assets/production/v4/README.md; testes e limites: ../docs/ART_051.md.
