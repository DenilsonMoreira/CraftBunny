# Craft Bunny 🐰🔨 — Godot 4

> **Status:** protótipo v0.3.3 com verificações automatizadas e APK de teste exportado; QA completo e playtest em Android físico pendentes. **Objetivo:** concluir uma versão 1.0 jogável de **uma única fase longa**, com pontuação por cenouras e ranking local. **Engine validada:** Godot 4.7.2 / GDScript / 2D.

## O jogo

**Craft Bunny** é um jogo de plataforma 2D de correr, saltar, enfrentar inimigos e improvisar caixas de madeira com o martelinho. O coelho atravessa cinco regiões conectadas de um mesmo mapa, até chegar à **casa do coelhinho**, que marca o final da tentativa. A competição é pelo maior número de cenouras coletadas, não pelo tempo de chegada.

**Escopo travado da v1.0:** uma fase (~12.000 px, revisável por playtest); sem checkpoints; sem lojas; sem áreas secretas; sem segunda fase; sem sistema de progressão persistente. **Somente os recordes e preferências/controles ficam salvos localmente.** Uma segunda fase será avaliada **após** validar a primeira.

## Iniciar e testar

Título, opções e controles com tema pixel art; inimigos exibem balão de detecção e feedback de dano. Arte, fonte, testes e limitações em assets/production/v2/pixel_menus_feedback.md.

Atualização visual: mundo ampliado em 25% pela câmera, com colisões preservadas. Ataque exclusivo do coelho em 12 quadros, martelo maior e alcance frontal de 32 unidades. Detalhes e testes em assets/production/v2/bunny_attack_12.md.

Versão Android de teste já exportada na pasta de trabalho anterior, com controles multitoque, paisagem e mínimo API 24. APKs não são versionados neste repositório; novas exportações ficam em builds/. Instalação, build e limitações em docs/ANDROID_BUILD.md. Execução em aparelho ainda pendente.

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
| Martelar | J |
| Construir caixa | K |
| Pausar | Esc/P |
| Reiniciar tentativa | R |

As teclas devem ser remapeáveis nas opções. Reiniciar começa sempre do início.

Construção: aproxime-se de um apoio e pressione K (padrão). Caixas podem ser empilhadas ao mirar uma caixa próxima; para atingir níveis mais altos, suba ou salte e deixe livre o espaço da nova caixa. Cada construção custa três tábuas; cenouras são apenas pontuação.

## Regras definitivas v1.0

| Elemento | Regra |
|---|---|
| Vida inicial do coelho | **3 HP = 3 corações** |
| Coração coletável | +1 HP, máximo 3 |
| Invulnerabilidade após dano | **1,0 segundo** |
| Martelada | **1 dano** por golpe validado |
| Pisão | **1 dano** ao cair por cima do inimigo; impulso de retorno e um quique no chão |
| Cobra | **2 HP**, **1 dano**, derruba **1 cenoura** |
| Guaxinim | **5 HP**, **2 danos**, derruba **3 cenouras** |
| Ave de rapina | **7 HP**, **3 danos**, derruba **5 cenouras** |
| Tábuas | sem limite de quantidade carregada |
| Caixa | custa **3 tábuas**, possui **2 HP** e **só o coelho pode destruí-la** |
| Cenouras | +1 ponto por cenoura, nenhuma outra função |
| Coletáveis | flutuam pouco acima do chão; coletados por contato |
| Fim da fase | tocar/entrar na área da **casa do coelhinho** |
| Derrota | HP = 0 ou queda fora da fase, sem checkpoint |
| Recordes | TOP 10, **exatamente três letras A–Z**; entra após vitória **ou** derrota, se qualificar |
| Salvamento | **somente ranking, áudio e controles**; nunca salvar posição, HP, madeira ou cenouras da tentativa |

**Empates no ranking:** comportamento atual usa ordenação por cenouras e exige superar o 10º lugar quando cheio; não introduzir novo critério de desempate sem registrar a decisão. Nunca registrar uma pontuação duas vezes na mesma tentativa.

### Física e combate — valores iniciais para teste (não balanceamento final)

- `SPEED = 230 px/s`, `ACCELERATION = 1250 px/s²`, `FRICTION = 1600 px/s²`.
- Gravidade `1150 px/s²`; impulso vertical `-311 px/s` (altura ideal aproximada **42 px**, equivalente à altura-alvo inicial do coelho). Ajustar **somente em playtest** após confirmar a escala do sprite/collision shape.
- **Coyote time = 0,12 s** e **jump buffer = 0,12 s**.
- Hitbox ativa do martelo **0,12 s**; intervalo entre marteladas **0,42 s**; impedir múltiplos acertos no mesmo alvo por golpe.
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

**Regra de design:** não criar saltos impossíveis com o pulo padrão nem trechos obrigatórios que consumam mais tábuas do que o jogador pode obter. O jogo precisa ser concluível mesmo após erros razoáveis; não depender de um único item perdido para completar a fase. Sem checkpoints significa que justiça, legibilidade e telegraph de ataques são essenciais.

## Arquivos existentes

- `project.godot`: configuração do projeto.
- `main.tscn`: cena inicial.
- `scripts/main.gd`: geração do mapa, HUD, menus, ranking e economia, **atualmente concentrados em um arquivo grande**.
- `scripts/player.gd`: jogador, física, martelo, câmera, HP.
- `scripts/enemy.gd`: comportamentos de inimigos, dano e drops.
- `scripts/box.gd`: caixas de 2 HP.
- `scripts/pickup.gd`: itens coletáveis.
- `scripts/parallax.gd`: fundo provisório.

**Arte atual:** placeholders desenhados via `_draw()`. As folhas de pixel art feitas durante o planejamento são referências visuais e **não estão integradas ao protótipo**. Tratar folhas com títulos/quadros como concept sheets; **não presumir que são sprite atlases prontos** para `AnimatedSprite2D`. Pode ser necessário recortar, remover fundos, padronizar dimensões e revisar frames. Consultar `docs/ASSETS.md`.

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
