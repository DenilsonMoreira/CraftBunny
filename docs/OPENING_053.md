# Abertura e música de título — 0.5.3

## Implementado

- `opening.tscn` é a cena inicial. A imagem da engine foi desativada no boot; a engine Godot e suas licenças foram mantidas.
- Seis imagens da prévia v2 aprovada, com olhos fechados no quadro “Já volto!”, são apresentadas por AtlasTextures. Arte completa preservada em `game/assets/production/intro/storyboard.png`, sem regeneração ou retoque.
- Passagem automática a cada 3,6 s, crossfade de 0,32 s; duração aproximada 21,6 s. A imagem mantém a proporção e os botões não cobrem os balões.
- Espaço, Enter, seta direita, clique ou toque avançam. Esc, botão PULAR e Voltar do Android encerram. Tecla repetida/soltura não avança; toque seguido de mouse emulado avança uma vez.
- Ao terminar ou pular, abre o título existente em `main.tscn`. NOVO JOGO inicia a partida. Reiniciar recarrega `main.tscn` e não repete a abertura; relançar o aplicativo mostra a cutscene novamente. Nenhuma preferência de progresso foi adicionada.
- `forest-birds.mp3` foi copiado de Downloads, preservando o arquivo fornecido. Reproduz em loop no bus Music, respeitando volume/mute salvos. O mesmo AudioStreamPlayer é transferido da abertura para o título, sem reiniciar a faixa na mudança de cena ou ao voltar dos menus de título.
- NOVO JOGO para forest-birds e inicia o tema de gameplay anterior. Morte, grito de queda, efeitos e demais regras foram preservados. Ao perder foco a abertura pausa seu relógio e a faixa; ao retornar, continua.

Somente a apresentação inicial foi alterada. HP, controles da partida, colisões, ferramentas, cenário, inventário e ranking permanecem. Alterações locais anteriores nas duas cenas de `game/scenes/editor_example/` preservadas.

## Arquivos

| Caminho | Papel |
|---|---|
| game/opening.tscn, scripts/opening.gd | Sequência, crossfade, botões, teclado/toque e entrada no título |
| game/scripts/menu_music.gd | Faixa de abertura/título, volume inicial salvo e foco |
| game/scripts/main.gd | Recebe o player de áudio e troca música ao iniciar a partida |
| game/assets/production/intro/ | PNG aprovado, import, catálogo e prompts/histórico |
| game/music/forest-birds.mp3 e import | Áudio fornecido, fonte original preservada |
| game/tools/test_opening.gd | Fluxo, entradas, recursos, música e capturas reproduzíveis |
| game/project.godot, export_presets.cfg | Boot e versão 0.5.3 / Android código15 |
| README, ROADMAP, TEST_PLAN, ASSETS, CREDITS e guias de build | Documentação e evidências |
| docs/qa_opening_*_053.png | Capturas dos seis painéis e título |

## Testes executados

| Verificação | Resultado |
|---|---|
| test_opening.gd em OpenGL com --capture | 52 checks, zero falhas; seis imagens e título revisados |
| test_opening.gd headless em fontes | 45 checks, zero falhas, incluindo término automático |
| test_audio.gd | Zero falhas; volumes, mute, tema da partida e morte |
| test_death.gd | 10 aprovados |
| test_flow.gd | 16 aprovados |
| test_tools.gd | 68 aprovados |
| test_touch.gd | 25 aprovados |
| test_mobility.gd | 40 aprovados |
| test_auto_ranking.gd | 22 aprovados em ambiente offline |

O teste da abertura verifica cena de entrada, logo desativado, regiões da imagem aprovada, fade, seis slides, navegação, duplo evento de toque, perda de foco, mute, ausência de jogador durante a intro, transferência da mesma instância de áudio, título/menus, tema da partida e morte. Preferências de QA ficam em arquivos dedicados; nenhum recorde fictício enviado online.

Alguns harnesses em headless ainda emitem avisos ObjectDB/resources no encerramento, com todos os checks aprovados. Esses avisos não foram declarados corrigidos.

Comandos na raiz, substituindo godot pelo executável console:

```text
godot --headless --path game --editor --quit-after 60
godot --path game --rendering-method gl_compatibility --script res://tools/test_opening.gd -- --capture
godot --headless --path game --script res://tools/test_opening.gd
godot --headless --main-pack game/builds/windows-0.5.3/CraftBunny-0.5.3.exe --script res://tools/test_opening.gd
godot --headless --path game --script res://tools/test_audio.gd
```

Capturas são gravadas em `user://qa_opening_*_053.png`; o caminho absoluto é impresso. F5 executa a abertura; F6 em `main.tscn` permite acessar diretamente o título para trabalhar na fase.

## Pendente de validação manual

Escutar a emenda do loop de forest-birds e comparar volume com o tema da partida. Avaliar duração/leitura em velocidade normal e comandos no Android físico. Os testes confirmam stream, loop, bus, volume e momento da transição; não substituem escuta humana ou execução em aparelho Android.

## Pacotes e validação da exportação

- PCK embutido no Windows: teste da abertura com 45 checks headless e 52 checks/capturas OpenGL, zero falhas. Arte, navegação, término automático e continuidade da música confirmados com recursos remapeados.
- EXE: 158.184.120 bytes, versão 0.5.3.0, SHA256 17e2a5f656a21f002175c71e7e10873b8dae2b0766005a46399512e385ca4f3d. Executado por 1450 frames a 60fps fixos (~24,2 s de lógica), atravessando a abertura completa até o título; saída 0, log sem erros. Importação e smoke headless de 120 frames também sem erros de parser/runtime.
- ZIP com créditos/licenças: 87.143.957 bytes; SHA256 42a51f475d3defe27174275e7ba0c2fcabd26c7553de88d65521400ccbaa006a.
- APK: 100.130.461 bytes, código15 / 0.5.3-android-test, SHA256 20377061dd81580c1c8d5a3b79fdb0ca7a5a1a5272b8eca82b02b431306b86a8. Assinatura v2/v3, mesmo certificado da 0.5.2, ARM32/64, INTERNET, mínimoAPI24/target36 verificados. Conferidos no ZIP do APK os destinos remapeados de opening.tscn, opening.gd, storyboard.png e forest-birds.mp3. Não equivale a execução em Android físico.
- Retenção local aplicada pelo script com validação de caminhos: mantidas 0.5.3 e 0.5.2. Originais, referências, fontes e histórico preservados.
- Nenhum upload ao armazenamento privado nem troca da versão de download do site nesta etapa.
