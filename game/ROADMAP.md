# ROADMAP — Craft Bunny v1.0

**Regra de uso:** `[x]` = testado/verificado no projeto, `[ ]` = pendente. Recursos já codificados no protótipo mas **não testados** continuam pendentes. **Prioridade máxima:** estabilizar o build antes de adicionar assets ou efeitos.

## M0 — Auditoria e inicialização (bloqueante)
- [ ] Importar projeto em Godot 4.3+ sem erros de parser.
- [ ] Abrir `main.tscn`; entrar em Novo Jogo e conseguir mover o personagem.
- [ ] Revisar scripts atuais e abrir issues para bugs reais; não reescrever o projeto por conveniência.
- [ ] Rodar importação headless, smoke test e registrar saída (se Godot instalada).
- [ ] Garantir que menu, derrota e reinício não gerem exceções.
**Pronto quando:** F5 abre o projeto e uma partida pode começar, terminar e reiniciar sem erro crítico.

## M1 — Movimento e câmera
- [ ] Validar A/D/setas, aceleração, atrito e colisões.
- [ ] Confirmar pulo base ~1 altura do coelho; não tunar antes do teste.
- [ ] Verificar coyote time de 0,12 s e jump buffer de 0,12 s.
- [ ] Corrigir salto de altura variável, clipping e aterrissagem nas bordas.
- [ ] Câmera suavizada, com limites horizontais e verticais; parallax sem tremor.
- [ ] Invulnerabilidade de 1 s, indicação visual e knockback.
**Pronto quando:** personagem atravessa sequência de teste sem bugs de física e sem sair dos limites de câmera.

## M2 — Combate e inimigos
- [ ] Cobra: 2 HP, 1 dano, 1 cenoura; patrulha + bote + recuperação.
- [ ] Guaxinim: 5 HP, 2 danos, 3 cenouras; patrulha + perseguição + investida.
- [ ] Ave: 7 HP, 3 danos, 5 cenouras; voo + telegraph + mergulho + recuperação.
- [ ] Martelo: 1 HP por acerto, hitbox 0,12 s, cooldown 0,42 s, 1 acerto por alvo/golpe.
- [ ] Verificar frames de invulnerabilidade e que danos simultâneos não atravessam proteção.
- [ ] Testar mortes, despawn/drops, colisão, knockback e ausência de dano depois da morte.
**Pronto quando:** todos os três inimigos podem ser derrotados e seus ataques funcionam como especificado.

## M3 — Inventário, coleta e construção
- [ ] HUD com 3 corações; coração recupera apenas HP faltante.
- [ ] Madeira sem limite (nova regra solicitada pelo usuário); HUD atualiza em toda coleta.
- [ ] Construir caixa custa exatamente 3 madeiras, não funciona sem recursos.
- [ ] Caixa sólida de 2 HP; martelo do coelho destrói; inimigo não destrói.
- [ ] Impedir caixas sobrepostas, dentro do coelho ou em posições inválidas.
- [ ] Cenouras flutuam e são coletadas por contato; drops exatos 1/3/5.
- [ ] Testar coletáveis nas bordas, sobre/embaixo de plataformas e ao sair da câmera.
**Pronto quando:** inventário e pontuação nunca divergem do que o jogador realmente coletou/gastou.

## M4 — Construir e revisar o mapa único
- [ ] Implementar os cinco trechos descritos em README (uma única fase contínua).
- [ ] Posicionar chão, buracos, plataformas e obstáculos utilizando dados editáveis.
- [ ] Adicionar aumento progressivo de inimigos e misturar padrões somente no fim.
- [ ] Garantir pulo/caixas suficientes; nenhum bloqueio impossível ou softlock.
- [ ] Implementar área de chegada na **casa do coelhinho** (não apenas coordenada X invisível).
- [ ] Remover áreas secretas, segundo nível e checkpoints do escopo.
- [ ] Validar câmera/parallax até o fim dos ~12.000 px.
**Pronto quando:** completar a fase inteira é possível sem comandos de depuração, com dificuldade progressiva e chegada clara.

