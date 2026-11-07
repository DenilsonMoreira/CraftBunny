# Tiles e props

## Terreno v2 — correção de continuidade

Novo arquivo ativo: forest_ground_v2.png, gerado com a ferramenta integrada de imagens. Prompt: textura quadrada opaca de terreno lateral em pixel art, grama verde no topo, terra marrom abaixo, preenchimento até as bordas, repetição horizontal, sem margem, moldura, cenário ou sombra externa.

O TileSet usa o arquivo completo. Células alternam espelhamento horizontal, garantindo que as amostras coincidam nas emendas; todos os trechos terminam na borda de sua colisão. Rochas e plataformas usam a nova textura opaca. A terra continua abaixo da superfície com escala própria por bloco.

Correção de apoio: sprites usam limites com alpha >= 0,65 e alinham os pés ao fundo de seus colliders. O coelho e inimigos terrestres iniciam na altura do solo. A ave continua aérea. O vídeo fornecido não foi decodificado nesta rodada; a confirmação visual foi feita por captura direta do Godot.

Verificação: importação e smoke test de 120 frames; captura renderizada em OpenGL com tools/capture_ground.gd. Resultado: GROUND_CAPTURE=0 e PLAYER_FEET=435.0 / FLOOR=435.0. Imagem em docs/qa_ground_v2.png, revisada visualmente. Ainda testar movimento, bordas e pousos por toda a fase.

O restante deste documento descreve a implementação anterior e suas fontes.

Fontes: `assets/references/tiles/forest_ground_tiles_generated.png` e `forest_foliage_props_generated.png`.

Chão e paredes devem formar tiles sólidos; árvores e folhagens ficam em camadas decorativas sem colisão.

As folhas de terreno e folhagem são RGBA e foram catalogadas como fontes de produção. O primeiro TileSet deve usar apenas os blocos de chão, mantendo as colisões físicas atuais até a validação visual.

## Integração inicial

`scripts/forest_visuals.gd` cria um TileSetAtlasSource com um bloco de 112x112 da região (142,16), identificado na folha oficial de terreno. Cada trecho recebe TileMapLayer visual dimensionado para terminar exatamente na borda do terreno. As colisões continuam nos corpos estáticos existentes; a camada visual desativa colisões.

Rochas e plataformas recebem recortes próprios. Pequenas árvores e arbustos da mesma folha são decoração sem colisão. Os originais e a cópia fonte permanecem intactos.

Validação: importação Godot 4.7.2 e smoke test de 120 frames concluídos sem erros, com saída completa. Ainda conferir visualmente em F5 as bordas da grama, emendas e escala dos props. O preenchimento marrom sob o terreno continua como base provisória. A folha dedicada de folhagens ainda não foi integrada.
