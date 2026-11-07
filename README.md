# Craft Bunny

Jogo de plataforma 2D em Godot e estrutura para seu futuro ranking global.

## Organização

| Pasta | Conteúdo |
|---|---|
| game/ | Projeto Godot, código, artes, áudio, testes e documentação do jogo |
| web/ | Área reservada para o site público e API de ranking |
| supabase/ | Área reservada para migrações e configuração do banco |
| docs/ | Decisões de integração e validação do repositório |

O jogo já possui ranking local. O site, API e ranking global ainda não foram implementados ou publicados. A criação das contas não conecta automaticamente os serviços.

## Abrir o jogo

Use Godot 4.7.2 para reproduzir a validação atual e importe game/project.godot. A engine não acompanha o repositório. Consulte game/README.md, game/AGENTS.md e game/ROADMAP.md para controles, regras e histórico.

No editor, pressione F5. Testes pela CLI:

```text
godot --headless --path game --editor --quit
godot --headless --path game --quit-after 120
godot --headless --path game --script res://tools/test_pixel_feedback.gd
```

## Ranking online: próxima implementação

O destino planejado é Vercel para web/ e API, com Supabase para os recordes. Ainda não importe web/ na Vercel: nesta etapa ela contém apenas a especificação, sem aplicação para executar.

Manter o ranking local independente da internet. Enviar recordes globais com confirmação do jogador, validar no servidor, evitar duplicatas e permitir consulta pública dos melhores resultados. Credenciais privadas ficam somente no servidor.

## Arquivos locais

APKs, executáveis Godot, SDK/JDK, caches, chaves e variáveis de ambiente não são versionados. Os presets Android foram sanitizados; execute a configuração local antes de exportar. game/tools/build_android.ps1 aceita -GodotPath ou GODOT_BIN, sem precisar copiar a engine para o repositório.

Artes originais preservadas em game/assets/references/. Créditos e licenças em game/assets/CREDITS.md; licença da fonte incluída. Não foi atribuída uma licença de código aberto ao projeto por esta organização.