## M5 — Arte e animações
- [ ] Catalogar imagens de referência do usuário (coelho sem roupas, com lenço gasto e bolsa).
- [ ] Extrair/preparar sprites reais em PNG transparente, padronizar dimensões e pivôs.
- [ ] `AnimatedSprite2D`: idle, andar, correr, saltar, cair, pousar, dano, morte, construir, martelar.
- [ ] Criar e integrar animações essenciais dos três inimigos (idle, patrulha, ataque, dano, morte).
- [ ] Integrar tileset da floresta e props (quando arquivos de produção estiverem disponíveis).
- [ ] Aplicar filtro nearest, pixel snapping coerente e testar escala sem borrões.
- [ ] Substituir HUD e menus provisórios por visual da paleta madeira/folhagem/laranja.
**Pronto quando:** nenhuma mecânica fica invisível ou dependente de placeholder obrigatório e as animações correspondem às hitboxes.

## M6 — Música, SFX, opções e ranking
- [ ] Importar efeitos Pixabay selecionados e catalogar licenças/fontes.
- [ ] Implementar SFX de pulo, martelo, dano, coleta, construção, inimigo e chegada.
- [ ] Integrar música de fundo em bus `Music`, efeitos em `SFX`, master em `Master`.
- [ ] Validar persistência de volume, muting e remapeamento; restaurar padrão.
- [ ] Validar TOP 10 local após derrota ou vitória, nome A–Z com 3 letras.
- [ ] Proteger ranking de registros duplicados, dados inválidos e corrupção de arquivo.
- [ ] Verificar que o jogo **não grava** progresso de fase.
**Pronto quando:** menu, controles, volume e recordes funcionam após fechar e reabrir o jogo.

## M7 — QA, ajuste e build v1.0
- [ ] Rodar todos os cenários de `docs/TEST_PLAN.md` e registrar resultados.
- [ ] Corrigir travamentos, softlocks, cenouras inacessíveis e bugs de colisão.
- [ ] Balancear tempos/altura somente com evidências de playtest.
- [ ] Revisar visibilidade de ataques da ave (3 de dano) e clareza dos feedbacks.
- [x] Exportar Windows e executar o build gerado fora do editor (0.3.5, smoke OpenGL de 120 frames; playtest completo pendente).
- [ ] Produzir changelog da v1.0 e inventário de assets/licenças.
- [ ] Congelar escopo; avaliar segunda fase **apenas depois da validação da v1.0**.
**Pronto quando:** jogador completa ou perde a fase, registra ranking confiável e reinicia sem erros em build exportada.

## Pós-v1.0 — fora de escopo
- [ ] Avaliar segunda fase após feedback real.
- [ ] Novas animações e movimentos de batalha, se necessários.
- [ ] Segredos, novos objetos construíveis, novos inimigos, desafios extras.

## Registro de execução (Codex deve preencher a cada sessão)

Envio automático (2026-11-10, escopo autorizado): recordes registrados no TOP 10 local consultam o TOP 100 global e são enviados automaticamente se elegíveis, sem bloquear o salvamento local. Empate no corte não entra; consulta falha, restart e envios duplicados protegidos. Menu global substituído por botão que abre o site. Jogo/presets 0.3.6; API permanece compatível com 0.3.4, sem nova migração. 21 checks novos, 15 de exclusão, 16 de fluxo e dez de integração Godot/API/PostgreSQL passaram; importação/smoke passaram. Aviso preexistente de encerramento do teste de fluxo documentado. QA manual dos novos recursos pendente; ver ../docs/AUTO_GLOBAL_RANKING.md.

Windows atualizado (2026-11-07): preset release x86_64 com PCK embutido e script reproduzível; EXE 0.3.5.0 gerado a partir do projeto atual, com ranking global e confirmação para zerar ranking local. A pasta antiga permanece preservada. Importação/smoke headless e smoke OpenGL do EXE passaram; 15 checks de exclusão local, 16 de fluxo e dez de integração Godot/API/PostgreSQL passaram no projeto. Aviso de recursos no encerramento do teste de fluxo e timeout ao tentar rodar script no release documentados. Playtest completo no Windows pendente; M7 em andamento. Ver docs/WINDOWS_BUILD.md.

