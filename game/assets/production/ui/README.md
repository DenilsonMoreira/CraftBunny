# Interface

Atualização: HUD agora utiliza a placa pixel art hud_wood.png e corações cheio/vazio de hearts.png. A tela de título usa a arte oficial com botões Godot sobrepostos e acesso a opções. Detalhes atuais em assets/production/v2/hearts_clouds_title.md; o texto abaixo descreve a etapa inicial do tema.

Fontes: `assets/references/ui/ui_hud_menus_reference.png` e `craft_bunny_title_screen.png`.

Textos e controles devem continuar sendo widgets Godot; usar as referências apenas para paleta, composição e estilo.

Tema inicial implementado em `scripts/ui_theme.gd`: painéis em marrom madeira, bordas douradas, destaque laranja, estado pressionado verde e textos creme. Botões têm indicação de foco por teclado. HUD e menus herdam o mesmo Theme; mensagens têm contorno para contraste com o cenário.

Menus usam área de rolagem dentro de um painel de 500x400 para manter ranking, opções e resultados acessíveis na resolução 960x540. Esta etapa reproduz a paleta da referência com StyleBoxFlat; molduras ilustradas e ícones da folha ainda não foram integrados.

Importação headless e inicialização de 120 frames no Godot 4.7.2 executadas sem erros. Conferência visual e navegação por todos os menus ainda pendentes.
