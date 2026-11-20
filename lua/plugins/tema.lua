-- Tema One Dark Pro com fundo em camadas, entre o One Dark Night do IntelliJ e o onedark_dark.
--   editor #191b20 · números #1e2127 · barra de status #181a1f · terminal #14161a · explorador/pickers #23262d
local C = {
  editor = "#191b20",
  numeros = "#1e2127", -- coluna de números, um pouco mais clara que o arquivo
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
        LineNr = { bg = C.numeros },
        LineNrAbove = { bg = C.numeros },
        LineNrBelow = { bg = C.numeros },
        SignColumn = { bg = C.numeros },
        FoldColumn = { bg = C.numeros },
        CursorLine = { bg = C.linha },
        CursorLineNr = { fg = "${yellow}", bg = C.linha },
        SpellBad = { sp = "${gray}", undercurl = true },
        SpellCap = {},
        SpellLocal = {},
        SpellRare = {},

        -- Markdown
        ["@markup.raw.block"] = { fg = "${fg}" },
        ["@markup.raw.block.markdown"] = { fg = "${fg}" },
        ["@markup.heading"] = { fg = "${blue}", bold = true },
        ["@markup.heading.markdown"] = { fg = "${blue}", bold = true },
        RenderMarkdownH1 = { fg = "${blue}", bold = true },
        RenderMarkdownH1Bg = { bg = "#25313f" },
        ["@markup.heading.1.markdown"] = { fg = "${blue}", bold = true },
        RenderMarkdownH2 = { fg = "${green}", bold = true },
        RenderMarkdownH2Bg = { bg = "#2a3329" },
        ["@markup.heading.2.markdown"] = { fg = "${green}", bold = true },
        RenderMarkdownH3 = { fg = "${yellow}", bold = true },
        ["@markup.heading.3.markdown"] = { fg = "${yellow}", bold = true },
        RenderMarkdownH4 = { fg = "${purple}", bold = true },
        ["@markup.heading.4.markdown"] = { fg = "${purple}", bold = true },
        RenderMarkdownH3Bg = { bg = C.editor },
        RenderMarkdownH4Bg = { bg = C.editor },
        RenderMarkdownH5Bg = { bg = C.editor },
        RenderMarkdownH6Bg = { bg = C.editor },
        RenderMarkdownBullet = { fg = "#6b7280" },
        RenderMarkdownDash = { fg = "#4b5263" },
        RenderMarkdownTableHead = { fg = "${blue}", bold = true },
        RenderMarkdownTableRow = { fg = "#4b5263" },
        MdCaixaVazia = { fg = "${gray}" },
        MdCaixaFeita = { fg = "${green}" },
        MdTextoFeito = { fg = "${gray}" },
        MdFazendo = { fg = "${yellow}" },
        MdUrgente = { fg = "${red}", bold = true },
        MdDescartado = { fg = "${gray}" },
        MdTextoDescartado = { fg = "${gray}", strikethrough = true },
        MdDuvida = { fg = "${purple}" },
        MdInfo = { fg = "${blue}" },
        MdBloqueado = { fg = "${orange}" },
        MdNota = { fg = "${cyan}" },
        MdTag = { fg = "${cyan}", bg = "#253238" },
        MdTagFront = { fg = "${blue}", bg = "#25313f" },
        MdTagBack = { fg = "${green}", bg = "#2a3329" },
        MdTagReport = { fg = "${purple}", bg = "#322a38" },
        MdNumero = { fg = "#7a7a7a" },
        MdTempo = { fg = "${gray}", italic = true },
        MdAlerta = { fg = "${orange}", bold = true },
        MdOk = { fg = "${green}", bold = true },
        MdMuda = { fg = "${blue}", bold = true },
        MdFora = { fg = "${purple}", bold = true },
        MdCalcular = { fg = "${yellow}" },
        MdDado = { fg = "${blue}", bold = true },
        MdQuando = { fg = "${yellow}", bold = true },
        MdEntao = { fg = "${green}", bold = true },
        MdFluxoLinha = { fg = "#4b5263" },
        MdFluxoSeta = { fg = "${cyan}", bold = true },
        MdFluxoRaiz = { fg = "${yellow}", bold = true },
        MdFluxoAcao = { fg = "${blue}" },
        MdFluxoTecla = { fg = "${orange}", bold = true },
        MdFluxoTexto = { fg = "${fg}" },
        MdFluxoRef = { fg = "${gray}" },
        MdTelaAba = { fg = "${purple}", bold = true },
        MdTelaFrame = { fg = "${cyan}", bold = true },
        MdTelaCampo = { fg = "${blue}" },
        MdTelaSoLeitura = { fg = "${gray}" },
        MdTelaCheck = { fg = "${yellow}" },
        MdBotaoVerde = { fg = "${green}", bg = "#2a3329", bold = true },
        MdBotaoVermelho = { fg = "${red}", bg = "#3a2a2d", bold = true },
        MdBotaoAzul = { fg = "${blue}", bg = "#25313f", bold = true },
        MdBotaoLaranja = { fg = "${orange}", bg = "#3a3027", bold = true },
        MdBotaoCinza = { fg = "${fg}", bg = "#2c313a" },
        MdCobolPalavra = { fg = "${purple}" },
        MdCobolConstante = { fg = "${orange}" },
        MdCobolNumero = { fg = "${orange}" },
        MdCobolString = { fg = "${green}" },
        MdCobolParagrafo = { fg = "${blue}", bold = true },
        MdCobolCampo = { fg = "${cyan}" },
        MdCobolComentario = { fg = "${gray}", italic = true },

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