Exclusão local/site (2026-11-07): botão ZERAR RANKING LOCAL com confirmação e foco em cancelar, exclusão persistente, guarda de estado e tratamento de falha. Ranking global/tentativa preservados. Site agora exibe painel minimalista pixel art do ranking primeiro e apresentação depois. 15 checks novos, 16 de fluxo, 18 API/SQL e build web passaram; revisão OpenGL/browser móvel executada. APK 0.3.5 assinado. Playtest físico pendente. Ver ../docs/LOCAL_RESET_AND_RANKING_LAYOUT.md.

Ativação do cliente global (2026-11-07): corrigida URL vazia; configurado https://craftbunny-web.vercel.app e exibida versão 0.3.4 no título. Consulta e abertura de uma sessão reais passaram, sem publicar scores de teste. Dez checks de integração local e 16 de fluxo passaram; importação/smoke e título OpenGL revisados. APK código 4 exportado, assinatura v2/v3, mesma chave do 0.3.3, INTERNET e URL interna conferidos. Build restaura preset sanitizado. Playtest em aparelho e envio público real pendentes. Ver docs/ANDROID_BUILD.md e ../docs/GLOBAL_RANKING.md.

Ranking global (2026-11-07, escopo adicional autorizado): site pixel art, API Vercel e migração Supabase; cliente opcional com confirmação, ranking local independente. 18 testes API/SQL, dez verificações Godot/HTTP/PostgreSQL e 16 checks de fluxo local passaram; build web e QA de filtros/paginação/móvel executados. Ativação online e APK com URL real pendentes. Ver ../docs/GLOBAL_RANKING.md.

Repositório (2026-11-07): cópia organizada em game/, com web/ e supabase/ reservados ao ranking global. Fontes/assets preservados; presets sanitizados; build Android aceita engine externa. Importação/smoke e 50 verificações de fluxo/feedback passaram; 21 arquivos de referência conferidos por hash. Detalhes em ../docs/REPOSITORY_SETUP.md. Nenhuma mudança de gameplay ou integração online nesta etapa.

Regressão de fluxo após menus pixel art: tools/test_flow.gd passou em 16 checks (pausa, recordes, persistência de controles, reinício e vitória), usando arquivos de QA isolados.

Menus/feedback (2026-11-06): recriados título e painel de madeira pixel art, fonte Silkscreen com licença, tema aplicado às opções/teclas/pausa/resultados/ranking e controles de toque. Três inimigos agora têm balão ! na detecção, pose hurt prioritária, clarão, faíscas e barra de vida/dano temporários. Regras de combate preservadas. Testes: 34 checks novos, dez título/HUD, dez toque e 24 pisão passaram; importação/smoke e quatro capturas OpenGL revisados. APK 0.3.3-android-test exportado, manifesto e assinatura v2/v3 conferidos. Ver assets/production/v2/pixel_menus_feedback.md. Playtest em aparelho e QA geral pendentes.

Escala/ataque (2026-11-06): câmera ampliada em 25%; nova arte bunny_attack_12.png em grade 4x3, martelo ampliado, pivôs de pés por quadro e alcance 32x26. Mantidos dano/cooldown/janela. Teste confirmou 12 quadros visíveis/um evento; 14 checks ave/martelo e dez de toque passaram. Importação, smoke e captura OpenGL revisados. APK 0.3.2-android-test exportado/assinatura verificada. Ver assets/production/v2/bunny_attack_12.md. Playtest do campo de visão menor e Android físico pendentes; QA geral continua aberto.

Android APK (2026-11-06, escopo adicional autorizado): controles multitoque, pausa/segundo plano/Voltar, paisagem e proporção preservada; ícone e preset Android, cache de atlas. Ferramentas locais JDK17/SDK/templates configuradas. APK de teste ARM32/64 exportado, assinatura v2/v3 e manifesto verificados, 72,27 MiB. Dez checks de toque passaram; smoke e captura OpenGL revisados. Nenhum aparelho ADB conectado: execução física pendente. Ver docs/ANDROID_BUILD.md. Isso não conclui QA geral nem exportação Windows.

Corações/nuvens/título (2026-11-06): gerados hearts.png e clouds.png; integrado coração coletável e cheio/vazio do HUD, nuvens em parallax distante e cópia da arte oficial como tela de título com botões funcionais. Dez checks passaram; importação, smoke e duas capturas OpenGL revisadas. Detalhes em assets/production/v2/hearts_clouds_title.md. Outras proporções de janela e percurso completo pendentes.

