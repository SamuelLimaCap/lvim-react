-- Visual dos .md: cores só nas linhas visíveis, sem varrer o arquivo a cada tecla.
local M = {}

local ns = vim.api.nvim_create_namespace("lvimreact_markdown")
local blocos = {}
local cobol_palavras, cobol_constantes
local limite = { ligado = false, colunas = 100 }
local ns_titulos = vim.api.nvim_create_namespace("lvimreact_titulos")

local ESTADOS = {
  { "%f[%w]A CONFIRMAR%f[%W]", "MdAlerta" },
  { "%f[%w]PENDENTE%f[%W]", "MdAlerta" },
  { "%f[%w]RESPONDIDA%f[%W]", "MdOk" },
  { "%f[%w]MANTER%f[%W]", "MdOk" },
  { "%f[%w]MUDAR%f[%W]", "MdMuda" },
  { "%f[%w]NAO MIGRAR%f[%W]", "MdFora" },
  { "%f[%w]a calcular%f[%W]", "MdCalcular" },
}
local CAMPOS = { Dado = "MdDado", Quando = "MdQuando", ["Então"] = "MdEntao" }
local TAGS = { front = "MdTagFront", back = "MdTagBack", report = "MdTagReport" }
local CAIXA = "\226[\148\149][\128-\191]" -- caracteres de desenho de caixa (U+2500 a U+257F)
local SETAS = { "\226\134[\144-\191]", "\226\135[\128-\191]", "\226\148\128>", "%->", "=>" }
local CORES_BOTAO = {
  verde = "MdBotaoVerde",
  vermelho = "MdBotaoVermelho",
  azul = "MdBotaoAzul",
  laranja = "MdBotaoLaranja",
  cinza = "MdBotaoCinza",
}
local ICONE = "[\238\239][\128-\191][\128-\191]" -- área privada do Unicode, onde ficam os ícones da Nerd Font
local TECLAS = { "^S?F%d+/S?F%d+", "^S?F%d+", "^ESC%f[%W]", "^PgUp/PgDn", "^PgUp", "^PgDn" }

local function marcar(buf, linha, ini, fim, grupo, prioridade)
  vim.api.nvim_buf_set_extmark(buf, ns, linha, ini, {
    end_col = fim,
    hl_group = grupo,
    ephemeral = true,
    priority = prioridade or 200,
  })
end

local function pintar_todos(buf, linha, texto, padrao, grupo, prioridade)
  local pos = 1
  while true do
    local ini, fim = texto:find(padrao, pos)
    if not ini then
      return
    end
    marcar(buf, linha, ini - 1, fim, grupo, prioridade)
    pos = fim + 1
  end
end

-- O cache só é refeito quando o buffer muda e a tela é redesenhada.
local function mapear(buf)
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  local cache = blocos[buf]
  if cache and cache.tick == tick then
    return cache.linhas, cache.botoes
  end
  local linhas, botoes, aberto, linguagem = {}, {}, nil, nil
  for i, texto in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local cerca, info = texto:match("^%s*(```+)%s*(%S*)")
    if cerca then
      linhas[i - 1] = "cerca"
      if not aberto then
        aberto, linguagem = cerca, info:lower()
      elseif #cerca >= #aberto and info == "" then
        aberto = nil
      end
    elseif aberto then
      linhas[i - 1] = linguagem
      local cor, nomes = texto:match("^%s*@(%a+)%s+(.*)$")
      if linguagem == "tela" and cor and CORES_BOTAO[cor] then
        for nome in nomes:gmatch("[^,]+") do
          botoes[vim.trim(nome)] = CORES_BOTAO[cor]
        end
      end
    end
  end
  blocos[buf] = { tick = tick, linhas = linhas, botoes = botoes }
  return linhas, botoes
end

