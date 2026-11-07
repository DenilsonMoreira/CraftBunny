# Árvores, matinhos e coletáveis

Novos arquivos gerados pela ferramenta integrada de imagens em 2026-11-06:

- forest_props.png: árvore de folhas largas, pinheiro, tufo de grama e arbusto baixo.
- collectibles.png: cenoura e tábua de madeira em duas regiões.

Prompts: pixel art limpa de contorno marrom e paleta quente compatível com Craft Bunny; fundo transparente, sem textos, sombras de chão ou cenário; árvores completas e folhagem pequena; cenoura laranja com três folhas e tábua dourada com veios e nó.

A geração de folhagem resultou numa banda alta de árvores e banda baixa de matinhos, em vez de quatro células uniformes. scripts/prop_art.gd usa regiões explícitas e limites alpha >=0,65 com cache; não divide essa folha cegamente em grade. A folha de itens usa duas metades.

Integração:

- scripts/parallax.gd substitui árvores geométricas e montanhas triangulares por árvores pixel art em duas faixas de profundidade. Limites máximos 220x310 e 185x245 px; tonalidade suavizada nas árvores distantes.
- scripts/main.gd remove os círculos grandes de cenário que ficavam atrás do parallax.
- scripts/forest_visuals.gd troca as árvores minúsculas e arbustos antigos por grama até 24x10 e arbusto até 30x14 px, apoiados em y435. Nenhuma nova colisão.
- scripts/pickup.gd usa Sprite2D: cenoura até 20x26 px, tábua até 26x16 px; proporção preservada, filtro Nearest e flutuação de 3 px. Área de coleta e inventário preservados.

Validação: importação Godot 4.7.2, captura OpenGL com tools/capture_ground.gd e revisão visual de docs/qa_ground_v2.png. Captura salva sem erros, PLAYER_FEET=435.0/FLOOR=435.0. Smoke test de 120 frames executado. Percurso inteiro e oclusão em trechos distantes ainda precisam de playtest.
