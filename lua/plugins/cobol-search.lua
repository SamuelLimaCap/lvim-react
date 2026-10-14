-- Busca somente fontes COBOL (.CBL / .CPY) a partir de uma pasta escolhida.
-- hidden/ignored = true porque o .gitignore de ~/projetos ignora cobol/desk e *.CBL.
local fontesbd = vim.fn.expand("~/projetos/cobol/desk/FONTESBD")

local function pasta_padrao()
  if vim.fn.isdirectory(fontesbd) == 1 then
    return fontesbd .. "/"
  end
  return vim.fn.getcwd() .. "/"
end

local function buscar_cobol(opts)
  opts = opts or {}
  local function abrir(dir)
    if not dir or dir == "" then
      return
    end
    dir = vim.fn.fnamemodify(vim.fn.expand(dir), ":p")
    if vim.fn.isdirectory(dir) == 0 then
      vim.notify("Pasta não encontrada: " .. dir, vim.log.levels.WARN)
      return
    end
    local picker = opts.grep and Snacks.picker.grep or Snacks.picker.files
    picker({
      title = (opts.grep and "Grep COBOL " or "COBOL ") .. vim.fn.fnamemodify(dir, ":~"),
      cwd = dir,
      ft = not opts.grep and { "CBL", "CPY" } or nil, -- fd -e não diferencia maiúsc./minúsc.
      glob = opts.grep and { "*.CBL", "*.CPY", "*.cbl", "*.cpy" } or nil,
      hidden = true,
      ignored = true,
    })
  end

  vim.ui.input({ prompt = "Pasta COBOL: ", default = pasta_padrao(), completion = "dir" }, abrir)
end

return {
  "snacks.nvim",
  keys = {
    { "<leader>fo", function() buscar_cobol() end, desc = "Find COBOL (.CBL/.CPY)" },
    { "<leader>so", function() buscar_cobol({ grep = true }) end, desc = "Grep COBOL (.CBL/.CPY)" },
  },
}