Ave/martelo (2026-11-06): corrigida condição de mergulho que mantinha ave acima do jogador; mira ao finalizar aviso, recuperação com subida/afastamento e saída por colisão. Martelada reduzida a 16x26 px e hurtboxes reais dos inimigos. tools/test_bird_hammer.gd: 12 checks passaram; teste de oito quadros/um golpe passou; importação/smoke executados. Detalhes em docs/BIRD_HAMMER_VALIDATION.md. Playtest próximo de obstáculos pendente.

Construção/empilhamento (2026-11-06): corrigida altura fixa de colocação; busca apoio no terreno, rochas, plataformas e caixas, alinha pilhas e evita sobreposição inclusive no mesmo tick. HUD passa a TÁBUAS; erro informa inventário. tools/test_build.gd: nove checks passaram; importação e smoke test executados. Detalhes em docs/BUILD_VALIDATION.md. Playtest de pilhas e movimento pendente.

Madeira/pisão/poços (2026-11-06): nova regra sem limite de madeira; pisão de 1 HP nos três inimigos, impulso e um quique no chão, oito frames e impact-thud. Novos PNGs de caixas intacta/rachada e poço, margem distante sustenta árvores. Teste tools/test_stomp.gd: 24 checks passaram; ataque passou; smoke e captura OpenGL revisada. Importação reporta arquivo não utilizado hammer-atack1.mp3 inválido. Detalhes em assets/production/v2/stomp_crate_pit.md. Playtest de combate móvel e escuta pendentes.

HUD pixel art e morte exclusiva (2026-11-06): criados hud_wood.png e bunny_death_8.png; quatro módulos de HUD com corações em pixels e ícones de itens. Morte em oito frames/0,80 s, olhos X e pose final mantida. Queda toca funny-scream antes de game-over e para o tema; dano não usa grito. Importação/smoke e captura OpenGL executados. Teste de morte: 10 verificações passaram; regressão de ataque/fluxo executada. Ver assets/production/v2/hud_death.md. Escuta e playtest de mortes aéreas pendentes.

Árvores e coletáveis pixel art (2026-11-06): criados forest_props.png e collectibles.png; substituídos árvores/círculos geométricos, decoração pequena desproporcional e placeholders de cenoura/madeira. Escala e regiões no helper prop_art.gd, árvores em parallax, matinhos baixos e Sprite2D nos itens. Importação, captura OpenGL revisada e smoke test executados; pés continuam em y435. Ver assets/production/v2/environment_items.md. Playtest ao longo da fase pendente; M5 em andamento.

Ataque de oito quadros (2026-11-06): criado bunny_attack_8.png exclusivo, grade 4x2 transparente, integrado ao jogador. Duração visual independente de 0,40 s para evitar corte na janela de dano. Grade parametrizada no leitor de atlas. Teste de ataque confirmou oito frames apresentados e um sinal de golpe; importação e smoke test executados. Detalhes/limitações em assets/production/v2/bunny_attack_8.md; playtest visual pendente.

Terreno contínuo e apoio (2026-11-06): novo forest_ground_v2.png substitui o recorte com margens no TileSet. Emendas espelhadas, arte opaca para chão/plataformas e terra em blocos. Corrigidos alpha bounds dos sprites e altura inicial dos personagens terrestres. Importação e smoke test executados; captura OpenGL revisada com pés em y435, igual ao chão. Ver docs/qa_ground_v2.png e catálogo de tiles. Percurso completo e todos os pousos ainda pendentes.

Personagens v2 e morte (2026-11-06): gerados e integrados novos atlas transparentes, na ordem coelho/cobra/guaxinim/ave, em assets/production/v2. Escala proporcional e alinhamento por alpha em scripts/sprite_atlas.gd. Sprites antigos do coelho movidos para .retired_sprites/bunny-v1 para recuperação; shader antigo removido. Tema para antes do som de morte. Importação e smoke test sem erros; testes de áudio 15/15 e fluxo 16/16 passaram, com aviso de recursos em uso no encerramento dos harnesses. Revisão visual em gameplay e ciclos exclusivos de dano/morte/construção do coelho pendentes. M5 permanece em andamento.

