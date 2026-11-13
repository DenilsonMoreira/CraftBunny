# Plano de testes — Craft Bunny

Registrar cada cenário como **Passou / Falhou / Não executado** e passos de reprodução quando falhar. Rodar primeiro na Godot e depois no executável Windows.

## Inicialização e fluxo
- [ ] T01 — F5 abre o título, sem erro de parser ou stack trace.
- [ ] T02 — Novo Jogo inicia sempre no começo, com 3 HP, 0 madeira, 0 cenouras.
- [ ] T03 — Pausa/retomada não deixa IA movimentar nem corrompe estado.
- [ ] T04 — Reinício após derrota e vitória zera tentativa, mantém recordes e opções.
- [ ] T05 — Queda no buraco encerra tentativa; não existe checkpoint nem botão continuar do meio.
- [ ] T06 — Entrar na casa do coelhinho encerra a fase e apresenta resultado.

## Movimentação
- [ ] T50 — Ferramentas: executar tools/test_tools.gd (68 checks aprovados); validar em partida real ciclo I, Dash L, danos, tempo pesado, parry, mira/munição, cancelamentos e saldo de ranking.
- [ ] T51 — Obstáculos: tools/test_tool_level.gd passou em 15 checks; percorrer manualmente as duas pontes e duas passagens com inimigos ativos, sem comandos de QA.
- [ ] T52 — Android físico: joystick com círculos de ação/troca/Dash/pulo/caixa/pausa, sem letras nos botões; 25 checks automatizados e seis capturas revisadas, ergonomia física pendente.
- [ ] T53 — Substituir estados do template SpriteFrames por arte final de 12 quadros e revisar pivôs. Carregamento de recurso foi automatizado; qualidade artística final pendente.
- [ ] T49 — Conferir martelo sem recorte nas duas direções e transição do planar sem aumento do corpo. 42 checks/capturas aprovados em tools/test_sprite_layout.gd; confirmação em partida real/Android físico pendente.
- [ ] T46 — Dash L no chão/ar: uma carga por salto, cooldown, bloqueio em paredes, sem dano/invulnerabilidade, buffer do martelo e construção normal depois. Coberto por tools/test_mobility.gd; playtest humano pendente.
- [ ] T47 — Duplo toque de pulo em 0,35 s: primeiro só salta, segundo aguarda descida, segurar plana, soltar cancela, limite 1 s, Dash suspende/retoma sem recarga aérea. Automatizado; playtest humano pendente.
- [ ] T48 — Artes de 12 quadros, lenço, poeira, rastro e som de Dash: capturas OpenGL revisadas em câmera lenta; validar fluidez em velocidade normal, escuta e multitoque em aparelho físico.
- [ ] T07 — Direção, aceleração e desaceleração funcionam nos dois sentidos.
- [ ] T08 — Pulo tem altura próxima ao corpo do coelho no sprite final; pouso sem atravessar chão.
- [ ] T09 — Coyote time: pular dentro de 0,12 s após sair da borda.
- [ ] T10 — Jump buffer: pressionar pulo até 0,12 s antes de aterrissar gera pulo.
- [ ] T11 — Câmera não revela fora do mapa e parallax permanece fluido até a chegada.

## Vida e martelo
- [ ] T12 — Coelho começa 3 HP; coração restaura um até no máximo 3.
- [ ] T13 — Dano inimigo 1/2/3 é aplicado corretamente (cobra/guaxinim/ave).
- [ ] T14 — Após golpe sobrevivido, outros ataques dentro de 0,5 s não tiram HP; novo dano depois desse intervalo. Automatizado em tools/test_tools.gd; playtest humano pendente.
- [ ] T15 — Martelo tira 1 HP por golpe, sem múltiplos hits involuntários na mesma animação.
- [ ] T16 — Cobra morre em 2, guaxinim em 5 e ave em 7 marteladas válidas.
- [ ] T17 — Inimigo derrotado não causa dano posteriormente.
- [ ] T18 — Ataque da ave possui aviso perceptível antes do mergulho.

