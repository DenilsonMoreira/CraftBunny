# AGENTS.md — Instruções para Codex

Você está desenvolvendo **Craft Bunny**, jogo de plataforma 2D **Godot 4.3+ / GDScript**, partindo do código existente. Leia `README.md`, `ROADMAP.md`, `docs/TEST_PLAN.md` e `docs/ASSETS.md` antes de alterar código.

## Regras inegociáveis
- **Uma fase**, em três alturas (floresta, copa e subsolo), casa do coelho = chegada, ranking de cenouras = competição. Largura atual **24.000 px**, reduzida de 48.000 em 2026-11-13 por solicitação. Mantidos 140 cenouras no mapa e 60 em drops, teto 200 pelo contrato 0.4.0. Tempo da fase compacta depende de playtest; não impor duração mínima.
- Após atacar, a ave pousa por 0,5 s antes de retornar ao voo (alteração autorizada em 2026-11-12). A escada da copa exige quatro caixas; manter retorno do subsolo sem gasto obrigatório.
- **Sem checkpoints nem save de progresso**. Persistir apenas recordes (e preferências de áudio e controles).
- Coelho: 3 HP, 1 s invulnerabilidade, martelo 1 dano; cobra 2 HP/1 dano/1 cenoura; guaxinim 5/2/3; ave 7/3/5.
- Madeira sem limite (alteração solicitada pelo usuário); caixa custa 3 madeiras, tem 2 HP e somente o coelho a destrói.
- Pisão autorizado: cair por cima de um inimigo causa 1 dano, impulso de retorno e um único quique pequeno ao pousar no chão, com animação própria e impact-thud.mp3.
- Coyote time e jump buffer 0,12 s; pulo ~altura do coelho com valores iniciais. Não tunar sem playtest.
- Habilidades autorizadas em 2026-11-13: Dash I (600 px/s, 0,16 s, cooldown 0,8 s, uma carga aérea) e planar pelo segundo toque de pulo (janela 0,35 s, até 1 s por salto, queda máxima 70 px/s). Sem dano/invulnerabilidade; manter colisões e regras de combate. Detalhes em ../docs/MOVEMENT_ABILITIES_042.md.
- Não adicionar fases, save points, loja, áreas secretas, multiplayer, monetização, sistemas extras ou mais ataques antes da validação da primeira fase.

## Fluxo de trabalho
1. Inspecione a arquitetura atual; prefira mudanças mínimas e progressivas. Refatore `main.gd` em componentes **somente quando reduzir risco** e sem alterar comportamento.
2. Trabalhe no **primeiro marco pendente** do `ROADMAP.md`; não implemente várias fases do roadmap na mesma solicitação sem autorização.
3. Execute verificações com Godot (`--headless --editor --quit`, `--headless --quit-after 120`) quando estiver disponível. Caso não esteja, registre *não testado*, nunca *aprovado*.
4. Se criar testes automatizados, deixe-os reprodutíveis com comando documentado. Para testes manuais, descreva passos e resultado observado.
5. Atualize `ROADMAP.md` e este pacote somente após testes. Descreva arquivo modificado, risco, validação, impedimento e próximo passo.
6. Preserve a licença e origem de assets. Não retire imagens de folhas de referência e assuma que são spritesheets perfeitos; confirme tamanhos e transparência.
7. Prefira configuração via constantes/recursos; evite números mágicos escondidos em métodos de gameplay.
8. Evite introduzir arquivos binários grandes, plugins ou dependências externas sem necessidade.
9. Nunca editar o ranking local como se fosse estado de gameplay; todo reinício deve criar tentativa nova.
10. Retenção autorizada em 2026-11-13: manter somente as duas últimas versões locais de builds. Após completar EXE/ZIP/APK, usar `tools/prune_builds.ps1 -Keep 2` para revisar e `-Apply` para limpar; nunca apagar fontes, referências, histórico Git ou armazenamento remoto como parte dessa limpeza.

## Definição de pronto por alteração
- Projeto abre sem erros; comportamento novo testado; regras preservadas; recurso documentado; testes e limitações declarados; checklist atualizado. Se não for possível executar Godot, alteração é **pendente de validação**.

## Formato do relatório ao fim de cada tarefa
1. **Implementado**: arquivos e comportamento.
2. **Testado**: comandos, resultados e testes manuais.
3. **Pendente / riscos**: itens que ainda precisam de teste.
4. **Roadmap**: checklist atualizado e próximo marco.

## Arte entregue
- Consulte `assets/references/README.md`; os PNGs/JPGs de referência agora acompanham o projeto.
- Preserve todos os originais em `assets/references/`. Gere recortes e sprites técnicos em pastas separadas.
- Não considere automaticamente implementada a integração visual apenas porque os PNGs estão disponíveis.
