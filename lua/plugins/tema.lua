-- Tema One Dark Pro com fundo em camadas, entre o One Dark Night do IntelliJ e o onedark_dark.
--   editor #1e2127 · barra de status #181a1f · terminal #14161a · explorador/pickers #23262d
local C = {
  editor = "#1e2127",
  lateral = "#181a1f", -- explorador / barra de status
  terminal = "#14161a",
  flutuante = "#23262d", -- pickers, hover, completion
  linha = "#272b33", -- linha do cursor
  borda = "#2c313a",
  selecao = "#323844",
}

-- terminal ganha fundo próprio (o explorador usa o mesmo cinza dos pickers)
local function camadas()
  local g = vim.api.nvim_create_augroup("tema_camadas", { clear = true })
  vim.api.nvim_create_autocmd("TermOpen", {
    group = g,
    callback = function()
      vim.wo.winhighlight = "Normal:TemaTerminal,NormalNC:TemaTerminal,SignColumn:TemaTerminal"
    end,
  })
end

return {
  {
    "olimorris/onedarkpro.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      colors = {
        onedark = {
          bg = C.editor,
          cursorline = C.linha,
          color_column = C.linha,
          selection = C.selecao,
          float_bg = C.flutuante,
        },
      },
      highlights = {
        TemaLateral = { bg = C.lateral },
        TemaTerminal = { bg = C.terminal },
        NormalFloat = { bg = C.flutuante },
        FloatBorder = { fg = C.borda, bg = C.flutuante },
        FloatTitle = { bg = C.flutuante },
        SnacksPickerBox = { bg = C.flutuante },
        SnacksPickerList = { bg = C.flutuante },
        SnacksPickerInput = { bg = C.flutuante },
        SnacksPickerPreview = { bg = C.editor },
        SnacksPickerBorder = { fg = C.borda, bg = C.flutuante },
        Pmenu = { bg = C.flutuante },
        BlinkCmpMenu = { bg = C.flutuante },
        BlinkCmpMenuBorder = { fg = C.borda, bg = C.flutuante },
        BlinkCmpDoc = { bg = C.flutuante },
        BlinkCmpDocBorder = { fg = C.borda, bg = C.flutuante },
        StatusLine = { bg = C.lateral },
        StatusLineNC = { bg = C.lateral },
        WinSeparator = { fg = C.borda, bg = "NONE" },
        CursorLine = { bg = C.linha },
        CursorLineNr = { fg = "${yellow}", bg = C.linha },
        TabLineFill = { bg = C.lateral },
        BufferLineFill = { bg = C.lateral },
      },
      options = { cursorline = true },
    },
    config = function(_, opts)
      require("onedarkpro").setup(opts)
      camadas()
    end,
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "onedark" } },
}
