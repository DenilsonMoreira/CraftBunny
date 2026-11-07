# Craft Bunny

Jogo de plataforma 2D em Godot e estrutura para seu futuro ranking global.

## Organização

| Pasta | Conteúdo |
|---|---|
| game/ | Projeto Godot, código, artes, áudio, testes e documentação do jogo |
| web/ | Site público em pixel art, API Vercel e testes |
| supabase/ | Migração SQL e instruções de configuração do banco |
| docs/ | Decisões de integração e validação do repositório |

O jogo possui ranking local e cliente global opcional. Site/API em https://craftbunny-web.vercel.app; consulta e criação de sessão reais verificadas. APK 0.3.5 com URL configurada e exclusão local com confirmação em game/builds/. Envio de uma tentativa real em aparelho ainda aguarda playtest.

## Abrir o jogo

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

Manter o ranking local independente da internet. Enviar recordes globais com confirmação do jogador, validar no servidor, evitar duplicatas e permitir consulta pública dos melhores resultados. Credenciais privadas ficam somente no servidor.

## Arquivos locais

APKs, executáveis Godot, SDK/JDK, caches, chaves e variáveis de ambiente não são versionados. Os presets Android foram sanitizados; execute a configuração local antes de exportar. game/tools/build_android.ps1 aceita -GodotPath ou GODOT_BIN, sem precisar copiar a engine para o repositório.

Artes originais preservadas em game/assets/references/. Créditos e licenças em game/assets/CREDITS.md; licença da fonte incluída. Não foi atribuída uma licença de código aberto ao projeto por esta organização.
