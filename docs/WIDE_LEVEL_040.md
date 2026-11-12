# Fase ampla em três alturas — 0.4.0 — 2026-11-12

Implementação baseada no esboço do responsável. Continua sendo uma única fase, sem checkpoint nem gravação de progresso. A geometria principal agora é uma cena nativa editável, não uma geração refeita a cada partida.

## Estrutura e meta de pontuação

Comprimento horizontal 48.000 px, quatro vezes o anterior. Três percursos sobrepostos:

| Região | Chão | Cenouras no mapa | Madeiras | Inimigos |
|---|---|---:|---:|---|
| Floresta | Y=435, terra com grama e árvores ao fundo | 40 | 24 | 3 cobras e 4 guaxinins |
| Copa | Y=-285, galhos com céu/nuvens, sem árvores atrás | 70 | 40 | 6 aves acima dos galhos |
| Subsolo | Y=915, terra e fundo marrom texturizado | 30 | 16 | 9 cobras e 2 guaxinins |

São **140 cenouras disponíveis sem derrotar inimigos**, dentro do objetivo de 120–150. Drops: 12 cobras x1 + 6 guaxinins x3 + 6 aves x5 = **60**. Total máximo exato **200**.

A meta de aproximadamente 15 minutos se refere a explorar/coletar pelas três alturas, não a um limite de tempo ou duração mínima obrigatória. A caminhada contínua pelas três rotas demanda aproximadamente dez minutos à velocidade máxima; saltos, desvios, caixas e combate foram planejados para aproximar o percurso exploratório de 15 minutos. **Ainda requer playtest humano cronometrado**; um percurso direto até a casa pode ser mais rápido. Não há cronômetro que bloqueie a chegada.

## Acesso, caixas e retorno

O acesso à copa fica no extremo direito, com escada subindo da direita para a esquerda. São 14 plataformas: dez desníveis de 40 px e quatro de 80 px. O salto normal alcança cerca de 50 px; os quatro desníveis de 80 precisam de uma caixa de 42 px para reduzir a diferença restante a 38 px. Os testes construíram e saltaram fisicamente cada trecho. Custo mínimo nesse trajeto: **4 caixas / 12 madeiras**; há 24 madeiras na floresta antes da escada, além do material no subsolo.

Os trechos de galho têm vãos de 64 px. Floresta/subsolo também têm vãos curtos. Três acessos de retorno no subsolo têm 12 plataformas unidirecionais de 40 px de desnível cada, permitindo subir sem gastar caixas. As plataformas de retorno deixam o coelho atravessá-las de baixo para cima.

O limite de morte por queda foi deslocado para abaixo do subsolo. Descer da floresta até o piso inferior não dispara o grito nem mata o personagem. A chegada está na casa pixel art no subsolo à direita, em X=47.600. Não basta passar por esse X na floresta ou na copa.

## Ave de rapina

Mantidos 7 HP, 3 de dano e 5 cenouras. Após o mergulho, procura um apoio real evitando o centro do coelho, desce, pousa e permanece **0,5 segundo** em estado grounded. Nesse estado não inicia outro ataque e pode receber marteladas; receber dano não cancela imediatamente a janela de chão. Depois retorna à altura de voo. Se não encontrar apoio, uma saída por tempo evita travar caindo eternamente.

## Editar na Godot

Abra o projeto atual `CraftBunny/CraftBunny/game/project.godot` e depois `res://scenes/level_wide/fase_ampla.tscn`. Use a área 2D; selecione InicioJogador e pressione F para enquadrar o início.

```text
FaseAmpla
├── Fundo
├── Terrenos
│   ├── Floresta   (TileMapLayer: pintar/apagar)
│   └── Subsolo    (TileMapLayer: pintar/apagar)
├── Plataformas
│   ├── Galho...       (posição e size no Inspetor)
│   ├── EscadaAlta...  (posição, size e colisão)
│   └── Retorno...     (one_way ativado)
├── InicioJogador
├── Inimigos           (arrastar prévias de cobra/guaxinim/ave)
├── Itens              (arrastar cenouras/madeiras/corações)
└── Chegada
    └── CasaPixelArt
```

Ctrl+S salva as alterações. F5 abre o jogo normal; F6 pela cena ampla também encaminha ao menu do jogo, e NOVO JOGO usa essa cena salva. O runtime lê as posições e a geometria; não repinta o mapa sobre o arquivo. Preserve a escala 0,25 dos TileMaps (tiles visuais 64 px) e use plataformas sem rotação. Ao mudar substancialmente os limites do mundo, atualize também câmera/queda; ao adicionar/remover cenouras ou inimigos, recalcule o teto do ranking.

