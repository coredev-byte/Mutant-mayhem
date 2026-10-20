# HUD da referência — revisão 4
Data: 2026-10-19

## Estado real
O layout foi aplicado no projeto conectado CAOS MUTANTE (place 129621048489588), em Edit, com backup do HUD anterior em ServerStorage.MM_PreNeonUI_Backup.HUDController_PreReference.
O Studio foi devolvido ao viewport padrão e saiu de Play.
Os arquivos locais estão salvos. Não foi confirmado um novo salvamento nativo .rbxl ou publicação na nuvem nesta revisão.
A fidelidade visual NÃO está concluída: o atlas ilustrado foi gerado, mas sua importação no Roblox falhou. A UI em execução usa os ícones vetoriais de reserva. O cenário 3D da referência não foi reconstruído nesta alteração.

## Implementado
- Composição desktop baseada em 1672×941, com barra de recursos, Coletar, status, seis botões à esquerda, cinco à direita, resumo da base e ação do primeiro pet.
- Painéis azul-escuro, gradientes, bordas cyan/violeta, badges condicionados ao estado real e animação reduzida conforme configuração.
- Dados reais: moedas, renda, base, número de pets e evento. Gemas e recurso de mutação exibem “—”, pois o servidor ainda não fornece essas moedas.
- Colocar primeiro pet, Coletar e navegação conectados ao backend existente.
- Adaptação de celular; área inferior livre para controles nativos em retrato; trilhos laterais roláveis em paisagem.
- HUDAtlas.luau preparado para um atlas 4×4, com recorte proporcional independente da resolução importada.

## Validação realizada
- Desktop: viewport 1919×1079. Sem TextLabels ultrapassando a largura de seus próprios retângulos na captura final.
- Telefone retrato: 401×778, captura após afastar a ação inferior dos controles de movimento/pulo.
- Telefone paisagem: 750×381, verificação visual e de largura de texto; posteriormente foi reduzida a altura dos trilhos para reservar os controles inferiores. Esse último ajuste específico de altura ainda não teve nova captura em paisagem.
- Primeiro pet: clique real mudou o CTA para Gerenciar meus pets e renda para +1.0/s.
- Coletar: clique real aumentou moedas de 100 para 120.
- Pets: clique real abriu o menu e ocultou HUD.
- Uma única raiz MutantMayhemUI presente.
- Sem erros de scripts MM no console final. Avisos FoundationProvider pertencem ao CorePackages do Roblox.
- Gamepads físicos, atlas carregado, publicação e persistência de produção não foram validados nesta revisão.
- ScreenOrientation Sensor; ScreenGui CoreUISafeInsets, IgnoreGuiInset false. HUD aplica compensação vertical para alinhar a composição com o viewport.

## Atlas ilustrado: etapa pendente
Arquivo: assets/hud-icons-v4.png (1254×1254 RGBA, 1.991.870 bytes).
Original preservado: C:/Users/Flowz/.codex/generated_images/01a15021-ceac-7012-a3b7-9f9e9d06e675/exec-4a353f2e-4944-4c9e-866a-526abb8ce93f.png
Referência: C:/Users/Flowz/Downloads/Laboratório Neon_ Hub de Mutantes.png

Brief do prompt usado: transformar a referência em um atlas de ícones de produção transparente, grade 4×4, sem texto ou botões, com ícones cartoon 3D arredondados, brilho neon cyan/violeta, contornos e reflexos glossy. Ordem: loja, gato cyan, DNA, frasco; estrela, mapa, presente, calendário; portal, amigos, engrenagem, moeda dourada; gema, orbe verde de mutação, gráfico de renda, pata. Foi solicitado 1024×1024; o arquivo retornado mede 1254×1254. O código usa coordenadas proporcionais.

Importação tentada pelo conector upload_image via servidor HTTP local. Retorno: “Unable to read file at path”. Rede foi autorizada, mas a verificação local continuou retornando EACCES. A alternativa pela interface do Studio falhou com “SendInput sent 0 of 1 events; GetLastError=87”. Nenhum ID fictício foi inserido.

Para concluir:
1. Importar o PNG como imagem no Roblox, no proprietário correto da experiência.
2. Copiar o ID de imagem aprovado.
3. Preencher Image="rbxassetid://ID_REAL" em ReplicatedStorage.MM.Shared.UI.HUDAtlas e no arquivo src/Shared/UI/HUDAtlas.luau.
4. Reiniciar Play e confirmar visualmente os 16 recortes. Caso a moderação ainda esteja pendente, aguardar o carregamento antes de marcar a fidelidade como concluída.

Documentação da renderização de imagens: https://create.roblox.com/docs/reference/engine/classes/ImageLabel
