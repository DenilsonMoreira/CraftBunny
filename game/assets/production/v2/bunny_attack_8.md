# Ataque exclusivo do coelho

Histórico: substituído no runtime por bunny_attack_12.png. Integração e testes atuais em bunny_attack_12.md.

Arquivo: bunny_attack_8.png. Gerado com a ferramenta integrada de imagens, usando bunny.png como referência de identidade. Prompt: folha transparente 4x2 com oito poses sequenciais do mesmo coelho sem roupas, lenço gasto, bolsa e martelo, voltado à direita; preparação, arma recuada, levantamento, início do balanço, impacto com arco curto, continuação, recuperação e retorno. Sem texto, cenário ou moldura.

Integrado em scripts/player.gd usando grade parametrizada de scripts/sprite_atlas.gd. Apoio no mesmo eixo dos pés (y=21 local), proporção preservada. Oito quadros ao longo de 0,40 s, equivalentes a 20 FPS, sem repetição. O relógio visual controla o frame e fixa a direção da arte no início do golpe. A pausa congela esse relógio. Morte interrompe a apresentação.

Gameplay preservado: hitbox de 0,12 s, cooldown 0,42 s, um sinal de acerto por golpe. O efeito gráfico do impacto é ilustrativo; a aplicação de dano conserva o instante anterior no início do golpe.

Teste reproduzível:

```powershell
& .\Godot_v4.7.2-stable_win64_console.exe --headless --path (Get-Location).Path --script res://tools/test_attack.gd
```

Godot 4.7.2: ATTACK_FRAMES=8 SEEN=8 HITS=1, ATTACK_TEST=PASS. Importação e smoke test executados. Harness ainda apresenta aviso de duas instâncias e um recurso em uso ao encerrar. Validação visual da folha feita; fluidez percebida e escala em movimento ainda exigem playtest.
