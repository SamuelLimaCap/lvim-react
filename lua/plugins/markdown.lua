return {
  {
    "epwalsh/obsidian.nvim",
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
    opts = {},
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
