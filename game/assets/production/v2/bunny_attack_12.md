# Ataque ampliado, 12 quadros e escala do mundo

2026-11-06. PNG: bunny_attack_12.png, RGBA 1448x1086, grade 4x3, células 362x362. Gerado pela ferramenta integrada imagegen, usando bunny_attack_8.png como referência de identidade. Originais e folha anterior preservados; runtime usa a nova folha.

Mesmo coelho creme sem roupas, lenço vermelho gasto e bolsa lateral. Cabeça e cabo do martelo solicitados em dobro de tamanho em relação ao corpo. A geração é ilustrativa: a proporção exata varia com perspectiva/rotação. Doze poses: antecipação, levantamento, balanço, impacto, continuação e recuperação.

Prompt utilizado:

Use case: identity-preserve. Asset type: production transparent pixel-art sprite sheet for Godot 2D Craft Bunny. Reference image is the OLD 8-frame attack, use ONLY as character identity/style reference. Create a NEW animation with EXACTLY TWELVE frames arranged in a perfectly regular 4-column by 3-row grid, chronological left to right then next row. Canvas aspect 4:3; square equal cells. Same cream rabbit with dark brown pixel outlines, no clothing, worn red scarf, brown shoulder satchel, pink inner ears, facing RIGHT in every cell. Crucial change: wooden hammer HEAD and HANDLE must both be exactly TWICE the linear size relative to rabbit compared with the reference hammer. Keep rabbit body dimensions constant across all twelve cells, do NOT shrink the body to make room for hammer. Leave ample transparent margins so the enormous wooden mallet and arc fit fully inside each cell, no contact between cells. Same feet baseline and body center in every cell. Twelve distinct fluid poses: 1 ready, 2 anticipation bend, 3 pull mallet back, 4 lift, 5 overhead, 6 acceleration, 7 forward swing, 8 strong forward impact at chest height, 9 follow through downward, 10 recoil, 11 lower mallet, 12 return ready. Strongly readable wooden mallet in every frame. Short warm golden pixel sweep on frames6-8 only. Crisp discrete pixel clusters, consistent proportions, limited warm palette, no blur. True RGBA transparency throughout between sprites, no background, no checkerboard painted in, no labels, no grid lines, no lettering, no floor shadows. This is a technical sprite sheet: exactly 4 columns x 3 rows, twelve distinct rabbit poses.

## Integração

scripts/player.gd: ATTACK_FRAME_COUNT=12; animação 0,40 s (30 quadros/s), relógio visual congelado pela pausa, direção fixada no começo. Mantidos dano 1, cooldown 0,42 s, janela 0,12 s e um evento de acerto por golpe. Dano permanece no início do golpe, como antes.

HAMMER_REACH passou de 16 para 32 unidades, altura 26. Retângulo começa na borda do corpo, x=13 à direita ou x=-45 à esquerda. Limite frontal 45 a partir do centro; hurtboxes reais de inimigos e caixas preservadas. Arco dourado decorativo.

scripts/sprite_atlas.gd aceita pivôs opcionais de pés por quadro. Doze pivôs medidos nesta folha mantêm apoio e centro do corpo durante o movimento da arma. Outras animações continuam com os pivôs anteriores. Escala uniforme compartilhada entre poses, sem esticar imagens individualmente.

Câmera WORLD_ZOOM=1,25: personagens, coletáveis, caixas, terreno e decoração aparecem 25% maiores. Geometria, movimento, pulo e colisões continuam nas mesmas coordenadas. HUD e botões mantêm tamanho/posição. Área visível menor: 768x432 unidades no viewport 960x540.

## Validação executada

- Importação Godot 4.7.2 e smoke --quit-after 120: saída 0, sem erros de parser/runtime.
- tools/test_attack.gd: ATTACK_FRAMES=12 SEEN=12 HITS=1; zoom 1,25 e retângulos espelhados 32x26 aprovados.
- tools/test_bird_hammer.gd: 14 checks aprovados, incluindo novo alcance a 60 unidades, erro além do limite, proximidade, direção, altura, caixas e regressão da ave.
- tools/test_touch.gd: dez checks aprovados.
- Captura OpenGL docs/qa_attack_12.png revisada: impacto, apoio no chão (pés y435) e interface multitoque.
- APK 0.3.2-android-test exportado e assinatura v2/v3 verificada; detalhes em docs/ANDROID_BUILD.md.

Harnesses de ataque/toque ainda reportam recursos em uso ao encerrar, avisos já existentes; smoke normal e captura encerraram sem esses avisos. Fluidez percebida, percurso inteiro com campo de visão menor e execução física no Android precisam de playtest. Marcos gerais de QA continuam abertos.

Reprodução: Godot --headless --path . --script res://tools/test_attack.gd; repetir para test_bird_hammer.gd e test_touch.gd. Captura: --path . --script res://tools/capture_ground.gd -- --touch --attack.
