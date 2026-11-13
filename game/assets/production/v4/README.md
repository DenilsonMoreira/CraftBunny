# Arte de ferramentas e obstáculos — 0.5.1

Gerada em 2026-11-13 com a ferramenta integrada `imagegen`, usando o coelho oficial v2 e as artes ambientais existentes como referência. Originais em `assets/references/` preservados. Os PNGs desta pasta têm transparência RGBA real; não dependem de remoção de fundo por shader.

| Folhas | Grade | Conteúdo |
|---|---|---|
| body_idle, body_run, body_jump, body_fall | 4×3 | 12 poses por estado, corpo sem ferramenta |
| body_dash, body_glide_wing, body_switch | 4×3 | 12 poses por estado; lenço aberto, transições e acesso à bolsa |
| attack_axe, attack_pickaxe, attack_slingshot | 4×3 | 12 poses por ataque, ferramenta já desenhada |
| aim_slingshot | 4×3 | 12 poses de preparação/mira sustentada |
| equipment | 2×2 | Martelo, machado, picareta, estilingue |
| tree_kit | 4×2 | Copa, casca, tronco horizontal, toco, raízes, duas pontas e lascas |
| rock_states | 2×2 | Intacta, rachada, muito rachada e escombros |

São **132 poses novas do coelho** em 11 folhas. O recurso `tool_frames.tres` contém **33 animações de 12 quadros**: variantes de corpo reutilizadas com quatro ferramentas modulares, três ataques novos, mira do estilingue e o ataque de martelo aprovado anteriormente. Não são 396 desenhos independentes. Morte e pisão existentes permanecem compartilhados.

`tool_visual.gd` seleciona os estados e posiciona a ferramenta por ponto de empunhadura; na troca, a anterior some junto à bolsa e a seguinte aparece. Ataques e mira com ferramenta incorporada não recebem uma segunda camada. `movement_fx.gd` usa a pose e ferramenta reais nos rastros.

O gerador `tools/build_tool_art.gd` cria os AtlasTextures com pivôs nos pés, canvas transparente comum e escala sem esticar quadros. Para reconstruir após editar folhas: `godot --headless --path game --script res://tools/build_tool_art.gd` na raiz do repositório. O jogador carrega automaticamente o recurso; a propriedade `final_tool_frames` continua aceitando substituição explícita. Template anterior preservado em `production/tools/`.

Árvores/rochas usam `world_art.gd`; regiões transparentes são recortadas em memória, sem alterar PNGs. As colisões, largura das pontes, HP, tempos e regras de ferramenta não foram modificados.

Prompts completos, incluindo ajustes de revisão: [PROMPTS.md](PROMPTS.md). Relatório, testes e limites: [ART_051.md](../../../../../docs/ART_051.md). Revisão humana de todas as transições em velocidade normal e Android físico continua pendente.
