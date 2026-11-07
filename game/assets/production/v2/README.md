# Personagens v2

Novas folhas PNG RGBA geradas com a ferramenta integrada de geração de imagens em 2026-11-06, na ordem solicitada: bunny.png, cobra.png, guaxinim.png, ave.png. Cada arquivo tem 1254x1254 pixels e grade lógica 4x4. Os dois pixels de sobra fora da grade são descartados pelo leitor.

Integração em scripts/sprite_atlas.gd: recorte por alpha, enquadramento centralizado, pés alinhados ao mesmo chão, escala uniforme por personagem e filtro Nearest. Limites visuais: coelho 48x60 (incluindo orelhas/arma), cobra e guaxinim 46x30, ave 52x38. Esses limites não alteram hitboxes.

Prompts usados na ferramenta integrada:

- Coelho: atlas 4x4 transparente, pixel art de contorno marrom, coelho creme sem roupas, lenço vermelho gasto, bolsa lateral, martelo; linhas idle, corrida, salto/pouso e ataque, voltado à direita e sem texto.
- Cobra: atlas 4x4 transparente, cobra verde de ventre creme, linhas idle, rastejo, bote e dois quadros de dano mais dois de morte.
- Guaxinim: atlas 4x4 transparente, quadrúpede cinza/marrom com máscara e cauda anelada, linhas idle, movimento, investida e dano/morte.
- Ave: atlas 4x4 transparente, ave de rapina marrom com cabeça creme e bico dourado, linhas voo lento, voo rápido, mergulho e dano/morte.

As imagens foram exibidas e revisadas no retorno da geração. Alpha zero nos cantos confirmado. Revisão artística durante gameplay ainda pendente; a transparência gerada pode conter pixels semitransparentes nas bordas.

Limitação do coelho: dano, morte e construção ainda reutilizam poses da nova folha; não são ciclos exclusivos. A aparência v1 foi retirada do jogo e movida para .retired_sprites/bunny-v1 (recuperável e ignorada pelo importador). Referências originais preservadas.

Áudio: morte interrompe MusicPlayer antes de iniciar DeathPlayer; guarda impede repetir o efeito após o fim da tentativa.
