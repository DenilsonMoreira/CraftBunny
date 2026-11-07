# Construção e empilhamento — 2026-11-06

O relato mostra 22 cenouras e uma tábua. O custo permanece três tábuas por caixa. HUD agora usa o título TÁBUAS e o erro de recursos informa o inventário atual, explicitando que cenouras não são materiais.

Corrigida a causa do bloqueio de empilhamento: scripts/main.gd usava FLOOR_Y fixo. A nova busca considera terreno, rochas, plataformas e caixas. Mira 40 px à frente; em caixas, alinha ao centro da base. Cada caixa mede 42x42 e encosta no topo do apoio. Apoios até 56 px acima/abaixo dos pés são alcançáveis.

Posições sem apoio integral ou com sobreposição no coelho/objeto são recusadas sem gasto. A verificação geométrica complementa a consulta de física para proteger contra solicitações repetidas no mesmo frame.

Como empilhar: aproxime-se lateralmente da caixa, olhe para ela e pressione a tecla de construção (K padrão). Para continuar uma pilha mais alta, suba ou salte até alcançar o apoio; o corpo do coelho precisa ficar fora do espaço da nova caixa. Construir sobre plataformas também é permitido.

Validação Godot 4.7.2: tools/test_build.gd passou nove checks, incluindo diferença cenouras/tábuas, construção com 22 tábuas, duas caixas no mesmo tick sem sobreposição, alinhamento de 42 px, limite de alcance, terceira caixa de posição elevada, buraco sem apoio, proteção do jogador e plataforma elevada. Importação e smoke test executados.

```powershell
& .\Godot_v4.7.2-stable_win64_console.exe --headless --path (Get-Location).Path --script res://tools/test_build.gd
```

Limites: playtest com remapeamento, movimento e pilhas extensas pendente. As caixas continuam StaticBody2D; comportamento de derrubar pilhas ao destruir a base não faz parte desta correção.