O exemplo inicial `scenes/editor_example/fase_exemplo.tscn` foi preservado, inclusive as edições locais existentes no exemplo e seu TileSet. A fase nova possui uma cópia independente do TileSet, para não ser alterada por futuras experiências naquele arquivo. `tools/create_wide_level.gd` é apenas ferramenta de autoria inicial e recusa sobrescrever uma cena existente.

## Ranking global e migração necessária

Nova versão de jogo/API: **0.4.0**, teto 200. Clientes anteriores continuam aceitos pelo contrato 0.3.4 e teto 139. Recordes e sessões históricas são preservados; o ranking público continua conjunto, com a versão de cada resultado já informada pela API.

No projeto Supabase conectado à Vercel, referência **ulxrndtgoslkjpmuibpj**, execute **todo** o arquivo `supabase/migrations/202611120003_wide_level_scores.sql`, de begin a commit. Ele atualiza constraints e RPCs sem apagar tabelas nem recordes, mantém o limite antigo e atualiza o cache PostgREST. Exige a migração inicial de ranking já aplicada; é independente das tabelas do download.

O servidor também precisa receber o commit desta versão pela Vercel. Antes da migração online, a versão 0.4.0 pode não conseguir abrir sessão global; o registro local continua funcionando. Após aplicar a migração, inicie uma tentativa nova para enviar ao global. Nenhuma chave nova é necessária; não copie credenciais no jogo.

## Validação e limites

- 28 checks em `game/tools/test_wide_level.gd`: totais exatos, distribuição por altura, câmera/queda, piso inferior seguro, quatro caixas construídas com custo correto, saltos físicos para os degraus, subida física completa de um retorno sem caixas e área de chegada.
- Seis checks em `game/tools/test_bird_ground.gd`: ataque/pouso, janela de 0,5 s, dano durante a janela, retorno ao voo e ausência de travamento.
- Regressões: 14 ave/martelo, nove construção, 24 pisão, 16 fluxo, 22 envio automático e 19 toque aprovados. Avisos de objetos/recursos no encerramento dos testes headless de pisão/fluxo/toque já conhecidos continuam registrados; não são declarados como execuções sem avisos.
- API/PostgreSQL: 34 testes aprovados, incluindo 200 aceito apenas na 0.4.0, 201 rejeitado em API e RPC, e 140 ainda rejeitado para a 0.3.4.
- Cliente Godot/API/PostgreSQL: dez checks aprovados com um resultado somente no banco temporário. Nenhuma pontuação fictícia publicada.
- Revisão OpenGL: capturas de floresta, copa, subsolo, escada e casa em `docs/qa_wide_*.png`.
- Corrigida indentação inconsistente em scripts para evitar que salvar pelo editor voltasse a produzir erro de parser. Scripts de build agora interrompem em SCRIPT ERROR/Parse Error, mesmo quando a Godot retorna código zero.

Ainda pendentes: percurso humano completo, tempo real próximo de 15 minutos, exploração/retorno de todos os vãos e desempenho/conforto em Android físico. A validação automatizada de pontos importantes não é tratada como prova de ausência de qualquer softlock possível.

Artes novas, prompts e origem integrada em [game/assets/production/v3/README.md](../game/assets/production/v3/README.md); casa e galho foram salvos separadamente e originais preservados.

## Builds e download controlado

- Windows: `game/builds/windows-0.4.0/CraftBunny-0.4.0.exe`, versão 0.4.0.0, 137.033.848 bytes; SHA256 `1ff4f47f53cc0fc57c0d1c2b47a1621a4bc455762a682ee1d617eed93a626594`. Smoke OpenGL fora do editor aprovado sem erros no log. ZIP com licenças em `game/builds/CraftBunny-Windows-0.4.0.zip`.
- Android: `game/builds/CraftBunny-Android-0.4.0.apk`, código 8, 80.986.248 bytes; SHA256 `d9fc3bb499fa5e51f3fc2629b0e0dccde114a1ec6618e4a807fa7790aeeb3265`. Manifesto 0.4.0-android-test, ARM32/64, INTERNET e assinatura v2/v3 conferidos. Certificado igual ao APK 0.3.7. Execução física ainda pendente.

APK enviado ao Blob privado, tamanho confirmado, sem sobrescrever builds anteriores. Para o botão BAIXAR APK selecionar a versão nova, atualizar Production na Vercel e fazer redeploy:

```dotenv
APK_BLOB_PATH=releases/0.4.0/d9fc3bb499fa/CraftBunny-Android-0.4.0.apk
APK_DOWNLOAD_VERSION=0.4.0
APK_DOWNLOAD_SHA256=d9fc3bb499fa5e51f3fc2629b0e0dccde114a1ec6618e4a807fa7790aeeb3265
```

Manter o segredo do Authenticator e demais credenciais. Upload do arquivo não altera as variáveis automaticamente. A migração SQL adicional e a seleção do download em produção permanecem ações de ativação do responsável; não são declaradas como concluídas online.
