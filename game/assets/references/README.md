# Referências de arte — Craft Bunny

Estes arquivos foram copiados para o projeto, mas **não são atlas técnicos prontos para `AnimatedSprite2D` ou `TileSet`**. São ilustrações compostas com etiquetas, fundos, sombras, molduras e espaçamento irregular.

## Prioridade de integração
1. `characters/bunny_animations_current.png` — coelho APROVADO: sem roupa, lenço gasto vermelho, bolsa lateral e martelo.
2. `enemies/enemies_animation_reference.png` — cobra, guaxinim, ave de rapina.
3. `items/collectibles_hearts_planks_carrots.png` — coração, madeira, cenoura; 3 HP, até 6 madeiras, 3 por caixa.
4. `tiles/forest_ground_tiles_generated.png` e `tiles/forest_foliage_props_generated.png` — terrenos, árvores e folhagem.
5. `ui/ui_hud_menus_reference.png` e `ui/craft_bunny_title_screen.png` — UI, menu e ranking.

`characters/bunny_animations_early.png` é histórico: não usar o coelho vestido como versão final.
`original_user_references/` contém imagens fornecidas pelo usuário, somente para referência visual. Verificar licença de reutilização externa.

## Plano de conversão para produção
- Trabalhar sobre **cópias**, preservando estas referências.
- Exportar **PNG RGBA de fundo realmente transparente** e quadros em dimensões consistentes (p.ex. 64×64/96×96, conforme teste).
- Separar animações em frames numerados, revisar o desenho/arma e manter pé/pivô alinhados.
- Separar arte da interface dos textos: preferir botões Godot reais com imagens como `StyleBoxTexture` ou `NinePatchRect`.
- Criar `SpriteFrames` por ação, `TileSet` com colisões apenas nos tiles sólidos, e validar em game.
- Não prometer automação perfeita dos recortes: sobreposição e inconsistências precisam de revisão artística.