QA de ranking/controles/fluxo (2026-11-06): corrigida leitura de dados inválidos, duplicação na releitura, trava por tentativa e rollback em memória se salvar falhar. Remapeamento ignora tipos inválidos e restaura menu após cancelamento. Teste reproduzível tools/test_flow.gd: 16 checks passaram sem avisos. Detalhes e limites em docs/FLOW_VALIDATION.md. M6/M7 permanecem em andamento; próximo item: revisar percurso completo e preparar exportação Windows.

Áudio e preferências (2026-11-06): corrigidos volumes iniciais, leitura sem regravação, mute em zero, tratamento de valores inválidos e botão de restaurar volumes. Teste reproduzível em `tools/test_audio.gd`: 13 checks passaram. Importação e smoke test de 120 frames concluídos sem erros. Harness específico reporta recursos em uso ao encerrar; escuta e emenda do loop pendentes. Detalhes em `docs/AUDIO_VALIDATION.md`. Próximo item: QA de ranking, controles e fluxo completo.

Tema de interface (2026-11-06): aplicado Theme reutilizável ao HUD, botões, menus, sliders e campo de nome, com paleta madeira/folhagem/laranja da referência oficial. Adicionada área de rolagem aos menus e contraste nas mensagens. Arquivos: `scripts/ui_theme.gd`, `scripts/main.gd`, catálogo UI. Importação e smoke test de 120 frames no Godot 4.7.2 sem erros. Revisão visual de todos os menus pendente; M5 ainda em andamento. Próxima etapa: validação de áudio, volumes e persistência.

Integração de terreno (2026-11-06): substituído o sprite invisível por TileSet/TileMapLayer visível, com recortes de grama, rochas, plataformas, árvores e arbustos em `scripts/forest_visuals.gd`. Colisões físicas existentes preservadas e decoração sem colisão. Importação e smoke test de 120 frames com Godot 4.7.2 concluídos sem erros. Revisão visual de emendas e props pendente; M5 em andamento. Próximo item: identidade visual do HUD e menus.

Sessão de integração dos inimigos (2026-11-06): AtlasTexture por estado para cobra, guaxinim e ave; transparência preliminar por shader; aviso de investida preservado; animação de morte com colisão desativada e drop único. Importação Godot 4.7.2 e smoke test de 120 frames executados com acesso autorizado aos caches; smoke test completo sem erros. Revisão visual dos recortes e exercício de todos os estados ainda pendentes. M5 permanece em andamento; próximo item: TileSet e props.

