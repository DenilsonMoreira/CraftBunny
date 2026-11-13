# Ferramentas acompanhando as mãos — 0.5.4

## Problema e correção

No vídeo `20261113-1650-16.0378954.mp4` (17 s), a ferramenta parece solta durante a corrida e encobre o rosto. Os estados de corpo usavam um ponto fixo por animação, embora a posição da mão varie entre os 12 quadros. O equipamento também era desenhado sobre todo o corpo.

`equipment_rig.gd` agora registra os centros das palmas em coordenadas dos próprios PNGs para idle, corrida, subida, queda, Dash e troca. Para planar, registra a posição da bolsa, liberando as duas mãos para o lenço. Nenhum PNG foi refeito ou alterado.

O gerador converte cada ponto para o canvas de seu quadro, incluindo o recorte, margem, escala e pivô dos pés. O SpriteFrames mantém **33 animações de 12 quadros**, agora com 12 encaixes e ângulos em cada sequência modular. O equipamento usa o encaixe do mesmo quadro do corpo, sem interpolação atrasada entre poses.

O cabo é desenhado atrás da mão/corpo, no mesmo nível do mundo, para a palma cobri-lo naturalmente. Inclinação para a frente evita sobreposição com o rosto; a corrida e o Dash têm pequenas variações por pose. Na troca, a ferramenta anterior some e a próxima aparece junto à mão real; a trajetória artificial atravessando o corpo foi removida. No planar, a ferramenta fica presa junto à bolsa.

Ambas as direções são espelhadas em conjunto. Ataques usam a direção registrada do golpe e Dash usa sua direção travada, mesmo ao pressionar a direção contrária. Os rastros copiam a mesma ordem de desenho do cabo e do corpo.

Ataques/mira já desenhados com a ferramenta incorporada continuam sem camada duplicada. Martelo de ataque, morte, pisão, cutscene e música anteriores preservados. **Nenhuma alteração em alcance, dano, duração de ataques, velocidade, colisões, inventário ou ranking.**

## Arquivos

| Arquivo | Alteração |
|---|---|
| game/scripts/equipment_rig.gd | Pontos de encaixe por quadro e inclinações |
| game/tools/build_tool_art.gd | Conversão de pontos para cada canvas e metadados do rig |
| game/assets/production/v4/tool_frames.tres | Recurso reconstruído, versão de rig 2 |
| game/scripts/tool_visual.gd | Encaixe sincronizado, ordem de desenho e direção visual |
| game/scripts/movement_fx.gd | Cabo atrás do corpo também nos rastros |
| game/tools/test_equipment_rig.gd | Verificação da palma real e transformações em ambos os lados; captura |
| game/tools/test_art.gd | Captura versionada e ordem visual correta das ferramentas |
| game/project.godot, export_presets.cfg | Versão 0.5.4 / Android código16 |
| README, ROADMAP, TEST_PLAN, catálogo e guias de build | Documentação |
| docs/qa_rig_sling_054.png, qa_art_poses_054.png | Doze quadros do estilingue e estados das quatro ferramentas |

As duas alterações locais anteriores em `game/scenes/editor_example/` foram mantidas fora desta entrega.

## Testes executados

| Suíte | Resultado |
|---|---|
| test_equipment_rig.gd -- --capture | **1.430 checks, zero falhas** |
| test_art.gd -- --capture --rig | 494 aprovados; captura das quatro ferramentas revisada |
| test_art.gd sem captura | 493 aprovados |
| test_tools.gd | 68 aprovados |
| test_presentation.gd | 46 aprovados |
| test_mobility.gd | 40 aprovados |
| test_touch.gd | 25 aprovados |
| test_sprite_layout.gd | 40 aprovados; alcance 32×26 e martelo anterior preservados |
| test_attack.gd | PASS; 12 quadros e um golpe |
| test_bird_hammer.gd | 14 aprovados |
| test_opening.gd | 45 aprovados; introdução e música mantidas |

A nova suíte verifica se os pontos marcados estão dentro de pixels reais da palma, todos os encaixes dos 12 quadros por estado, os quatro equipamentos em ambos os lados, coincidência geométrica entre empunhadura e ponto do corpo, movimento real do ponto na sequência, ordem de desenho, bolsa no planar e direção de ataque/Dash. Os checks geométricos não equivalem a centenas de sessões de playtest.

Alguns harnesses antigos ainda emitem avisos de ObjectDB/resources ao encerrar, mesmo com checks aprovados; não foram declarados corrigidos. Ambiente de testes offline, sem envio de recordes públicos.

Comandos na raiz:

```text
godot --headless --path game --editor --quit-after 60
godot --headless --path game --script res://tools/build_tool_art.gd
godot --path game --rendering-method gl_compatibility --script res://tools/test_equipment_rig.gd -- --capture
godot --path game --rendering-method gl_compatibility --script res://tools/test_art.gd -- --capture --rig
godot --headless --main-pack game/builds/windows-0.5.4/CraftBunny-0.5.4.exe --script res://tools/test_equipment_rig.gd
```

O teste do rig grava `user://qa_rig_sling_054.png`, imprimindo o caminho absoluto. Capturas históricas preservadas. Recursos finais ainda permitem substituição explícita no jogador; o encaixe novo depende dos metadados gerados pelo script.

## Validação manual pendente

Avaliar a sensação em velocidade normal ao correr, virar, saltar, trocar de ferramenta e combinar Dash/planar. Repetir em Android físico. As poses foram conferidas em capturas, mas não houve playtest humano completo da fase nesta atualização.

## Exportação e retenção verificadas

- Pacote Windows: teste de rig com 1.429 checks headless e 1.430/captura OpenGL, zero falhas. Captura do estilingue revisada com recursos exportados.
- EXE 158.532.312 bytes, versão 0.5.4.0, SHA256 6749309cce4eb98d6daad12f39b0db5980281dbb8eec3e5f2b1eb68336791a55. Smoke OpenGL de 1450 frames a 60fps fixos atravessou a abertura automática até o título, saída0 e log sem erros. Importação final e smoke headless de 120 frames também sem erros de parser/runtime.
- ZIP com créditos/licenças: 87.483.817 bytes, SHA256 68a70d800153f1c7b9c8377b5acb89c5849860a6d06a4d3dedcf4669cc278c48.
- APK 100.134.718 bytes, código16/0.5.4-android-test, SHA256 bb8c7ee48cf5e9ab4d9206ddc221c7dcce38bc7b3af2637fe186e3a12cd67334. Assinatura v2/v3, mesmo certificado da 0.5.3, ARM32/64, INTERNET, mínimoAPI24/target36 verificados. Destinos remapeados de equipment_rig.gd, tool_visual.gd e tool_frames.tres conferidos dentro do APK. Não equivale a execução em aparelho físico.
- Retenção local aplicada: 0.5.4 e 0.5.3. Referências, originais e histórico Git preservados. Sem upload do APK ou alteração do download do site nesta etapa.
