# Pisão, caixa e poço

Alterações autorizadas pelo usuário em 2026-11-06: madeira sem limite e novo ataque por pisão. Atualizados AGENTS.md, README.md, ROADMAP.md e TEST_PLAN.

Arte criada com a ferramenta integrada:

- bunny_stomp_8.png: folha transparente 4x2. Prompt: mesmo coelho creme sem roupas, lenço gasto, bolsa e martelo; oito poses sequenciais de queda, compressão de impacto, impulso, ápice, retorno e pouso; identidade de bunny.png, sem texto ou inimigos incorporados.
- crate_states.png: dois quadros transparentes, caixa frontal intacta e rachada, madeira dourada, travessas em X, rebites e contorno pixel art, sem perspectiva ou fundo.
- forest_pit.png: poço opaco com centro escuro, paredes laterais de terra/pedra e raízes; sem ponte, chão inferior ou personagem.

Integração:

- Pisão exige velocidade descendente, colisão com normal superior e pés previamente acima do alvo. Causa 1 HP por chegada, mesmo se o alvo estiver na recuperação visual de outro golpe, e inicia impact-thud.mp3.
- Impulso após pisão: -240 px/s; proteção de contato de 0,16 s evita novo evento pelo mesmo encontro. Ao pousar em chão/caixa, um único quique de -110 px/s. Não quica no chão indefinidamente. Folha de oito frames exibida ao longo de 0,80 s. Um novo pisão válido inicia nova sequência.
- Inimigos não aplicam ataque por baixo ao jogador que está pousando sobre eles. Contato lateral e danos 1/2/3 continuam existentes.
- Madeira não bloqueia a coleta após seis; HUD mostra quantidade, sem capacidade máxima. Caixa continua custando três tábuas e tendo 2 HP.
- Caixa usa estados intacto/rachado dentro da forma física de 42x42.
- Poços preenchem somente as lacunas entre trechos de chão, sem adicionar colisão. Árvores são apoiadas numa margem distante contínua em y415; o chão jogável continua em y435.

Validação Godot 4.7.2:

- tools/test_stomp.gd: 24 checks passaram. Colisão real por cima de cobra/guaxinim/ave causou exatamente 1 dano, preservou HP do coelho, tocou impacto, mostrou oito frames e fez um quique no chão. Casos lateral/por baixo não causaram pisão. Coleta até 26 tábuas, custo de três e destruição em dois golpes verificados.
- tools/test_attack.gd: oito frames, um acerto, passou.
- tools/test_death.gd: dez verificações passaram; morte por dano e sequência grito→morte por queda preservadas.
- Captura OpenGL tools/capture_ground.gd -- --gap, revisada visualmente em docs/qa_gap_crate.png.
- Smoke test de 120 frames executado sem erros de runtime.

Limitações: importação encontrou falha de decodificação no arquivo novo não utilizado music/hammer-atack1.mp3; preservado para o usuário substituir se desejado. Os assets usados pelo jogo importaram. Alguns harnesses continuam reportando duas instâncias e um recurso em uso no encerramento. Playtest em inimigos móveis e escuta do impacto ainda necessários para avaliar sensação e balanceamento.

Comando:

```powershell
& .\Godot_v4.7.2-stable_win64_console.exe --headless --path (Get-Location).Path --script res://tools/test_stomp.gd
```
