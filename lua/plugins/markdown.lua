return {
  {
    "epwalsh/obsidian.nvim",
    enabled = false,
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    otps = {
      workspaces = {
        {
          name = "work",
          path = "~/Documents/obsidian/Geral",
        },
      },
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = true,
    opts = {
      heading = {
        sign = false,
        icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
      },
      code = {
        sign = false,
        width = "block",
        min_width = 90,
        left_pad = 2,
        right_pad = 2,
        border = "thin",
      },
      bullet = {
        icons = { "•", "◦", "•", "◦" },
      },
      checkbox = {
        unchecked = { icon = "󰄱 ", highlight = "MdCaixaVazia" },
        checked = { icon = "󰄲 ", highlight = "MdCaixaFeita", scope_highlight = "MdTextoFeito" },
        custom = {
          fazendo = { raw = "[/]", rendered = "󰑮 ", highlight = "MdFazendo" },
          urgente = { raw = "[!]", rendered = "󰀦 ", highlight = "MdUrgente" },
          descartado = { raw = "[~]", rendered = "󰜺 ", highlight = "MdDescartado", scope_highlight = "MdTextoDescartado" },
          duvida = { raw = "[?]", rendered = "󰘥 ", highlight = "MdDuvida" },
          info = { raw = "[i]", rendered = "󰋽 ", highlight = "MdInfo" },
          bloqueado = { raw = "[b]", rendered = "󰒃 ", highlight = "MdBloqueado" },
          nota = { raw = "[n]", rendered = "󰎞 ", highlight = "MdNota" },
        },
      },
      pipe_table = {
        preset = "round",
        border_virtual = true,
      },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.nvim",
    },
  },

  -- {
  --   "iamcco/markdown-preview.nvim",
  --   cmd = {
  --     "MarkdownPreviewToggle",
  --     "MarkdownPreview",
  --     "MarkdwonPreviewStop",
  --   },
  --   build = "cd app && npm isntall",
  --   init = function()
  --     vim.g.mkdp_filetypes = { "markdown" }
  --   end,
  --   ft = { "markdown" },
  -- },
}
