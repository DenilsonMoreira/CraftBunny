# Ranking, controles e fluxo — 2026-11-06

Godot 4.7.2 / Windows. Executar na pasta do projeto:

```powershell
& .\Godot_v4.7.2-stable_win64_console.exe --headless --path (Get-Location).Path --script res://tools/test_flow.gd
```

16 checks passaram, FLOW_FAILURES=0, sem erros ou avisos na saída completa.

Cobertura: título e vida inicial, início, pausa e retomada por estado, derrota/resultados, nomes inválidos, um registro por tentativa, releitura sem duplicação, arquivo sem progresso de gameplay, container e entradas inválidas de ranking, empate no décimo lugar, qualificação acima do décimo, persistência do remapeamento, configuração de tecla inválida, nova cena com inventário/HP zerados e vitória.

Os testes usam somente user://qa_flow_records.cfg, qa_flow_controls.cfg e qa_flow_audio.cfg e os removem ao concluir; os recordes e preferências pessoais não são escritos.

Correções em scripts/main.gd: leitura defensiva do ranking, nome A–Z/3 letras, pontos inteiros não negativos, limpeza antes da releitura, trava de registro por tentativa, restauração da lista em memória se o salvamento falhar, leitura defensiva das teclas e retorno ao menu quando o remapeamento é cancelado.

Limites: a recriação da cena testa os valores iniciais; o botão de reinício/reload_current_scene não foi acionado pelo harness. Pausa foi validada por estados, sem medir física durante vários frames. Vitória/derrota foram disparadas diretamente, sem percorrer a fase ou testar chegada física. Não exercitados nesta rodada: falha de disco, arquivo sintaticamente corrompido e restauração de controles padrão. A ordenação/qualificação foi verificada, mas o TOP 10 completo após registro ainda precisa de QA ampliado.
