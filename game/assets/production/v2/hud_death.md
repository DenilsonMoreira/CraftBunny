# HUD e morte exclusivos

Arquivos criados com a ferramenta integrada de geração de imagens em 2026-11-06:

- hud_wood.png: placa de madeira escura com borda de carvalho, rebites, folhas verdes e detalhe laranja. Prompt: pixel art frontal, fundo transparente, área interior vazia, sem textos ou ícones. Reutilizada em quatro módulos do HUD.
- bunny_death_8.png: folha 4x2 com oito poses exclusivas do coelho, olhos X em todos os frames; atordoado, joelhos cedendo, inclinação, queda, impacto e pose final deitado. Prompt preserva identidade de bunny.png, lenço gasto, bolsa e martelo, fundo transparente, escala constante, sem cenário.

scripts/pixel_hud.gd desenha corações em pixels, títulos e contadores sobre os módulos: vida, cenouras, madeira/capacidade e custo da caixa. Os ícones de item usam as texturas de produção. Corações vazios indicam HP faltante. O texto é widget/desenho Godot, sem texto incorporado na imagem.

scripts/player.gd apresenta os oito quadros de morte em 0,80 s, mantém a última pose e aplica gravidade até pousar se necessário. A animação de ataque é ocultada durante a morte.

Queda no buraco: sinal em y>525 ao cair, interrompe o tema e inicia funny-scream.mp3; morte por queda em y>735 espera o término do grito antes de tocar game-over.mp3. Morte por dano toca game-over diretamente. A tentativa é bloqueada imediatamente e o resultado aguarda a animação. Reinício cria uma cena nova.

Validação Godot 4.7.2:

- importação e smoke test de 120 frames sem erros;
- tools/test_death.gd: 10 verificações passaram, incluindo oito frames, pose mantida, apoio no chão, HUD vazio, grito apenas na queda e ausência de sobreposição grito/morte;
- captura OpenGL em docs/qa_ground_v2.png revisada visualmente: quatro módulos cabem em 960x540;
- testes de regressão de ataque e fluxo executados.

Comando:

```powershell
& .\Godot_v4.7.2-stable_win64_console.exe --headless --path (Get-Location).Path --script res://tools/test_death.gd
```

O harness ainda reporta duas instâncias e um recurso em uso no encerramento. Conferência auditiva e playtest de mortes durante saltos ainda pendentes.
