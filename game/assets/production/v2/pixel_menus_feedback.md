# Menus pixel art e feedback de inimigos

2026-11-06, Godot 4.7.2. Escopo solicitado: recriar título e painéis de controle, destacar dano e detecção dos inimigos.

## Arte e interface

- title_pixel.png: nova composição de título, com coelho sem roupas, lenço vermelho, bolsa e martelo; logo superior e espaço para quatro botões reais. Referência title_screen.png preservada.
- menu_panel.png: moldura de madeira pixel art, interior escuro e folhas nos cantos; referência hud_wood.png preservada e reutilizada nos botões.
- scripts/ui_theme.gd: fonte pixelada Silkscreen, painéis/botões texturizados, destaque de foco/hover/pressionado, campos de texto, barras de rolagem e sliders de cantos retos.
- scripts/main.gd: botões NOVO JOGO, RECORDES, OPÇÕES e CONTROLES; mesmas rotas e callbacks. Painéis de pausa, resultados, ranking, áudio e remapeamento herdam o tema. Opções visíveis no viewport 960x540; controles de teclado preservam remapeamento.
- scripts/touch_controls.gd: botões de madeira com fonte pixelada e indicação de pressionado. Áreas e tratamento multitoque preservados.

Fonte: Silkscreen Regular, copyright The Silkscreen Project Authors; SIL Open Font License 1.1 preservada em fonts/OFL.txt. Arquivos obtidos de https://github.com/google/fonts/tree/main/ofl/silkscreen. Não foi adicionada dependência online em runtime.

Artes criadas pela ferramenta integrada imagegen, salvas nesta pasta. Originais de assets/references preservados.

Prompt do título:

Use case: stylized-concept. Asset type: full-screen 16:9 pixel art main menu background for Craft Bunny game. Use provided old title ONLY as style and world reference, create a NEW professional composition. Crisp hand-crafted retro pixel art, discrete pixel clusters, nearest-neighbor look, warm forest greens and honey wood. Large cream rabbit without clothes, worn red scarf, brown side satchel and oversized wooden mallet on the LOWER LEFT quarter, expressive heroic friendly pose. Forest meadow, grass blocks, wooden crate, carrots, distant mountains and waterfall, soft clouds. Upper center has a beautifully readable wooden game logo with ONLY exact words 'Craft Bunny', rabbit ears on top, orange Bunny letters, cream Craft letters. Logo confined to top 35% of frame, not enormous. Crucial UI composition: CENTER RIGHT area from x=48% to 85%, y=43% to 90% must be quiet dark green forest clearing, visually uncluttered, left completely EMPTY for four separate actual game buttons to be overlaid later. NO painted buttons, NO menu labels, no options or Recordes or Novo Jogo text baked into art. Rabbit occupies leftmost 35% and does not cover empty UI area. Full bleed landscape composition, no borders, no watermark, no UI mockup cards. Match visual identity of reference while making all surfaces pixel art.

Prompt do painel:

Use case: ui-mockup. Asset type: single reusable blank pixel-art GUI panel frame for Craft Bunny Godot game. One large rectangular 4:3 dark walnut wooden control menu panel, honey golden carved wooden border, small square iron nails at the four corners, tiny bright green ivy leaves at outer corners. Genuine crisp retro pixel-art clusters, same warm palette as reference wooden HUD. Main central area from 8% to 92% is VERY DARK and plain walnut, subtle restrained horizontal wood grain, empty for readable menu controls. Narrow consistent border, no title plaque, no internal sections, no text, no letters, no icons, no buttons. Straight square stepped pixel corners, not round vector curves. Panel fills 94% canvas with small transparent margins. Truly transparent RGBA outside panel. Single panel only, not a sheet. Intended to stretch as background of a 500x400 options dialog, prioritize readable dark interior.

## Detecção e dano

scripts/enemy.gd + scripts/enemy_hit.gdshader:

- Balão pixelado com ! dura 0,90 s ao passar de não detectado para detectado. Não reinicia a cada frame; reaparece após sair do alcance e voltar. Usa o alcance existente de cada inimigo.
- Clarão quente de 0,24 s, faíscas em pixels e pose hurt priorizada imediatamente após acerto.
- Barra de vida e quantidade de dano recebida por 1,25 s; efeito visual sem novas regras de dano.
- Material exclusivo por inimigo: atingir um não altera o material dos demais. Timers visuais congelam com inimigos inativos/pausa e retornam ao normal ao expirar.

Mantidos HP, dano, drops, recuperação de 0,28 s, knockback, hitboxes e comportamento da IA.

## Testes executados

- Importação --headless --editor --quit e smoke --headless --quit-after 120: saída 0, sem falhas de parser/runtime.
- tools/test_pixel_feedback.gd: 34 checks passaram. Fonte/tema, acesso aos controles, detecção, reaquisição, ausência de reinício por frame, dano único, pose, shader, fim dos efeitos e pausa nos três inimigos.
- tools/test_title_hearts.gd: dez checks passaram, incluindo novo jogo, opções, ranking e HUD.
- tools/test_touch.gd: dez checks passaram, incluindo multitoque, pausa, salto/movimento, segundo plano e Voltar.
- tools/test_stomp.gd: 24 checks passaram, incluindo dano e quique nos três inimigos, construção e madeira.
- tools/test_flow.gd: 16 checks passaram, incluindo pausa/retomada, ranking, persistência de teclas e nova tentativa, com arquivos de teste isolados.
- Capturas OpenGL revisadas: docs/qa_title.png, docs/qa_pixel_controls.png, docs/qa_pixel_settings.png, docs/qa_pixel_feedback.png. O efeito de dano está visível na captura do guaxinim.
- APK 0.3.3-android-test (código 3) exportado, manifesto ARM32/64 e assinatura v2/v3 verificados. Identificação e SHA256 em docs/ANDROID_BUILD.md.

Reprodução: Godot --headless --path . --script res://tools/test_pixel_feedback.gd; trocar o script pelos demais acima. Capturas: --path . --script res://tools/capture_ground.gd -- --title, --controls, --touch --settings ou --feedback.

Harnesses antigos de título/toque/pisão ainda reportam recursos em uso ao encerrar; novo teste de feedback, smoke e capturas encerraram sem esses avisos. Nenhum playtest físico Android ou percurso completo foi realizado nesta etapa. QA geral e exportação Windows continuam pendentes no roadmap.
