-- Barra de rolagem na lateral direita (marca cursor, busca, diagnósticos, git e marks)
return {
  "lewis6991/satellite.nvim",
  event = "VeryLazy",
  opts = {
    current_only = false,
    winblend = 50,
    excluded_filetypes = {
      "snacks_picker_list",
      "snacks_picker_input",
      "snacks_dashboard",
      "neo-tree",
      "lazy",
      "mason",
    },
  },
}
