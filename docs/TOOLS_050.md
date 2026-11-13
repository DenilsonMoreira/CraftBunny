# Ferramentas, desafios ambientais e Android — 0.5.0 — 2026-11-13

Implementação incremental no projeto existente, com Godot 4.7.2 e CharacterBody2D preservados. Regras atualizadas por solicitação expressa: invulnerabilidade 0,5 s, martelo a cada 0,35 s, I troca ferramentas e L executa Dash. As demais regras continuam: 3 HP, caixas de 2 HP/3 tábuas, inimigos/drops 2/1/1, 5/2/3, 7/3/5, uma fase de 24.000 px, sem checkpoint/save de progresso. Coyote time e jump buffer **0,12 s** cada; gravidade/impulso de pulo não alterados (1150 / -340, altura ideal ~50 px).

## Implementado

- Equipamento cíclico: martelo → machado → picareta → estilingue. Catálogo único define dano, preparação, janela ativa e tempo total. Troca de 0,24 s, destaque/nome/ícone no HUD e som `item-switch.mp3` fornecido pelo usuário. Pedido durante ataque/Dash é adiado até o fim da ação; mirar é cancelado sem disparo acidental.
- Martelo: 1 dano, 0,35 s, ativa 0,12 s; único responsável por construir e destruir caixas. Machado: 2 dano, 0,55 s, preparação 0,10/ativa 0,12. Picareta: 3 dano, 1 s com 0,30 preparação/0,20 ativa/0,50 recuperação. Um acerto por alvo por golpe.
- Picareta ativa: verifica o mergulho da ave antes da emissão de dano por contato/ataque e após seu movimento. Só intercepta ave descendo na região frontal/superior do golpe. Aplica 3 dano/knockback e cancela aquele mergulho. Não altera invulnerabilidade do jogador; ataques laterais, preparação e recuperação não recebem proteção automática.
- Estilingue: segurar J mira e mostra parábola enquanto o jogador anda. Soltar J cria um projétil e desconta uma cenoura somente se houver saldo. Velocidade (±390,-230), gravidade 900, colisão varrida com círculo de 4 px, dano 3 e máximo de 4 s. Cenário e caixas param o projétil; ele não quebra obstáculos reservados às ferramentas. Movimento do dono não o faz atingir o próprio coelho.
- `carrot_count` continua sendo o saldo único da tentativa; o consumo de munição reduz diretamente a pontuação usada na qualificação TOP 10, no registro local e no envio TOP 100. Nenhuma recontagem posterior devolve munição gasta. Recordes antigos preservados; contrato global 0.4.0/200 não exige migração nova.
- Dois buracos de 1.024 px (X=2.048–3.072 e 14.336–15.360) atravessam os três pisos: retirada de terreno e recorte de galhos impedem atalhos por baixo/cima. Árvores próximas exigem três golpes de machado, caem sempre à direita em 0,65 s e viram pontes sólidas de 1.184 px; suportam retorno e construção. Simulação com pulo+Dash+planar não cruzou os vãos sem ponte. Limite conservador considerando até as 80 tábuas empilhadas também fica abaixo do vão.
- Duas passagens baixas no subsolo, em X=6.144 e 18.432, possuem rochas de três golpes de picareta, teto/fundo/piso e 12 cenouras **já existentes** visíveis no interior. A rocha é necessária para acessar essas cenouras; não há área secreta. Rachaduras, fragmentos e som provisório de impacto. A abertura não consome madeira/munição. Os dois desafios de árvore ficam no percurso de travessia; os de pedra dão acesso às cenouras úteis conforme o escopo solicitado.
- Orçamento preservado: 140 cenouras de mapa + 60 drops = 200 antes de gastar munição; 80 tábuas, 24 inimigos, mesma casa/escada de quatro caixas/retornos do subsolo. Quatro coletáveis foram realinhados a superfícies após abrir os novos vãos.
- Android: analógico esquerdo preservado; círculos com ícones de pulo, ferramenta/ação atual, caixa, troca, Dash e pausa. Área de toque circular, multitoque e liberação na pausa/foco preservados. A mira destaca o botão de ação e o HUD.
- Preferências antigas: binding antigo de Dash em I migra para L quando o arquivo não possui o schema novo; outros remapeamentos continuam válidos. O Input Map do projeto contém todas as ações oficiais.

