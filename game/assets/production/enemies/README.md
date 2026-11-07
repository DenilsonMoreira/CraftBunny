# Inimigos

Atualização v2: os três inimigos usam agora PNGs novos em assets/production/v2. O shader de remoção de fundo antigo foi removido; o texto abaixo descreve a implementação anterior, substituída. Consulte v2/README.md para escala e estados atuais.

Fonte: `assets/references/enemies/enemies_animation_reference.png`.

Separar cobra, guaxinim e ave antes de criar `SpriteFrames`. As hitboxes continuam pertencendo à física existente.

Estado atual: `scripts/enemy.gd` cria AtlasTexture para cada estado usando regiões delimitadas da folha oficial, com filtro Nearest. O shader `reference_background.gdshader` remove o fundo roxo em runtime. A folha original permanece intacta.

Idle, movimento, ataque, dano e morte têm recortes próprios. Os inimigos derrotados deixam de colidir imediatamente, entregam o drop uma vez e exibem a morte por 0,4 s antes de serem removidos.

Integração preliminar: conferir recortes e resíduos do fundo no jogo. O shader não equivale a PNGs de produção com transparência revisada. O aviso da investida continua desenhado sobre o sprite.

Validação desta etapa: Godot 4.7.2, importação headless e smoke test de 120 frames executados com permissão para criar caches; smoke test com saída completa sem erros. Isso confirma carregamento e inicialização, não todos os estados de combate.
