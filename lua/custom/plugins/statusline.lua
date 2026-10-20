-- Statusline with powerline-style pointed edges (needs a Nerd Font)
-- Replaces kickstart's mini.statusline. See `:help lualine.txt`
vim.pack.add { 'https://github.com/nvim-lualine/lualine.nvim' }

require('lualine').setup {
  options = {
    theme = 'auto', -- picks up the colorscheme's lualine theme when it has one
    section_separators = { left = '\u{e0b0}', right = '\u{e0b2}' }, -- solid arrows
    component_separators = { left = '\u{e0b1}', right = '\u{e0b3}' }, -- thin arrows
  },
}
