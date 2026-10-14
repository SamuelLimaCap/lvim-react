vim.g.mapleader = " "
-- vim.g.treesitter_compiler = { "gcc" }

vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.title = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cinwords = "<"
vim.opt.indentexpr = ""

vim.opt.hlsearch = true
vim.opt.backup = false
vim.opt.showcmd = true
-- vim.opt.cmdheight = true
vim.opt.laststatus = 0
vim.opt.expandtab = true
vim.opt.scrolloff = 10
vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.smarttab = false
-- vim.opt.breakintent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.wrap = false
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.path:append({ "**" })
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "cursor"

vim.opt.formatoptions:append({ "r" })

-- COBOL: o runtime só registra extensões minúsculas (cbl/cob)
vim.filetype.add({
  extension = {
    CBL = "cobol",
    COB = "cobol",
    CPY = "cobol",
  },
})

--undercurl in wezterm terminal

vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

--   { name = "dev", url = "postgres://support_treinamento:support@localhost:5432/vendas" },
--   { name = "staging", url = "Replace with your database connection URL." },
-- }
--
--
vim.api.nvim_create_user_command("DBTriggers", function()
  local sql = [[
SELECT
    event_object_schema AS schema,
    event_object_table  AS tabela,
    trigger_name        AS trigger,
    string_agg(event_manipulation, ', ' ORDER BY event_manipulation) AS eventos,
    action_timing       AS timing
FROM information_schema.triggers
GROUP BY
    event_object_schema,
    event_object_table,
    trigger_name,
    action_timing
ORDER BY
    event_object_schema,
    event_object_table,
    trigger_name;
  ]]

  vim.cmd("DB " .. sql)
end, {})
