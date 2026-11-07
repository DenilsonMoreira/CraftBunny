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
- [ ] T07 — Direção, aceleração e desaceleração funcionam nos dois sentidos.
- [ ] T08 — Pulo tem altura próxima ao corpo do coelho no sprite final; pouso sem atravessar chão.
- [ ] T09 — Coyote time: pular dentro de 0,12 s após sair da borda.
- [ ] T10 — Jump buffer: pressionar pulo até 0,12 s antes de aterrissar gera pulo.
- [ ] T11 — Câmera não revela fora do mapa e parallax permanece fluido até a chegada.

## Vida e martelo
- [ ] T12 — Coelho começa 3 HP; coração restaura um até no máximo 3.
- [ ] T13 — Dano inimigo 1/2/3 é aplicado corretamente (cobra/guaxinim/ave).
- [ ] T14 — Após golpe sobrevivido, outros ataques dentro de 1 s não tiram HP.
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
- [ ] T26 — Só entra no TOP 10 quem qualifica; aceitar exatamente 3 letras A–Z.
- [ ] T27 — Registrar após vitória e após derrota, sem duplicar registro.
- [ ] T28 — Fechar/reabrir mantém TOP 10 ordenado; nenhuma posição/HP/inventário salvo.
- [ ] T29 — Dados malformados em records.cfg não causam crash.
- [ ] T30 — Controles e volumes persistem; existe recuperação de configuração inválida.

## Balanceamento e distribuição
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
