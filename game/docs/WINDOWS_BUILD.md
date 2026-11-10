# Windows 0.3.5 — 2026-11-07

Versão atual 0.3.7 (2026-11-10): `game/builds/windows-0.3.7/CraftBunny-0.3.7.exe` e ZIP `game/builds/CraftBunny-Windows-0.3.7.zip`, sem botão de envio manual. Propriedades 0.3.7.0 e smoke OpenGL de 120 frames fora do editor aprovados. SHA256 `ac429c3c4ad789379e2602cdf98b31351ca2286c4eb0e9304576c11903808b91`. Detalhes em ../../docs/TOUCH_ANALOG.md; notas seguintes são históricas.

Atualização 2026-11-10: versão atual 0.3.6 em `game/builds/windows-0.3.6/CraftBunny-0.3.6.exe` e ZIP `game/builds/CraftBunny-Windows-0.3.6.zip`. Smoke OpenGL fora do editor aprovado, propriedades 0.3.6.0, SHA256 `9948D65171ACDC6110568A0A428B088BA2345F65C4BF911750EB24055EE90065`. Envio automático e botão global abrindo o site em `../../docs/AUTO_GLOBAL_RANKING.md`. As seções abaixo preservam o histórico do primeiro build 0.3.5.

O projeto atual está em `CraftBunny/CraftBunny/game`. A pasta anterior `Craft_Bunny_Codex_Com_Sprites/Craft_Bunny_Codex` é uma cópia antiga: abrir seu project.godot continua executando o jogo antigo. O APK não atualiza essa cópia nem executáveis de PC automaticamente.

## Executar a versão atual

Abra `game/builds/windows-0.3.5/CraftBunny-0.3.5.exe`, sem precisar da Godot. O pacote ZIP ao lado contém o executável e os avisos de licença. O título mostra `v0.3.5 | LOCAL + GLOBAL`; propriedades do executável: versão 0.3.5.0, arquitetura x86_64. Ranking global configurado para https://craftbunny-web.vercel.app, exclusão de ranking local com confirmação e demais recursos do APK 0.3.5. Protocolo da API permanece 0.3.4 por compatibilidade com o servidor.

Para desenvolver, importe o `game/project.godot` do repositório atual. Não há atualização automática de builds anteriores. Caminhos de recordes/preferências não foram alterados; não apagamos arquivos do usuário. As regras de gameplay e as artes originais foram preservadas.

## Reproduzir a exportação

Godot 4.7.2 e templates oficiais Windows x86_64 da mesma versão são necessários. Os templates usados nesta máquina foram extraídos do pacote oficial já existente em `AppData/Local/CraftBunnyAndroid/export_templates.tpz` para `AppData/Roaming/Godot/export_templates/4.7.2.stable`.

Na raiz do repositório:

```powershell
./game/tools/build_windows.ps1 -GodotPath 'CAMINHO/DA/Godot_console.exe'
```

Preset `Windows`: release x86_64, PCK embutido, versão 0.3.5.0, sem assinatura Authenticode. Executáveis e ZIPs permanecem ignorados pelo Git; nenhuma credencial é necessária para a exportação. Referências e documentação não são distribuídas no PCK.

## Validação

- Importação headless e exportação release: aprovadas em Godot 4.7.2.
- Projeto: smoke headless de 120 frames aprovado.
- Executável exportado: iniciado fora do editor por 120 frames com renderização OpenGL/Intel Iris Xe, saída zero, sem erros no log.
- Exclusão local: 15 checks aprovados no projeto, usando arquivo de teste isolado.
- Fluxo: 16 checks aprovados no projeto. O encerramento desse teste emite aviso de dois objetos/um recurso ainda em uso; não observado no smoke do executável. Não tratamos esse teste como livre de avisos.
- Cliente Godot/API/PostgreSQL isolado: dez checks aprovados e exatamente um resultado gravado apenas no banco temporário do teste, sem publicação de recorde real.
- Tentativa de executar o script de teste local diretamente no release por `--script` não terminou em 30 segundos; processo de teste encerrado. Portanto, as verificações detalhadas de exclusão são do projeto, não declaradas como aprovadas no release.
- APK: usuário confirmou download e funcionamento; nenhuma nova exportação Android foi necessária nesta etapa.

Executável: 135.761.496 bytes. SHA256: `6BD3B4387A28A8F4C5030C22224E63E8A5AA0303D273907CDDBF36CA3ADA8A20`.

Pendente: playtest completo no Windows com entrada, som, persistência após reinício e envio de recorde real. M7 permanece em andamento.
