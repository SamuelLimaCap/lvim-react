# lvim-react

Neovim (LazyVim) para React e para **ler/escrever Markdown**. Abre com `lvim-react`
(`NVIM_APPNAME=lvim-react nvim`).

É também o editor que o [yazi](https://github.com/SamuelLimaCap/yazi) usa para abrir `.md`/`.xml`, e onde
o [lvim-dbupdater](https://github.com/SamuelLimaCap/lvim-dbupdater) abre o guia (`<leader>uH`).

## Instalação

```bash
git clone git@github.com:SamuelLimaCap/lvim-react.git ~/nvim-configs/lvim-react
ln -s ~/nvim-configs/lvim-react ~/.config/lvim-react
echo "alias lvim-react='NVIM_APPNAME=lvim-react nvim'" >> ~/.bashrc && source ~/.bashrc
lvim-react   # 1ª abertura: baixa os plugins
```

Precisa de: Neovim 0.10 ou mais novo, git, Node (LSPs de JS/TS e CSS pelo Mason), ripgrep e fd.

## Arquivos fora do repositório

`<leader>fx` (ou `:Externos`) lista todos e mostra quais existem na máquina.

| Caminho | Para quê | Como obter |
|---|---|---|
| `~/.local/share/lvim-react/site/spell/pt.utf-8.spl` | dicionário português do corretor | ver abaixo |
| `~/Documents/obsidian/Geral` | cofre do Obsidian (obsidian.nvim) | opcional; outro caminho: `lua/plugins/markdown.lua` |
| `~/projetos/cobol/desk/FONTESBD` | busca nos fontes COBOL | opcional |

### Dicionário português

O corretor começa desligado e liga/desliga com `:Corretor` (confere inglês e português).
Ele só liga se achar o dicionário, que não vem no repositório:

```bash
mkdir -p ~/.local/share/lvim-react/site/spell
cd ~/.local/share/lvim-react/site/spell
curl -fLO https://ftp.nluug.nl/pub/vim/runtime/spell/pt.utf-8.spl
curl -fLO https://ftp.nluug.nl/pub/vim/runtime/spell/pt.utf-8.sug   # sugestões (opcional)
```

### Cofre do Obsidian

```lua
-- lua/plugins/markdown.lua
workspaces = {
  { name = "Geral", path = "~/Documents/obsidian/Geral" },
},
```

Sem a pasta, o obsidian.nvim só avisa; o resto funciona.

## Markdown

As cores e as teclas de Markdown ficam em `lua/lvimreact/markdown.lua`. A decoração é feita só nas
linhas visíveis, para a digitação não ficar lenta em arquivos grandes.
