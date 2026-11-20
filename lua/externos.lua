-- Arquivos e pastas FORA de ~/.config/<config> que esta config lê ou grava.
-- Atalho padrão em todas as configs: <leader>fx (também :Externos).
-- Este arquivo é IGUAL nas 5 configs (lvim-java, lvim-vue, lbd, lvim-dbupdater, lvim-react):
-- ao mudar, copie para as outras (scripts/sincronizar-externos).
-- Na janela: <CR> abre o arquivo/pasta da linha, q/<Esc> fecha.
local M = {}

local D = vim.fn.stdpath("data")
local C = vim.fn.stdpath("cache")
local S = vim.fn.stdpath("state")
local H = vim.env.HOME

-- { caminho, para quê, segredo? }
local LISTAS = {
  ["lvim-java"] = {
    { H .. "/projetos/java-sinc", "projeto Java (módulos em lvimjava/modulos.lua)" },
    { H .. "/projetos", "raiz dos projetos (buscas)" },
    { H .. "/projetos/cobol/desk/FONTESBD", "busca nos fontes COBOL" },
    { H .. "/.m2/repository", "jars e -sources.jar (fontes de bibliotecas)" },
    { D .. "/jls", "JLS instalado (servidor de linguagem)" },
    { H .. "/jls", "código do JLS local (gera o jar de dist/)" },
    { D .. "/google-java-format/google-java-format.jar", "formatador (<leader>cf)" },
    { D .. "/arquivos-fixados.json", "arquivos fixados" },
    { C .. "/lvimjava-indice-fontes.json", "índice classe -> -sources.jar" },
    { C .. "/jls-jar-sources-lvim", "fontes extraídos dos jars" },
    { S .. "/lsp.log", "log do LSP (crashes do JLS: 'SEVERE Main main')" },
    { H .. "/.ideavimrc", "origem dos atalhos portados do IntelliJ (só referência)" },
  },
  ["lvim-vue"] = {
    { H .. "/projetos/sinc-vue", "projeto Vue 2" },
    { H .. "/volar-ts/node_modules/typescript/lib", "TypeScript usado pelo Volar" },
    { vim.fn.exepath("vue-language-server"), "Volar 1.8.27 (npm global)" },
    { D .. "/arquivos-fixados.json", "arquivos fixados" },
    { C .. "/lvim-vue-info", "cache do lvim-vue" },
  },
  ["lbd"] = {
    { D .. "/conexoes.json", "conexões do dbee (usuário/senha)", true },
    { D .. "/dbee", "binário e estado do dbee (notas, histórico)" },
    { H .. "/projetos", "raiz dos projetos (buscas)" },
    { H .. "/projetos/cobol/desk/FONTESBD", "busca nos fontes COBOL" },
    { H .. "/Documents/obsidian/Geral", "cofre do Obsidian" },
  },
  ["lvim-dbupdater"] = {
    { H .. "/projetos/sinc-dbupdater", "projeto (Liquibase)" },
    { D .. "/bases.json", "bases para aplicar (IP/usuário/senha)", true },
    { H .. "/.local/share/lbd/conexoes.json", "conexões do lbd (status/banco)", true },
    { H .. "/nvim-configs/lbd/lua", "módulo lbd.sql reaproveitado" },
    { C .. "/indice.json", "índice de tabelas/colunas (autocomplete)" },
    { H .. "/.lemminx", "cache de XSDs do lemminx (pom.xml)" },
    { H .. "/.config/lvim-react", "abre o guia no lvim-react (<leader>uH)" },
  },
  ["lvim-react"] = {
    { D .. "/site/spell/pt.utf-8.spl", "dicionário pt (fora do git)" },
    { H .. "/projetos", "raiz dos projetos (buscas)" },
    { H .. "/projetos/cobol/desk/FONTESBD", "busca nos fontes COBOL" },
    { H .. "/Documents/obsidian/Geral", "cofre do Obsidian" },
  },
}

local function curto(p)
  return (p:gsub("^" .. vim.pesc(H), "~"))
end

function M.abrir()
  local nome = vim.env.NVIM_APPNAME or "nvim"
  local lista = LISTAS[nome] or {}
  local linhas = { " Fora de ~/.config/" .. nome .. "   (<CR> abre, q fecha)", "" }
  local caminhos = {}
  local largura = 0
  for _, e in ipairs(lista) do
    largura = math.max(largura, #curto(e[1]))
  end
  for _, e in ipairs(lista) do
    local p = e[1]
    local ok = p ~= "" and vim.uv.fs_stat(p) ~= nil
    local marca = ok and "✓" or "✗"
    local extra = e[3] and "  [SENHAS]" or ""
    linhas[#linhas + 1] = string.format(" %s %-" .. largura .. "s  %s%s", marca, curto(p), e[2], extra)
    caminhos[#linhas] = p
  end
  linhas[#linhas + 1] = ""
  linhas[#linhas + 1] = " ✓ existe   ✗ não existe nesta máquina"

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, linhas)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  local w = 0
  for _, l in ipairs(linhas) do
    w = math.max(w, vim.fn.strdisplaywidth(l))
  end
  w = math.min(w + 2, vim.o.columns - 4)
  local h = math.min(#linhas, vim.o.lines - 4)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = w,
    height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = "minimal",
    border = "rounded",
    title = " Arquivos externos ",
    title_pos = "center",
  })
  local function fechar()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end
  local o = { buffer = buf, nowait = true }
  vim.keymap.set("n", "q", fechar, o)
  vim.keymap.set("n", "<Esc>", fechar, o)
  vim.keymap.set("n", "<CR>", function()
    local p = caminhos[vim.api.nvim_win_get_cursor(win)[1]]
    if not p or p == "" or not vim.uv.fs_stat(p) then return end
    fechar()
    vim.cmd.edit(vim.fn.fnameescape(p))
  end, o)
  vim.api.nvim_win_set_cursor(win, { math.min(3, #linhas), 0 })
end

function M.setup()
  vim.keymap.set("n", "<leader>fx", M.abrir, { desc = "Arquivos externos (fora do ~/.config)" })
  vim.api.nvim_create_user_command("Externos", M.abrir, { desc = "Arquivos externos (fora do ~/.config)" })
end

return M
