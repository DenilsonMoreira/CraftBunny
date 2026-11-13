# Correções de apresentação 0.5.2 — 2026-11-13

## Corrigido

O vídeo fornecido (`20261113-1556-37.1388774.mp4`, 19,2 s) mostra o corpo provisório ao usar ferramentas alternativas. A causa foi reproduzida no pacote Windows 0.5.1: `FileAccess.file_exists` retornava falso para o caminho fonte `.tres`, enquanto `ResourceLoader.exists` retornava verdadeiro. A exportação remapeia o recurso para formato binário. Os testes anteriores em fontes não detectavam essa diferença.

`player.gd` agora pré-carrega explicitamente o SpriteFrames padrão. O recurso customizado exportado no jogador ainda tem prioridade. O pacote 0.5.2 foi testado com os caminhos remapeados, sem depender das fontes soltas: os corpos, ataques e mira finais aparecem com as ferramentas corretas, sem usar o placeholder. Não foi necessário recriar as folhas de arte.

`tool_obstacle.gd` usa um único tronco e as mesmas pontas durante toda a queda e na ponte final. A rotação acelera, a copa desaparece gradualmente e há uma pequena acomodação ao atingir o solo; não existe mais troca abrupta de um tronco vertical por outra geometria horizontal no último quadro. O toco permanece na origem. A visualização termina exatamente na posição da colisão existente.

Sons fornecidos pelo usuário:

- `music/falling-tree.mp3`: inicia uma vez no último acerto válido de machado, quando a queda começa. Os golpes anteriores mantêm o impacto de corte existente.
- `music/rock-falls.mp3`: toca em cada acerto válido de picareta na rocha, inclusive antes de ela quebrar.

Ambos sem loop, no bus SFX, respeitando os ajustes de volume. Ataques adicionais na árvore já caindo não reiniciam a queda nem o áudio.

Mantidos os 0,65 s até a ponte sólida, três golpes corretos por obstáculo, dimensões de colisão, controles, danos, orçamento de cenouras e regras de ranking. Originais e alterações anteriores do usuário em `scenes/editor_example/` preservados.

## Arquivos

- `game/scripts/player.gd`: recurso padrão por preload, compatível com exportação.
- `game/scripts/tool_obstacle.gd`: pose contínua de queda, tronco compartilhado, copa e novos sons.
- `game/music/falling-tree.mp3`, `rock-falls.mp3` e imports: arquivos fornecidos, importados sem loop.
- `game/tools/test_presentation.gd`: teste de regressão específico para fontes e pacotes exportados; capturas opcionais.
- `game/project.godot`, `export_presets.cfg`: 0.5.2, Android código 14.
- README, ROADMAP, TEST_PLAN, CREDITS e guias de build atualizados.
- `docs/qa_tree_fall_052.png` e `qa_export_tool_{1,2,3}_052.png`: árvore em seis instantes e ataques renderizados a partir do pacote Windows.

## Testes executados

| Verificação | Resultado |
|---|---|
| Reprodução no pacote 0.5.1 | Confirmada: fonte inexistente, recurso existente, arte padrão não carregada |
| test_presentation.gd em fontes com captura | **47 checks**, zero falhas |
| test_presentation.gd no pacote Windows, headless | **46 checks**, zero falhas; fonte continua inexistente, recurso final carregado corretamente |
| Mesmo pacote, OpenGL, --capture-tools --touch | **49 checks**, zero falhas; três capturas de ataque revisadas |
| test_tools.gd | 68 aprovados |
| test_tool_level.gd | 15 aprovados; ambos os buracos, árvores/ponte e rochas atravessados fisicamente |
| test_touch.gd | 25 aprovados |
| test_mobility.gd | 40 aprovados |
| test_art.gd sem captura | 493 aprovados |
| test_attack.gd | PASS, 12 quadros observados e um golpe |
| test_death.gd | 10 aprovados |
| test_audio.gd | Zero falhas, áudio/preferências e interrupção do tema na morte preservados |
| Importação e smoke headless de 120 frames | Sem erros de parser/runtime |

Alguns harnesses ainda emitem avisos ObjectDB/resources no encerramento, com todos os checks aprovados. Eles não foram declarados corrigidos. Não houve teste online nem envio de recordes fictícios.

Comandos, na raiz do repositório:

```text
godot --headless --path game --editor --quit-after 60
godot --path game --rendering-method gl_compatibility --script res://tools/test_presentation.gd -- --capture
godot --headless --main-pack game/builds/windows-0.5.2/CraftBunny-0.5.2.exe --script res://tools/test_presentation.gd
godot --main-pack game/builds/windows-0.5.2/CraftBunny-0.5.2.exe --rendering-method gl_compatibility --script res://tools/test_presentation.gd -- --capture-tools --touch
godot --headless --path game --script res://tools/test_tools.gd
godot --headless --path game --script res://tools/test_tool_level.gd
```

O teste do pacote usa a engine console para abrir o PCK embutido no EXE; não abre as fontes de `game/`. Capturas de ferramentas são salvas em `user://qa_export_tool_*_052.png`, com caminho absoluto impresso no log.

## Validação manual pendente

Avaliar o volume dos dois arquivos ouvindo-os no jogo, fluidez percebida da queda em velocidade normal e percurso completo. Executar no Android físico para confirmar renderização e combinação dos controles touch. Os testes verificaram importação, stream, momento de reprodução e bus dos sons; não substituem a escuta humana.

## Builds e retenção

- Windows EXE: 153.887.352 bytes, propriedades 0.5.2.0, SHA256 5e71d192ad104834803148e279afc7914448c0962d89410a2363e420a525fdc0. Smoke do executável OpenGL por 120 frames, saída 0 e log sem erros.
- ZIP com créditos e licenças: 82.893.504 bytes, SHA256 2582c812c9439467a5622808a6678c2e58057ca30914135a2ce41db85f27633f.
- APK: 95.886.074 bytes, código14 / 0.5.2-android-test, SHA256 81e663e9459eaf90170a68066bf470dde2d18d6e093518f8530f486ba4ec17de. Assinatura v2/v3, mesmo certificado da 0.5.1, ARM32/64, INTERNET, mínimoAPI24 e target36 verificados. Inspeção do ZIP confirmou o destino binário de tool_frames.tres.remap e ambos os streams MP3 dentro do APK; isso não equivale à execução em Android físico.
- Mantidas somente as versões locais 0.5.2 e 0.5.1, com verificação de caminhos pelo script de retenção. Fontes, referências, histórico e armazenamento remoto preservados.
- APK disponível localmente. Nenhum upload ao Blob ou troca da versão de download do site nesta etapa.
