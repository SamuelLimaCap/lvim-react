-- TODO em laranja (cor própria, não a amarela padrão)
return {
  "folke/todo-comments.nvim",
  opts = {
    colors = { warning = { "#e0af68", "DiagnosticWarn" } }, -- mantém default p/ WARN/HACK
    keywords = {
      TODO = { icon = " ", color = "#ff8800" },
    },
  },
  config = function(_, opts)
    require("todo-comments").setup(opts)
    vim.api.nvim_set_hl(0, "TodoFgTODO", { fg = "#ff8800", bold = true })
    vim.api.nvim_set_hl(0, "TodoSignTODO", { fg = "#ff8800" })
  end,
}
