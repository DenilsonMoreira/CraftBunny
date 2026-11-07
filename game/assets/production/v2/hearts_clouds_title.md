# Corações, nuvens e título

Implementado em 2026-11-06.

Arte nova gerada pela ferramenta integrada:

- hearts.png: duas regiões, coração rubi cheio com brilho creme e slot vazio escuro com aro bronze; prompt pede pixel art simétrica e nítida a 24x24, fundo transparente e sem texto/sombra/glow.
- clouds.png: duas nuvens brancas com sombras azul/lilás, perfis de pixels em degraus e tamanhos distintos; prompt pede duas formas isoladas sobre transparência, sem cenário, contorno escuro ou texto.

title_screen.png é uma cópia intacta da arte oficial assets/references/ui/craft_bunny_title_screen.png. O original foi preservado.

Integração:

- prop_art.gd fornece regiões ajustadas por alpha, em cache;
- pickup.gd apresenta coração com até 24x24, filtro Nearest e flutuação existente;
- pixel_hud.gd substitui os antigos corações desenhados por ícones cheio/vazio com até 28x26;
- sky_clouds.gd cria nuvens atrás da floresta, em Parallax2D próprio (scroll 0,15/0,6);
- main.gd apresenta a arte oficial na tela de título em toda a área 960x540. Botões reais transparentes cobrem Novo Jogo e Recordes; foco de teclado e realce são visíveis. Opções continua como botão funcional abaixo. A arte sai ao iniciar ou abrir outro menu.

Validação Godot 4.7.2: dez verificações passaram em tools/test_title_hearts.gd (carregamento, hotspots, Recordes/Opções/Novo Jogo, camada de nuvens, texturas de coração e recuperação de HP). Importação e smoke test de 120 frames sem erros. Capturas OpenGL revisadas: docs/qa_title.png e docs/qa_hearts_clouds.png.

```powershell
& .\Godot_v4.7.2-stable_win64_console.exe --headless --path (Get-Location).Path --script res://tools/test_title_hearts.gd
```

Regras de cura preservadas: +1 HP, máximo três; coração não consumido quando a vida está cheia. Playtest em outras proporções de janela e durante percurso completo ainda pendente.