## Preparado para sprites finais

- Martelo, morte, pisão e lenço mantêm os assets de produção existentes e a correção de enquadramento/escala da 0.4.3.
- Novas variantes de ferramenta/switch são **provisórias**, desenhadas modularmente em 12 passos por ação, com nomenclatura consistente. Há 32 slots no template SpriteFrames. Não foram produzidas 20 spritesheets finais nem declaradas 12 artes únicas para cada sequência.
- `final_tool_frames` permite substituir estados preenchidos, mantendo fallback para os demais. Orientações de canvas/pivô em `game/assets/production/tools/README.md`. Ícones, árvore gigante, ponte e rochas possuem representação técnica funcional que ainda pode receber acabamento artístico.

## Arquivos criados/alterados

| Arquivo/pasta | Responsabilidade |
|---|---|
| `game/scripts/tool_catalog.gd` | Enum, ordem, estatísticas e nomes de animação |
| `game/scripts/player.gd` | Estado de equipamento, inputs, temporizadores, mira, parry e recurso de arte final |
| `game/scripts/main.gd` | Resolução de golpes, munição, projétil, HUD, dicas e migração de controles |
| `game/scripts/enemy.gd` | Verificação de interceptação antes do dano da ave |
| `game/scripts/carrot_projectile.gd` | Movimento balístico, colisão e dano único |
| `game/scripts/tool_visual.gd` | Poses provisórias, SpriteFrames finais e prévia de trajetória |
| `game/scripts/tool_icons.gd` | Ícones nativos compartilhados |
| `game/scripts/tool_obstacle.gd` | Árvore/ponte e rocha, propriedades exportadas e preview no editor |
| `game/scripts/pixel_hud.gd` | Ferramenta ativa, destaque de troca e indicador de mira |
| `game/scripts/touch_controls.gd` | Botões circulares com ícones e troca por toque |
| `game/scripts/movement_fx.gd` | Rastros provisórios sem mostrar martelo ao usar outra ferramenta |
| `game/scenes/level_wide/fase_ferramentas.tscn` | Fase ativa com os quatro desafios editáveis |
| `game/assets/production/tools/tool_frames_template.tres`, `README.md` | 32 slots de arte final e instruções |
| `game/music/item-switch.mp3` e `.import` | Som fornecido pelo usuário, integrado em SFX |
| `game/tools/author_tool_level.gd` | Autoria uma vez, sem sobrescrever geometria existente; flag explícita para alinhar marcadores sem regenerar |
| `game/tools/create_tool_frames.gd` | Geração inicial do template sem sobrescrever arquivo preenchido |
| `game/tools/test_tools.gd` | Testes de ferramentas, dano, munição, parry, ranking e recursos de animação |
| `game/tools/test_tool_level.gd` | Testes físicos dos quatro desafios |
| `game/tools/test_tools_visual.gd` | Capturas de interface, mira e obstáculos |
| `game/tools/test_touch.gd`, `test_wide_level.gd` | Regressões ajustadas aos círculos e aos dois novos vãos autorizados |
| `game/project.godot`, `export_presets.cfg` | Input Map e versão 0.5.0 |
| `README.md`, `game/README.md`, `game/AGENTS.md`, `game/ROADMAP.md`, `game/docs/TEST_PLAN.md`, guias de build e créditos | Regras vigentes, documentação e validação |
| `docs/qa_tools_*.png` | Seis capturas OpenGL revisadas |

Metadados `.uid` e `.import` acompanham os novos recursos. As duas alterações locais anteriores em `game/scenes/editor_example/` foram preservadas, sem incluí-las neste trabalho. Nenhuma arte original foi apagada.

## Testes realmente executados

