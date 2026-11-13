# Ferramentas e animações técnicas — 0.5.0

## Implementado e provisório

O martelo preserva as artes de produção existentes, incluindo ataque e Dash de 12 quadros. Machado, picareta, estilingue e switch usam desenho modular provisório em `scripts/tool_visual.gd`: coelho sem roupa, lenço vermelho, bolsa e ferramenta selecionada. O controlador possui 12 passos por estado, com preparação/ação/recuperação coordenadas aos tempos de gameplay. Isso **não equivale a 12 artes finais distintas** para cada animação. Ícones são desenhos nativos em `scripts/tool_icons.gd`, compartilhados por HUD, toque e ferramentas. Árvores/rochas também têm representação técnica provisória; referências originais foram preservadas.

## Integrar SpriteFrames finais

`tool_frames_template.tres` é um recurso editável da Godot com 32 slots vazios. Os nomes são produto das ferramentas `hammer`, `axe`, `pickaxe`, `slingshot` com os estados:

| Estado | Quadros previstos | Comportamento |
|---|---|---|
| idle | 12 | ciclo |
| run | 12 | ciclo de movimento |
| jump | 12 | subida, sem modificar física |
| fall | 12 | queda |
| attack | 12 | progresso da ação selecionada |
| dash | 12 | arrancada + saída visual |
| switch | 12 | troca de 0,24 s |
| glide | 12 | lenço aberto |

Exemplos: `axe/attack`, `pickaxe/jump`, `slingshot/run`, `hammer/dash`. Duplique o template antes de preencher. A propriedade exportada `final_tool_frames` do jogador recebe o recurso; apenas estados existentes com pelo menos um quadro substituem o placeholder. Estados vazios permanecem jogáveis com o fallback. O carregamento de uma animação fornecida foi testado automaticamente.

Recomendação para arte técnica sem escala extra: células **96×80**, corpo com altura visível ~53 px e pés no pivô **(48,61)**, direção-base para a direita, filtro Nearest e alpha real. Mantenha margem para ferramentas nos dois lados; caso seja necessário canvas maior, preservar centro/pivô e configurar o recurso coerentemente. A colisão continua 26×42 e não acompanha o tamanho do desenho. O controlador usa até os primeiros 12 quadros de cada estado, com tempo dirigido pela ação; não associar dano a quadros visuais.

Nenhuma imagem de referência foi recortada nem apagada nesta etapa. Este pacote prepara o suporte às spritesheets definitivas; criação artística final e revisão de alinhamento em velocidade normal permanecem pendentes.
