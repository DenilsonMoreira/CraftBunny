# Validação de áudio — 2026-11-06

Godot 4.7.2 / Windows.

Implementado em scripts/main.gd:

- volumes padrão aplicados mesmo sem arquivo salvo;
- leitura de preferências sem regravar arquivo;
- valores numéricos limitados a 0–1 e dados inválidos substituídos pelo padrão;
- zero silencia o bus e valores positivos reativam o áudio;
- botão RESTAURAR VOLUMES nas opções;
- aviso quando não for possível salvar.

Comando reproduzível (a partir da pasta do projeto):

```powershell
& .\Godot_v4.7.2-stable_win64_console.exe --headless --path (Get-Location).Path --script res://tools/test_audio.gd
```

Resultado: 13 checks passaram, AUDIO_FAILURES=0. Incluem carregamento e duração dos quatro arquivos, buses, propriedade de loop, mute, gravação/releitura, dados inválidos, restauração e início do tema com Novo Jogo.

O teste usa somente user://craft_bunny_audio_test.cfg e remove esse arquivo ao terminar. Preferências e ranking pessoais não são alterados em disco. As alterações de volume nos buses só afetam o processo de teste.

Limitação: o encerramento do teste específico reportou 2 instâncias ObjectDB e 1 recurso em uso. Importação e smoke test normal de 120 frames terminaram sem esses avisos. Investigar o encerramento do harness em QA.

Pendente de escuta manual: volume relativo entre tema e efeitos, ausência de cortes/clipping, continuidade da emenda do loop, eventos de coleta/ataque/morte durante uma partida. A propriedade de loop foi verificada, mas o áudio não foi escutado nesta rodada.
