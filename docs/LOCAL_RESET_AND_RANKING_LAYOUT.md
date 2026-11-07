# Exclusão local e painel global no topo

2026-11-07.

## Jogo

Menu RECORDES → ZERAR RANKING LOCAL abre confirmação pixel art com CANCELAR e SIM, APAGAR OS RECORDES. Cancelar recebe foco inicial; abrir/cancelar não altera o arquivo. Confirmar grava entries=[] e então limpa a memória. Se a gravação falhar, mantém os registros em memória e apresenta erro. A confirmação só executa enquanto seu diálogo está ativo; fechar/trocar tela revoga a ação pendente. Botão desabilitado quando o ranking já está vazio.

Não modifica o ranking global, token/sessão online, vida, cenouras, madeira, tentativa já registrada ou pausa. A exclusão local não pode ser desfeita. Dados reais do jogador não foram apagados durante o desenvolvimento.

APK 0.3.5 (código 5), game/builds/CraftBunny-Android-0.3.5.apk: 79.741.400 bytes, SHA256 A4582F7A33EA9DF76036E5C8A1FB903D52FAC30BFED046F18C1576531D785150. Assinatura v2/v3 verificada. Versão da interface vem de application/config/version; contrato do ranking mantém versão compatível 0.3.4, mesma fase e regras, sem migração SQL adicional.

## Site

Ranking global passa a primeira seção depois do cabeçalho. Painel minimalista pixel art com contorno reto, pequenos detalhes nos cantos, resumo compacto e fonte pixelada. Apresentação/arte do jogo abaixo do ranking; link da apresentação volta ao painel superior. Busca, filtros, paginação e API preservados.

## Testes

- tools/test_local_reset.gd: 15 checks em arquivo de QA isolado. Abrir, foco em cancelar, cancelamento, guarda contra chamada fora do diálogo, exclusão explícita, persistência/reload, botão desabilitado, preservação da tentativa/global e falha de gravação.
- tools/test_flow.gd: 16 checks passaram; smoke executado. Aviso antigo de recursos em uso ao encerrar o harness de fluxo continua.
- npm test: 18 testes API/SQL passaram; npm run build aprovado.
- Captura OpenGL da confirmação revisada: game/docs/qa_pixel_reset-local.png.
- Navegador: ranking como primeira seção, apresentação abaixo; revisão em janela normal e largura 390 px, sem overflow horizontal observado. docs/qa_ranking_top.png e docs/qa_ranking_top_mobile.png. Prévia local sem credenciais mostra estado de preparação, não é falha do site em produção.
- Exportação APK 0.3.5 concluída, manifesto código 5/nome 0.3.5 e internet conferidos. Configuração headless continua com avisos de cleanup do editor, sem impedir exportação.

Não realizado playtest físico Android. Nenhum recorde global foi apagado nem publicado por estes testes.
