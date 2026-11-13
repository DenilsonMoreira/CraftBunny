# Dash e lenço — 2026-11-13

Produção com a ferramenta integrada **imagegen**, duas chamadas separadas, transparência real RGBA. Referência de identidade: `../v2/bunny.png`, preservada. Originais gerados permanecem também no diretório de imagens do Codex. Não houve recorte/limpeza destrutiva das referências.

## Arquivos e integração

- `bunny_dash_12.png`: 1448×1086, grade 4×3, células 362×362. Doze poses de antecipação, arrancada com lenço esticado e frenagem. Sequência completa em 0,24 s: velocidade de Dash somente nos primeiros 0,16 s, mais 0,08 s de recuperação visual.
- `bunny_glide_12.png`: mesmas dimensões/grade, doze poses; 0–2 abertura (0,04 s/quadro), 3–8 ciclo de tecido (0,06 s/quadro), 9–11 recolhimento (0,04 s/quadro). A sequência só começa na descida. O lenço fica estendido entre as patas; sem roupas novas ou alteração da colisão.
- `scripts/sprite_atlas.gd` calibra escala por limites alpha e posiciona os pés em Y=21. `player.gd` usa um sprite independente para as habilidades, com prioridade de morte/dano/ataque/pisão preservada.
- Imagens residuais e poeira são efeitos em tempo de execução (`movement_fx.gd`), sem duplicar dano ou colisões.
- `tools/test_mobility_visual.gd` observou os 12 índices de cada animação durante simulação OpenGL em câmera lenta (0,25×). Duas capturas em `docs/qa_mobility_*.png` revisadas. Fluidez percebida em velocidade normal e pivôs em movimento precisam de playtest humano.

## Prompts usados

### Dash

Use case: stylized-concept. Create a NEW production pixel-art spritesheet for Craft Bunny DASH, using attached image ONLY as character identity/style reference. Exactly 12 distinct chronological frames in a precise 4 columns x 3 rows uniform grid, reading left to right top to bottom. Transparent background, no text labels borders or shadows on ground. One whole cream rabbit in each cell, facing RIGHT, same consistent scale and feet baseline and center pivot per cell, generous transparent margins, never cross cells. No clothes, worn red scarf, brown side satchel and small wooden hammer held safely. Animation: frames1-2 leaning forward into horizontal burst; frames3-9 streamlined fast dash with ears swept back, red scarf stretched LEFT in wind, legs trailing with subtle distinct running movement; frames10-12 braking back to standing pose. Keep same cream fur pink ear interiors dark brown pixel outlines and warm pixel shading as reference. Hard crisp pixel-art edges, no blur. Full body ears hammer scarf all inside each frame. Output landscape 4:3 sheet. No baked afterimages: those are runtime effects.

### Planar

Use case: stylized-concept. NEW production pixel-art spritesheet Craft Bunny GLIDE WITH RED SCARF. Reference is character style ONLY. EXACTLY 12 fullbody distinct frames in uniform FOUR columns by THREE rows grid; read left-right top-bottom. Transparent background, no floor, no labels text borders. Same cream rabbit facing RIGHT every frame, pink ears darkbrown outlines brown side satchel wooden hammer tucked at belt, NO CLOTHES. Rabbit opens its worn RED SCARF wide like small fabric hang-glider above shoulders, two forepaws raised spread holding scarf ends, hindpaws slightly apart hanging downward. NO umbrella wings parachute separate object: it is the same red neckscarf opened and taut between paws. Frame1-3 progressively spread paws and open scarf, frame4-9 stable airborne descent gently rippling scarf with subtle different ear/paw/body motion, frame10-12 release scarf gradually folding back into original neckscarf and transition to normal falling pose. Maintain body scale and central body pivot across everycell, generous transparent spacing, all ears scarf limbs insidecell. Sharp visible pixel clusters and warm palette exactly consistent with reference. 4:3 landscape sheet.
