# Organização e validação do repositório

2026-11-07. Destino autorizado: https://github.com/DenilsonMoreira/CraftBunny.

Cópia organizada em game/, preservando a pasta de trabalho anterior. web/ e supabase/ contêm especificações, ainda sem aplicação, banco ou integração ativa.

## Preparação

Fontes Godot, scripts, artes de referência/produção, sons, ferramentas e documentação. .gitignore exclui engine, SDKs, builds, caches, chaves, ambientes e credenciais locais. Presets sem caminhos locais, senha ou keystore; build_android.ps1 aceita -GodotPath/GODOT_BIN ou godot no PATH.

Não copiados APKs, executáveis Godot, .godot, .build_tools e sprites aposentados. Áudio inválido não utilizado hammer-atack1.mp3 retirado apenas desta cópia; original preservado na pasta anterior.

## Validação antes do envio

- Godot 4.7.2: importação completa --headless --path game --editor --quit, saída 0.
- Smoke --headless --path game --quit-after 120, saída 0.
- tools/test_flow.gd: 16 verificações aprovadas.
- tools/test_pixel_feedback.gd: 34 verificações aprovadas.
- 21 arquivos de referência comparados por hash: idênticos aos originais.
- Parser PowerShell: script Android aprovado. Nenhum comando Git executado no PowerShell.
- Busca textual por padrões comuns de tokens/chaves privadas nos fontes/configurações: nenhuma ocorrência; não constitui auditoria exaustiva de segurança.

O harness de fluxo mantém aviso conhecido de dois objetos/um recurso em uso ao encerrar; importação, smoke e teste de feedback concluíram sem esse aviso. Importação informa diferença entre Build Tools 35.0.1 e Target SDK 36, aviso local já registrado.

Nenhum novo APK gerado nesta organização: exportar exige configurar localmente templates/SDK/chave. Sem mudança de gameplay, novo teste físico Android ou publicação Vercel/Supabase.

## Próxima etapa

Implementar site/API em web/, migrações em supabase/ e integração HTTPS opcional do jogo, preservando ranking local offline. Configurar validação, deduplicação e controle de acesso no servidor antes de receber recordes reais.
