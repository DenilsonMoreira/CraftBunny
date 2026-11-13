# Assets — Preparação e integração

## Direção de arte aprovada
- Pixel art 2D em paleta quente: madeira, folhagem verde, laranja de cenoura, tons terrosos; GUI em placas de madeira.
- **Coelhinho sem roupas**, com **lenço vermelho gasto**, **bolsa lateral** e **martelinho**. Evitar versões antigas com jardineira/roupas.
- Expressões claras, boa silhueta, animações legíveis na resolução de jogo.
- Três inimigos: cobra verde, guaxinim marrom/cinza, ave de rapina marrom.
- Cenoura, tábua e coração flutuam pouco acima do chão e são pegos por contato.

## Referências visuais produzidas na conversa
- Tela de título “Craft Bunny” com `Novo Jogo` e `Recordes`.
- Folha de movimentos do coelho: idle, andar, correr, pulo, pouso, dano, morte, construção, ataque.
- Folha de estados dos inimigos: idle, movimento, ataque, dano, morte.
- Kit visual de HUD, ranking, opções e botões.
- Folha de cenouras, tábuas e corações; tilesets de terreno, árvores e folhagens.

**Importante:** as imagens estão incluídas em `assets/references/` neste pacote. São **folhas ilustrativas de referência**, não spritesheets técnicos prontos. Para produzir assets funcionais, recortar e limpar individualmente os quadros, remover fundos/molduras/legendas, padronizar tamanho e pivô e verificar transparência, alinhamento e consistência. Não recortar por divisão em grade cega. Referências externas enviadas pelo usuário devem ter direitos de uso verificados antes da publicação. A folha atual do coelho é `assets/references/characters/bunny_animations_current.png`; a anterior é histórica e não deve substituir a aparência aprovada.

## Padrão sugerido de produção
- Sprites isolados em PNG RGBA (fundo transparente), com pivôs e margens consistentes.
- `AnimatedSprite2D` + `SpriteFrames` separados por personagem/ação; nomes `idle`, `walk`, `run`, `jump`, `fall`, `land`, `hurt`, `death`, `craft`, `attack`.
- `TileSet` e `TileMapLayer` no Godot 4.3+ para chão e paredes; decoração em camadas sem colisão.
- Manter a hitbox atrelada à física, não à imagem, salvo ataque intencional.
- Assets em `assets/characters/`, `assets/enemies/`, `assets/tiles/`, `assets/ui/`, `assets/audio/music/`, `assets/audio/sfx/`.
- Testar filtro `Nearest` na resolução final, evitando blur e bleeding.

## Efeitos sonoros
- Fonte planejada: https://pixabay.com/pt/sound-effects/ .
- Eventos prioritários: pulo, aterrissagem, martelo, golpe recebido, ataque inimigo, morte, coletar cenoura, coletar madeira, curar, construir caixa, caixa quebrar, finalizar fase, navegar em menus.
- Conectar faixas ao bus `Music` e efeitos ao bus `SFX`; suportar controle master e preferências persistentes.
- Registrar origem, licença e nome de cada download em `assets/CREDITS.md` antes de publicar.

## Pacote v4 / 0.5.1

Artes de ferramentas e obstáculos substituem o desenho provisório do lançamento 0.5.0. Onze folhas de 12 quadros, quatro equipamentos e kits ambientais. Atlas, pivôs, composição e prompts em ../assets/production/v4/README.md; validação em ../../docs/ART_051.md. Referências e assets anteriores preservados.

## Abertura aprovada 0.5.3

production/intro/storyboard.png reutiliza a prévia v2 aprovada, com olhos fechados no terceiro painel. AtlasTextures separam seis cenas sem editar o original. Catálogo/prompts em ../assets/production/intro/README.md. Forest-birds fornecido pelo usuário e creditado em assets/CREDITS.md. Integração/testes em ../../docs/OPENING_053.md.

## Encaixe 0.5.4

Imagens v4 preservadas. equipment_rig.gd contém centros de mão por quadro; tool_frames.tres recebe attachments/angles por pose e é reconstruído por build_tool_art.gd. Cabos atrás das mãos e ferramentas junto à bolsa no planar. Detalhes/testes em ../../docs/EQUIPMENT_RIG_054.md.