| Teste | Resultado |
|---|---|
| `test_tools.gd` | **68 checks aprovados**, incluindo teclas físicas I/L, ciclo/HUD/som, danos, timing pesado, três casos de ave, mira móvel, consumo/não disparo sem munição, colisões, drops exatos, saldo do ranking, migração e carregamento de frames finais |
| `test_tool_level.gd` | **15 checks aprovados**: ambos os vãos não atravessáveis com pulo/Dash/planar, três golpes reais de machado por árvore, travessia física de ambas as pontes, bloqueio e abertura real de ambas as rochas/corredores |
| `test_mobility.gd` | 40 aprovados |
| `test_touch.gd` | 25 aprovados, incluindo troca por círculo e rejeição de toque no canto externo |
| `test_wide_level.gd` | 32 aprovados; apoio de itens, orçamento, escada/caixas e retorno do subsolo |
| `test_build.gd` | 9 aprovados |
| `test_bird_hammer.gd` | 14 aprovados |
| `test_stomp.gd` | 24 aprovados |
| `test_flow.gd` | 16 aprovados |
| `test_auto_ranking.gd` | 22 aprovados |
| `test_attack.gd` | PASS, 12 quadros e um evento por martelada |
| `test_sprite_layout.gd` | 40 aprovados, enquadramento e escala da 0.4.3 preservados |
| `test_death.gd` | 10 aprovados |
| `npm run test:game` em `web/` | 10 checks Godot/API/PostgreSQL aprovados, com um resultado somente no banco temporário local |
| `test_tools_visual.gd -- --touch` | Seis capturas OpenGL geradas e revisadas: toque, mira, árvore, ponte, rocha e passagem aberta |

Nenhuma pontuação fictícia enviada ao serviço público. Algumas suítes antigas e a suíte física de fase ainda podem emitir avisos de ObjectDB/resources no encerramento; seus checks passaram. A suíte nova de ferramentas encerrou sem esses avisos. Não declarar os avisos antigos como corrigidos.

Comandos na raiz do repositório:

```text
godot --headless --path game --editor --quit
godot --headless --path game --script res://tools/test_tools.gd
godot --headless --path game --script res://tools/test_tool_level.gd
godot --headless --path game --script res://tools/test_touch.gd
godot --path game --rendering-method gl_compatibility --script res://tools/test_tools_visual.gd -- --touch
godot --headless --path game --quit-after 120
```

## Dependente de teste manual

F5 → NOVO JOGO: alternar com I, golpear com J, construir com martelo/K, usar L e duplo Espaço. Percorrer os quatro desafios sem comandos de QA, voltar pelas pontes, avaliar clareza das dicas e dificuldade na presença de inimigos. Confirmar sensação dos tempos de machado/picareta, interceptação com posicionamento humano, som/volume e transições em velocidade normal. No Android físico, combinar joystick com pulo, mira/soltura, troca e Dash; avaliar tamanho/posição dos círculos e cancelamento ao perder foco. Não foi realizado percurso humano completo nem playtest em aparelho conectado. As artes finais de novas ferramentas/poses continuam pendentes.

## Builds e retenção verificados

- Importação headless com espera de 60 frames e smoke headless de 120 frames aprovados, sem erros de parser/runtime. Configuração/exportação rápida de editor headless pode emitir avisos de RID no encerramento; a importação com espera e a execução final do jogo não apresentaram esses erros.
- Windows `game/builds/windows-0.5.0/CraftBunny-0.5.0.exe`: 139.313.072 bytes, versão 0.5.0.0, SHA256 `d45944d20c6984ea6c2afc8e26dc1a8e63015b52cc745ee994c888935bea454a`. Smoke OpenGL de 120 frames fora do editor aprovado, saída 0 e log sem erros. ZIP com créditos/licenças `game/builds/CraftBunny-Windows-0.5.0.zip`, 68.445.599 bytes.
- Android `game/builds/CraftBunny-Android-0.5.0.apk`: 83.212.930 bytes, SHA256 `3f46e9cb99ef8784768d27dae006a4d31b4cfeb03d7f0515d1025539434ad37e`, código 12 / 0.5.0-android-test, ARM32/64, INTERNET, assinatura v2/v3 e mesmo certificado da 0.4.3 confirmados. Atualização por cima preserva os dados; execução física não realizada.
- Limpeza local executada com validação de caminhos: mantidas **0.5.0 e 0.4.3**, removidas seis entradas da 0.4.2, liberando 429.928.893 bytes. Fontes/histórico/referências preservados. Log: `game/builds/prune-0.5.0.log`.
- APK novo disponível localmente; nenhum upload ao armazenamento privado nem alteração da seleção de download do site nesta etapa.
