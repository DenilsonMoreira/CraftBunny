# Craft Bunny

Jogo de plataforma 2D em Godot e estrutura para seu futuro ranking global.

## Organização

| Pasta | Conteúdo |
|---|---|
| game/ | Projeto Godot, código, artes, áudio, testes e documentação do jogo |
| web/ | Site público em pixel art, API Vercel e testes |
| supabase/ | Migração SQL e instruções de configuração do banco |
| docs/ | Decisões de integração e validação do repositório |

O jogo 0.4.1 tem uma fase editável de 24.000 px com floresta, copa e subsolo; 140 cenouras no mapa e 60 em drops, total 200, mantendo 24 inimigos. Salva o TOP 10 local e envia resultados elegíveis ao global. Android com analógico semitransparente. Site/API em https://craftbunny-web.vercel.app. Guia atual em docs/COMPACT_LEVEL_041.md; contrato/migração 0.4.0 preservados.

## Abrir o jogo

Exemplo para aprender edição visual na Godot: `game/scenes/editor_example/fase_exemplo.tscn`. Terreno TileMap pintável, posição inicial do coelho e cobra arrastáveis; executar com F6. Guia em `game/docs/EDITABLE_EXAMPLE.md`. A fase principal permanece separada.

Windows 0.4.1: execute `game/builds/windows-0.4.1/CraftBunny-0.4.1.exe`. APK: `game/builds/CraftBunny-Android-0.4.1.apk`. Binários não são versionados. Use o projeto atual do repositório; a pasta anterior não recebe atualizações automaticamente. Cena editável: `game/scenes/level_wide/fase_compacta.tscn`. Guia em `docs/COMPACT_LEVEL_041.md`.

Use Godot 4.7.2 para reproduzir a validação atual e importe game/project.godot. A engine não acompanha o repositório. Consulte game/README.md, game/AGENTS.md e game/ROADMAP.md para controles, regras e histórico.

No editor, pressione F5. Testes pela CLI:

```text
godot --headless --path game --editor --quit
godot --headless --path game --quit-after 120
godot --headless --path game --script res://tools/test_pixel_feedback.gd
```

## Ranking online

O site também possui BAIXAR APK para distribuição controlada por código do Google Authenticator. A ativação do arquivo privado e autenticador é separada do ranking; veja [docs/PRIVATE_APK_DOWNLOAD.md](docs/PRIVATE_APK_DOWNLOAD.md).

Vercel para web/ e API, Supabase para os recordes. A pasta web/ já contém aplicação executável: Root Directory web, Framework Other, Install npm ci, Build npm run build, Output public. Guia em [docs/GLOBAL_RANKING.md](docs/GLOBAL_RANKING.md).

Manter o ranking local independente da internet. Ao registrar as três letras, enviar automaticamente recordes elegíveis ao global, validar no servidor, evitar duplicatas e permitir consulta pública dos melhores resultados pelo site. Credenciais privadas ficam somente no servidor.

## Arquivos locais

APKs, executáveis Godot, SDK/JDK, caches, chaves e variáveis de ambiente não são versionados. Os presets Android foram sanitizados; execute a configuração local antes de exportar. game/tools/build_android.ps1 aceita -GodotPath ou GODOT_BIN, sem precisar copiar a engine para o repositório.

Artes originais preservadas em game/assets/references/. Créditos e licenças em game/assets/CREDITS.md; licença da fonte incluída. Não foi atribuída uma licença de código aberto ao projeto por esta organização.