local function pintar_texto(buf, linha, texto)
  for _, estado in ipairs(ESTADOS) do
    pintar_todos(buf, linha, texto, estado[1], estado[2])
  end
  local rotulo = texto:match("^%s*%- %*%*([^%*:]+):?%*%*")
  if rotulo and CAMPOS[rotulo] then
    local ini = texto:find(rotulo, 1, true)
    marcar(buf, linha, ini - 1, ini - 1 + #rotulo, CAMPOS[rotulo])
  end
  if not texto:match("^%s*%- %[.%]") then
    return
  end
  local numero = texto:match("^%s*%- %[.%]%s+(%d[%d%.]*)%s")
  if numero then
    local ini = texto:find(numero, 1, true)
    marcar(buf, linha, ini - 1, ini - 1 + #numero, "MdNumero")
  end
  pintar_todos(buf, linha, texto, "%[%d+h%d*m?%]", "MdTempo")
  pintar_todos(buf, linha, texto, "%[%d+m%]", "MdTempo")
  local pos = 1
  while true do
    local ini, fim, nome = texto:find("#(%a[%w_%-]*)#", pos)
    if not ini then
      return
    end
    marcar(buf, linha, ini - 1, fim, TAGS[nome] or "MdTag")
    pos = fim + 1
  end
end

local function primeira_seta(texto, inicio, fim)
  local a, b
  for _, padrao in ipairs(SETAS) do
    local i, f = texto:find(padrao, inicio)
    if i and i <= fim and (not a or i < a) then
      a, b = i, f
    end
  end
  return a, b
end

local function pintar_fluxo(buf, linha, texto)
  local fim_util = #texto
  local ref = texto:find("[%w_]+%.%u%u+:%d")
  if ref then
    marcar(buf, linha, ref - 1, #texto, "MdFluxoRef", 210)
    fim_util = ref - 1
  end
  pintar_todos(buf, linha, texto, CAIXA, "MdFluxoLinha", 210)

  local pos = 1
  while true do
    local _, f = texto:find("^%s+", pos)
    if not f then
      _, f = texto:find("^" .. CAIXA, pos)
    end
    if not f then
      break
    end
    pos = f + 1
  end
  while fim_util >= pos and texto:sub(fim_util, fim_util):match("%s") do
    fim_util = fim_util - 1
  end
  if pos > fim_util then
    return
  end

  if pos == 1 then
    marcar(buf, linha, 0, fim_util, "MdFluxoRaiz")
    return
  end

  for _, padrao in ipairs(SETAS) do
    pintar_todos(buf, linha, texto, padrao, "MdFluxoSeta", 210)
  end
  pintar_todos(buf, linha, texto, "'[^']*'", "MdCobolString", 210)

  local fim_acao, ini_texto = fim_util, nil
  local seta, fim_seta = primeira_seta(texto, pos, fim_util)
  if seta then
    fim_acao, ini_texto = seta - 1, fim_seta + 1
  else
    local a, b = texto:find("%s%s+", pos)
    if a and a < fim_util then
      fim_acao, ini_texto = a - 1, b + 1
    end
  end
  marcar(buf, linha, pos - 1, fim_acao, "MdFluxoAcao")
  if ini_texto and ini_texto <= fim_util then
    marcar(buf, linha, ini_texto - 1, fim_util, "MdFluxoTexto")
  end

  local corpo = texto:sub(pos, fim_util)
  for _, padrao in ipairs(TECLAS) do
    local _, f = corpo:find(padrao)
    if f then
      marcar(buf, linha, pos - 1, pos - 1 + f, "MdFluxoTecla", 205)
      break
    end
  end
end

-- Bloco tela: aba, frame, campos e botões com a cor declarada em @cor Nome, Nome.
local function pintar_tela(buf, linha, texto, botoes)
  local cor = texto:match("^%s*@(%a+)%s")
  if cor then
    marcar(buf, linha, 0, #texto, CORES_BOTAO[cor] or "MdFluxoRef")
    return
  end
  pintar_todos(buf, linha, texto, CAIXA, "MdFluxoLinha", 210)
  pintar_todos(buf, linha, texto, "%b()", "MdFluxoRef", 205)
  pintar_todos(buf, linha, texto, "%b{}", "MdTelaSoLeitura", 210)
  for rotulo, grupo in pairs({ aba = "MdTelaAba", frame = "MdTelaFrame" }) do
    local ini = texto:find(rotulo .. ":", 1, true)
    while ini do
      local fim = texto:find("%s%s", ini) or (#texto + 1)
      local caixa = texto:find(" " .. CAIXA, ini)
      if caixa and caixa < fim then
        fim = caixa
      end
      marcar(buf, linha, ini - 1, fim - 1, grupo, 210)
      ini = texto:find(rotulo .. ":", fim, true)
    end
  end
  local pos = 1
  while true do
    local ini, fim = texto:find("%b[]", pos)
    if not ini then
      return
    end
    local miolo = texto:sub(ini + 1, fim - 1)
    local nome = vim.trim((miolo:gsub(ICONE, "")))
    local grupo
    if botoes[nome] then
      grupo = botoes[nome]
    elseif nome == "" or nome == "x" then
      grupo = "MdTelaCheck"
    elseif miolo:find("_", 1, true) then
      grupo = "MdTelaCampo"
    else
      grupo = "MdBotaoCinza"
    end
    marcar(buf, linha, ini - 1, fim, grupo, 210)
    pos = fim + 1
  end
end

-- As palavras reservadas vêm da sintaxe de COBOL que acompanha o Neovim.
local function carregar_cobol()
  cobol_palavras, cobol_constantes = {}, {}
  for palavra in ("IF TO BY IN GO CALL END-CALL END-PERFORM GOBACK COPY INVOKE EXEC END-EXEC COMP COMP-3 LOCK"):gmatch("%S+") do
    cobol_palavras[palavra] = true
  end
  local sintaxe = vim.api.nvim_get_runtime_file("syntax/cobol.vim", false)[1]
  if not sintaxe then
    return
  end
  for _, texto in ipairs(vim.fn.readfile(sintaxe)) do
    local grupo, palavras = texto:match("^syn keyword cobol(%a+)%s+(.*)")
    if grupo then
      local destino = grupo == "Constant" and cobol_constantes or cobol_palavras
      for palavra in palavras:gmatch("%S+") do
        if palavra ~= "contained" then
          destino[palavra] = true
        end
      end
    end
  end
end

local function pintar_cobol(buf, linha, texto)
  if texto:match("^%s*%*") or texto:match("^%s*|%*") then
    marcar(buf, linha, 0, #texto, "MdCobolComentario")
    return
  end
  if not cobol_palavras then
    carregar_cobol()
  end
  local limpo = texto:gsub('"[^"]*"', function(s)
    return string.rep(" ", #s)
  end):gsub("'[^']*'", function(s)
    return string.rep(" ", #s)
  end)
  pintar_todos(buf, linha, texto, '"[^"]*"', "MdCobolString")
  pintar_todos(buf, linha, texto, "'[^']*'", "MdCobolString")

  local comentario = limpo:find("%*>") or limpo:find("|%*")
  if comentario then
    marcar(buf, linha, comentario - 1, #texto, "MdCobolComentario", 210)
    limpo = limpo:sub(1, comentario - 1)
  end

  local paragrafo = limpo:match("^%s*([%w%-]+)%.%s*$")
  local anterior
  for ini, palavra, fim in limpo:gmatch("()([%w_%-]+)()") do
    local maiuscula = palavra:upper()
    local grupo
    if cobol_palavras[maiuscula] then
      grupo = "MdCobolPalavra"
    elseif cobol_constantes[maiuscula] then
      grupo = "MdCobolConstante"
    elseif palavra:match("^%-?%d+$") then
      grupo = "MdCobolNumero"
    elseif palavra == paragrafo or anterior == "PERFORM" then
      grupo = "MdCobolParagrafo"
    elseif palavra:match("%a") then
      grupo = "MdCobolCampo"
    end
    if grupo then
      marcar(buf, linha, ini - 1, fim - 1, grupo)
    end
    anterior = maiuscula
  end
end

local function dividir_linha(texto)
  local celulas, atual, em_codigo = {}, {}, false
  local corpo = texto:gsub("^%s*|", ""):gsub("|%s*$", "")
  local i = 1
  while i <= #corpo do
    local c = corpo:sub(i, i)
    if c == "\\" and corpo:sub(i + 1, i + 1) == "|" then
      atual[#atual + 1] = "|"
      i = i + 1
    elseif c == "|" and not em_codigo then
      celulas[#celulas + 1] = vim.trim(table.concat(atual))
      atual = {}
    else
      if c == "`" then
        em_codigo = not em_codigo
      end
      atual[#atual + 1] = c
    end
    i = i + 1
  end
  celulas[#celulas + 1] = vim.trim(table.concat(atual))
  return celulas
end

-- Mostra a linha da tabela sob o cursor como um cartão.
function M.cartao()
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)[1]
  local function e_tabela(n)
    local texto = vim.api.nvim_buf_get_lines(buf, n - 1, n, false)[1]
    return texto and texto:match("^%s*|") ~= nil
  end
  if not e_tabela(cursor) then
    vim.notify("O cursor não está em uma tabela", vim.log.levels.WARN)
    return
  end
  local topo = cursor
  while topo > 1 and e_tabela(topo - 1) do
    topo = topo - 1
  end
  local lidas = vim.api.nvim_buf_get_lines(buf, topo - 1, topo + 1, false)
  local cabecalho = dividir_linha(lidas[1])
  local atual = vim.api.nvim_buf_get_lines(buf, cursor - 1, cursor, false)[1]
  local celulas = dividir_linha(atual)
  -- A primeira linha fica vazia porque o render-markdown mostra cru o texto sob o cursor.
  local linhas = { "" }
  for i, valor in ipairs(celulas) do
    linhas[#linhas + 1] = ("- **%s:** %s"):format(cabecalho[i] or ("Coluna " .. i), valor)
  end

  local largura = math.min(100, vim.o.columns - 6)
  local altura = 0
  for _, texto in ipairs(linhas) do
    altura = altura + math.ceil(math.max(1, vim.fn.strdisplaywidth(texto)) / largura)
  end
  local flutuante = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(flutuante, 0, -1, false, linhas)
  vim.bo[flutuante].filetype = "markdown"
  vim.bo[flutuante].modifiable = false
  local janela = vim.api.nvim_open_win(flutuante, true, {
    relative = "editor",
    width = largura,
    height = math.min(altura + 1, vim.o.lines - 6),
    row = math.floor((vim.o.lines - altura) / 2) - 1,
    col = math.floor((vim.o.columns - largura) / 2),
    style = "minimal",
    border = "rounded",
    title = " Linha da tabela  •  q fecha ",
    title_pos = "center",
  })
  vim.wo[janela].wrap = true
  vim.wo[janela].linebreak = true
  vim.wo[janela].conceallevel = 2
  for _, tecla in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", tecla, "<cmd>close<CR>", { buffer = flutuante, silent = true })
  end
end

-- Árvore dos títulos do arquivo, com o texto da seção na pré-visualização.
function M.estrutura()
  local buf = vim.api.nvim_get_current_buf()
  local nome = vim.api.nvim_buf_get_name(buf)
  local em_bloco = mapear(buf)
  local raiz = { text = "" }
  local itens, pilha, ultimo = {}, {}, {}
  local cursor = vim.api.nvim_win_get_cursor(0)[1]
  local atual = 1
  for i, texto in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local marcas, titulo = texto:match("^(#+)%s+(.+)$")
    if marcas and #marcas <= 6 and not em_bloco[i - 1] then
      local nivel = #marcas
      while #pilha > 0 and pilha[#pilha].nivel >= nivel do
        pilha[#pilha] = nil
      end
      local pai = pilha[#pilha] or raiz
      local item = {
        text = vim.trim(titulo:gsub("%*%*", ""):gsub("`", "")),
        nivel = nivel,
        parent = pai,
        buf = buf,
        file = nome,
        pos = { i, 0 },
      }
      ultimo[pai] = item
      itens[#itens + 1] = item
      pilha[#pilha + 1] = item
      if i <= cursor then
        atual = #itens
      end
    end
  end
  if #itens == 0 then
    vim.notify("Este arquivo não tem títulos", vim.log.levels.WARN)
    return
  end
  for _, item in pairs(ultimo) do
    item.last = true
  end

  Snacks.picker.pick({
    source = "estrutura_markdown",
    title = "Estrutura do arquivo",
    items = itens,
    tree = true,
    focus = "list", -- em modo inserção o render-markdown não desenha a pré-visualização
    matcher = { sort_empty = false },
    format = function(item, picker)
      local partes = Snacks.picker.format.tree(item, picker)
      partes[#partes + 1] = { item.text, "RenderMarkdownH" .. item.nivel }
      return partes
    end,
    preview = "file",
    jump = { reuse_win = false },
    win = {
      preview = {
        wo = { wrap = true, linebreak = true, breakindent = true, conceallevel = 2, signcolumn = "no" },
      },
    },
    on_show = function(picker)
      picker.list:view(atual)
      picker:show_preview()
    end,
  })
end

-- Largura como o texto aparece renderizado: sem **, crases e a parte escondida de links.
local function posicoes_ocultas(texto)
  local ocultas = {}
  local function ocultar(ini, fim)
    for i = ini, fim do
      ocultas[i] = true
    end
  end
  for ini in texto:gmatch("()%*%*") do
    ocultar(ini, ini + 1)
  end
  for ini in texto:gmatch("()`") do
    ocultas[ini] = true
  end
  for abre, meio, fim in texto:gmatch("()%[[^%]]*()%]%([^)]*%)()") do
    ocultas[abre] = true
    ocultar(meio, fim - 1)
  end
  local caixa = texto:match("^%s*%- ()%[.%] ")
  if caixa then
    ocultar(caixa, caixa + 2)
  end
  return ocultas
end

-- Onde quebrar: devolve { coluna em bytes, espaços até a borda da janela }.
-- O limite conta o que aparece; os espaços contam também o que está escondido,
-- porque o Neovim considera o texto oculto ao quebrar a linha.
local function quebras(texto, largura_janela)
  local ocultas = posicoes_ocultas(texto)
  local recuo = #texto:match("^%s*") + #(texto:match("^%s*([%-%*%+] )") or texto:match("^%s*(%d+%. )") or "")
  local resultado = {}
  local visivel, total, candidato = 0, 0, nil
  local i = 1
  while i <= #texto do
    local caractere = texto:match("^[%z\1-\127\194-\244][\128-\191]*", i) or texto:sub(i, i)
    local largura = vim.fn.strdisplaywidth(caractere)
    if not ocultas[i] and visivel + largura > limite.colunas and candidato then
      resultado[#resultado + 1] = { candidato.byte - 1, largura_janela - candidato.total }
      visivel = recuo + (visivel - candidato.visivel)
      total = recuo + (total - candidato.total)
      candidato = nil
    end
    total = total + largura
    if not ocultas[i] then
      visivel = visivel + largura
    end
    if caractere == " " and i < #texto then
      candidato = { byte = i + 1, visivel = visivel, total = total }
    end
    i = i + #caractere
  end
  return resultado
end

local function ns_limite(win)
  local ns = vim.api.nvim_create_namespace("lvimreact_limite_" .. win)
  vim.api.nvim__ns_set(ns, { wins = { win } })
  return ns
end

local function janela_de_texto(win)
  return vim.api.nvim_win_is_valid(win)
    and vim.api.nvim_win_get_config(win).relative == ""
    and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "markdown"
end

local function aplicar_limite(win, primeira, ultima)
  if not (limite.ligado and janela_de_texto(win)) then
    return
  end
  local buf = vim.api.nvim_win_get_buf(win)
  local largura = vim.api.nvim_win_get_width(win) - vim.fn.getwininfo(win)[1].textoff
  local ns = ns_limite(win)
  primeira = primeira or 0
  ultima = ultima or vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_buf_clear_namespace(buf, ns, primeira, ultima)
  if largura <= limite.colunas then
    return
  end
  local em_bloco = mapear(buf)
  for i, texto in ipairs(vim.api.nvim_buf_get_lines(buf, primeira, ultima, false)) do
    local linha = primeira + i - 1
    if not em_bloco[linha] and #texto > limite.colunas and not texto:match("^%s*|") and not texto:match("^#") then
      for _, quebra in ipairs(quebras(texto, largura)) do
        vim.api.nvim_buf_set_extmark(buf, ns, linha, quebra[1], {
          virt_text = { { string.rep(" ", quebra[2]) } },
          virt_text_pos = "inline",
          scoped = true,
        })
      end
    end
  end
end

local function limpar_limite()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ns = ns_limite(win)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    end
  end
end

-- Limita só o texto corrido; tabelas, fluxos, código e títulos usam a janela inteira.
function M.alternar_limite(colunas)
  if colunas then
    limite.colunas, limite.ligado = colunas, true
  else
    limite.ligado = not limite.ligado
  end
  limpar_limite()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    aplicar_limite(win)
  end
  vim.notify(limite.ligado and ("Texto limitado a " .. limite.colunas .. " colunas") or "Texto até o fim da janela")
end

-- Espaço extra acima dos títulos, para a seção se destacar do texto.
local function espacar_titulos(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "markdown" then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf, ns_titulos, 0, -1)
  local em_bloco = mapear(buf)
  for i, texto in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local marcas = texto:match("^(#+)%s")
    if marcas and i > 1 and not em_bloco[i - 1] then
      local vazias = {}
      for n = 1, #marcas <= 2 and 2 or 1 do
        vazias[n] = { { "", "" } }
      end
      vim.api.nvim_buf_set_extmark(buf, ns_titulos, i - 1, 0, { virt_lines = vazias, virt_lines_above = true })
    end
  end
end

local function preparar_buffer(buf)
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.opt_local.breakindent = true
  vim.opt_local.breakindentopt = "list:2"
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = "no"
  vim.opt_local.foldcolumn = "0"
  espacar_titulos(buf)
  vim.b[buf].snacks_indent = false
  local function tecla(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = buf, silent = true, desc = desc })
  end
  tecla("<leader>fi", M.estrutura, "Estrutura do arquivo")
  tecla("<leader>cc", function()
    M.alternar_limite()
  end, "Markdown: limitar o texto a 100 colunas")
  tecla("<leader>mt", M.cartao, "Markdown: linha da tabela como cartão")
  tecla("<leader>mr", "<cmd>NoNeckPain<CR>", "Markdown: modo leitura")
  tecla("<leader>mm", "<cmd>RenderMarkdown buf_toggle<CR>", "Markdown: renderizado ou cru")
end

function M.setup()
  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, _, buf)
      return vim.bo[buf].filetype == "markdown"
    end,
    on_line = function(_, _, buf, linha)
      local texto = vim.api.nvim_buf_get_lines(buf, linha, linha + 1, false)[1]
      if not texto or texto == "" then
        return
      end
      local linhas, botoes = mapear(buf)
      local tipo = linhas[linha]
      if not tipo then
        pintar_texto(buf, linha, texto)
      elseif tipo == "fluxo" then
        pintar_fluxo(buf, linha, texto)
      elseif tipo == "cobol" then
        pintar_cobol(buf, linha, texto)
      elseif tipo == "tela" then
        pintar_tela(buf, linha, texto, botoes)
      end
    end,
  })

  local grupo = vim.api.nvim_create_augroup("lvimreact_markdown", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = grupo,
    pattern = "markdown",
    callback = function(ev)
      preparar_buffer(ev.buf)
    end,
  })
  vim.api.nvim_create_autocmd("BufDelete", {
    group = grupo,
    callback = function(ev)
      blocos[ev.buf] = nil
    end,
  })
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].filetype == "markdown" and buf == vim.api.nvim_get_current_buf() then
      preparar_buffer(buf)
    end
  end

  vim.api.nvim_create_autocmd({ "BufWinEnter", "TextChanged", "InsertLeave" }, {
    group = grupo,
    pattern = "*.md",
    callback = function(ev)
      espacar_titulos(ev.buf)
      aplicar_limite(vim.api.nvim_get_current_win())
    end,
  })
  vim.api.nvim_create_autocmd("TextChangedI", {
    group = grupo,
    pattern = "*.md",
    callback = function()
      local linha = vim.api.nvim_win_get_cursor(0)[1]
      aplicar_limite(vim.api.nvim_get_current_win(), linha - 1, linha)
    end,
  })
  vim.api.nvim_create_autocmd("VimResized", {
    group = grupo,
    callback = function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        aplicar_limite(win)
      end
    end,
  })
  vim.api.nvim_create_autocmd("WinResized", {
    group = grupo,
    callback = function()
      for _, win in ipairs(vim.v.event.windows or {}) do
        aplicar_limite(win)
      end
    end,
  })
  vim.api.nvim_create_user_command("LimiteTexto", function(opts)
    M.alternar_limite(tonumber(opts.args))
  end, { nargs = "?", desc = "Liga ou desliga o limite do texto; aceita o número de colunas" })

  -- Desligado por padrão; quando ligado, confere inglês e português.
  vim.api.nvim_create_user_command("Corretor", function()
    if #vim.api.nvim_get_runtime_file("spell/pt.utf-8.spl", false) == 0 then
      vim.notify("Falta o dicionário: spell/pt.utf-8.spl em " .. vim.fn.stdpath("data") .. "/site", vim.log.levels.ERROR)
      return
    end
    vim.wo.spell = not vim.wo.spell
    vim.notify("Corretor " .. (vim.wo.spell and "ligado (en + pt_br)" or "desligado"))
  end, { desc = "Liga ou desliga o corretor (en + pt_br)" })
end

return M