## Coleta, caixa e pontuação
- [ ] T19 — Madeira não possui limite; coletar a 7ª unidade e seguintes aumenta o inventário e atualiza o HUD.
- [ ] T35 — Pisão por cima causa exatamente 1 dano, toca impact-thud, exibe oito frames e gera um quique no chão; contato lateral não é pisão.
- [ ] T20 — Construção com menos de 3 madeiras falha sem gastar materiais.
- [ ] T21 — Construção com pelo menos 3 gasta exatamente 3; caixa é sólida e escalável.
- [ ] T22 — Caixa perde 1 HP por martelada e quebra na segunda; inimigos não quebram caixas.
- [ ] T23 — Não é possível construir dentro de obstáculos/corpo do jogador ou no vazio.
- [ ] T36 — Construir sobre outra caixa e plataforma elevada alinha o apoio, gasta três tábuas e rejeita sobreposição/fora de alcance sem gasto.
- [ ] T24 — Cobra dropa 1, guaxinim 3, ave 5 cenouras após a morte; só contam quando recolhidas.
- [ ] T25 — Cenouras espalhadas ficam acessíveis, flutuam e são coletadas por contato.

## Ranking e preferências
- [ ] T39 — Android: analógico semitransparente move nos dois sentidos, tem zona morta, não trava fora da base e libera na pausa/foco; pulo/ataque/caixa simultâneos. Automatizado em tools/test_touch.gd; ergonomia física pendente.
- [ ] T40 — Resultado sem ENVIAR AO GLOBAL; registrar no TOP 10 local mantém envio automático quando qualifica no global. Automatizado em tools/test_auto_ranking.gd; playtest pendente.
- [ ] T37 — Registrar resultado no TOP 10 local envia automaticamente se entrar no TOP 100 global; empate no corte, rede indisponível e falha ao salvar não causam envio indevido ou perda local. Automatizado em tools/test_auto_ranking.gd; playtest pendente.
- [ ] T38 — RANKING GLOBAL abre o site no navegador, sem tabela global no jogo. Confirmar em Windows e Android.
- [ ] T26 — Só entra no TOP 10 quem qualifica; aceitar exatamente 3 letras A–Z.
- [ ] T27 — Registrar após vitória e após derrota, sem duplicar registro.
- [ ] T28 — Fechar/reabrir mantém TOP 10 ordenado; nenhuma posição/HP/inventário salvo.
- [ ] T29 — Dados malformados em records.cfg não causam crash.
- [ ] T30 — Controles e volumes persistem; existe recuperação de configuração inválida.

## Balanceamento e distribuição
- [ ] T45 — Fase 0.4.1 com 24.000 px: conferir maior densidade, quatro caixas na escada e retornos do subsolo. 32 checks de mapa, capturas OpenGL e smoke do EXE aprovados; playtest humano completo e cronometragem pendentes. Relatório: ../../docs/COMPACT_LEVEL_041.md.
- [ ] T42 — Fase 0.4.0: explorar três alturas, usar quatro caixas na escada e retornar do subsolo sem caixas; confirmar 140 cenouras de mapa e 200 com todos os drops. 28 checks automatizados passaram; playtest completo pendente.
- [ ] T43 — Ave pousa durante 0,5 s após mergulhar, permanece atacável mesmo se receber dano e retorna ao voo. Seis checks automatizados passaram; playtest físico pendente.
- [ ] T44 — Cronometrar percurso exploratório da fase ampla e ajustar para cerca de 15 minutos com evidência de playtest. Não executado; não é duração mínima imposta.
- [ ] T41 — Editor: abrir scenes/editor_example/fase_exemplo.tscn, arrastar InicioJogador/Cobra, pintar/apagar Terreno, salvar e executar com F6. Verificar que F5 mantém o jogo principal. 19 checks automatizados aprovados em tools/test_editor_example.gd; edição manual pelo usuário pendente.
- [ ] T31 — Cada uma das cinco áreas tem progressão legível e densidade crescente de inimigos.
- [ ] T32 — Nenhuma plataforma/buraco excede o alcance de pulo + caixas disponíveis sem alternativa.
- [ ] T33 — Todos os coletáveis obrigatórios e a casa são alcançáveis sem comandos de debug.
- [ ] T34 — Jogo exportado para Windows abre, aceita entrada, reproduz som e salva recordes.

## Relatório de teste (copiar a cada rodada)

```text
Data:
Versão/commit:
Godot:
Sistema operacional:
Casos executados:
Casos aprovados:
Falhas e reprodução:
Próximo ajuste:
```
