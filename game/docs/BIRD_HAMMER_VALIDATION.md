# Ave acima do coelho e alcance da martelada

Atualização posterior: alcance atual 32x26 e animação exclusiva de 12 quadros, autorizados pelo usuário com o martelo maior. O texto de 16x26 abaixo é histórico. Teste atualizado passou em 14 checks. Ver assets/production/v2/bunny_attack_12.md.

2026-11-06 / Godot 4.7.2.

Causa reproduzida por código: a ave perseguia uma altura cerca de 68 px acima do jogador, mas a entrada no ataque exigia distância diagonal <=77 px. A diferença de altura de spawn podia mantê-la fora desse raio, alternando direção em torno do mesmo X.

Correções em scripts/enemy.gd:

- aviso de mergulho usa alinhamento horizontal e distância de até 110 px, com aproximação antes do ataque;
- direção do mergulho é capturada ao terminar o aviso, apontando para o jogador;
- colisão durante o mergulho inicia recuperação imediatamente;
- recuperação sobe até a altura de voo e se afasta horizontalmente; limite de 1,2 s permite sair do estado se houver obstrução;
- zona de troca de direção evita tremor de um frame ao cruzar o X do jogador.

HP, dano 3, recompensa 5, aviso de 0,55 s e cooldown de 2,5 s preservados.

Martelo: área anterior 55x47 px substituída por 16x26 px logo à frente do corpo, espelhada à esquerda. Agora scripts/main.gd usa o retângulo físico dos inimigos: 36x26 terrestres e 40x24 ave, em vez de uma área genérica inflada de 46x46. Caixas continuam usando seu retângulo real de 42x42.

O coelho precisa chegar a cerca de 16 px da borda física do alvo. Dano 1, cooldown 0,42 s e janela de 0,12 s preservados. A animação de oito quadros mantém duração visual de 0,40 s.

Teste:

```powershell
& .\Godot_v4.7.2-stable_win64_console.exe --headless --path (Get-Location).Path --script res://tools/test_bird_hammer.gd
```

12 checks passaram: distâncias próxima/longe, esquerda/direita, alvo atrás e acima, caixas perto/longe, aviso e mergulho diretamente acima do jogador, recuperação de altitude, deslocamento visível e ataque a partir do spawn y245. O alvo do teste usa invulnerabilidade para permitir observação repetida.

Importação e smoke test executados; tools/test_attack.gd confirmou oito frames e um acerto. O teste de ataque ainda mostra o aviso de recursos em uso ao encerrar; o teste dedicado ave/martelo concluiu sem avisos.

Limites: vídeo fornecido não foi decodificado nesta rodada. A reprodução foi automatizada em condições equivalentes de alinhamento vertical; playtest junto de paredes, copas e plataformas ainda necessário.
