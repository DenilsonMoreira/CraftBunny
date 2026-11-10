# Primeiro exemplo de fase editável — 2026-11-10

Abra o projeto atual do repositório: `CraftBunny/CraftBunny/game/project.godot`, usando a Godot 4.7.2. A pasta antiga Craft_Bunny_Codex não recebe automaticamente os arquivos novos.

## Abrir e jogar

1. No painel Arquivos/FileSystem da Godot, abra `res://scenes/editor_example/fase_exemplo.tscn`.
2. Selecione a área **2D** no topo. Coelho, cobra e terra já ficam visíveis antes de executar.
3. Pressione **F6** para jogar somente esta cena. **F5 continua abrindo o jogo principal**.
4. Use A/D ou setas, Espaço para pular, J para martelar e R para reiniciar o exemplo.
5. Pare a execução para voltar a editar. Salve com Ctrl+S.

## O que mover no painel Cena

```text
ExemploEditavel
├── Fundo
├── Terreno               ← pintar e apagar terra
├── InicioJogador         ← arrastar o coelho / ponto de início
├── Inimigos
│   └── Cobra             ← arrastar o ponto inicial da cobra
└── Interface
```

Selecione **InicioJogador**, ative a ferramenta Mover e arraste no editor 2D. A prévia do coelho acompanha o marcador e o personagem nasce nessa posição ao executar. Faça o mesmo com **Inimigos/Cobra**. Para manter os pés sobre a superfície inicial em Y=384, o centro do coelho está em Y=363 e o da cobra em Y=371.

InicioJogador e Cobra são cenas reutilizáveis, equivalentes a prefabs. A prévia está agrupada com o marcador: mova o marcador, sem deslocar o filho Previa. Você pode duplicar Cobra com Ctrl+D dentro de Inimigos e reposicioná-la. Não duplique InicioJogador: o exemplo usa um único início.

## Pintar o terreno

1. Selecione **Terreno** no painel Cena.
2. Abra o painel **TileMap** da Godot, escolha um tile no atlas e use a ferramenta de pintura no cenário.
3. A primeira linha do atlas contém terra com grama; as linhas inferiores contêm terra para preencher embaixo.
4. Use a ferramenta de borracha ou botão direito para apagar células. Ctrl+S salva a alteração.
5. Execute com F6 para testar a colisão do novo terreno.

Cada tile já tem colisão sólida. Pinte chão abaixo do personagem e do inimigo para não deixá-los cair. As artes existentes são grandes: o TileSet usa regiões de 256x256 da imagem original e o nó Terreno tem escala 0,25, resultando em blocos visuais de **64x64**. Preserve essa escala ao aprender; não é necessário editar o TileSet nem redimensionar a imagem.

O exemplo começa com 14 colunas e três linhas de terra (42 células), um início do coelho e uma cobra. O chão é realmente serializado em um TileMapLayer: abrir, jogar e salvar a cena não recria nem sobrescreve sua pintura.

Para os primeiros testes, mantenha os elementos na área de 960x540: a câmera desta demonstração está limitada a essa área. Ampliar o mapa e os limites da câmera fica para a próxima adaptação.

## Alcance desta etapa

É uma cena de aprendizado separada, sem menu, ranking, áudio ou construção de caixas. Usa diretamente os scripts atuais do coelho, cobra e coletável: movimento, pulo, dano/invulnerabilidade, martelo, pisão e recompensa existentes. Coelho 3 HP, cobra 2 HP/1 dano/1 cenoura. Não altera a fase principal, os recordes, o APK nem a pontuação máxima do ranking. O script do exemplo não cria sessões online nem grava arquivos de jogador.

`tools/create_editor_example.gd` foi usado uma vez para produzir os arquivos nativos. Ele recusa sobrescrever uma fase_exemplo.tscn existente; **não rode o gerador para editar o mapa**. Faça as alterações pela cena e pelo TileMap. Os arquivos originais de arte foram reutilizados, sem modificações.

## Verificações

- Importação e smoke de 120 frames da cena: aprovados com Godot 4.7.2.
- `tools/test_editor_example.gd`: 19 checks aprovados. Verifica células e colisões, prévias presentes no editor, pintura/apagamento e posições preservados ao salvar/reabrir, nascimento no marcador alterado, pouso no chão, movimento/pulo, martelo de um dano, cobra derrotada após dois golpes, drop/coleta e cena principal preservada.
- Execução OpenGL: os mesmos checks e captura adicional aprovados, imagem revisada em `../../docs/qa_editable_example.png`.
- Testes usam cena temporária em user://, removida após a execução, sem editar o exemplo entregue ou recordes reais.
- Smoke da cena principal e 15 checks de regressão da exclusão de recordes locais aprovados após a adição do exemplo.

Reproduzir na raiz do repositório com a Godot console:

```text
godot --headless --path game --editor --quit
godot --headless --path game res://scenes/editor_example/fase_exemplo.tscn --quit-after 120
godot --headless --path game --script res://tools/test_editor_example.gd
```

Para gerar a captura, execute o último comando sem --headless e acrescente `-- --capture`. O teste não envia recordes públicos. Ajuste visual/interação manual no editor e o percurso maior continuam sendo os próximos passos; este exemplo não migra automaticamente a fase principal.
