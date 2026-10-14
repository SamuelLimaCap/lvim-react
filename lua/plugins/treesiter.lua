return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- tag = "v0.9.1",
    opts = {
      ensure_installed = {
        -- "javascriptreact",
        "javascript",
        "typescript",
        -- "css",
        "gitignore",
        "graphql",
        "http",
        "json",
        -- "scss",
        "sql",
        "vim",
        "lua",
        "sql",
        "sqlfluff",
      },
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },
      indent = {
        enable = false,
      },
      highlight = {
        enable = true,
        disable = { "css" },
      },
    },
  },
}