| Data | Marco | Mudança | Testes executados | Limitações / próximo passo |
|---|---|---|---|---|
| 2026-11-06 | Preparação | Roadmap, regras e base v0.3 reunidos | Inspeção estática do ZIP | Godot não disponível neste ambiente; iniciar por M0 |
| 2026-11-06 | M0 — auditoria | Corrigida inferência de tipo em `scripts/main.gd`, inferência em `scripts/enemy.gd` e sintaxe do desenho da ave; regras de gameplay preservadas | Godot 4.7.2: `--headless --path <absoluto> --editor --quit` e `--headless --path <absoluto> --quit-after 120`; sem erros de parser/runtime reportados após correções | Sandbox não permite criar `.godot`, `user://` ou logs em `AppData`; F5/manual, menu, derrota e reinício ainda pendentes. Não iniciar M5 antes de validar fora do sandbox |
| 2026-11-06 | M1 — correção pontual | Ajustado o impulso vertical do coelho de `-311` para `-320` para superar a caixa sólida de 42 px; regras de caixa, custo, HP e colisão preservadas | Smoke test headless repetido após alteração; sem novos erros de parser/runtime | Teste manual de salto sobre caixa ainda necessário fora do sandbox; validar também coyote time e altura percebida |
| 2026-11-06 | M1–M3 — estabilização | Revisão do movimento, câmera, combate, coleta e construção; corrigido o dano repetido da mesma investida inimiga com guarda de um acerto por ataque | Godot 4.7.2: importação headless e smoke test após a correção; sem erros de parser/runtime | Validação manual pendente para T07–T25; não marcar marcos como concluídos sem confirmar controles, colisões, drops, caixa e HUD em execução |
| 2026-11-06 | M1–M3 — feedback de playtest | Ajustado salto curto para ainda limpar caixas; adicionado dano por contato com cooldown de 0,6 s por inimigo; mantidos danos cobra/guaxinim/ave em 1/2/3 e bloqueio de acerto duplicado | Godot 4.7.2: importação headless e smoke test; sem erros de parser/runtime | Confirmar manualmente salto, toque no inimigo e diferença entre dano de contato/investida; dano 2/3 do guaxinim/ave segue regra do README |
| 2026-11-06 | M1 — correção de acessibilidade da caixa | Aumentada a margem do salto para `-340/-335` e aproximada a caixa de 53 para 40 px do coelho, evitando que o arco bata na lateral antes de alcançar o topo | Testes headless de importação e smoke test executados após a alteração | Repetir o teste manual do vídeo; confirmar que a caixa não sobrepõe o corpo do coelho |
| 2026-11-06 | M4 — passagem do primeiro obstáculo | Rebaixados rochas e plataformas geradas para manter cada salto dentro do alcance do pulo/caixa, sem remover a progressão vertical | Importação headless e smoke test executados após a alteração | Confirmar manualmente o trecho caixa → rocha → plataforma; M5 visual permanece pendente |
| 2026-11-06 | M5 — preparação de arte | Criada estrutura `assets/production/` e catálogo por categoria, preservando as concept sheets originais e bloqueando uso direto de folhas compostas no jogo | Inspeção visual da folha oficial do coelho; sem integração de runtime nesta etapa | Recortes RGBA, SpriteFrames e TileSet ainda precisam de limpeza/revisão antes da integração |
| 2026-11-06 | M5 — recortes preliminares | Gerados recortes técnicos separados por estado do coelho em `assets/production/characters/bunny/draft/`; referências originais preservadas | Script de preparação executado; arquivos PNG criados para revisão visual | Recortes ainda não são produção: fundo/sombras podem exigir limpeza manual; não integrar antes da revisão |
| 2026-11-06 | M1–M4 — validação manual | Usuário confirmou movimento, pulo, câmera, dano, invulnerabilidade, coleta, construção, destruição de caixas, rochas, plataformas, buracos e chegada; reduzida altura das paredes cinzas para permitir retorno sem caixa | Validação manual informada pelo usuário; importação headless e smoke test após ajuste | Repetir o percurso completo após a mudança e confirmar retorno em todos os trechos |
| 2026-11-06 | M5 — limpeza preliminar | Gerada segunda cópia dos frames do coelho com remoção automática conservadora do fundo conectado às bordas; `draft/` preservado | Script de limpeza executado e amostra visual revisada | Ainda requer revisão artística, alinhamento de pivôs e criação de `SpriteFrames`; não integrar automaticamente |
| 2026-11-06 | M5 — spritesheet consolidado | Criado `bunny_spritesheet_clean.png` em grade regular 7x9, usando os frames limpos e preservando todas as referências anteriores | Script de composição executado; PNG RGBA gerado | Ainda falta criar `SpriteFrames` e integrar ao jogador após teste visual no Godot |
| 2026-11-06 | M6 — áudio inicial | Integrados tema, coleta, morte e ataque a `Music`/`SFX`; arquivos mantidos em `music/` | Importação headless e smoke test após integração | Confirmar volumes no jogo e registrar origem/licença dos MP3 antes da distribuição |
| 2026-11-06 | M5 — integração visual inicial | Integrado `bunny_spritesheet_clean.png` via `AnimatedSprite2D` com estados idle, walk, run, jump, land, hurt, death, craft e attack; placeholder permanece como fallback | Importação headless e smoke test após integração | Teste visual manual necessário para escala, pivô, flip e sincronização com hitbox |
| 2026-11-06 | M5 — catálogo de inimigos e tiles | Inspecionadas visualmente as folhas oficiais; tiles RGBA aprovados como fontes de produção e folha de inimigos mantida sem integração direta por ser composta | Inspeção visual das referências; testes headless não necessários para arquivos não integrados | Próximo recorte técnico: estados individuais dos três inimigos e TileSet Godot com colisões revisadas |
